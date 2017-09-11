$include (C8051F310.inc)
	
		  ORG   0000H

    	  LJMP  MAIN  



;--------T0��ʱ�����ж����---------
;ÿ��1ms�����жϣ��������ѭ��ѡͨ
          ORG   000BH            ;--


          LJMP  display			 ;--
;----------------------------------- 

;--------T1��ʱ�����ж����---------
;�����жϣ��������
;ÿ0.5ms����һ���ж�
          ORG   001BH            ;--

		  ljmp T1J				 ;--������ʱ�ж�1�������
		  		
;----------------------------------- 


;--------T2��ʱ�����ж����---------
;��ʱ�жϣ����ݲ�ͬ��ģʽ���ṩ��ͬ����ʱ
          ORG   002BH            ;--
		  CLR  TF2H				 ;����жϱ�־λ

	   	  LJMP  T2INTU			 ;--������ʱ�ж�2�������
;----------------------------------

;--------T3��ʱ�����ж����---------
;ÿ��0.25s����һ���ж�
          ORG   0073H            ;--
		  anl  91H,#7FH			 ;����жϱ�־λ
		  MOV PCA0CPM0,21H		 ;��21H��ֵ����PCAOCPM0
	   	  LJMP  T3CHULI			 ;--������ʱ�ж�3�������
;----------------------------------



;----------------T3��ʱ���жϳ���-----
T3CHULI: JB P2.2,light 			 ;�ж��Ƿ��й�
		 setb 01H				 ;���־λ��1

		 mov 44H,#30			 ;��ʱ��������30
		 CLR TR2				 ;�رռ�����2
		 RETI
LIGHT:	 CLR 01H				 ;������־λ
		 SETB TR2			 	 ;����������2
		 RETI		  
;--------------------------------------


;----------------T2��ʱ���жϳ���(100ms)-----
T2INTU:
		JB 10H,T2L0				  ;ģʽ0��1��Ӧ�ļ�����ʱ����
		JB 11H,T2L0
		JB 12H,T2L2				  ;ģʽ2��Ӧ�ļ�����ʱ����
T2L0:   ljmp t2l0p
T2L2:   ljmp t2l2p



;--------;ģʽ0��1��Ӧ�ļ�����ʱ����-----------
;44H30�ν���T2����3���ڶ��й⣬��رյƹ�------
t2l0p:  DJNZ 44h,rt2l0					;======
		clr 0EH							;======
		mov 44H,#30						;======
		reti							;======
rt2l0:									;======
		RETI							;======
;----------------------------------------======


;--------;ģʽ2��Ӧ�ļ�����ʱ����-----------
;45H100�ν���T2������ʱ10s��رյƹ�------
t2l2p:  							   ;======
		DJNZ 45h,rt2l2				   ;======
		clr 0EH						   ;======
		MOV PCA0CPM0,21H			   ;======
		mov 44H,#30					   ;======
		reti						   ;======
rt2l2:								   ;======
		RETI						   ;======
;--------------------------------------=======








;--------------------------------------------- ----------
NOJIANCE:setb psw.3			 ;�������������,1s��ȥ�����״̬
		 setb psw.4		  
		 INC R3
		 CJNE R3,#0,T11
		 INC R2
T11:	 cjne r2,#007H,T1R
		 cjne r3,#0D0H,T1R
		 MOV R3,#00H
		 MOV R2,#0
		 SETB 03H
T1R:	 CLR PSW.3
		 clr psw.4
		 CLR 04H
		 CLR 05H
		 RETI
;----------------------------------------------------



;------����˵��������---------------------------=
;-----�����ھ�û��������������������״̬-----
XIAOCHUNV:setb psw.3
		  setb psw.4
		  INC R6
		  CJNE R6,#00,TR7
		  INC R7
TR7:	  CJNE R7,#00FH,T1R
		  CJNE R6,#0A0H,T1R
		  MOV R7,#0
		  CLR 06H
		  MOV R0,#0
		  MOV R4,#0
		  CLR 05H
		  sjmp t1r
;---------------------------------------------==


