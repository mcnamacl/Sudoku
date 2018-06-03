	AREA	Sudoku, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	IMPORT  ClearScreen
	IMPORT  setCursorPosition
	EXPORT	start
	PRESERVE8

start
	BL ClearScreen				; clear console screen
	LDR R0, =greeting			; load greet string
	BL displayString			; display greeting
	
	BL getkey; 
	CMP R0, #'1'				; if (userInput == 1){
	BEQ getGridOne				; load grid one}
	
	CMP R0, #'2'				; else if (userInput == 2){
	BEQ getGridTwo				; load grid two}
	
	CMP R0, #'3'				; else if (userInput == 3){
	BEQ getGridThree			; load grid three}
	
	CMP R0, #'4'				; else if (userInput == 4){
	BEQ getGridFour				; load grid four}
	
	CMP R0, #'5'				; else if (userInput == 5){
	BEQ getGridFive				; load grid five}
	
getGridOne
	LDR	R6, =gridOne
	B askUser

getGridTwo
	LDR R6, =gridTwo
	B askUser

getGridThree
	LDR R6, =gridThree
	B askUser
	
getGridFour
	LDR R6, =gridFour
	B askUser
	
getGridFive
	LDR R6, =gridFive
	B askUser
	
askUser
	BL sendchar					; send userInput to console
	BL ClearScreen				; clear console
	LDR R0, =query				; load query string
	BL displayString			; display query
	
	BL getkey					; get userInput
	CMP R0, #'y'				; if (userInput == y){
	BNE startSolving
	
	BL sendchar					; send userInput to console
	MOV R0, R6					;
	BL copyGrid					; copy chosen grid to tmp grid
	MOV R5, R0					;
	BL ClearScreen				; clear console
	LDR R0, =inputSystem		; load inputSystem string 
	BL displayString			; display inputSystem 
	MOV R0, R6					; set up grid as parameter
	BL display					; display grid
	MOV R0, R6					; set up grid as parameter
	MOV R1, R5					; give amount of original coordinates in grid
	BL takeInputs				; get the user to input the numbers into the grid}

startSolving					; else {
	BL sendchar					; send userInput to console
	BL ClearScreen				; clear console
	MOV R0, R6					; set up grid as parameter
	MOV R1, #0					; x = 0
	MOV R2, #0					; y = 0
	MOV R3, #0					; for counter = 0
	BL sudoku					; solve sudoku
	CMP R0, #0					; if (solved != true) {
	BEQ printAnswer
	
	LDR R0, =error				; load error string
	BL displayString			; display error
	
	LDR R0, =tmpGrid			; get tmp grid with copy of original grid
	MOV R1, #0					; x = 0
	MOV R2, #0					; y = 0
	MOV R3, #0					; for counter = 0
	BL sudoku					; solve
	LDR R0, =tmpGrid			; 
	BL display					; display grid
	MOV R0, #0x0A				; new line
	BL sendchar					;
	LDR R0, =correct			; load correct string
	BL displayString			; display correct
	B stop						; }

printAnswer						; else {
	BL ClearScreen				; clear screen
	LDR R0, =correct			; load corrext string
	BL displayString			; display correct
	MOV R0, R6					; set up grid as parameter
	BL display					; display solved grid}
	
stop	B	stop



; getSquare subroutine (2D)
; returns R3 = element at given coordinates
; parameters R0 = starting address of grid, R1 = row number, R2 = column number
getSquare
	STMFD sp!,{R4-R10,LR}		;
	MOV R4, R0					; array start adr
	MOV R5, R1					; row number
	MOV R6, R2					; column number
	MOV R7, #9					; number of rows
	MOV R8, #9					; number of columns
	MUL R9, R5, R7				;
	ADD R9, R9, R6				; get index of element
	LDRB R10, [R4, R9]			; get element
	MOV R3, R10					; put element in parameter
	LDMFD sp!,{R4-R10,pc}

; setSquare subroutine (2D)
; returns void
; parameters R0 = starting address of grid, R1 = row number, R2 = column number, R3 = number to be placed
setSquare
	STMFD sp!,{R4-R10,LR}		;
	MOV R4, R0					; array start adr
	MOV R5, R1					; row number
	MOV R6, R2					; column number
	MOV R10, R3					; number to be placed
	MOV R7, #9					; number of rows
	MOV R8, #9					; number of columns
	MUL R9, R5, R7				;
	ADD R9, R9, R6				; get index of where the element is to be stored
	STRB R10, [R4, R9]			; store element
	LDMFD sp!,{R4-R10,pc}


