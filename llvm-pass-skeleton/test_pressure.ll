; ModuleID = 'test_pressure.c'
source_filename = "test_pressure.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @pressure(i32 noundef %a, i32 noundef %b, i32 noundef %c, i32 noundef %d) #0 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %c.addr = alloca i32, align 4
  %d.addr = alloca i32, align 4
  %x1 = alloca i32, align 4
  %x2 = alloca i32, align 4
  %x3 = alloca i32, align 4
  %x4 = alloca i32, align 4
  %x5 = alloca i32, align 4
  %x6 = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  store i32 %c, ptr %c.addr, align 4
  store i32 %d, ptr %d.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %mul = mul nsw i32 %0, 2
  store i32 %mul, ptr %x1, align 4
  %1 = load i32, ptr %b.addr, align 4
  %mul1 = mul nsw i32 %1, 3
  store i32 %mul1, ptr %x2, align 4
  %2 = load i32, ptr %c.addr, align 4
  %mul2 = mul nsw i32 %2, 4
  store i32 %mul2, ptr %x3, align 4
  %3 = load i32, ptr %d.addr, align 4
  %mul3 = mul nsw i32 %3, 5
  store i32 %mul3, ptr %x4, align 4
  %4 = load i32, ptr %a.addr, align 4
  %5 = load i32, ptr %b.addr, align 4
  %mul4 = mul nsw i32 %4, %5
  store i32 %mul4, ptr %x5, align 4
  %6 = load i32, ptr %c.addr, align 4
  %7 = load i32, ptr %d.addr, align 4
  %mul5 = mul nsw i32 %6, %7
  store i32 %mul5, ptr %x6, align 4
  %8 = load i32, ptr %x1, align 4
  %9 = load i32, ptr %x2, align 4
  %add = add nsw i32 %8, %9
  %10 = load i32, ptr %x3, align 4
  %add6 = add nsw i32 %add, %10
  %11 = load i32, ptr %x4, align 4
  %add7 = add nsw i32 %add6, %11
  %12 = load i32, ptr %x5, align 4
  %add8 = add nsw i32 %add7, %12
  %13 = load i32, ptr %x6, align 4
  %add9 = add nsw i32 %add8, %13
  %14 = load i32, ptr %a.addr, align 4
  %add10 = add nsw i32 %add9, %14
  %15 = load i32, ptr %b.addr, align 4
  %add11 = add nsw i32 %add10, %15
  %16 = load i32, ptr %c.addr, align 4
  %add12 = add nsw i32 %add11, %16
  %17 = load i32, ptr %d.addr, align 4
  %add13 = add nsw i32 %add12, %17
  ret i32 %add13
}

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"}