;---------------------------------------------------------
;--------------T1��ʱ���жϳ���-------------------------
;---------------����������----------------------------
;-----------------------------------------------------------

t1j:     JNB 03H,NOJIANCE	   ;���а�����1���ڲ��������
		 SETB PSW.3			   ;����ʼ��⣬�任�����Ĵ�����
		 CLR PSW.4
		 INC R4				   ;R4+1
JIANCE:	 JB P2.1,havevoice	   ;����Ƿ�������
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice


NOVOICE: JB 06H,XIAOCHUNV		 ;��06HΪ1������Ϊ������־λδ������������������
		 JnB 05h,nov3			 ;��һֱû������������λ05HΪ0����ֱ������
		 CLR PSW.4				 ;ѡ�������Ĵ���1
		 SETB PSW.3				 
		 JNB 04H,T3R2			 ;��������Ч��R2��R3���������1.2���ڶ�û������	��������Ч���
		 INC R2
		 CJNE R2,#0,T2R
		 INC R3
T2R:	 CJNE R3,#09H,NOV1
		 cjne R2,#060H,NOV1
		 SJMP OUTEN
T3R2:	 CJNE R4,#200,nov2		 
		 JC NOV1
nov2:	 mov r0,#0
		 mov r4,#0
		 CLR 04H
		 CLR 05H
		 mov R2,#0
		 mov r3,#0
NOV1:	 CLR PSW.3				   ;��ԭ�����Ĵ���0
		 CLR PSW.4
		 RETI
NOV3:	 mov r4,#0
		  CLR PSW.3				   ;��ԭ�����Ĵ���0
		 CLR PSW.4
		 RETI

;-----------������Ч����LED���п���--------
OUTEN:    MOV R3,#0
		  MOV R2,#0
		  mov R4,#0
		  MOV R0,#0
		  CLR 05H
		  CLR 04H
		  JB 0EH,off
		  JNB 01H,T3R0
		  SETB 0EH
		  SETB 00H
T3R0:	  CLR PSW.3
		  CLR PSW.4
		  RETI
off:	  MOV PCA0CPM0,#02H		   ;�ر�
		  CLR 0EH
		  CLR 00H
		  CLR PSW.3
		  RETI
;-----------------------------------------


havevoice:JB 06H,XIAOCHUV
		  setb 05H
		  SETB 04H
		  CLR PSW.4				 ;ѡ�������Ĵ���1
	 	  SETB PSW.3		   
		  CJNE R4,#200,T3C1	  ;	��R4����200ʱ��������������Ϊ������Ч
T3C1:	  JNC NOV			  ;R4����200ʱ������NOV
		  CLR PSW.3			  ;�����ж�
		  CLR PSW.4
		  RETI
NOV:	  SETB 06H		  ;����������0.1s����������������Ч ,��Ҫ��������������������06H
		  CLR 04H		  ;��������0.1s����������������Ч,����������Чλ
		  MOV R0,#0
		  MOV R1,#0
		  MOV R4,#0
		  CLR PSW.3
		  RETI

;------------��˵����������������������������Ϊ˵����Ȼ����---------
XIAOCHUV: SETB PSW.3
		  SETB PSW.4
		  MOV R7,#00H	   ;��������
		  mov r6,#0
		  CLR PSW.3
		  CLR PSW.4
		  RETI
;-------------------------------------------------------------------------



;-----------------------------------
		  ORG 0500H
;---------------ģʽ0���̳���ת��ת��ַ--------------
KEY01:LJMP KEY1
KEY02:LJMP KEY2
KEY03:LJMP KEY3
KEY04:LJMP KEY4
;----------ģʽ0���̳���ת��ת��ַ---------		  
JUDGE:    LCALL DL1				;��ʱȥ��
		  JNB P2.4,KEY04		;��P2.4Ϊ0����˵��KI0���м����룬������1�жϵ���ת����
		  JNB P2.5,KEY03	    ;��P2.5Ϊ0����˵��KI1���м����룬������2�жϵ���ת����
		  JNB P2.6,KEY02	    ;��P2.6Ϊ0����˵��KI2���м����룬������3�жϵ���ת����
		  JNB P2.7,KEY01	    ;��P2.6Ϊ0����˵��KI2���м����룬������3�жϵ���ת����
		  JnB 10h,jnol1
		  setb tr1	