; displayString subroutine
; returns void
; parameters R0 = starting address of string
displayString
	STMFD SP!, {R4, R5, LR};
	MOV R4, R0; 
	
displayStringLoop
	LDRB R5, [R4], #1			; load char, adr++
	CMP R5, #0					; if (char != 0){
	BEQ endDisplayString		; 
	MOV R0, R5					; display the char
	BL sendchar					; }
	B displayStringLoop; 

endDisplayString
	LDMFD SP!, {R4, R5, PC};


; isValid subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R0 = starting address of grid
isValidAll
	STMFD SP!, {R4-R7, LR}		;
	MOV R4, R0					; load grid address
	MOV R5, R1					; saving row number
	MOV R6, R2					; saving column number
	
	MOV R0, R4					; set up parameters
	MOV R1, R5					;
	MOV R3, #1					; checkRow = true
	BL isValidRowAndCol			; check rows
	CMP R0, #0					; if invalid end 
	BNE endIsValid
	
	MOV R0, R4					; set up parameters
	MOV R1, R6					;
	MOV R3, #0					; checkRow = false
	BL isValidRowAndCol			; check columns
	
	CMP R0, #0					; if invalid end
	BNE endIsValid
	
	MOV R0, R4					; set up parameters
	MOV R1, R5					;
	MOV R2, R6					;	 
	BL isValidBox				; check 3x3 grid

endIsValid
	LDMFD SP!, {R4-R7, pc}		;
		
	

; row and column is valid subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R0 = starting address of grid, R1 = to check row / to check column
isValidRowAndCol
	STMFD SP!, {R4-R12,LR}		;
	MOV R4, R0					; address of grid
	MOV R12, R3					; store true/false
	MOV R5, R1					; row/column number
	
	LDR R10, =arrayForUnique	; tmpArray address
	MOV R11, #0					; amount of values to be stored in tmpArray
	
	MOV R6, #0					; column/row number
	MOV R7, #0					; column/row counter

forGettingRowAndColArray
	ADD R7, R7, #1				; column/row counter++
	CMP R7, #9					; while (column/row counter != 9){
	BGT checkArray
	
	CMP R12, #1					; if (checkRow == true){
	BNE columnOne				;
	MOV R0, R4					; grid address
	MOV R1, R5					; column number
	MOV R2, R6					; row number
	BL getSquare				; get element at those coordinates
	B continueChecking			; } 

columnOne; else if (checkRow == false){
	MOV R0, R4; grid address
	MOV R1, R6; row number
	MOV R2, R5; column number
	BL getSquare; get element at those coordinates }
	
continueChecking	
	ADD R6, R6, #1; column/row number++
	MOV R9, R3; get element
	CMP R9, #0; if (element != 0){
	BEQ forGettingRowAndColArray
	ADD R11, R11, #1; amount of values in tmpArray++
	STRB R9, [R10], #1; store element }
	B forGettingRowAndColArray; }
	
checkArray
	LDR R0, =arrayForUnique; tmpArray address into parameter
	MOV R1, R11; amount of values in tmpArray into parameter
	BL compare; compare subroutine
	LDMFD SP!, {R4-R12, PC}
	

; box subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R0 = starting address of grid, R1 = current row; R2 = current column
isValidBox
	STMFD SP!,{R4-R6,LR};
	MOV R4, R0; starting address of grid
	MOV R5, R1; row coordinate
	MOV R6, R2; column coordinate
	
	MOV R1, R5; set up parameter
	BL getCoordinate;
	MOV R5, R1; return x
	
	MOV R1, R6; set up parameter
	BL getCoordinate;
	MOV R6, R1; return y
	
	MOV R0, R4; set up parameters, address of grid
	MOV R1, R5; x
	MOV R2, R6; y
	BL isUniqueBox; 
	LDMFD sp!,{R4-R6,pc};


; get the coordinates to check 3x3 box subroutine
; return R1 = coordinate 
; parameters R1 = x or y coordinate of position of element being placed
getCoordinate
	STMFD SP!, {R4, R5, LR}; 
	MOV R4, R1; x or y coordinate of position of element being placed
	MOV R5, #-3; quoient counter

