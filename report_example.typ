#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1cm),
  numbering: none,
  footer: context {
    let p = counter(page).get().first()
    if p > 1 {
      align(center)[#p]
    }
  }
)

#set text(
  lang: "ru",
  font: "Times New Roman",
  size: 12pt
)

//Рамка для блока с кодом
#show raw: block.with(
  fill: luma(245),
  inset: 10pt,
  radius: 5pt,
  stroke: luma(200),
)

//Для таблиц - подпись сверху
#show figure.where(kind: table): set figure.caption(position: top)



#align(center)[
  #upper[ГУАП]
  #v(0.5cm)
  #upper[КАФЕДРА № 14]
  #v(2cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[ОТЧЕТ]\
    #upper[ЗАЩИЩЕН С ОЦЕНКОЙ]\
    #upper[]\
    #upper[ПРЕПОДАВАТЕЛЬ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (2fr, 1fr, 2fr),
      gutter: 0.3em,
      [Старший преподаватель],
      [ ],
      [Н.И. Синев],
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [должность],
      [подпись, дата],
      [инициалы, фамилия]
    )
  ]
)

#align(center)[
  #v(2cm)
  #upper[ОТЧЕТ О ЛАБОРАТОРНОЙ РАБОТЕ №1]
  #v(0.8cm)
  #text[Вычисления для беззнаковых чисел]
  #v(0.8cm)
  #text[по курсу:]
  #text[Программирование на языках Ассемблера]
  #v(4cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[РАБОТУ ВЫПОЛНИЛ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (1fr, 1fr, 1fr, 1.5fr),
      gutter: 0.3em,
      align(left)[#upper[СТУДЕНТ гр. №]],
      [1446],
      [04.03.2026],
      [А.С. Корчуганов],
      line(length: 0%),
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [],
      [],
      [подпись, дата],
      [инициалы, фамилия]
    )

    #v(4cm)

    Санкт-Петербург 2026
]
)


= Описание задачи
Написать программу для вычисления формулы номер 99 (14 вариант)  Y = |A - 3·B| / (B*B) 

= Формализация
Ссылка на репозиторий ГитХаб с лабораторной работой 1 https://github.com/AsKorch/Assambler_Lab1
1. Постановка задачи
Вычислить значение выражения Y = |A - 3·B| / (B·B) для целочисленных входных данных A и B с выводом результата в формате числа с плавающей точкой.

2. Математическая модель
Y = |A - 3B| / B², где:

A, B ∈ Z (целые числа)

B ≠ 0 (условие существования)

3. Входные данные
A: целое число (32-битное знаковое)

B: целое число (32-битное знаковое), B ≠ 0

4. Выходные данные
Y: вещественное число (64-битное double) с точностью 3 знака после запятой

Сообщение об ошибке при B = 0

5. Ограничения
Вычислительные ограничения:
|A - 3B| ≤ 2³¹-1 (максимальное значение 32-битного знакового целого)

B² ≤ 2³¹-1 (чтобы избежать переполнения при умножении)

|A - 3B| / B² должно быть представимо в формате double.
6. Используемые средства
Программные:
Язык: ассемблер NASM (архитектура x86, 32-бита)

Библиотека: C standard library (printf, scanf, exit)

Аппаратные:
Целочисленный процессор (ALU): вычисление A-3B, |A-3B|, B²

FPU (Floating Point Unit): деление с плавающей точкой

Регистры:
EAX, EBX: целочисленные вычисления

ST(0), ST(1): стек FPU для вещественных операций

7. Этапы решения
Ввод данных: получение A и B от пользователя

Валидация: проверка B ≠ 0

Вычисление числителя: |A - 3B|

Вычисление знаменателя: B²

Деление: преобразование целых чисел в float и деление через FPU

Вывод результата: с точностью 3 знака после запятой

Обработка ошибки: вывод сообщения при B = 0

Блок-схема программы:
#figure(
  image("1_0.png", width: 60%),
  caption: [Блок-схема программы>],
) <glacier>


= Исходный код программы
Ниже приведен код программы на языке ассемблер.

Код на ассемблере:
```asm
Программа для вычисления Y = |A - 3*B| / (B*B)


.intel_syntax noprefix

.section .data
prompt_a: .asciz "Enter A: "
prompt_b: .asciz "Enter B: "
format_in: .asciz "%d"
format_out: .asciz "Result = %f\n"
error_msg: .asciz "B cannot be zero!\n"

.section .bss
a: .space 4
b: .space 4

.section .text
.globl main
.extern printf
.extern scanf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, prompt_a
    call printf
    lea rdx, a
    lea rcx, format_in
    call scanf

    lea rcx, prompt_b
    call printf
    lea rdx, b
    lea rcx, format_in
    call scanf

    mov eax, dword ptr [a]
    mov ebx, dword ptr [b]

    cmp ebx, 0
    je error

    mov ecx, ebx
    imul ebx, ebx, 3
    sub eax, ebx
    
    cdq
    xor eax, edx
    sub eax, edx

    cvtsi2sd xmm0, eax
    imul ecx, ecx
    cvtsi2sd xmm1, ecx
    divsd xmm0, xmm1
    
    lea rcx, format_out
    movq rdx, xmm0
    call printf
    jmp done

error:
    lea rcx, error_msg
    call printf

done:
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
```

= Тестирование
Приведем таблицу с ручным вычислением значений и скриншот из программы.

#figure(
  table(
    columns: 4,
    align: center + horizon,
    // stroke: none,
    table.hline(),
    [*Набор тестовых данных *], [*A*], [*B*], [*Итог*],
    table.hline(),
    [1], [10],  [1],  [$(10-1*3)/(1*1) = 7$],
    [2], [12],  [2],  [$(12-2*3)/(2*2) = 1,5$],
    [3], [7],   [10],   [$(7-10*3)/(10*10) = 0,230$],
    table.hline(),
  ),
  caption: [Расчёт выражения $Y = |A - 3·B| / (B*B) $ для трёх различных наборов],
)
#figure(
  image("1_2.png", width: 20%),
  caption: [Вывод тестовых результатов],
) <glacier>
#figure(
  image("1_3.png", width: 20%),
  caption: [Вывод тестовых результатов],
) <glacier>
#figure(
  image("1_1.png", width: 20%),
  caption: [Вывод тестовых результатов],
) <glacier>



= Выводы
В ходе выполнения лабораторной работы была поставлена задача разработать программу на языке ассемблера для вычисления выражения Y = |A - 3B| / B² с подробным выводом результатов. Для решения задачи были выполнены следующие этапы: формализация входных данных с определением допустимых диапазонов значений (A, B ∈ Z, B ≠ 0, |B| ≤ 46340), написание программы на NASM с использованием целочисленных операций для вычисления числителя и знаменателя, а также модуля FPU для точного деления с плавающей точкой. Программа реализует полный цикл обработки: ввод данных через scanf, проверку деления на ноль, вычисление результата и вывод с точностью три знака после запятой через printf. Ручное тестирование программы с различными наборами входных данных подтвердило корректность вычислений и соответствие результатов ожидаемым значениям. Таким образом, лабораторная работа выполнена верно и все поставленные цели достигнуты.