jnol1:	  LJMP LOOP				;����������
;-------------------------------------

;-----------------------������--------------------------
MAIN:     MOV SP,#60H			  ;��ջָ�븳ֵ
		  
		 LCALL  Init_Device	  ;�����������ļ�
		  

   ;--------------����ֵ--------------------
   		  MOV R2,#24			  ;R2����
		  MOV R1,#08H			  ;�洢�ռ��׵�ַ24H
CLEAR:	  MOV @R1,#00H			  ;����
		  INC R1				  ;R1=R1+1
		  DJNZ R2,CLEAR			  ;ѭ�����㹤���Ĵ���
	   	  MOV R0,#00H		
		  MOV R3,#00H
		  MOV 40H,#00H		
		  MOV 41H,#00H
		  MOV 42H,#00H
		  MOV 43H,#00H
		  MOV R2,#00H
		 
		  MOV TH0,#00H		
		  MOV TH0,#00H
		  MOV R5,#00H		
		  SETB TR0 				  ;������ʱ��0
		  ORL  91H,#04H			   ;������ʱ��3
		  MOV 20H,#0FFH
		  SETB 02H				  ;��ʾ����־λ��1
		  CLR 04H				  ;����������Чλ
		  clr 06H				  ;����������־λ
		  CLR 05H				  ;����������־λ
		  MOV 21H,#42H			  ;PCA0�ĵ�Ч��ַ��ֵ
		  MOV 22H,#00H
		  MOV 23H,#00H
		  MOV PCA0CPH0,#0FFH	  ;Ĭ��ռ�ձ���С

;------ģʽѡ�����
LOOP:	 ;-----ģʽ0----
 
		  mov R7,43h
		  CJNE R7,#00H,L1
		  MOV 22H,#01H		 ;ģʽ0��־λ��1
		  MOV 23H,#00H	   	  
		  ORL  91H,#04H		 ;�����������
		  SETB TR1
		  LJMP LOOP0

L1:		  CJNE R7,#01H,L2
		  MOV 22H,#02H		 ;ģʽ1��־λ��1
		  MOV 23H,#00H
		  CLR TR1
		  ORL  91H,#04H		 ;������عر�����
		  SETB 0EH
		  LJMP LOOP0

L2:		  CJNE R7,#02H,L3
		  MOV 22H,#04H			;ģʽ2��־λ��1
		  MOV 23H,#00H
		  clr tr1				;�رչ������
		  MOV PCA0CPM0,#02H
		  clr tr2
		  ANL  91H,#0FBH
		  LJMP LOOP2
 ;-------ģʽ����------
L3:		  CJNE R7,#03H,L4
		  MOV 22H,#00H
		  MOV 23H,#00H
		  clr TR1
		  LJMP LOOP2
L4:		  CJNE R7,#04H,L5
		  MOV 22H,#00H
		  MOV 23H,#00H
		  LJMP LOOP1
L5:		  CJNE R7,#05H,L6
		  MOV 22H,#00H
		  MOV 23H,#00H
		  LJMP LOOP1
L6:		  CJNE R7,#06H,L7
		  MOV 22H,#00H
		  MOV 23H,#00H
		  LJMP LOOP1
L7:		  CJNE R7,#07H,LOOP
		  MOV 22H,#00H
		  MOV 23H,#00H
		  LJMP LOOP1


;-----------------ģʽ0--------
LOOP0:	  
		  JNB P2.7,JUDGEL0	 ;��P2.7Ϊ0����˵��K4�����룬����4�жϵ���ת����
		  JNB P2.4,JUDGEL0	 ;��P2.4Ϊ0����˵��K1�����룬����1�жϵ���ת����
		  JNB P2.5,JUDGEL0	 ;��P2.5Ϊ0����˵��K2�����룬����2�жϵ���ת����
		  JNB P2.6,JUDGEL0	 ;��P2.6Ϊ0����˵��K3�����룬����3�жϵ���ת����
		  LJMP LOOP0