loop				;do {
	ADD R5, R5, #3; counter+=3
	SUB R4, R4, #3; coordinate=-3 }
	CMP R4, #0; while (coordinate > 0)
	BGE	loop
	
	MOV R1, R5; set up coordinate
	LDMFD SP!, {R4, R5, PC}
	

; unique box subroutine
; returns void
; parameters R0 = starting address of grid
isUniqueBox
	STMFD sp!, {R4-R12,lr};
	MOV R12, R0; address of grid
	MOV R4, R1; x
	MOV R5, R2; y
	MOV R6, R2; y
	MOV R7, #0; row counter == 0
	LDR R9, =arrayForUnique;
	MOV R11, #0; tmp array counter

forRowUnique
	CMP R7, #3; if (row counter != 3){
	BEQ endOfGettingArray; 
	MOV R5, R6; reset y
	MOV R8, #0; column counter == 0 }

checkCol
	CMP R8, #3; if (column counter != 3){
 	BNE forColUnique; 
	ADD R7, R7, #1; row counter++
	ADD R4, R4, #1; x++ 
	B forRowUnique; 
	
forColUnique
	MOV R0, R12; set parameters, address of grid
	MOV R1, R4; x
	MOV R2, R5; y
	BL getSquare;
	ADD R5, R5, #1; column counter++
	CMP R3, #0; if (element at square coordinates != 0){
	BEQ cont
	ADD R11, R11, #1; tmp array counter++
	STRB R3, [R9], #1; element stored in tmp array }
	
cont
	ADD R8, R8, #1; column counter++ }
	B checkCol;

endOfGettingArray
	LDR R0, =arrayForUnique; set parameters, tmp array address
	MOV R1, R11; length of array
	BL compare

endOfUnique
	LDMFD sp!,{R4-R12,pc};
	

; unique array subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R0 = starting address of tmpArray, R1 = number of values in tmpArray
compare 
	STMFD sp!,{R4-R10,lr}; 
	MOV R4, R0; tmp array grid address
	MOV R5, R1; length of array
	MOV R10, R5; length of array
	MOV R0, #0; return value
	MOV R9, #0; counter

whileArrayUnique
	LDRB R7, [R4], #1; load digit to be checked against
	MOV R6, #0; counter
	SUB R5, R5, #1; length of array--
	CMP R5, #0; if (length of array > 0){
	BEQ endOfCompare
	
forArrayCheck
	LDRB R8, [R4, R6]; load digit to be checked
	ADD R6, R6, #1; counter++
	CMP R7, R8; if (digit to be checked against != digit to be checked){
	BEQ invalid; } 
	CMP R6, R5; if (counter != length of array){
	BEQ whileArrayUnique; }
	B forArrayCheck; }

invalid
	MOV R0, #1; isValid = false

; resets tmp array back to 0
endOfCompare
	LDR R4, =arrayForUnique; load tmp array address
	MOV R5, R10; length of array
	MOV R6, #0; element to replace 

forSetArray          ; do {
	STRB R6, [R4], #1; store 0 in tmp array
	SUB R5, R5, #1; length of array-- }
	CMP R5, #0; while (length of array > 0)
	BNE forSetArray; 	
	LDMFD sp!,{R4-R10,pc}; 
	
	
; taking inputs subroutine
; returns void
; parameters R0 = address of grid, R1 = amount of orignal coordinates
takeInputs
	STMFD SP!, {R4-R8,LR};
	MOV R4, R0; address of grid
	MOV R8, R1; amount of original coordinates
	
continueToTakeInputs
	MOV R0, #0x13; move cursor to bottom right of grid
	MOV R1, #0x13; 
	BL setCursorPosition; 
	BL getkey; get input
	BL getUserCoordinates; get x coordinate
	CMP R0, #10; if (result == 10){
	BEQ endAndSolve; check grid solution}
	MOV R5, R0; R5 = x
	BL getkey; get input
	BL getUserCoordinates; get y coordinate
	CMP R0, #10; if (result == 10){
	BEQ endAndSolve; check grid solution}
	MOV R6, R0; R6 = y
	MOV R1, R5;
	MOV R2, R6;
	MOV R3, R8;
	BL isNotOriginalCoordinate
	CMP R0, #1
	BEQ continueToTakeInputs
	
	BL getkey; get input
	CMP R0, #'n'; if (input == n){
	BEQ endAndSolve; check grid solution}
	
	BL sendchar; 
	MOV R7, R0; 
	SUB R7, R7, #'0'; number to be placed - 0x30
	
	MOV R1, R5; x
	MOV R2, R6; y
	MOV R3, R7; number to be placed
	MOV R0, R4; grid address
	BL setSquare; put number in square
	
	ADD R5, R5, #1; converting x to console coordinates
	ADD R0, R5, R5; 
	
	ADD R6, R6, #1; converting y to console coordinates
	ADD R1, R6, R6; 
	BL setCursorPosition; set cursor position
	ADD R7, R7, #'0'; number to be placed + 0x30
	MOV R0, R7; 
	BL sendchar; send number to console
	B continueToTakeInputs; 
	
