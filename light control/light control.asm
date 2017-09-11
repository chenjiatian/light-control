$include (C8051F310.inc)
	
		  ORG   0000H

    	  LJMP  MAIN  



;--------T0定时器的中断入口---------
;每隔1ms进入中断，对数码管循环选通
          ORG   000BH            ;--


          LJMP  display			 ;--
;----------------------------------- 

;--------T1定时器的中断入口---------
;进入中断，检测声音
;每0.5ms进入一次中断
          ORG   001BH            ;--

		  ljmp T1J				 ;--跳到定时中断1处理程序
		  		
;----------------------------------- 


;--------T2定时器的中断入口---------
;计时中断，根据不同的模式，提供不同的延时
          ORG   002BH            ;--
		  CLR  TF2H				 ;清除中断标志位

	   	  LJMP  T2INTU			 ;--跳到定时中断2处理程序
;----------------------------------

;--------T3定时器的中断入口---------
;每隔0.25s进入一次中断
          ORG   0073H            ;--
		  anl  91H,#7FH			 ;清除中断标志位
		  MOV PCA0CPM0,21H		 ;将21H的值赋给PCAOCPM0
	   	  LJMP  T3CHULI			 ;--跳到定时中断3处理程序
;----------------------------------



;----------------T3定时器中断程序-----
T3CHULI: JB P2.2,light 			 ;判断是否有光
		 setb 01H				 ;光标志位置1

		 mov 44H,#30			 ;延时计数器置30
		 CLR TR2				 ;关闭计数器2
		 RETI
LIGHT:	 CLR 01H				 ;清零光标志位
		 SETB TR2			 	 ;开启计数器2
		 RETI		  
;--------------------------------------


;----------------T2定时器中断程序(100ms)-----
T2INTU:
		JB 10H,T2L0				  ;模式0和1对应的计数延时程序
		JB 11H,T2L0
		JB 12H,T2L2				  ;模式2对应的计数延时程序
T2L0:   ljmp t2l0p
T2L2:   ljmp t2l2p



;--------;模式0和1对应的计数延时程序-----------
;44H30次进入T2，即3秒内都有光，则关闭灯光------
t2l0p:  DJNZ 44h,rt2l0					;======
		clr 0EH							;======
		mov 44H,#30						;======
		reti							;======
rt2l0:									;======
		RETI							;======
;----------------------------------------======


;--------;模式2对应的计数延时程序-----------
;45H100次进入T2，即延时10s后关闭灯光------
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
NOJIANCE:setb psw.3			 ;不检测声音程序,1s后去除这个状态
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



;------消除说话声程序---------------------------=
;-----两秒内均没有声音，才消除有噪声状态-----
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
;--------------T1定时器中断程序-------------------------
;---------------声音检测程序----------------------------
;-----------------------------------------------------------

t1j:     JNB 03H,NOJIANCE	   ;若有按键，1秒内不检测声音
		 SETB PSW.3			   ;否则开始检测，变换工作寄存器组
		 CLR PSW.4
		 INC R4				   ;R4+1
JIANCE:	 JB P2.1,havevoice	   ;检测是否有声音
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice
		 JB P2.1,havevoice


NOVOICE: JB 06H,XIAOCHUNV		 ;若06H为1，则认为噪声标志位未消除，进入噪声程序
		 JnB 05h,nov3			 ;若一直没声音，即声音位05H为0，则直接跳出
		 CLR PSW.4				 ;选定工作寄存器1
		 SETB PSW.3				 
		 JNB 04H,T3R2			 ;若声音有效，R2，R3则计数，当1.2秒内都没有声音	则声音有效输出
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
NOV1:	 CLR PSW.3				   ;还原工作寄存器0
		 CLR PSW.4
		 RETI
NOV3:	 mov r4,#0
		  CLR PSW.3				   ;还原工作寄存器0
		 CLR PSW.4
		 RETI