JUDGEL0:  clr tr1
          LJMP JUDGE




JUDGEL1:  
		  anl  91H,#7FH
		  LJMP JUDGE
LOOP1:	  JNB P2.7,JUDGEL1	 ;��P2.7Ϊ0����˵��K4�����룬������4�жϵ���ת����
		  JNB P2.4,JUDGEL1	 ;��P2.4Ϊ0����˵��K1�����룬������1�жϵ���ת����
		  JNB P2.5,JUDGEL1	 ;��P2.5Ϊ0����˵��K2�����룬������2�жϵ���ת����
		  JNB P2.6,JUDGEL1	 ;��P2.6Ϊ0����˵��K3�����룬������3�жϵ���ת����
		  LJMP LOOP


;----------------����-----------------


;-------------�������Ӽ�----------------------------
L1G1:      SETB 0EH
		   SJMP KEY1L1
KEY1:	   CLR 03H				;�رռ��������־λ	
		   JB 11H,L1G1			;Ϊ�˱��ֵ���һ��
KEY1L1:	CJNE R3,#99H,k1
		   SJMP W1
k1:		   MOV A, R3
		   NOP
		   ADD A,#01H	   ;A=A+1
		   NOP
		   DA A             ;������BCD��
		   NOP
		   MOV R3,A			;A����R3��������ʾ���ȵȼ�
		   NOP
W1:		   MOV A,R3
		   NOP
		   MOV DPTR,#TABLE		;����ı����ȵȼ�
		   NOP
		   MOVC A,@A+DPTR	
		   NOP
		   MOV PCA0CPH0,A  
		   NOP
		   MOV PCA0CPM0,21H 
		   CJNE R2,#5FH,RE1
W3:		   JB P2.7,W2
		   CJNE R2,#5FH,RE1		 ;�����������ٴν��밴��
		   MOV R4,#01H
		   LCALL DL0
		   SJMP KEY1


RE1:	   LCALL DL1		   ;��ʱȥ������ⰴ���Ƿ��ɿ�
		   INC R2
		   SJMP W3  	       ;��P2.7��Ϊ0��˵������δ�ɿ������¼��

W2:		   MOV R2,#00H			;����ģʽ1���򲻶�T1��ʱ�����д���
		   CLR 03H
		   jB 12H,K1L2
		  JnB 10h,K1nol1
		  setb tr1	
K1nol1:	  LJMP LOOP0		   ;����������
K1L2:	  LJMP LOOP2



 ;-------���ȼ��ټ�-------
L1G:	   CLR 0EH
		   SJMP w12
KEY2:	   CLR 03H			   ;�رռ��������־λ
			CJNE R3,#00H,k2	   ;Ϊ�˱��ֵ���һ��
			JB 11H,L1G
		   SJMP w12
k2:		   MOV A, R3
		   NOP
		   ADD A,#99H	   ;A=A+1	
		   NOP
		   DA A             ;������BCD��
		   NOP
		   MOV R3,A			 ;A����R3��������ʾ���ȵȼ�
		   NOP
W12:	   MOV A,R3
		   NOP
		   MOV DPTR,#TABLE	   ;����ı����ȵȼ�
		   NOP
		   MOVC A,@A+DPTR
		   NOP	
		   MOV PCA0CPH0,A
		   MOV PCA0CPM0,21H
		   NOP


		   CJNE R2,#5FH,RE12	 ;�����������ٴν��밴��
W32:	   JB P2.6,W22

		   CJNE R2,#5FH,RE12	  ;�����������ٴν��밴��
		   MOV R4,#01H
		   LCALL DL0
		   SJMP KEY2


RE12:	   LCALL DL1		   ;��ʱȥ������ⰴ���Ƿ��ɿ�
		   INC R2
		   SJMP W32  	        ;��P2.7��Ϊ0��˵������δ�ɿ������¼��
W22:	   MOV R2,#00H
		   LCALL DL1
		 jB 12H,K2L2
		  JnB 10h,K2nol1	   ;����ģʽ1���򲻶�T1��ʱ�����д���
		  setb tr1	
		   CLR 03H
K2nol1:	  LJMP LOOP0		   ;����������
K2L2:	   LJMP LOOP2



;-------------������ر�����ܼ�---------------------
kEY3:	   	CLR 03H
			JNB 02H,xianshi
		   CLR TR0
		   CLR 02H
		   MOV P1,#0FH
		   SJMP RE3
XIANSHI:   SETB TR0
		   SETB 02H

RE3:	   LCALL DL1		   ;��ʱȥ������ⰴ���Ƿ��ɿ�

		   JNB P2.5,RE3  	   ;��P2.5��Ϊ0��˵������δ�ɿ������¼��
		   JB 12H,K3L2
		  JnB 10h,K3nol1		;����ģʽ1���򲻶�T1��ʱ�����д���
		  setb tr1	
		   CLR 03H
K3nol1:	  LJMP LOOP0		   ;����������
 K3L2:    LJMP LOOP2
 ;-------------ģʽ�л�	��-----

KEY4:	   CLR 03H
		   INC 43H
		   MOV R0,43h
 		   MOV R7,43H
		   CJNE R7,#3,re4
		   MOV 43h,#0
		   MOV R0,43h
RE4:	   LCALL DL1		   ;��ʱȥ������ⰴ���Ƿ��ɿ�
		   JNB P2.4,RE4  	   ;��P2.5��Ϊ0��˵������δ�ɿ������¼��
		  JnB 10h,K4nol1		;����ģʽ1���򲻶�T1��ʱ�����д���
		  setb tr1	
		   CLR 03H
K4nol1:	   LJMP LOOP		   ;����������



;---------------ģʽ2----------------------------
 ;������Ӧ�İ�������
KEY01L2:LJMP KEY1
KEY02L2:LJMP KEY2
KEY03L2:LJMP KEY3
KEY04L2:LJMP KEY4
;----------ģʽ2���̳���ת��ת��ַ---------		  
JUDGEl2:    LCALL DL1				;��ʱȥ��
		  JNB P2.4,KEY04l2		;��P2.4Ϊ0����˵��K1�����룬����1�жϵ���ת����
		  JNB P2.5,KEY03L2	    ;��P2.5Ϊ0����˵��K2�����룬����2�жϵ���ת����
		  JNB P2.6,KEY02L2	    ;��P2.6Ϊ0����˵��K3�����룬����3�жϵ���ת����
		  JNB P2.7,KEY01L2	    ;��P2.6Ϊ0����˵��K4�����룬����4�жϵ���ת����
		 	
		  LJMP LOOP2				;����������


LOOP2:    JB P2.1,KONGZHI
	 	  JNB P2.7,JUDGEL2	 ;��P2.7Ϊ0����˵��K4�����룬����4�жϵ���ת����
		  JNB P2.4,JUDGEL2	 ;��P2.4Ϊ0����˵��K1�����룬����1�жϵ���ת����
		  JNB P2.5,JUDGEL2	 ;��P2.5Ϊ0����˵��K2�����룬����2�жϵ���ת����
		  JNB P2.6,JUDGEL2	 ;��P2.6Ϊ0����˵��K3�����룬����3�жϵ���ת����
		  sjmp loop2
KONGZHI:  JB  P2.2,LOOP2
		  MOV PCA0CPM0,#42H 
		  NOP
		  SETB TR2
		  LCALL DL1
		  mov  45h,#100		 
		  sjmp loop2



;---------------��ʱ����----------------
		ORG   2550H
DL1:	MOV   R7,  #10H
DLA:     MOV   R6,  #0FFH
DLB:    DJNZ  R6,  DLB
		DJNZ  R7,  DLA
 		RET

DL4:	MOV   R4,#05H
DL0:	MOV   R7,  #0FFH
DL:     MOV   R6,  #0FFH
DL6:    DJNZ  R6,  DL6		
		DJNZ  R7,  DL
		DJNZ  R4,DL0

 		RET	