endAndSolve
	MOV R0, #0x0A; 
	BL sendchar; next line
	MOV R0, R4; set up parameters, grid address
	MOV R1, #0; x = 0
	MOV R2, #0; y = 0
	BL sudoku; check the solution
	LDMFD SP!, {R4-R8, PC}
	

; convert ascii coordinates to decimal subroutine
; return R0 = coordinate in decimal
; parameters R0 = coordinate
getUserCoordinates
	STMFD SP!, {LR};
	BL sendchar;	
	SUB R0, R0, #0x41; ascii higher case letter to decimal
	CMP R0, #9; if (number > 8){
	BLT endOfGettingUserCoordinates;
	
sendUserWantingSolve;
	MOV R0, #10; return 10 }

endOfGettingUserCoordinates
	LDMFD SP!, {PC}


; check x/y arrays with x/y user coordinates subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R1 = user x, R2 = user y
isNotOriginalCoordinate
	STMFD SP!, {R4-R11, LR}
	MOV R4, R1; user x
	MOV R5, R2; user y
	MOV R6, R3; amount of original coordinates
	LDR R7, =tmpArrayX; original x values
	LDR R8, =tmpArrayY; original y values
	MOV R9, #-1; index
	MOV R11, #1; result = false
	
forNotOriginalCoordinateX; for (index = -1; index < 9; index++) {
	ADD R9, R9, #1; 
	CMP R9, R6; 
	BEQ preEndOfNotOriginalCoordinate; 
	LDRB R10, [R7, R9]; load original x at position index
	CMP R10, R4; if (original x == user x) {
	BNE forNotOriginalCoordinateX
	
checkNotOriginalCoordinateY
	LDRB R10, [R8, R9]; load original y at position index
	CMP R10, R2; if (original y != user y) {
	BEQ endOfNotOriginalCoordinate; continue with for loop }
	B forNotOriginalCoordinateX; }

preEndOfNotOriginalCoordinate; 
	MOV R11, #0; result = true
	
endOfNotOriginalCoordinate
	MOV R0, R11; return result
	LDMFD SP!, {R4-R11, PC};  


; sudoku solver subroutine
; returns R0 = 0 (true) / R0 = 1 (false)
; parameters R0 = grid address, R1 = x, R2 = y, R3 = counter in for loop
sudoku
	STMFD SP!, {R4-R9,R12,LR}
	MOV R4, R0; grid address
	MOV R5, R1; next x
	MOV R6, R2; next y
	MOV R9, R3; set counter in for loop to 0
	MOV R12, #1; result = FALSE
	
	MOV R7, R5; next row = row
	ADD R8, R6, #1; next column = column++ 
	CMP R8, #9; if (next column > 8){
	BNE continueOn; 
	MOV R8, #0; next column = 0
	ADD R7, R7, #1; next row++}
	
continueOn
	MOV R0, R4; set parameters, grid address
	MOV R1, R5; x
	MOV R2, R6; y
	BL getSquare; 
	CMP R3, #0; if (element != 0){
	BEQ elseIfZero; 
	
	CMP R5, #8; if (row == 8 && column == 8){
	BNE elseIfNotEnd
	CMP R6, #8; 
	BNE elseIfNotEnd
	
	MOV R12, #0; result = true
	MOV R0, R12; 
	B trueEndOfSudoku; end}
	
elseIfNotEnd; else {
	MOV R0, R4; set parameters, grid address
	MOV R1, R7; next row
	MOV R2, R8; next column
	MOV R3, #0; for counter = 0
	BL sudoku; recursion}
	B endOfSudoku
	
	
