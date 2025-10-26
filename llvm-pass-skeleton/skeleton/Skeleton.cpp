#include <llvm/Analysis/AliasAnalysis.h>
#include <llvm/CodeGen/CalcSpillWeights.h>
#include <llvm/CodeGen/LiveIntervals.h>
#include <llvm/CodeGen/LiveRangeEdit.h>
#include <llvm/CodeGen/LiveRegMatrix.h>
#include <llvm/CodeGen/LiveStacks.h>
#include <llvm/CodeGen/MachineBlockFrequencyInfo.h>
#include <llvm/CodeGen/MachineDominators.h>
#include <llvm/CodeGen/MachineFunctionPass.h>
#include <llvm/CodeGen/MachineLoopInfo.h>
#include <llvm/CodeGen/RegAllocRegistry.h>
#include <llvm/CodeGen/RegisterClassInfo.h>
#include <llvm/CodeGen/Spiller.h>
#include <llvm/CodeGen/VirtRegMap.h>
#include <llvm/InitializePasses.h>
#include <llvm/Support/raw_ostream.h>

#include <queue>

#include "Logging.h"

using namespace llvm;

namespace llvm
{

void initializeRAMinimalPass (PassRegistry &Registry);

} // namespace llvm

/// A minimal register allocator that goes through the list of live intervals
/// and materialize them whenever there are physical registers available. If
/// none is available then the interval is spilled.
class RAMinimal final : public MachineFunctionPass, private LiveRangeEdit::Delegate {
    private:
        MachineFunction *MF;

        // Slot Indices: assigns a unique id to each machine instruction
        const SlotIndexes *SI;
        
        // Virtual Register Mapping: 
        VirtRegMap *VRM;

        // Stores the allocated physical and virtual registers
        // materialize the virtual regs to physical regs.
        MachineRegisterInfo *MRI;

        // Describe the target machine, immutable object
        const TargetRegisterInfo *TRI;
        
        
        // Live Intervals
        // Live range of each Virtual register, has a weight initialized to 0
        LiveIntervals *LIS;


        std::queue<LiveInterval *> LIQ; // FIFO Queue
        void enqueue (LiveInterval *const LI)
        {
                LOG_INFO << "Pushing {Reg=" << BOLD (*LI) << "}";
                LIQ.push (LI);
        }
        LiveInterval *dequeue ()
        {
                if (LIQ.empty ()) {
                        return nullptr;
                }
                LiveInterval *LI = LIQ.front ();
                LOG_INFO << "Popping {Reg=" << BOLD (*LI) << "}";
                LIQ.pop ();
                return LI;
        }
        
        // Live Register Matrix
        // 2D array: SlotIndicies x Reg Units
        LiveRegMatrix *LRM;


        // Register Class Information
        // tells you what type of register you will need (32 bit, 64 bit etc.)
        RegisterClassInfo RCI;

        // Spiller
        std::unique_ptr<Spiller> SpillerInstance;
        SmallPtrSet<MachineInstr *, 32> DeadRemats;

        /// @brief Attempt to spill all live intervals that interfere with @c LI but
        /// have less spill weights.
        /// @return True if successful, false otherwise
        /// @sa selectOrSplit 3.3.
        bool
        spillInterferences (LiveInterval *const LI, MCRegister PhysReg, SmallVectorImpl<Register> *const SplitVirtRegs)
        {
                SmallVector<const LiveInterval *, 8> IntfLIs;

                for (MCRegUnitIterator Units (PhysReg, TRI); Units.isValid (); ++Units) {
                        LiveIntervalUnion::Query &Q = LRM->query (*LI, *Units);
                        
                        for (const LiveInterval *const IntfLI : reverse (Q.interferingVRegs ())) {
                                if (!IntfLI->isSpillable () || IntfLI->weight () > LI->weight ()) {
                                        return false;
                                }
                                IntfLIs.push_back (IntfLI);
                        }
                }
                // Spill each interfering vreg allocated to PhysRegs.
                for (unsigned IntfIdx = 0; IntfIdx < IntfLIs.size (); ++IntfIdx) {
                        const LiveInterval *const LIToSpill = IntfLIs[IntfIdx];
                        // avoid duplicates
                        if (!VRM->hasPhys (LIToSpill->reg ())) {
                                continue;
                        }
                        // Deallocate the interfering virtual registers.
                        LRM->unassign (*LIToSpill);
                        LiveRangeEdit LRE (LIToSpill, *SplitVirtRegs, *MF, *LIS, VRM, this, &DeadRemats);
                        SpillerInstance->spill (LRE);
                }
                return true;
        }

