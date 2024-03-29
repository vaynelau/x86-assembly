STACK 	SEGMENT	PARA	STACK
		DW		100H DUP(?)
STACK	ENDS

DATA	SEGMENT	PARA             
	X		DW 	8
	Y		DW  8
	S1	DB	'Hail Hydra!',00H,'$'
	S2	DB	'Wakanda Forever!',00H,'$'
	S2_PH	DB	128 DUP(0)
	CHAR 	DB	'l'
	OP 		DB 	0
	MSG_S2	DB	'S2=','$'
	MSG_EQ 	DB 	'S1=S2',0DH,0AH,'$'
	MSG_GT 	DB 	'S1>S2',0DH,0AH,'$'
	MSG_LT  DB	'S1<S2',0DH,0AH,'$'
	MSG_FOUND DB	'CHAR FOUND IN S1',0DH,0AH,'$'
	MSG_NOT_FOUND DB 'CHAR NOT FOUND IN S1',0DH,0AH,'$'
    NEW_LINE DB     0DH,0AH,'$'
    JMP_TABLE DW	MULTI,STRCPY,STRCMP,LOOKUP,STRCAT,MULTI2,STRCPY2,STRCMP2,LOOKUP2,STRCAT2
DATA 	ENDS

CODE 	SEGMENT PARA
		ASSUME	CS:CODE,DS:DATA,SS:STACK


DISP_MSG    MACRO   MSG
		PUSH  	DX
		PUSH 	AX
		MOV     DX,OFFSET MSG
		MOV     AH,9
		INT     21H
		POP 	AX
		POP	 	DX
ENDM


GET_OP 	MACRO
		MOV 	AH,1
		INT 	21H
		MOV 	OP,AL
		ENDM


DISP_VALUE PROC
		PUSH 	DX
		PUSH 	CX
		PUSH	BX
		PUSH 	AX

		MOV 	CX,5
		MOV 	BX,10

DLP1:
		XOR 	DX,DX
		DIV 	BX
		PUSH 	DX
		LOOP 	DLP1

		MOV 	BX,0
		MOV 	CX,5
DLP2:
		POP 	DX
		CMP 	DL,0
		JNZ 	DLP2_1
		CMP 	BX,0
		JZ 		DLP2_2
DLP2_1:
		MOV 	BX,1
		OR 		DL,30H
		MOV 	AH,2
		INT  	21H
DLP2_2:
		LOOP 	DLP2

		DISP_MSG NEW_LINE
		POP 	AX
		POP 	BX
		POP 	CX
		POP 	DX
		RET
DISP_VALUE ENDP


MULTI PROC
		PUSH 	BP
		MOV 	BP,SP
		PUSH 	BX

		MOV 	AX,[BP+4]
		MOV 	BX,[BP+6]
		MUL 	BX

		POP 	BX
		POP 	BP
		RET 	4
MULTI ENDP


MULTI2 PROC
		MUL 	DX
		RET
MULTI2 ENDP


STRCPY PROC
		PUSH 	BP
		MOV 	BP,SP
		PUSH 	DI 
		PUSH 	SI

		MOV 	SI,[BP+4]
		MOV		DI,[BP+6]
		CALL 	STRCPY2

		POP 	SI
		POP 	DI
		POP 	BP
		RET 	4
STRCPY ENDP


STRCPY2 PROC
		PUSH	AX
		CLD
COPY:
		LODSB
		STOSB
		CMP 	AL,'$'
		JNZ 	COPY

		DISP_MSG MSG_S2
		DISP_MSG S2
		DISP_MSG NEW_LINE
		POP		AX
		RET
STRCPY2 ENDP


STRCMP 	PROC
		PUSH 	BP
		MOV 	BP,SP
		PUSH 	DI
		PUSH 	SI

		MOV 	SI,[BP+4]
		MOV 	DI,[BP+6]
		CALL 	STRCMP2

		POP 	SI
		POP 	DI
		POP 	BP
		RET 	4
STRCMP 	ENDP


STRCMP2 PROC
        CLD
CMP_NEXT:
        CMPSB
        JNZ     CMP_END
        CMP     BYTE PTR [SI],'$'
        JZ      CMP_END
        JMP     CMP_NEXT
CMP_END:
		JA 		L2_1
		JB 		L2_2

		DISP_MSG MSG_EQ
		JMP 	SHORT CMP_RET
L2_1:
		DISP_MSG MSG_GT
		JMP 	SHORT CMP_RET
L2_2:
		DISP_MSG MSG_LT
CMP_RET:
		RET
STRCMP2 ENDP


LOOKUP PROC
		PUSH 	BP
		MOV	 	BP,SP
		PUSH	DI
		PUSH	AX

		MOV 	DI,[BP+6]
		MOV 	AX,[BP+4]
		CALL 	LOOKUP2

		POP		AX
		POP		DI
		POP 	BP
		RET		4
LOOKUP ENDP


LOOKUP2 PROC
		CLD
SC_NEXT:
		SCASB
		JZ 		FOUND
		CMP     BYTE PTR [DI],0
		JNZ		SC_NEXT

		DISP_MSG MSG_NOT_FOUND
		JMP 	SHORT LOOKUP_RET
FOUND:
		DISP_MSG MSG_FOUND
