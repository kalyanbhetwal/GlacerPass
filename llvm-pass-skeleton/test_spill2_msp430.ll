; ModuleID = 'test_spill2.c'
source_filename = "test_spill2.c"
target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430"

; Function Attrs: noinline nounwind optnone
define dso_local i16 @test(i16 noundef %a, i16 noundef %b, i16 noundef %c, i16 noundef %d, i16 noundef %e) #0 {
entry:
  %a.addr = alloca i16, align 2
  %b.addr = alloca i16, align 2
  %c.addr = alloca i16, align 2
  %d.addr = alloca i16, align 2
  %e.addr = alloca i16, align 2
  %x1 = alloca i16, align 2
  %x2 = alloca i16, align 2
  %x3 = alloca i16, align 2
  %x4 = alloca i16, align 2
  %x5 = alloca i16, align 2
  store i16 %a, ptr %a.addr, align 2
  store i16 %b, ptr %b.addr, align 2
  store i16 %c, ptr %c.addr, align 2
  store i16 %d, ptr %d.addr, align 2
  store i16 %e, ptr %e.addr, align 2
  %0 = load i16, ptr %a.addr, align 2
  %1 = load i16, ptr %b.addr, align 2
  %add = add nsw i16 %0, %1
  store i16 %add, ptr %x1, align 2
  %2 = load i16, ptr %c.addr, align 2
  %3 = load i16, ptr %d.addr, align 2
  %add1 = add nsw i16 %2, %3
  store i16 %add1, ptr %x2, align 2
  %4 = load i16, ptr %e.addr, align 2
  %5 = load i16, ptr %a.addr, align 2
  %add2 = add nsw i16 %4, %5
  store i16 %add2, ptr %x3, align 2
  %6 = load i16, ptr %x1, align 2
  %7 = load i16, ptr %x2, align 2
  %add3 = add nsw i16 %6, %7
  store i16 %add3, ptr %x4, align 2
  %8 = load i16, ptr %x3, align 2
  %9 = load i16, ptr %x4, align 2
  %add4 = add nsw i16 %8, %9
  store i16 %add4, ptr %x5, align 2
  %10 = load i16, ptr %x5, align 2
  %11 = load i16, ptr %b.addr, align 2
  %add5 = add nsw i16 %10, %11
  %12 = load i16, ptr %c.addr, align 2
  %add6 = add nsw i16 %add5, %12
  %13 = load i16, ptr %d.addr, align 2
  %add7 = add nsw i16 %add6, %13
  %14 = load i16, ptr %e.addr, align 2
  %add8 = add nsw i16 %add7, %14
  ret i16 %add8
}

attributes #0 = { noinline nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 2}
!1 = !{!"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"}