elseIfZero
	CMP R12, #0; if (result == false){
	BEQ endOfForLoop
	CMP R0, #0;  
	BEQ endOfForLoop
	ADD R9, R9, #1; for counter++
	CMP R9, #9;  if (for counter <= 9){
	BGT endOfForLoop
	MOV R0, R4; set parameters, grid address
	MOV R1, R5; next row
	MOV R2, R6; next column
	MOV R3, R9; keep track of the for counter
	BL setSquare; set square
	BL isValidAll; check if that is valid
	CMP R0, #1; if (valid){
	BEQ elseIfZero
	
	CMP R5, #8; see if end
	BNE elseIfNotEnd2
	CMP R6, #8; 
	BNE elseIfNotEnd2
	MOV R12, #0; if (end){
	MOV R0, R12; result = true
	B trueEndOfSudoku; }
	
elseIfNotEnd2; else {
	MOV R0, R4; set parameters, grid address
	MOV R1, R7; next row
	MOV R2, R8; next column
	MOV R3, #0; for counter = 0
	BL sudoku; recursion}
	B elseIfZero
	
endOfForLoop
	CMP R12, #0; if (result != true){
	BEQ endOfSudoku
	CMP R0, #0; 
	BEQ endOfSudoku
	MOV R9, #0; for counter = 0
	MOV R0, R4; set parameters, grid address  
	MOV R1, R5; row
	MOV R2, R6; column
	MOV R3, #0; number to be placed
	BL setSquare; backtrack and set that square to 0}

endOfSudoku
	MOV R12, R0; save result (true/false)
	LDMFD SP!, {R4-R9,R12, PC}

trueEndOfSudoku
	LDMFD SP!, {R4-R9,R12, PC}
	
	
; display grid subroutine
; returns void
; paramaters R0 = grid address
display
	STMFD SP!, {R4-R8, LR}
	MOV R4, R0; 
	MOV R7, #0; row counter = 0
	
forRowDisplay
	MOV R8, #0; 
	LDR R5, =gridLinesH; load horizontal grid lines
	LDR R6, =gridLinesV; load vertical grid lines
	CMP R7, #0; 
	BEQ preForColDisplay; 
	MOV R0, #0x0A; 
	BL sendchar
	
whileDisplayingRow; while (char != 0){	
	LDRB R0, [R5], #1; load char at horizontal grid line address
	CMP R0, #0; display char
	BEQ preForColDisplay;
	BL sendchar;
	B whileDisplayingRow; }

preForColDisplay
	MOV R0, #0x0A;
	BL sendchar; new line
forColDisplay; do {
	LDRB R0, [R6], #1; 
	BL sendchar; display vertical line
	MOV R0, R4; set parameters, grid address
	MOV R1, R7; x
	MOV R2, R8; y
	BL getSquare; get element at those coordinates
	MOV R0, R3;
	ADD R0, R0, #'0'; convert hexadecimal to ascii
	BL sendchar; display on console
	ADD R8, R8, #1; column counter++ }
	CMP R8, #9; while (column counter != 9)
	BNE forColDisplay
	ADD R7, R7, #1; row counter++
	CMP R7, #9; if (row counter != 9){
	BNE forRowDisplay; new row}
		
	MOV R0, #0x0A; else {
	BL sendchar; new line
	LDR R5, =gridLinesH; load horizontal grid lines
whileDisplayingRow2; while (char != 0){	
	LDRB R0, [R5], #1; load char at horizontal grid line address
	CMP R0, #0; 
	BEQ endOfDisplay; 
	BL sendchar; display char
	B whileDisplayingRow2; }

endOfDisplay
	LDMFD SP!, {R4-R8, PC}
	
	
; copy grid subroutine
; returns R0 = amount of coordinates
; parameters R0 = grid address
copyGrid
	STMFD SP!, {R4-R10,LR}
	MOV R4, R0; grid address
	MOV R5, #0; x
	MOV R6, #0; y
	LDR R7, =tmpGrid; tmp grid
	LDR R8, =tmpArrayX; 
	LDR R9, =tmpArrayY; 
	MOV R10, #0; amount of coordinate values
	B startCopying