;-----------声控有效，对LED进行控制--------
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
off:	  MOV PCA0CPM0,#02H		   ;关闭
		  CLR 0EH
		  CLR 00H
		  CLR PSW.3
		  RETI
;-----------------------------------------


havevoice:JB 06H,XIAOCHUV
		  setb 05H
		  SETB 04H
		  CLR PSW.4				 ;选定工作寄存器1
	 	  SETB PSW.3		   
		  CJNE R4,#200,T3C1	  ;	若R4大于200时还有声音，则认为声音无效
T3C1:	  JNC NOV			  ;R4大于200时，跳到NOV
		  CLR PSW.3			  ;返回中段
		  CLR PSW.4
		  RETI
NOV:	  SETB 06H		  ;有声音大于0.1s又有声音，声音无效 ,需要两秒内无声音方可消除06H
		  CLR 04H		  ;有声音的0.1s内无声音，声音无效,清零声音有效位
		  MOV R0,#0
		  MOV R1,#0
		  MOV R4,#0
		  CLR PSW.3
		  RETI

;------------有说话声音后两秒内若有声音，则认为说话仍然进行---------
XIAOCHUV: SETB PSW.3
		  SETB PSW.4
		  MOV R7,#00H	   ;消除声音
		  mov r6,#0
		  CLR PSW.3
		  CLR PSW.4
		  RETI
;-------------------------------------------------------------------------



;-----------------------------------
		  ORG 0500H
;---------------模式0键盘长跳转中转地址--------------
KEY01:LJMP KEY1
KEY02:LJMP KEY2
KEY03:LJMP KEY3
KEY04:LJMP KEY4
;----------模式0键盘长跳转中转地址---------		  
JUDGE:    LCALL DL1				;延时去抖
		  JNB P2.4,KEY04		;若P2.4为0，则说明KI0列有键按入，跳至列1判断的中转程序
		  JNB P2.5,KEY03	    ;若P2.5为0，则说明KI1列有键按入，跳至列2判断的中转程序
		  JNB P2.6,KEY02	    ;若P2.6为0，则说明KI2列有键按入，跳至列3判断的中转程序
		  JNB P2.7,KEY01	    ;若P2.6为0，则说明KI2列有键按入，跳至列3判断的中转程序
		  JnB 10h,jnol1
		  setb tr1	
jnol1:	  LJMP LOOP				;跳回主程序
;-------------------------------------

;-----------------------主程序--------------------------
MAIN:     MOV SP,#60H			  ;堆栈指针赋值
		  
		 LCALL  Init_Device	  ;长调用配置文件
		  

   ;--------------赋初值--------------------
   		  MOV R2,#24			  ;R2置数
		  MOV R1,#08H			  ;存储空间首地址24H
CLEAR:	  MOV @R1,#00H			  ;清零
		  INC R1				  ;R1=R1+1
		  DJNZ R2,CLEAR			  ;循环清零工作寄存器
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
		  SETB TR0 				  ;开启定时器0
		  ORL  91H,#04H			   ;开启定时器3
		  MOV 20H,#0FFH
		  SETB 02H				  ;显示器标志位置1
		  CLR 04H				  ;清零声音有效位
		  clr 06H				  ;清零噪声标志位
		  CLR 05H				  ;清零声音标志位
		  MOV 21H,#42H			  ;PCA0的等效地址赋值
		  MOV 22H,#00H
		  MOV 23H,#00H
		  MOV PCA0CPH0,#0FFH	  ;默认占空比最小

;------模式选择程序
LOOP:	 ;-----模式0----
 
		  mov R7,43h
		  CJNE R7,#00H,L1
		  MOV 22H,#01H		 ;模式0标志位置1
		  MOV 23H,#00H	   	  
		  ORL  91H,#04H		 ;开启光控声控
		  SETB TR1
		  LJMP LOOP0

L1:		  CJNE R7,#01H,L2
		  MOV 22H,#02H		 ;模式1标志位置1
		  MOV 23H,#00H
		  CLR TR1
		  ORL  91H,#04H		 ;开启光控关闭声控
		  SETB 0EH
		  LJMP LOOP0

