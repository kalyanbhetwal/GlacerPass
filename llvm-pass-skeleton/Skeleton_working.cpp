#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/PassRegistry.h"
#include "llvm/PassInfo.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class MyMachinePass : public MachineFunctionPass {
public:
  static char ID;
  
  MyMachinePass() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override {
    errs() << "[MyMachinePass] Processing Machine Function: " 
           << MF.getName() << "\n";
    
    // Example: Iterate through basic blocks and instructions
    for (MachineBasicBlock &MBB : MF) {
      errs() << "  MBB: " << MBB.getName() << " (ID: " << MBB.getNumber() << ")\n";
      for (MachineInstr &MI : MBB) {
        errs() << "    ";
        MI.print(errs());
      }
    }
    
    return false; // Return true if you modify the MachineFunction
  }

  StringRef getPassName() const override { 
    return "My Machine Function Pass"; 
  }
  
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    MachineFunctionPass::getAnalysisUsage(AU);
    // Add any pass dependencies here if needed
    // AU.addRequired<SomeOtherPass>();
    // AU.setPreservesAll(); // if you don't modify anything
  }
};
} // end anonymous namespace

char MyMachinePass::ID = 0;

// For legacy pass manager machine passes, manually register in PassRegistry
namespace llvm {
  void initializeMyMachinePassPass(PassRegistry &Registry) {
    const char *PassName = "My Machine Function Pass";
    const char *PassArg = "my-machine-pass";
    
    PassInfo *PI = new PassInfo(
        PassName,
        PassArg,
        &MyMachinePass::ID,
        // Constructor function
        PassInfo::NormalCtor_t(+[]() -> Pass* { 
          return new MyMachinePass(); 
        }),
        false,  // is CFG only pass
        false   // is analysis pass
    );
    
    Registry.registerPass(*PI, false);
  }
}

// Automatically initialize when library is loaded
struct StaticInit {
  StaticInit() {
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    initializeMyMachinePassPass(Registry);
  }
};

static StaticInit InitializeEverything;

// // C-style export for explicit pass creation (optional, for debugging)
// extern "C" {
//   MachineFunctionPass* createMyMachinePass() {
//     return new MyMachinePass();
//   }
// }