        /// Allocate a physical register for @c LI , or have the spiller splits it
        /// into a list of virtual registers.
        MCRegister selectOrSplit (LiveInterval *const LI, SmallVectorImpl<Register> *const SplitVirtRegs)
        {
                /// 3.1. Obtain a plausible allocation order.
                ArrayRef<MCPhysReg> Order = RCI.getOrder (MF->getRegInfo ().getRegClass (LI->reg ()));

                SmallVector<MCPhysReg, 16> Hints;

                bool IsHardHint = TRI->getRegAllocationHints (LI->reg (), Order, Hints, *MF, VRM, LRM);

                if (!IsHardHint) {
                        for (const MCPhysReg &PhysReg : Order) {
                                Hints.push_back (PhysReg);
                        }
                }

                // Debug: show all available registers before filtering
                outs() << "Available registers before filtering: [";
                for (const MCPhysReg &PhysReg : Hints) {
                        outs() << TRI->getRegAsmName(PhysReg) << " ";
                }
                outs() << "]\n";

                // For functions with "discard" attribute, only use R10-R13
                // For functions without "discard" attribute, use all registers EXCEPT R10-R13
                if (MF->getFunction().hasFnAttribute("discard")) {
                        SmallVector<MCPhysReg, 16> FilteredRegs;
                        for (const MCPhysReg &PhysReg : Hints) {
                                StringRef RegName = TRI->getRegAsmName(PhysReg);
                                if (RegName == "R10" || RegName == "R11" || RegName == "R12" || RegName == "R13") {
                                        FilteredRegs.push_back(PhysReg);
                                }
                        }
                        Hints.clear();
                        Hints.append(FilteredRegs.begin(), FilteredRegs.end());
                        outs() << "*** DISCARD MODE: Limited to R10-R13 ***\n";
                } else {
                        SmallVector<MCPhysReg, 16> FilteredRegs;
                        for (const MCPhysReg &PhysReg : Hints) {
                                StringRef RegName = TRI->getRegAsmName(PhysReg);
                                if (RegName != "R10" && RegName != "R11" && RegName != "R12" && RegName != "R13") {
                                        FilteredRegs.push_back(PhysReg);
                                }
                        }
                        Hints.clear();
                        Hints.append(FilteredRegs.begin(), FilteredRegs.end());
                        outs() << "*** NORMAL MODE: Using all registers except R10-R13 ***\n";
                }

                outs () << "Hint Registers: [";

                for (const MCPhysReg &PhysReg : Hints) {
                        outs () << TRI->getRegAsmName (PhysReg) << ", ";
                }
                outs () << "]\n";

                SmallVector<MCRegister, 8> PhysRegSpillCandidates;

                // traverse through preferred allocation, and check if we can use this register for the live interval.
                for (MCRegister PhysReg : Hints) {
                        /// 3.2. Check for interference on physical registers.
                        switch (LRM->checkInterference (*LI, PhysReg)) {
                        case LiveRegMatrix::IK_Free:
                                // Here we directly (and naively) return the first physical register
                                // that is available.
                                outs () << "Allocating physical register " << BOLD (TRI->getRegAsmName (PhysReg))
                                        << "\n";
                                return PhysReg;

                        // The PhysReg has already been allocated to another virtual reg.
                        // Interference can be resolved by removing interfering register.
                        case LiveRegMatrix::IK_VirtReg: PhysRegSpillCandidates.push_back (PhysReg); continue;
                        default: continue;
                        }
                }


                // All registers are taken, must determine which register to spill
                /// 3.3. Attempt to spill all the interfering registers with less spill
                /// weight.
                /// @sa spillInterferences
                for (MCRegister PhysReg : PhysRegSpillCandidates) {
                        if (!spillInterferences (LI, PhysReg, SplitVirtRegs)) {
                                continue;
                        }
                        return PhysReg;
                }
                /// 3.4. Spill the current virtual register.
                // Check if this interval can be spilled (prevents spilling already-spilled intervals)
                if (!LI->isSpillable()) {
                        outs () << "*** ERROR: Cannot spill " << BOLD (*LI) << " - interval is not spillable! ***\n";
                        report_fatal_error("Unable to allocate register - interval cannot be spilled");
                }
                outs () << "*** SPILLING virtual register " << BOLD (*LI) << " to stack ***\n";
                LiveRangeEdit LRE (LI, *SplitVirtRegs, *MF, *LIS, VRM, this, &DeadRemats);
                SpillerInstance->spill (LRE);
                outs () << "*** Spill complete, created " << SplitVirtRegs->size() << " new virtual registers ***\n";
                return 0;
        }

