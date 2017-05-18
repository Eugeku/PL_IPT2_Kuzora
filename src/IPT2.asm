model small

.data
	arr dw 1,-43,-6,15,32,4,8,5,4,10,1,43,256,-15,32,4,8,5,4,115   ; Массив элементов.
	max dw ? 					; Максимальный элемент.
	min dw ? 					; Минимальный элемент.
	su dw ? 					; Разность.
	mes dw ?
	mes1 db 'MAX element: $'
	mes2 db 'MIN element: $'
	blank db '', 10, 13, '$'
	subBet db 'MAX-MIN = $'

.stack 100h

.code
	start:
		mov ax, @data
		mov ds, ax
		mov mes, offset mes1 		
		call far ptr ShowMess
		call far ptr FindMax
		call far ptr OutInt
		mov mes, offset blank 		
		call far ptr ShowMess
		mov mes, offset mes2 		
		call far ptr ShowMess
		call far ptr FindMin
		call far ptr OutInt
		mov mes, offset blank 		
		call far ptr ShowMess
		call far ptr FindSub
		mov mes, offset subBet 		
		call far ptr ShowMess
		mov ax, su
		call far ptr OutInt
		call far ptr Endprog
		
		ShowMess proc far		; Процедура вывода сообщений на экран.
			mov dx, mes
			mov ah,09h
			int 21h
			ret
		ShowMess endp
		
		FindSub proc far
			mov ax, max
			mov bx, min
			sub ax, bx
			mov su, ax
			ret
		FindSub endp
		
		FindMax proc far
			mov ax,0			; Нумерация начинается с 0.
			mov cl,20*type arr	; 20 двухбайтных элементов.
			mul cl				; В ax – позиция первого элемента. 
			mov bx,ax			; Занесение в bx значения из ax, так как регистр ax не 
								; может быть использован для косвенной адресации.
			mov ax,arr[bx]		; Занесение в ax первого элемента.
								; Поиск максимума.
			mov cx,20-1			; Будет сравниваться 19 элементов.
			L1:
			add bx,type arr		; Увеличение на 2 индекса массива.
			cmp ax,arr[bx]		; В ax – текущий максимум.
			jge no_new_max		; Если в ax число, меньшее элемента массива, то
			mov ax,arr[bx]		; занесение нового максимума в ax.
			no_new_max:
			loop L1				; Цикл, после выполнения которого в ax будет max.
			mov max, ax
			ret
		FindMax endp
		
		FindMin proc far
			mov ax,0			; Нумерация начинается с 0.
			mov cl,20*type arr	; 20 двухбайтных элементов.
			mul cl				; В ax – позиция первого элемента. 
			mov bx,ax			; Занесение в bx значения из ax, так как регистр ax не 
								; может быть использован для косвенной адресации.
			mov ax,arr[bx]		; Занесение в ax первого элемента.
								; Поиск минимума.
			mov cx,20-1			; Будет сравниваться 19 элементов.
			L2:
			add bx,type arr		; Увеличение на 2 индекса массива.
			cmp ax,arr[bx]		; В ax – текущий мимнимум.
			jle no_new_min		; Если в ax число, больше элемента массива, то
			mov ax,arr[bx]		; занесение нового минимума в ax.
			no_new_min:
			loop L2				; Цикл, после выполнения которого в ax будет min.
			mov min, ax
			ret
		FindMin endp
		
		OutInt proc far
		   test    ax, ax		; Проверяем число на знак.
		   jns     oi1
		   mov  cx, ax			; Если оно отрицательное, выведем минус и оставим его модуль.
		   mov     ah, 02h
		   mov     dl, '-'
		   int     21h
		   mov  ax, cx
		   neg     ax
								; Количество цифр будем держать в CX.
		oi1:  
			xor     cx, cx
			mov     bx, 10 		; Основание сс. 10 для десятеричной и т.п.
		oi2:
			xor     dx,dx
			div     bx
								; Делим число на основание сс. 
								; В остатке получается последняя цифра.
								; Сразу выводить её нельзя, поэтому сохраним её в стэке.
			push    dx
			inc     cx
								; А с частным повторяем то же самое, отделяя от него очередную
								; цифру справа, пока не останется ноль, что значит, что дальше
								; слева только нули.
			test    ax, ax
			jnz     oi2
								; Теперь приступим к выводу.
			mov     ah, 02h
		oi3:
			pop     dx
								; Извлекаем очередную цифру, переводим её в символ и выводим.
			add     dl, '0'
			int     21h
			loop    oi3			; Повторим ровно столько раз, сколько цифр насчитали.
			ret
		OutInt endp
		
		Endprog proc far
			mov ah, 01h 		; Прерывание дос на ожидание любого дествия с клавиатуры
			int 21h
			mov ah, 4Ch 		; Прерывание дос на завершение программы
			int 21h	
		Endprog endp
	end start