LOOKUP_RET:
		RET
LOOKUP2 ENDP


STRCAT PROC
		PUSH 	BP
		MOV 	BP,SP
		PUSH 	DI
		PUSH 	SI

		MOV 	SI,[BP+4]
		MOV 	DI,[BP+6]
		CALL 	STRCAT2

		POP 	SI
		POP 	DI
		POP 	BP
		RET 	4
STRCAT ENDP

STRCAT2 PROC
		PUSH	AX
		CLD
		MOV		AX,0
SC_LOOP:
		SCASB
		JNZ		SC_LOOP
		DEC		DI
CAT_COPY:
		LODSB
		STOSB
		CMP 	AL,'$'
		JNZ 	CAT_COPY

		DISP_MSG MSG_S2
		DISP_MSG S2
		DISP_MSG NEW_LINE
		POP		AX
		RET
STRCAT2 ENDP


MAIN	PROC 	FAR
		MOV 	AX,DATA
		MOV 	DS,AX
		MOV 	ES,AX

MAIN_LOOP:
		GET_OP
		DISP_MSG NEW_LINE
CASE_A:
		CMP 	OP,'A'
		JNE		CASE_B
		PUSH 	X
		PUSH 	Y
		MOV 	DX,OFFSET NEXT_A
		PUSH	DX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,0
		MOV 	BX,[BX]
		JMP 	BX
NEXT_A:		
		CALL 	DISP_VALUE
		JMP 	CONTINUE
CASE_B:
		CMP 	OP,'B'
		JNE		CASE_C
		MOV 	DX,OFFSET S2
		PUSH 	DX
		MOV 	DX,OFFSET S1
		PUSH 	DX
		MOV 	DX,OFFSET NEXT_B
		PUSH	DX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,2
		MOV 	BX,[BX]
		JMP 	BX
NEXT_B:
		JMP 	CONTINUE
CASE_C:
		CMP 	OP,'C'
		JNE		CASE_D
		MOV 	DX,OFFSET S2
		PUSH 	DX
		MOV 	DX,OFFSET S1
		PUSH 	DX
		MOV 	DX,OFFSET NEXT_C
		PUSH	DX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,4
		MOV 	BX,[BX]
		JMP 	BX
NEXT_C:
		JMP 	CONTINUE
CASE_D:
		CMP 	OP,'D'
		JNE		CASE_E
		MOV 	DX,OFFSET S1
		PUSH 	DX
		MOV 	DL,CHAR
		XOR 	DH,DH
		PUSH 	DX
		MOV 	DX,OFFSET NEXT_D
		PUSH	DX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,6
		MOV 	BX,[BX]
		JMP 	BX
NEXT_D:
		JMP 	CONTINUE
CASE_E:
		CMP 	OP,'E'
		JNE		CASE_aa
		MOV 	DX,OFFSET S2
		PUSH 	DX
		MOV 	DX,OFFSET S1
		PUSH 	DX
		MOV 	DX,OFFSET NEXT_E
		PUSH	DX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,8
		MOV 	BX,[BX]
		JMP 	BX
NEXT_E:
		JMP 	CONTINUE
CASE_aa:
		CMP 	OP,'a'
		JNE		CASE_bb
		MOV 	AX,X
		MOV 	DX,Y
		MOV 	BX,OFFSET NEXT_aa
		PUSH	BX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,10
		MOV 	BX,[BX]
		JMP 	BX
NEXT_aa:
		CALL 	DISP_VALUE
		JMP 	CONTINUE
CASE_bb:
		CMP 	OP,'b'
		JNE		CASE_cc
		MOV	 	SI,OFFSET S1
		MOV 	DI,OFFSET S2
		MOV 	BX,OFFSET NEXT_bb
		PUSH	BX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,12
		MOV 	BX,[BX]
		JMP 	BX
NEXT_bb:
		JMP 	CONTINUE
CASE_cc:
		CMP 	OP,'c'
		JNE		CASE_dd
		MOV 	SI,OFFSET S1
		MOV 	DI,OFFSET S2
		MOV 	BX,OFFSET NEXT_cc
		PUSH	BX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,14
		MOV 	BX,[BX]
		JMP 	BX
NEXT_cc:
		JMP 	CONTINUE
CASE_dd:
		CMP 	OP,'d'
		JNE		CASE_ee
		MOV	 	DI,OFFSET S1
		MOV 	AL,CHAR
		MOV 	BX,OFFSET NEXT_dd
		PUSH	BX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,16
		MOV 	BX,[BX]
		JMP 	BX
NEXT_dd:
		JMP 	CONTINUE
CASE_ee:
		CMP 	OP,'e'
		JNE		CONTINUE
		MOV 	SI,OFFSET S1
		MOV 	DI,OFFSET S2
		MOV 	BX,OFFSET CONTINUE
		PUSH	BX
		MOV		BX,OFFSET JMP_TABLE
		ADD		BX,18
		MOV 	BX,[BX]
		JMP 	BX
CONTINUE:
		CMP 	OP,'q'
		JZ 		EXIT
		JMP 	MAIN_LOOP
EXIT:
		MOV 	AX,4C00H
		INT 	21H
MAIN 	ENDP

CODE 	ENDS
		END 	MAIN