;-------------------------------------------------
;-------------��ʾ����̬��ʾ����------------------
;-------------------------------------------------
display:   	CLR    C		 ;����Cλ
			CJNE R5,#02H,X1	 ;�ж�R5��02�Ĵ�С
			SJMP display2	 ;R5����2��ѡͨ�����2
X1:			JNC  display3	 ;cy=0������R5=3��ѡͨ�����3
		    CJNE R5,#01H,X0	 ;R5С��2������1���бȽ�
			SJMP display1	 ;R5����1��ѡͨ�����1
X0:			SJMP display0	 ;R5С��1��ѡͨ�����0


     ;----------�����0��ʾģʽ��λ-----
display0: MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  NOP
		  NOP
		  NOP
		  MOV A,#0FH		 ;����R0����λ
		  ANL A,R0			 ;��R0��A�������������R0����λ����A��
		  CLR ACC.4			 ;P0.7,P0.6���㣬ѡͨ�����0
		  CLR ACC.5		
		  MOV P1,A			 ;����õ�ֵ����P1�������0�õ���ʾ
		  MOV R5,#1			 ;R5��1����һ���жϵ�����ѡͨ�����1
		  RETI				 ;��ʱ��1�жϷ���
     ;--------------------------------------

     ;---------�����1��ʾģʽ��λ------
display1: MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  NOP
		  NOP
		  MOV A,#0F0H		 ;����R0����λ
		  ANL A,R0			 ;��R0��A�������������R0����λ����A��
		  SWAP A			 ;����A�еĸ���λ�͵���λ
		  CJNE A,#00H,light_l
		  MOV P1,#0fh
		  MOV R5,#2			 ;R5��0����һ���жϵ�����ѡͨ�����0
		  RETI				 ;��ʱ��1�жϷ���
light_l:  CLR ACC.5			 ;P0.7��0,P0.6��1��ѡͨ�������1
		  SETB ACC.4  
		  MOV P1,A
		  MOV R5,#2			 ;R5��2����һ���жϵ�����ѡͨ�����2
		  RETI				 ;��ʱ��1�жϷ���
     ;------------------------------------

     ;-----------�����3��ʾR3����λ----------
display2:  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  nop
		  NOP
		  NOP
		  MOV A,#0FH		 ;����R3����λ
		  ANL A,R3			 ;��R3��A�������������R3����λ����A��
		  
		  SETB ACC.5			 ;P0.7��1,P0.6��0��ѡͨ�������2
		  SETB ACC.4
		  MOV P1,A			 ;����õ�ֵ����P1�������2�õ���ʾ
		  MOV R5,#3			 ;R5��3����һ���жϵ�����ѡͨ�����3
		  RETI				 ;��ʱ��1�жϷ���
	 ;------------------------------------

	 ;-----------�����2��ʾ���ȸ���λ--------
display3: MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  MOV P1,#0FFH		 ;���������,����������ܴ�����ë��
		  NOP
		  NOP
		  NOP
		  MOV A,#0F0H		 ;����R3����λ
		  ANL A,R3			 ;��R3��A�������������R3����λ����A��
		  SWAP A			 ;����A�еĸ���λ�͵���λ
		  CJNE A,#00H,light_h
		  MOV P1,#3fh
		  MOV R5,#0			 ;R5��0����һ���жϵ�����ѡͨ�����0
		  RETI				 ;��ʱ��1�жϷ���
light_h:  CLR ACC.4		 ;P0.7��1,P0.6��1��ѡͨ�������3
		  SETB ACC.5
		  MOV P1,A			 ;����õ�ֵ����P1�������3�õ���ʾ
		  MOV R5,#0			 ;R5��0����һ���жϵ�����ѡͨ�����0
		  RETI				 ;��ʱ��1�жϷ���
	 ;-----------------------------------		  	  
	
;-----------------------------------------------
;----------���Ȳ��ұ�--------------------------------
      ORG  2800H

