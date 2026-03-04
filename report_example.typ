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


extern printf
extern scanf
extern exit

section .data
    promptA db "A = ", 0
    promptB db "B = ", 0
    inputMsg db "A = %d", 10, "B = %d", 10, 0
    resultMsg db "Y = %.3f", 10, 0
    errorMsg db "Error: Division by zero!", 10, 0
    formatInt db "%d", 0

section .bss
    A resd 1
    B resd 1
    resultFloat resq 1

section .text
    global main

main:
    push ebp
    mov ebp, esp

    ; Ввод A
    push promptA
    call printf
    add esp, 4
    
    push A
    push formatInt
    call scanf
    add esp, 8

    ; Ввод B
    push promptB
    call printf
    add esp, 4
    
    push B
    push formatInt
    call scanf
    add esp, 8

    ; Проверка B на 0
    mov eax, [B]
    cmp eax, 0
    je .error

    ; Выводим введенные значения
    push dword [B]
    push dword [A]
    push inputMsg
    call printf
    add esp, 12

    ; Вычисляем |A - 3B|
    mov eax, [B]
    imul eax, 3         ; eax = 3B
    mov ebx, [A]
    sub ebx, eax        ; ebx = A - 3B
    
    ; Модуль
    mov eax, ebx
    cmp eax, 0
    jge .abs_done
    neg eax
.abs_done:
    push eax            ; сохраняем |A-3B| в стек

    ; Вычисляем B^2
    mov eax, [B]
    imul eax, eax       ; eax = B^2
    push eax            ; сохраняем B^2 в стек

    ; Загружаем в FPU для точного деления
    fild dword [esp+4]  ; ST(0) = |A-3B|
    fild dword [esp]    ; ST(0) = B^2, ST(1) = |A-3B|
    fdivp               ; ST(0) = |A-3B| / B^2
    
    ; Сохраняем результат
    fstp qword [resultFloat]
    
    add esp, 8          ; очищаем стек от сохраненных значений

    ; Выводим результат
    push dword [resultFloat+4]
    push dword [resultFloat]
    push resultMsg
    call printf
    add esp, 12

    push 0
    call exit

.error:
    push errorMsg
    call printf
    add esp, 4
    push 1
    call exit
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