    public:
        static char ID;

        StringRef getPassName () const final
        {
                return "Minimal Register Allocator";
        }
        RAMinimal () : MachineFunctionPass (ID)
        {
        }

        void getAnalysisUsage (AnalysisUsage &AU) const final
        {
                MachineFunctionPass::getAnalysisUsage (AU);
                AU.setPreservesCFG ();
#define REQUIRE_AND_PRESERVE_PASS(PassName)                                                                            \
        AU.addRequired<PassName> ();                                                                                   \
        AU.addPreserved<PassName> ()

                REQUIRE_AND_PRESERVE_PASS (SlotIndexesWrapperPass);
                REQUIRE_AND_PRESERVE_PASS (VirtRegMapWrapperLegacy);
                REQUIRE_AND_PRESERVE_PASS (LiveIntervalsWrapperPass);
                REQUIRE_AND_PRESERVE_PASS (LiveRegMatrixWrapperLegacy);

                // The following passes are implicitly requested by the spiller.
                REQUIRE_AND_PRESERVE_PASS (LiveStacksWrapperLegacy);
                REQUIRE_AND_PRESERVE_PASS (AAResultsWrapperPass);
                REQUIRE_AND_PRESERVE_PASS (MachineDominatorTreeWrapperPass);
                REQUIRE_AND_PRESERVE_PASS (MachineLoopInfoWrapperPass);
                REQUIRE_AND_PRESERVE_PASS (MachineBlockFrequencyInfoWrapperPass);
        }

        /// Request the all PHINode's are removed before doing the register
        /// allocation.
        MachineFunctionProperties getRequiredProperties () const final
        {
                return MachineFunctionProperties ().set (MachineFunctionProperties::Property::NoPHIs);
        }
        /// After the register allocation, each virtual register no longer has a
        /// single definition.
        MachineFunctionProperties getClearedProperties () const final
        {
                return MachineFunctionProperties ().set (MachineFunctionProperties::Property::IsSSA);
        }