TABLE: DB  0FFH,0FEH,0FDH,0FCH,0FBH,0FAH,0F9H,0F8H,0F7H,0F6H
	   ORG 2810H
	   DB  0F5H,0F4H,0F3H,0F2H,0F1H,0F0H,0EFH,0EEH,0EDH,0ECH
	   ORG 2820H
	   DB  0EBH,0EAH,0E9H,0E8H,0E7H,0E6H,0E5H,0E4H,0E3H,0E2H
	   ORG 2830H

	   DB  0E0H,0DEH,0DCH,0DAH,0D8H,0D6H,0D4H,0D2H,0D0H,0CEH
	   ORG 2840H
	   DB  0CCH,0CAH,0C8H,0C6H,0C4H,0C2H,0C0H,0BEH,0BCH,0BAH
	   ORG 2850H
	   DB  0B8H,0B6H,0B4H,0B2H,0B0H,0AEH,0ACH,0AAH,0A8H,0A6H
	   ORG 2860H
	   DB  0A3H,0A0H,9DH,9AH,97H,94H,91H,8EH,8BH,88H
	   ORG 2870H
	   DB  85H,82H,7FH,7CH,79H,76H,73H,70H,6DH,6AH
	   ORG 2880H
	   DB  67H,64H,61H,5CH,5AH,57H,54H,51H,4DH,40H
	   ORG 2890H
	   DB  3aH,34H,2fH,28H,23H,1ch,17h,10h,08h,00H	
public  Init_Device

INIT SEGMENT CODE
    rseg INIT

; Peripheral specific initialization functions,
; Called from the Init_Device label
PCA_Init:
    mov  PCA0CN,    #040h
    anl  PCA0MD,    #0BFh
    mov  PCA0MD,    #000h
    mov  PCA0CPM0,  #042h
    ret

Timer_Init:
    mov  TMOD,      #022h
	mov  TL1,       #080h
	MOV TH1,#80h
    mov  TMR2RLL,   #04Fh
    mov  TMR2RLH,   #09Ch
    mov  TMR2L,     #04Fh
    mov  TMR2H,     #09Ch
	mov  TMR3RLL,   #008h
    mov  TMR3RLH,   #0f6h
    mov  TMR3L,     #008h
    mov  TMR3H,     #0f6h
    ret

    Port_IO_Init:
    ; P0.0  -  Skipped,     Open-Drain, Digital
    ; P0.1  -  Skipped,     Open-Drain, Digital
    ; P0.2  -  Skipped,     Open-Drain, Digital
    ; P0.3  -  Skipped,     Open-Drain, Digital
    ; P0.4  -  Skipped,     Open-Drain, Digital
    ; P0.5  -  Skipped,     Open-Drain, Digital
    ; P0.6  -  Skipped,     Open-Drain, Digital
    ; P0.7  -  Skipped,     Open-Drain, Digital

    ; P1.0  -  Skipped,     Open-Drain, Digital
    ; P1.1  -  Skipped,     Open-Drain, Digital
    ; P1.2  -  Skipped,     Open-Drain, Digital
    ; P1.3  -  Skipped,     Open-Drain, Digital
    ; P1.4  -  Skipped,     Open-Drain, Digital
    ; P1.5  -  Skipped,     Open-Drain, Digital
    ; P1.6  -  Skipped,     Open-Drain, Digital
    ; P1.7  -  Skipped,     Open-Drain, Digital
    ; P2.0  -  CEX0 (PCA),  Open-Drain, Digital
    ; P2.1  -  Unassigned,  Open-Drain, Digital
    ; P2.2  -  Unassigned,  Open-Drain, Digital
    ; P2.3  -  Unassigned,  Open-Drain, Digital

    mov  P0SKIP,    #0FFh
    mov  P1SKIP,    #0FFh
    mov  XBR1,      #041h
    ret

Interrupts_Init:
    mov  IT01CF,    #020h
	mov  EIE1,      #080h
    mov  IE,        #0AAh
    ret

; Initialization function for device,
; Call Init_Device from your main program
Init_Device:
    lcall PCA_Init
    lcall Timer_Init
    lcall Port_IO_Init
    lcall Interrupts_Init
    ret

end