increaseX; for (x < 9){
	ADD R5, R5, #1; x++
	CMP R5, #9; 
	BEQ finishedCopying
	MOV R6, #0; y = 0
	
startCopying; do {
	MOV R0, R4; set parameters, grid address
	MOV R1, R5; x
	MOV R2, R6; y
	BL getSquare; get element 
	CMP R3, #0; if (element != 0){
	BEQ continueCopying; 
	ADD R10, R10, #1
	STRB R5, [R8], #1
	STRB R6, [R9], #1
	MOV R0, R7; set element in tmp grid
	BL setSquare; }
	
continueCopying
	ADD R6, R6, #1; y++ }
	CMP R6, #9;  
	BEQ increaseX; while (y < 9)
	B startCopying; }
	
finishedCopying
	MOV R0, R10;
	LDMFD SP!, {R4-R10,PC}
	
	AREA	Grids, DATA, READWRITE

gridOne
		DCB	7,9,0,0,0,0,3,0,0
    	DCB	0,0,0,0,0,6,9,0,0
    	DCB	8,0,0,0,3,0,0,7,6
    	DCB	0,0,0,0,0,5,0,0,2
    	DCB	0,0,5,4,1,8,7,0,0
    	DCB	4,0,0,7,0,0,0,0,0
    	DCB	6,1,0,0,9,0,0,0,8
    	DCB	0,0,2,3,0,0,0,0,0
    	DCB	0,0,9,0,0,0,0,5,4
	
gridTwo
		DCB 7,0,0,6,2,0,9,0,0
		DCB 0,0,3,0,9,8,0,0,1
		DCB 0,9,8,7,0,0,0,6,0
		DCB 0,0,7,0,0,0,0,5,0
		DCB 9,0,0,0,0,0,0,0,4
		DCB 0,3,0,0,0,0,1,0,0
		DCB 0,8,0,0,0,4,2,1,0
		DCB 1,0,0,9,6,0,3,0,0
		DCB 0,0,2,0,7,1,0,0,5
		
gridThree
		DCB	0,2,0,1,0,0,8,0,0
		DCB 0,0,9,2,0,0,5,0,0
		DCB 8,5,0,0,3,0,0,1,0
		DCB 0,0,0,0,0,0,0,4,0
		DCB 1,0,0,5,0,9,0,0,2
		DCB 0,3,0,0,0,0,0,0,0
		DCB 0,9,0,0,6,0,0,5,3
		DCB 0,0,4,0,0,3,9,0,0
		DCB 0,0,3,0,0,1,0,2,0
		
gridFour
		DCB 4,0,0,9,0,0,0,0,0
		DCB 0,9,0,0,0,0,0,7,0
		DCB 0,0,8,0,0,7,1,4,0
		DCB 0,0,3,0,5,0,0,0,0
		DCB 9,0,0,3,1,2,0,0,8
		DCB 0,0,0,0,8,0,9,0,0
		DCB 0,3,5,2,0,0,7,0,0
		DCB 0,4,0,0,0,0,0,6,0
		DCB 0,0,0,0,0,1,0,0,2
		
gridFive
		DCB 0,5,8,0,0,4,3,0,0
		DCB 0,0,0,0,0,0,8,0,7
		DCB 1,9,0,0,7,0,0,0,0
		DCB 0,0,3,0,0,8,0,5,0
		DCB 4,0,0,0,0,0,0,0,9
		DCB 0,2,0,9,0,0,1,0,0
		DCB 0,0,0,0,8,0,0,1,3
		DCB 6,0,7,0,0,0,0,0,0
		DCB 0,0,9,5,0,0,7,2,0
				
tmpGrid
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		
arrayForUnique
		DCB 0,0,0,0,0,0,0,0,0
	

tmpArrayX
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0	
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		
tmpArrayY
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0		

gridLinesV
		DCB "||||||||||||",0 
		
gridLinesH
		DCB "------------------",0
		
greeting
	DCB "Hello, which grid would you like to solve/like to see solved: 1, 2, 3, 4, or 5?", 0
	
query
	DCB "Would you like to solve it? y/n",0
	
inputSystem
	DCB "The coordinate system works as follows: AA = 1,1 etc, A-I are accepted inputs, type 'n' to check your solution",0
	
error
	DCB "Sorry that is not the correct solution.",0
	
correct
	DCB "This is the correct solution.",0
	
	END