L2:		  CJNE R7,#02H,L3
		  MOV 22H,#04H			;模式2标志位置1
		  MOV 23H,#00H
		  clr tr1				;关闭光控声控
		  MOV PCA0CPM0,#02H
		  clr tr2
		  ANL  91H,#0FBH
		  LJMP LOOP2
 ;-------模式扩充------
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


;-----------------模式0--------
LOOP0:	  
		  JNB P2.7,JUDGEL0	 ;若P2.7为0，则说明K4键按入，跳至4判断的中转程序
		  JNB P2.4,JUDGEL0	 ;若P2.4为0，则说明K1键按入，跳至1判断的中转程序
		  JNB P2.5,JUDGEL0	 ;若P2.5为0，则说明K2键按入，跳至2判断的中转程序
		  JNB P2.6,JUDGEL0	 ;若P2.6为0，则说明K3键按入，跳至3判断的中转程序
		  LJMP LOOP0
JUDGEL0:  clr tr1
          LJMP JUDGE




JUDGEL1:  
		  anl  91H,#7FH
		  LJMP JUDGE
LOOP1:	  JNB P2.7,JUDGEL1	 ;若P2.7为0，则说明K4键按入，跳至列4判断的中转程序
		  JNB P2.4,JUDGEL1	 ;若P2.4为0，则说明K1键按入，跳至列1判断的中转程序
		  JNB P2.5,JUDGEL1	 ;若P2.5为0，则说明K2键按入，跳至列2判断的中转程序
		  JNB P2.6,JUDGEL1	 ;若P2.6为0，则说明K3键按入，跳至列3判断的中转程序
		  LJMP LOOP


;----------------按键-----------------


;-------------亮度增加键----------------------------
L1G1:      SETB 0EH
		   SJMP KEY1L1
KEY1:	   CLR 03H				;关闭检测声音标志位	
		   JB 11H,L1G1			;为了保持灯亮一致
KEY1L1:	CJNE R3,#99H,k1
		   SJMP W1
k1:		   MOV A, R3
		   NOP
		   ADD A,#01H	   ;A=A+1
		   NOP
		   DA A             ;调整成BCD码
		   NOP
		   MOV R3,A			;A赋给R3，用于显示亮度等级
		   NOP
W1:		   MOV A,R3
		   NOP
		   MOV DPTR,#TABLE		;查表，改变亮度等级
		   NOP
		   MOVC A,@A+DPTR	
		   NOP
		   MOV PCA0CPH0,A  
		   NOP
		   MOV PCA0CPM0,21H 
		   CJNE R2,#5FH,RE1
W3:		   JB P2.7,W2
		   CJNE R2,#5FH,RE1		 ;若长按，则再次进入按键
		   MOV R4,#01H
		   LCALL DL0
		   SJMP KEY1


RE1:	   LCALL DL1		   ;延时去抖，检测按键是否松开
		   INC R2
		   SJMP W3  	       ;若P2.7扔为0，说明按键未松开，重新检测

W2:		   MOV R2,#00H			;若非模式1，则不对T1定时器进行处理
		   CLR 03H
		   jB 12H,K1L2
		  JnB 10h,K1nol1
		  setb tr1	
K1nol1:	  LJMP LOOP0		   ;返回主程序
K1L2:	  LJMP LOOP2



 ;-------亮度减少键-------
L1G:	   CLR 0EH
		   SJMP w12
KEY2:	   CLR 03H			   ;关闭检测声音标志位
			CJNE R3,#00H,k2	   ;为了保持灯亮一致
			JB 11H,L1G
		   SJMP w12
k2:		   MOV A, R3
		   NOP
		   ADD A,#99H	   ;A=A+1	
		   NOP
		   DA A             ;调整成BCD码
		   NOP
		   MOV R3,A			 ;A赋给R3，用于显示亮度等级
		   NOP
