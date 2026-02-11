; ============================================
; RESTAURANT BILLING SYSTEM
; Assembly Language (NASM)
; ============================================
; Features:
; - Display Menu with Prices
; - Take Orders
; - Calculate Subtotal
; - Add 10% Service Tax
; - Add 5% GST
; - Generate Final Bill
; ============================================

section .data
    ; System Messages
    msg_welcome db '========================================', 0
                db 10, '   WELCOME TO ASSEMBLY RESTAURANT', 0
                db 10, '========================================', 0
                db 10, 0
    
    msg_menu db 10, '----------- TODAYS MENU -----------', 0
             db 10, '1. Veg Biryani     - Rs 180', 0
             db 10, '2. Chicken Biryani - Rs 250', 0
             db 10, '3. Paneer Butter   - Rs 220', 0
             db 10, '4. Butter Chicken  - Rs 320', 0
             db 10, '5. Naan           - Rs 40', 0
             db 10, '6. Garlic Naan    - Rs 60', 0
             db 10, '7. Cold Drink     - Rs 50', 0
             db 10, '8. Ice Cream      - Rs 80', 0
             db 10, '9. Generate Bill', 0
             db 10, '0. Exit', 0
             db 10, '------------------------------------', 0
             db 10, 0
    
    msg_choice db 10, 'Enter your choice: ', 0
    msg_quantity db 10, 'Enter quantity: ', 0
    msg_continue db 10, 'Continue ordering? (y/n): ', 0
    msg_invalid db 10, 'Invalid choice! Please try again.', 10, 0
    msg_thanks db 10, '========================================', 0
               db 10, '   THANK YOU! VISIT AGAIN!', 0
               db 10, '========================================', 10, 0
    
    ; Bill Formatting
    msg_bill_header db 10, '========================================', 0
                    db 10, '           FINAL BILL', 0
                    db 10, '========================================', 0
                    db 10, 'Item', 9, 9, 'Qty', 9, 'Price', 9, 'Total', 10, 0
    msg_separator db '----------------------------------------', 10, 0
    msg_bill_footer db '========================================', 10, 0
    
    msg_subtotal db 10, 'Subtotal:       Rs ', 0
    msg_tax db 'Service Tax (10%): Rs ', 0
    msg_gst db 'GST (5%):        Rs ', 0
    msg_total db 10, 'GRAND TOTAL:     Rs ', 0
    msg_payment db 10, 'Payment Method: ', 0
    msg_cash db 'Cash', 10, 0
    msg_card db 'Card', 10, 0
    msg_upi db 'UPI', 10, 0
    
    ; Payment options
    msg_payment_options db 10, 'Select Payment Method:', 10
                        db '1. Cash', 10
                        db '2. Card', 10
                        db '3. UPI', 10
                        db 'Enter choice: ', 0
    
    ; Item names for bill
    item1 db 'Veg Biryani     ', 0
    item2 db 'Chicken Biryani ', 0
    item3 db 'Paneer Butter   ', 0
    item4 db 'Butter Chicken  ', 0
    item5 db 'Naan           ', 0
    item6 db 'Garlic Naan    ', 0
    item7 db 'Cold Drink     ', 0
    item8 db 'Ice Cream      ', 0
    
    ; Item prices
    price1 dd 180
    price2 dd 250
    price3 dd 220
    price4 dd 320
    price5 dd 40
    price6 dd 60
    price7 dd 50
    price8 dd 80
    
    ; New line
    newline db 10, 0
    tab db 9, 0
    
    ; Order tracking
    order_items times 100 db 0    ; Store item IDs
    order_quantities times 100 dd 0 ; Store quantities
    order_prices times 100 dd 0    ; Store item prices
    
    ; Counters
    item_count dd 0
    total_amount dd 0
    subtotal dd 0
    service_tax dd 0
    gst dd 0
    grand_total dd 0
    
    ; Format strings
    fmt_str db '%s', 0
    fmt_int db '%d', 0
    fmt_newline db 10, 0
    fmt_tab db 9, 0
    
    ; Buffer for input
    buffer db 10
    db 0
    times 10 db 0
    
    choice_buffer db 10, 0
    quantity_buffer db 10, 0
    continue_buffer db 10, 0
    payment_buffer db 10, 0

section .bss
    ; Uninitialized data
    temp resd 1
    i resd 1
    j resd 1

section .text
    global _start
    extern printf, scanf, getchar, putchar, exit

