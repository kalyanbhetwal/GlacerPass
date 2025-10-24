; ModuleID = 'test_pressure.c'
source_filename = "test_pressure.c"
target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430"

; Function Attrs: noinline nounwind optnone
define dso_local i16 @pressure(i16 noundef %a, i16 noundef %b, i16 noundef %c, i16 noundef %d) #0 {
entry:
  %a.addr = alloca i16, align 2
  %b.addr = alloca i16, align 2
  %c.addr = alloca i16, align 2
  %d.addr = alloca i16, align 2
  %x1 = alloca i16, align 2
  %x2 = alloca i16, align 2
  %x3 = alloca i16, align 2
  %x4 = alloca i16, align 2
  %x5 = alloca i16, align 2
  %x6 = alloca i16, align 2
  store i16 %a, ptr %a.addr, align 2
  store i16 %b, ptr %b.addr, align 2
  store i16 %c, ptr %c.addr, align 2
  store i16 %d, ptr %d.addr, align 2
  %0 = load i16, ptr %a.addr, align 2
  %mul = mul nsw i16 %0, 2
  store i16 %mul, ptr %x1, align 2
  %1 = load i16, ptr %b.addr, align 2
  %mul1 = mul nsw i16 %1, 3
  store i16 %mul1, ptr %x2, align 2
  %2 = load i16, ptr %c.addr, align 2
  %mul2 = mul nsw i16 %2, 4
  store i16 %mul2, ptr %x3, align 2
  %3 = load i16, ptr %d.addr, align 2
  %mul3 = mul nsw i16 %3, 5
  store i16 %mul3, ptr %x4, align 2
  %4 = load i16, ptr %a.addr, align 2
  %5 = load i16, ptr %b.addr, align 2
  %mul4 = mul nsw i16 %4, %5
  store i16 %mul4, ptr %x5, align 2
  %6 = load i16, ptr %c.addr, align 2
  %7 = load i16, ptr %d.addr, align 2
  %mul5 = mul nsw i16 %6, %7
  store i16 %mul5, ptr %x6, align 2
  %8 = load i16, ptr %x1, align 2
  %9 = load i16, ptr %x2, align 2
  %add = add nsw i16 %8, %9
  %10 = load i16, ptr %x3, align 2
  %add6 = add nsw i16 %add, %10
  %11 = load i16, ptr %x4, align 2
  %add7 = add nsw i16 %add6, %11
  %12 = load i16, ptr %x5, align 2
  %add8 = add nsw i16 %add7, %12
  %13 = load i16, ptr %x6, align 2
  %add9 = add nsw i16 %add8, %13
  %14 = load i16, ptr %a.addr, align 2
  %add10 = add nsw i16 %add9, %14
  %15 = load i16, ptr %b.addr, align 2
  %add11 = add nsw i16 %add10, %15
  %16 = load i16, ptr %c.addr, align 2
  %add12 = add nsw i16 %add11, %16
  %17 = load i16, ptr %d.addr, align 2
  %add13 = add nsw i16 %add12, %17
  ret i16 %add13
}

attributes #0 = { noinline nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 2}
!1 = !{!"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"}