W12:	   MOV A,R3
		   NOP
		   MOV DPTR,#TABLE	   ;查表，改变亮度等级
		   NOP
		   MOVC A,@A+DPTR
		   NOP	
		   MOV PCA0CPH0,A
		   MOV PCA0CPM0,21H
		   NOP


		   CJNE R2,#5FH,RE12	 ;若长按，则再次进入按键
W32:	   JB P2.6,W22

		   CJNE R2,#5FH,RE12	  ;若长按，则再次进入按键
		   MOV R4,#01H
		   LCALL DL0
		   SJMP KEY2


RE12:	   LCALL DL1		   ;延时去抖，检测按键是否松开
		   INC R2
		   SJMP W32  	        ;若P2.7扔为0，说明按键未松开，重新检测
W22:	   MOV R2,#00H
		   LCALL DL1
		 jB 12H,K2L2
		  JnB 10h,K2nol1	   ;若非模式1，则不对T1定时器进行处理
		  setb tr1	
		   CLR 03H
K2nol1:	  LJMP LOOP0		   ;返回主程序
K2L2:	   LJMP LOOP2



;-------------开启或关闭数码管键---------------------
kEY3:	   	CLR 03H
			JNB 02H,xianshi
		   CLR TR0
		   CLR 02H
		   MOV P1,#0FH
		   SJMP RE3
XIANSHI:   SETB TR0
		   SETB 02H

RE3:	   LCALL DL1		   ;延时去抖，检测按键是否松开

		   JNB P2.5,RE3  	   ;若P2.5扔为0，说明按键未松开，重新检测
		   JB 12H,K3L2
		  JnB 10h,K3nol1		;若非模式1，则不对T1定时器进行处理
		  setb tr1	
		   CLR 03H
K3nol1:	  LJMP LOOP0		   ;返回主程序
 K3L2:    LJMP LOOP2
 ;-------------模式切换	键-----

KEY4:	   CLR 03H
		   INC 43H
		   MOV R0,43h
 		   MOV R7,43H
		   CJNE R7,#3,re4
		   MOV 43h,#0
		   MOV R0,43h
RE4:	   LCALL DL1		   ;延时去抖，检测按键是否松开
		   JNB P2.4,RE4  	   ;若P2.5扔为0，说明按键未松开，重新检测
		  JnB 10h,K4nol1		;若非模式1，则不对T1定时器进行处理
		  setb tr1	
		   CLR 03H
K4nol1:	   LJMP LOOP		   ;返回主程序



;---------------模式2----------------------------
 ;跳至相应的按键程序
KEY01L2:LJMP KEY1
KEY02L2:LJMP KEY2
KEY03L2:LJMP KEY3
KEY04L2:LJMP KEY4
;----------模式2键盘长跳转中转地址---------		  
JUDGEl2:    LCALL DL1				;延时去抖
		  JNB P2.4,KEY04l2		;若P2.4为0，则说明K1键按入，跳至1判断的中转程序
		  JNB P2.5,KEY03L2	    ;若P2.5为0，则说明K2键按入，跳至2判断的中转程序
		  JNB P2.6,KEY02L2	    ;若P2.6为0，则说明K3键按入，跳至3判断的中转程序
		  JNB P2.7,KEY01L2	    ;若P2.6为0，则说明K4键按入，跳至4判断的中转程序
		 	
		  LJMP LOOP2				;跳回主程序


LOOP2:    JB P2.1,KONGZHI
	 	  JNB P2.7,JUDGEL2	 ;若P2.7为0，则说明K4键按入，跳至4判断的中转程序
		  JNB P2.4,JUDGEL2	 ;若P2.4为0，则说明K1键按入，跳至1判断的中转程序
		  JNB P2.5,JUDGEL2	 ;若P2.5为0，则说明K2键按入，跳至2判断的中转程序
		  JNB P2.6,JUDGEL2	 ;若P2.6为0，则说明K3键按入，跳至3判断的中转程序
		  sjmp loop2