        bool runOnMachineFunction (MachineFunction &MF) final
        {
                this->MF = &MF;

                // Check if function has "discard" attribute
                bool hasDiscardAttr = MF.getFunction().hasFnAttribute("discard");

                outs () << "************************************************\n"
                        << "* Machine Function: " << MF.getName() << "\n"
                        << "* Has discard attribute: " << (hasDiscardAttr ? "YES" : "NO") << "\n"
                        << "************************************************\n";
                // The *SlotIndexes* maps each machine instruction to a unique ID.
                SI = &getAnalysis<SlotIndexesWrapperPass> ().getSI ();
                for (const MachineBasicBlock &MBB : MF) {
                        MBB.print (outs (), SI);
                        outs () << "\n";
                }
                outs () << "************************************************\n\n";

                // 1. Get the requested analysis results from the following passes:
                //    - VirtRegMap
                //    - LiveIntervals
                //    - LiveRegMatrix
                //    and setup the spiller.

                // The *VirtRegMap* maps virtual registers to physical registers and stack
                // slots.
                VRM = &getAnalysis<VirtRegMapWrapperLegacy> ().getVRM ();
                // The *TargetRegisterInfo* is an immutable description of all the machine
                // registers the target has.
                TRI = &VRM->getTargetRegInfo ();
                // The *MachineRegisterInfo* has information of both the physical and the
                // virtual registers.
                MRI = &VRM->getRegInfo ();
                MRI->freezeReservedRegs (); // freeze the reserved registers before the
                                            // actual allocations begin
                // The *LiveIntervals* describe the live range of each virtual register.
                LIS = &getAnalysis<LiveIntervalsWrapperPass> ().getLIS ();
                // The *LiveRegMatrix* keeps track of virtual register interference along
                // two dimensions: slot indices and register units. The matrix is used by
                // register allocators to ensure that no interfering virtual registers get
                // assigned to overlapping physical registers.
                LRM = &getAnalysis<LiveRegMatrixWrapperLegacy> ().getLRM ();

                // The *RegisterClassInfo* provides dynamic information about target
                // register classes. We will be using it to obtain a plausible allocation
                // order of physical registers.
                RCI.runOnMachineFunction (MF);

                VirtRegAuxInfo VRAI (
                        MF, *LIS, *VRM, getAnalysis<MachineLoopInfoWrapperPass> ().getLI (), getAnalysis<MachineBlockFrequencyInfoWrapperPass> ().getMBFI ());
                VRAI.calculateSpillWeightsAndHints ();

                // Create RequiredAnalyses struct for the new Spiller API
                Spiller::RequiredAnalyses SpillerAnalyses {
                        .LIS = *LIS,
                        .LSS = getAnalysis<LiveStacksWrapperLegacy> ().getLS (),
                        .MDT = getAnalysis<MachineDominatorTreeWrapperPass> ().getDomTree (),
                        .MBFI = getAnalysis<MachineBlockFrequencyInfoWrapperPass> ().getMBFI ()
                };
                SpillerInstance.reset (createInlineSpiller (SpillerAnalyses, MF, *VRM, VRAI, LRM));

                // 2. Obtain the virtual registers and push them to the worklist.
                for (unsigned VirtualRegIdx = 0; VirtualRegIdx < MRI->getNumVirtRegs (); ++VirtualRegIdx) {
                        Register Reg = Register::index2VirtReg (VirtualRegIdx);
                        // skip all unused registers
                        if (MRI->reg_nodbg_empty (Reg)) {
                                continue;
                        }
                        enqueue (&LIS->getInterval (Reg));
                }

                // 3. Keep traversing until all the workitems in the list have been
                //    processed.
                while (LiveInterval *const LI = dequeue ()) {
                        // again, skip all unused registers
                        if (MRI->reg_nodbg_empty (LI->reg ())) {
                                LIS->removeInterval (LI->reg ());
                                continue;
                        }
                        // invalidate all previous interference queries.
                        LRM->invalidateVirtRegs ();

                        // For each virtual register, Allocate to a physical register (if
                        // available) or split to a list of virtual registers.
                        SmallVector<Register, 4> SplitVirtRegs;
                        MCRegister PhysReg = selectOrSplit (LI, &SplitVirtRegs);

                        if (PhysReg) {
                                LRM->assign (*LI, PhysReg);
                        }
                        // enqueue the splitted live ranges
                        for (Register Reg : SplitVirtRegs) {
                                LiveInterval *LI = &LIS->getInterval (Reg);
                                if (MRI->reg_nodbg_empty (LI->reg ())) {
                                        LIS->removeInterval (LI->reg ());
                                        continue;
                                }
                                enqueue (LI);
                        }
                } // while (dequeue())
                // cleanup
                SpillerInstance->postOptimization ();
                for (MachineInstr *const DeadInst : DeadRemats) {
                        LIS->RemoveMachineInstrFromMaps (*DeadInst);
                        DeadInst->eraseFromParent ();
                }
                DeadRemats.clear ();
                return true;
        }
};

char RAMinimal::ID = 0;


static RegisterRegAlloc MinimalRegAllocator ("minimal", "Minimal Register Allocator", [] () -> FunctionPass * {
        return new RAMinimal ();
});


INITIALIZE_PASS_BEGIN (RAMinimal, // NOLINT(misc-use-anonymous-namespace)
                       "minimal",
                       "Minimal Register Allocator",
                       false,
                       false)
INITIALIZE_PASS_DEPENDENCY (SlotIndexesWrapperPass)
INITIALIZE_PASS_DEPENDENCY (VirtRegMapWrapperLegacy)
INITIALIZE_PASS_DEPENDENCY (LiveIntervalsWrapperPass)
INITIALIZE_PASS_DEPENDENCY (LiveRegMatrixWrapperLegacy)
INITIALIZE_PASS_DEPENDENCY (LiveStacksWrapperLegacy);
INITIALIZE_PASS_DEPENDENCY (AAResultsWrapperPass);
INITIALIZE_PASS_DEPENDENCY (MachineDominatorTreeWrapperPass);
INITIALIZE_PASS_DEPENDENCY (MachineLoopInfoWrapperPass);
INITIALIZE_PASS_DEPENDENCY (MachineBlockFrequencyInfoWrapperPass);
INITIALIZE_PASS_END (RAMinimal, // NOLINT(misc-use-anonymous-namespace)
                     "minimal",
                     "Minimal Register Allocator",
                     false,
                     false)