; ============================================
; Print string function
; ============================================
print_string:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, [ebp+8]    ; string to print
    mov edx, [ebp+12]   ; length
    int 0x80
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 8

; ============================================
; Print integer function
; ============================================
print_int:
    push ebp
    mov ebp, esp
    sub esp, 16         ; local buffer
    
    mov eax, [ebp+8]    ; number to print
    mov ebx, 10         ; divisor
    mov ecx, 0          ; digit counter
    lea edi, [ebp-1]    ; buffer end
    
    ; Handle zero
    cmp eax, 0
    jne .convert_loop
    mov byte [edi], '0'
    inc ecx
    jmp .print
    
.convert_loop:
    cmp eax, 0
    je .print
    
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    jmp .convert_loop
    
.print:
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, ecx
    int 0x80
    
    add esp, 16
    pop ebp
    ret 4

; ============================================
; Print new line
; ============================================
print_newline:
    push ebp
    mov ebp, esp
    push dword newline
    call print_string
    pop ebp
    ret

; ============================================
; Print tab
; ============================================
print_tab:
    push ebp
    mov ebp, esp
    push dword tab
    call print_string
    pop ebp
    ret

; ============================================
; Read integer input
; ============================================
read_int:
    push ebp
    mov ebp, esp
    
    ; Read string input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 10
    int 0x80
    
    ; Convert to integer
    mov esi, buffer
    xor eax, eax
    xor ecx, ecx
    mov ebx, 10
    
.convert:
    movzx edx, byte [esi]
    cmp dl, 10          ; newline
    je .done
    cmp dl, 0           ; null
    je .done
    sub dl, '0'
    imul eax, ebx
    add eax, edx
    inc esi
    jmp .convert
    
.done:
    pop ebp
    ret

; ============================================
; Read character input
; ============================================
read_char:
    push ebp
    mov ebp, esp
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 2
    int 0x80
    
    mov al, [buffer]
    pop ebp
    ret

; ============================================
; Clear screen
; ============================================
clear_screen:
    push ebp
    mov ebp, esp
    
    mov eax, 4
    mov ebx, 1
    mov ecx, clear_cmd
    mov edx, clear_len
    int 0x80
    
    pop ebp
    ret

; ============================================
; Display welcome message
; ============================================
display_welcome:
    push ebp
    mov ebp, esp
    
    ; Print welcome message
    push dword msg_welcome
    call print_string
    
    pop ebp
    ret

; ============================================
; Display menu
; ============================================
display_menu:
    push ebp
    mov ebp, esp
    
    ; Print menu
    push dword msg_menu
    call print_string
    
    pop ebp
    ret

; ============================================
; Process order
; ============================================
process_order:
    push ebp
    mov ebp, esp
    
.order_loop:
    ; Display menu
    call display_menu
    
    ; Get user choice
    push dword msg_choice
    call print_string
    call read_int
    mov ebx, eax
    
    ; Check choice
    cmp ebx, 0
    je .exit
    cmp ebx, 9
    je .generate_bill
    
    ; Validate choice (1-8)
    cmp ebx, 1
    jl .invalid
    cmp ebx, 8
    jg .invalid
    
    ; Get quantity
    push dword msg_quantity
    call print_string
    call read_int
    mov ecx, eax
    
    ; Validate quantity
    cmp ecx, 0
    jle .invalid
    
    ; Store order
    mov eax, [item_count]
    mov [order_items + eax], bl
    mov [order_quantities + eax*4], ecx
    
    ; Get price based on choice
    mov edx, ebx
    dec edx
    shl edx, 2
    mov esi, price1
    add esi, edx
    mov edx, [esi]
    mov [order_prices + eax*4], edx
    
    ; Calculate and add to subtotal
    imul edx, ecx
    add [subtotal], edx
    
    ; Increment item count
    inc dword [item_count]
    
    jmp .order_loop
    
.invalid:
    push dword msg_invalid
    call print_string
    jmp .order_loop
    
.generate_bill:
    call generate_bill
    jmp .done
    
.exit:
    call display_thanks
    
.done:
    pop ebp
    ret

; ============================================
; Generate bill
; ============================================
generate_bill:
    push ebp
    mov ebp, esp
    
    ; Clear screen
    call clear_screen
    
    ; Print bill header
    push dword msg_bill_header
    call print_string
    call print_newline
    
    ; Print separator
    push dword msg_separator
    call print_string
    
    ; Print ordered items
    xor ecx, ecx        ; counter
    mov [i], ecx
    