KONGZHI:  JB  P2.2,LOOP2
		  MOV PCA0CPM0,#42H 
		  NOP
		  SETB TR2
		  LCALL DL1
		  mov  45h,#100		 
		  sjmp loop2



;---------------延时程序----------------
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
;-------------显示屏动态显示程序------------------
;-------------------------------------------------
display:   	CLR    C		 ;清零C位
			CJNE R5,#02H,X1	 ;判断R5与02的大小
			SJMP display2	 ;R5等于2，选通数码管2
X1:			JNC  display3	 ;cy=0，表明R5=3，选通数码管3
		    CJNE R5,#01H,X0	 ;R5小于2，再与1进行比较
			SJMP display1	 ;R5等于1，选通数码管1
X0:			SJMP display0	 ;R5小于1，选通数码管0


     ;----------数码管0显示模式低位-----
display0: MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  NOP
		  NOP
		  NOP
		  MOV A,#0FH		 ;屏蔽R0高四位
		  ANL A,R0			 ;将R0与A进行与操作，将R0低四位存至A中
		  CLR ACC.4			 ;P0.7,P0.6置零，选通数码管0
		  CLR ACC.5		
		  MOV P1,A			 ;将查得的值赋给P1，数码管0得到显示
		  MOV R5,#1			 ;R5赋1，下一次中断到来，选通数码管1
		  RETI				 ;定时器1中断返回
     ;--------------------------------------

     ;---------数码管1显示模式高位------
display1: MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  NOP
		  NOP
		  MOV A,#0F0H		 ;屏蔽R0低四位
		  ANL A,R0			 ;将R0与A进行与操作，将R0高四位存至A中
		  SWAP A			 ;交换A中的高四位和低四位
		  CJNE A,#00H,light_l
		  MOV P1,#0fh
		  MOV R5,#2			 ;R5赋0，下一次中断到来，选通数码管0
		  RETI				 ;定时器1中断返回
light_l:  CLR ACC.5			 ;P0.7置0,P0.6置1，选通定数码管1
		  SETB ACC.4  
		  MOV P1,A
		  MOV R5,#2			 ;R5赋2，下一次中断到来，选通数码管2
		  RETI				 ;定时器1中断返回
     ;------------------------------------

     ;-----------数码管3显示R3低四位----------
display2:  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  nop
		  NOP
		  NOP
		  MOV A,#0FH		 ;屏蔽R3高四位
		  ANL A,R3			 ;将R3与A进行与操作，将R3低四位存至A中
		  
		  SETB ACC.5			 ;P0.7置1,P0.6置0，选通定数码管2
		  SETB ACC.4
		  MOV P1,A			 ;将查得的值赋给P1，数码管2得到显示
		  MOV R5,#3			 ;R5赋3，下一次中断到来，选通数码管3
		  RETI				 ;定时器1中断返回
	 ;------------------------------------

	 ;-----------数码管2显示亮度高四位--------
display3: MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  MOV P1,#0FFH		 ;清零数码管,消除换数码管带来的毛刺
		  NOP
		  NOP
		  NOP
		  MOV A,#0F0H		 ;屏蔽R3低四位
		  ANL A,R3			 ;将R3与A进行与操作，将R3高四位存至A中
		  SWAP A			 ;交换A中的高四位和低四位
		  CJNE A,#00H,light_h
		  MOV P1,#3fh
		  MOV R5,#0			 ;R5赋0，下一次中断到来，选通数码管0
		  RETI				 ;定时器1中断返回
light_h:  CLR ACC.4		 ;P0.7置1,P0.6置1，选通定数码管3
		  SETB ACC.5
		  MOV P1,A			 ;将查得的值赋给P1，数码管3得到显示
		  MOV R5,#0			 ;R5赋0，下一次中断到来，选通数码管0
		  RETI				 ;定时器1中断返回
	 ;-----------------------------------		  	  
	
;-----------------------------------------------
;----------亮度查找表--------------------------------
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