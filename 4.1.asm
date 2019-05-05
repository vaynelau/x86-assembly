;多次查找并删除指定字符，每次都输出查找结果
STACK 	SEGMENT	PARA	STACK
		DW		100H DUP(?)
STACK	ENDS

DATA	SEGMENT	PARA
	S1				DB	'Hail Hydra! Hail Hydra!',00H,'$'
	CHAR			DB	'l'
	MSG_IN			DB	' in ','$'
	MSG_NOT_FOUND	DB	'Not found ','$'
    NEW_LINE 		DB	0DH,0AH,'$'
DATA 	ENDS

CODE 	SEGMENT PARA
		ASSUME	CS:CODE,DS:DATA,SS:STACK


PUT_CHAR 		MACRO	CHAR
        MOV     DL,CHAR
        MOV     AH,2
        INT     21H
ENDM


DISP_MSG		MACRO	MSG
		MOV     DX,OFFSET MSG
		MOV     AH,9
		INT     21H
ENDM


Find_ch PROC
		PUSH 	BP
		MOV	 	BP,SP
		PUSH	DI
		PUSH	SI
		PUSH	AX

FIND_START:
		MOV 	DI,[BP+6]
		MOV 	AX,[BP+4]

        CLD
SC_NEXT:
		SCASB
		JZ 		FOUND
		CMP     BYTE PTR [DI],0
		JNZ		SC_NEXT

		DISP_MSG	MSG_NOT_FOUND
		PUT_CHAR	CHAR
		DISP_MSG	MSG_IN
		DISP_MSG	S1
		DISP_MSG	NEW_LINE
		JMP			FIND_RET
FOUND:
		PUT_CHAR	CHAR
		DISP_MSG	MSG_IN
		DISP_MSG	S1
		DISP_MSG	NEW_LINE
		
		MOV			SI,DI
		DEC			DI
MOV_NEXT:
		MOVSB
		CMP			BYTE PTR [DI],'$'
		JNZ			MOV_NEXT

		JMP			FIND_START


FIND_RET:
		POP		AX
		POP		SI
		POP		DI
		POP 	BP
		RET		4
Find_ch ENDP

MAIN	PROC
		MOV 	AX,DATA
		MOV 	DS,AX
		MOV 	ES,AX

		MOV		DX,OFFSET S1
		PUSH	DX
		MOV		DL,CHAR
		XOR		DH,DH
		PUSH	DX
		CALL	Find_ch

		MOV 	AX,4C00H
		INT 	21H
MAIN	ENDP

CODE	ENDS
		END		MAIN