.print_items:
    mov ecx, [i]
    cmp ecx, [item_count]
    jge .calculate_totals
    
    ; Get item ID
    xor ebx, ebx
    mov bl, [order_items + ecx]
    
    ; Print item name
    dec ebx
    shl ebx, 2
    mov esi, item1
    add esi, ebx
    push dword [esi]
    call print_string
    
    ; Print quantity
    call print_tab
    call print_tab
    mov eax, [order_quantities + ecx*4]
    push eax
    call print_int
    
    ; Print price
    call print_tab
    mov eax, [order_prices + ecx*4]
    push eax
    call print_int
    
    ; Print total
    call print_tab
    mov eax, [order_quantities + ecx*4]
    mov ebx, [order_prices + ecx*4]
    imul eax, ebx
    push eax
    call print_int
    
    call print_newline
    
    inc dword [i]
    jmp .print_items
    
.calculate_totals:
    ; Print separator
    push dword msg_separator
    call print_string
    
    ; Print subtotal
    push dword msg_subtotal
    call print_string
    mov eax, [subtotal]
    push eax
    call print_int
    call print_newline
    
    ; Calculate service tax (10%)
    mov eax, [subtotal]
    mov ebx, 10
    mul ebx
    mov ebx, 100
    div ebx
    mov [service_tax], eax
    
    ; Print service tax
    push dword msg_tax
    call print_string
    mov eax, [service_tax]
    push eax
    call print_int
    call print_newline
    
    ; Calculate GST (5%)
    mov eax, [subtotal]
    mov ebx, 5
    mul ebx
    mov ebx, 100
    div ebx
    mov [gst], eax
    
    ; Print GST
    push dword msg_gst
    call print_string
    mov eax, [gst]
    push eax
    call print_int
    call print_newline
    
    ; Calculate grand total
    mov eax, [subtotal]
    add eax, [service_tax]
    add eax, [gst]
    mov [grand_total], eax
    
    ; Print grand total
    push dword msg_total
    call print_string
    mov eax, [grand_total]
    push eax
    call print_int
    call print_newline
    
    ; Process payment
    call process_payment
    
    ; Print bill footer
    push dword msg_bill_footer
    call print_string
    
    pop ebp
    ret

; ============================================
; Process payment
; ============================================
process_payment:
    push ebp
    mov ebp, esp
    
    ; Display payment options
    push dword msg_payment_options
    call print_string
    
    ; Get payment method
    call read_int
    
    ; Print payment method
    push dword msg_payment
    call print_string
    
    cmp eax, 1
    je .cash
    cmp eax, 2
    je .card
    cmp eax, 3
    je .upi
    jmp .cash
    
.cash:
    push dword msg_cash
    call print_string
    jmp .done
    
.card:
    push dword msg_card
    call print_string
    jmp .done
    
.upi:
    push dword msg_upi
    call print_string
    jmp .done
    
.done:
    pop ebp
    ret

; ============================================
; Display thank you message
; ============================================
display_thanks:
    push ebp
    mov ebp, esp
    
    push dword msg_thanks
    call print_string
    
    pop ebp
    ret

; ============================================
; Reset system for new order
; ============================================
reset_system:
    push ebp
    mov ebp, esp
    
    ; Reset all counters and totals
    mov dword [item_count], 0
    mov dword [subtotal], 0
    mov dword [service_tax], 0
    mov dword [gst], 0
    mov dword [grand_total], 0
    mov dword [i], 0
    mov dword [j], 0
    
    ; Clear order arrays
    mov ecx, 0
.clear_loop:
    cmp ecx, 100
    jge .done
    mov byte [order_items + ecx], 0
    mov dword [order_quantities + ecx*4], 0
    mov dword [order_prices + ecx*4], 0
    inc ecx
    jmp .clear_loop
    
.done:
    pop ebp
    ret

; ============================================
; Main program
; ============================================
_start:
    ; Display welcome message
    call display_welcome
    
.main_loop:
    ; Process orders and generate bill
    call process_order
    
    ; Ask if user wants to continue
    push dword msg_continue
    call print_string
    call read_char
    
    ; Check if user wants to continue
    cmp al, 'y'
    je .continue
    cmp al, 'Y'
    je .continue
    jmp .exit
    
.continue:
    ; Reset system for new order
    call reset_system
    call clear_screen
    jmp .main_loop
    
.exit:
    ; Display thank you message
    call display_thanks
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ============================================
; Data section for clear screen
; ============================================
section .data
clear_cmd db 27, '[2J', 27, '[H'
clear_len equ $ - clear_cmd
