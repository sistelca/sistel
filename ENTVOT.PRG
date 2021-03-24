* RUTINA PARA VOTACION 
* ALTERNATIVA, DEBE INTERACTUAR CON
* UN PROGRAMA DE ADMINISTRACION 
* DE LISTADO DE VOTANTES
* Y TENER INSTALADA LA INTERRUPCION 
* PARA PERIODO DE RETARDO
* 11/05/95

REQUEST DBFCDX
IF OPC=2
	TOTALZ()
	RETURN
ENDIF
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Abriendo Archivos. Espere un Momento...")
IF ABRECOM()
	CATALOG->(DBSEEK("21"))
	DO WHILE .NOT. CATALOG->(EOF())
		SELECT (CATALOG->NOM_ARCH)
		IF FCOUNT()==CATALOG->L_INF .OR. EOF()
			CLOSE ALL
			OJO()
			RETURN
		ENDIF
		CATALOG->(DBSKIP())
	ENDDO
ELSE
	OJO()
	CLOSE ALL
	RETURN
ENDIF

RELACION()

USE CATEGO SHARED NEW
IF !NETERR()
	SET INDEX TO CATEGO
ELSE
	SALIR()
	RETURN
ENDIF

USE CANDI SHARED NEW
IF !NETERR()
	SET INDEX TO CANDI
ELSE
	SALIR()
	RETURN
ENDIF
Ptd:=.T.
IF CANDI->NPSIM>0
	USE INTERM SHARED NEW
	IF !NETERR()
		SET INDEX TO INTERM
	ELSE
		SALIR()
		RETURN
	ENDIF

	USE PART_GRP SHARED NEW
	IF !NETERR()
		SET INDEX TO PART_GRP
	ELSE
		SALIR()
		RETURN
	ENDIF
	SELECT INTERM
	SET RELATION TO NO INTO PART_GRP
	Ptd:=.F.
	SELECT CANDI
	CaIn:=INDEXKEY(0)
	DBSETRELATION("INTERM", {|| &CaIn}, &CaIn)
ENDIF

@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Introduzca Datos...")
@ 24, 0 SAY "<F1> Ayuda"
@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"

* Saltar este bloque de instrucciones en caso
* de caida del sistema, alternativa si hubo caida
* entonces ......

WOPEN(8, 10, 18, 69, .T.)
WBOX(0)
@ 0, 0 SAY CENTER("Introduzca Datos:")
DO WHILE .T.
	SELECT CATALOG
	VAR1:=SPACE(5)
	VAR2:=SPACE(2)
	GO LASTREC()-1
	@ 2, 10 SAY "C¢digo de "+TRIM(NOMBRE) GET VAR1 PICT "99999" VALID IF(SPACE(1)$VAR1, .F., .T.)
	GO LASTREC()
	@ 4, 10 SAY TRIM(NOMBRE)+" N§ " GET VAR2 PICT "99" VALID IF(SPACE(1)$VAR2, .F., .T.)
	SETCURSOR(1)
	READ
	SETCURSOR(0)
	IF LASTKEY()==27
		CLOSE ALL
		WCLOSE()
		RETURN
	ENDIF
	SELECT (NOM_ARCH)
	DBSEEK(VAR1+VAR2)
	IF FOUND()
		c:="S"
		@ 6, 10 SAY "Confirmar (S/N) " GET c PICT "!" VALID IF(c="S" .OR. c="N", .T., .F.)
		SETCURSOR(1)
		READ
		SETCURSOR(0)
		IF c=="S"
			EXIT
		ELSE
			@ 6, 0 CLEAR TO 6, 70
			LOOP
		ENDIF
	ENDIF
ENDDO
WCLOSE()
* Fin de bloque

WOPEN(0, 0, 24, 79, .T.)
WBOX(0)
USE TITULOS SHARED NEW
IF NETERR()
	SALIR()
	RETURN
ENDIF
FOR i=1 TO 3
	@ i-1, 0 SAY CENTER(TRIM(TITULO))
	SKIP
NEXT i
*i+=1
SELECT CATALOG
DBSEEK("21")
DO WHILE .NOT. EOF()
	@ i,  0 SAY TRIM(NOMBRE)+REPLICATE(".", 20-LEN(TRIM(NOMBRE)))
	IF RECNO()==LASTREC()-1
		Cont:="CODIGO"
	ELSEIF RECNO()==LASTREC()
		Cont:="NUM"
	ELSE
		Cont:=SUBSTR(TRIM(NOMBRE), 1, 1)+ESCREF
	ENDIF
	SELECT (NOM_ARCH)
	IF .NOT. EOF()
		FOR j=1 TO CATALOG->L_INF
			IF FIELDSIZE(j)>=30
				EXIT
			ENDIF
		NEXT j
		@ i, 22 SAY &Cont
		IF CATALOG->TIPO
			@ i, 30 SAY FIELDGET(j)
		ELSE
			@ i, 25 SAY CHR(251)
		ENDIF
	ELSE
		@ i, 22 SAY REPLICATE("=", 10)
	ENDIF
	SELECT CATALOG
	i+=1
	SKIP
ENDDO
CATALOG->(DBGOBOTTOM())
SELECT (CATALOG->NOM_ARCH)

* Saltar este bloque en caso de caida
IF RLOCK()
	FOR i=CATALOG->L_INF+1 TO FCOUNT()
		FIELDPUT(i, 0)
	NEXT i
ELSE
	ALERT("Otro usuario a bloqueado registro; Intente de nuevo...")
	WCLOSE()
	CLOSE ALL
	RETURN
ENDIF

*TotMes(1)
ALERT("Pulse <Enter> para Continuar...")
* Fin de bloque

USE ELECTOR SHARED NEW VIA "DBFCDX"
IF !NETERR()
	SET INDEX TO ELECTOR
	SET ORDER TO TAG CLAVENT
ELSE
	WCLOSE()
	SALIR()
	CLOSE ALL
	RETURN
ENDIF
FnVt:=0
CANCREF()
Msg1:="<<< Modulo de Votaci¢n >>>"
Color:=SETCOLOR()
SETCOLOR("W+/N")
@ 20, (80-LEN(Msg1))/2 SAY Msg1
SETCOLOR(Color)

DO WHILE .T.
	DO WHILE INKEY()<>276  && Alt+T
		ELECTOR->(DBSEEK("10"))
		IF .NOT. ELECTOR->(FOUND())
			LOOP
		ELSEIF ELECTOR->(RLOCK())
			DO WHILE .T.
				Vent:=WSELECT()
				VotEm:=.F.
				VotEm:=VOTAR()
				IF VALTYPE(VotEm)=="A"
					WOPEN(24-LEN(VotEm)-6, 2, 24, 77, .T.)
					WBOX(1)
					@ 0, 0 SAY CENTER("Voto Emitido:")
					@ 1, 0 TO 1, 76
					FOR i=1 TO LEN(VotEm)
						CATEGO->(DBSEEK(VotEm[i, 1]))
						@ i+1, 0 SAY TRIM(CATEGO->CATEG)+" : "
						CANDI->(DBSEEK(VotEm[i, 1]+VotEm[i, 2]+VotEm[i,3]))
						IF SELECT("PART_GRP")>0 .AND. CANDI->(FOUND())
							PART_GRP->(DBSEEK(VotEm[i, 4]))
							PARTIDO:=PART_GRP->SIGLAS
						ELSE
							PARTIDO:=SPACE(15)
						ENDIF
						IF CANDI->(FOUND())
							@ i+1, LEN(TRIM(CATEGO->CATEG))+4 SAY TRIM(CANDI->NOMBRE)+SPACE(5)+PARTIDO
						ELSE
							@ i+1, LEN(TRIM(CATEGO->CATEG))+2 SAY " Abstenci¢n"
						ENDIF
					NEXT i
					@ i+2, 30 PROMPT "Si"
					@ i+2, 40 PROMPT "Cancelar"
					i1:=i+2
					Aceptar:=0
					MENU TO Aceptar

					IF Aceptar=1
						CATALOG->(DBGOBOTTOM())
						Atra:=ALIAS()
						SELECT (CATALOG->NOM_ARCH)
						IF RLOCK()
							FOR i=1 TO LEN(VotEm)
								CATEGO->(DBSEEK(VotEm[i, 1]))
								Lcan:=CATALOG->L_INF+CATEGO->FACU-CATEGO->FSIM
								CANDI->(DBSEEK(VotEm[i, 1]+VotEm[i, 2]+VotEm[i, 3]))
								IF CANDI->(FOUND())
									Lcan+=CANDI->NPar-CANDI->NpSim
								ELSE
									Lcan:=CATALOG->L_INF+CATEGO->FACU-1
								ENDIF
								Vcan:=FIELDGET(Lcan)+1
								FIELDPUT(Lcan, Vcan)
								FIELDPUT(CATALOG->L_INF+CATEGO->FACU, 1)
								IF SELECT("PART_GRP")>0 .AND. CANDI->(FOUND())
									Vpar:=FIELDGET(Lcan+VotEm[i, 5])+1
									FIELDPUT(Lcan+VotEm[i, 5], Vpar)
								ENDIF
							NEXT i
						ENDIF
						SELECT (Atra)
						REPLACE ELECTOR->CLV2 WITH "1"
						ELECTOR->(DBCOMMIT())
						@ i1, 0 CLEAR TO i1, 76
						WCLOSE()
						EXIT
					ELSE
						WCLOSE()
						LOOP
					ENDIF
				ELSEIF VALTYPE(VotEm)=="L"
					CATEGO->(DBGOTOP())
					REPLACE ELECTOR->CLV2 WITH "1"
					ELECTOR->(DBCOMMIT())
					DO WHILE .NOT. CATEGO->(EOF())
						IF CATEGO->ESCREF=="11"
							CANDI->(DBSEEK(CATEGO->NIV))
							IF CANDI->(FOUND())
								CATALOG->(DBGOBOTTOM())
								Atra:=ALIAS()
								SELECT (CATALOG->NOM_ARCH)
								IF RLOCK()                
									Lcan:=CATALOG->L_INF+CATEGO->FACU-1
									Vcan:=FIELDGET(Lcan)+1
									FIELDPUT(Lcan, Vcan)
									FIELDPUT(CATALOG->L_INF+CATEGO->FACU, 1)
								ENDIF
								SELECT (Atra)
							ENDIF
						ELSE
							CATALOG->(DBSEEK(CATEGO->ESCREF))
							SELECT (CATALOG->NOM_ARCH)
							Clave:=INDEXKEY(0)
							Conte:=&(INDEXKEY(0))
							SELECT CANDI
							LOCATE FOR NIV==CATEGO->NIV .AND. &Clave==Conte
							IF FOUND()
								CATALOG->(DBGOBOTTOM())
								Atra:=ALIAS()
								SELECT (CATALOG->NOM_ARCH)
								IF RLOCK()
									Lcan:=CATALOG->L_INF+CATEGO->FACU-1
									Vcan:=FIELDGET(Lcan)+1
									FIELDPUT(Lcan, Vcan)
									FIELDPUT(CATALOG->L_INF+CATEGO->FACU, 1)
								ENDIF
								SELECT (Atra)
							ENDIF
						ENDIF
						CATEGO->(DBSKIP())
					ENDDO
					FOR j=WSELECT() TO Vent+1 STEP -1
						WCLOSE()
					NEXT j
					EXIT
				ENDIF
			ENDDO
			TONE(1250); TONE(3000); TONE(2500); TONE(2000); TONE(3000)
			WAITPERIOD(1000)
			DO WHILE WAITPERIOD()
			ENDDO
		ENDIF
	ENDDO
	IF FINVOT()==1
		EXIT
	ELSE
		LOOP
	ENDIF
ENDDO

*TotMes(0)

WCLOSE()
CLOSE ALL
RETURN


STATIC FUNCTION ABRECOM()
LOCAL TMP1, TMP
CLOSE ALL
IF FILE("CATIND.DBF") .AND. FILE("CATORD.NTX")
	DV:=.T.
	USE CATIND SHARED NEW
	IF !NETERR()
		SET INDEX TO CATORD
	ELSE
		SALIR()
		RETURN
	ENDIF
	USE CATALOG SHARED NEW
	IF !NETERR()
		SET INDEX TO DIVCATE 
	ELSE
		SALIR()
		RETURN
	ENDIF
	SET RELATION TO ESCREF INTO CATIND
	DBSEEK("21")
	DO WHILE .NOT. EOF()
	     USE (NOM_ARCH) SHARED NEW
	     IF !NETERR()
		     ABRE:=ALIAS()
		     SELECT CATIND
		     TMP:={}
		     DO WHILE ESCREF=(CATALOG->ESCREF)
			  AADD(TMP, {NOMIND, ID_EN})
			  SKIP
		     ENDDO
		     SELECT (ABRE)
		     TMP1:=TMP
		     TMP:=ASORT(TMP1,,,{|x,y| x[2]<y[2]})
		     TMP1:=""
		     FOR I=1 TO LEN(TMP)
			  DBSETINDEX(TMP[I,1])
		     NEXT
	     ELSE
		     SALIR()
		     RETURN
	     ENDIF
	     SELECT CATALOG
	     SKIP
	ENDDO
	CLOSE CATIND
ELSE
	DV:=.F.
ENDIF
RETURN (DV)

STATIC FUNCTION SALIR()
ALERT("Error en Apertura de Archivos. Proceso Abortado..")
CLOSE ALL
RETURN

STATIC FUNCTION RELACION()
SELECT CATALOG
DBSEEK("21")
FOR i=2 TO LASTREC()-1
	nREG:=RECNO()
	nESC:=ESCAL
	SELECT (NOM_ARCH)
	ARPRI:=ALIAS()
	CLA:=INDEXKEY(0)
	SELECT CATALOG
	LOCATE FOR VAL(ESCAL)==VAL(nESC)+1
	IF .NOT. FOUND()
		EXIT
	ENDIF
	SELECT (NOM_ARCH)
	DBSETRELATION((ARPRI), {|| &CLA}, &CLA)
	SELECT CATALOG
	GO nREG
	SKIP
NEXT i
RETURN

STATIC FUNCTION FINVOT()
LOCAL Opcion:={"Si", "Cancelar"}
FnVt:=ALERT("Finalizar Proceso de Votaci¢n", Opcion)
RETURN FnVt

STATIC FUNCTION VOTAR()
SET KEY 299 TO VOTESC
SELECT CATEGO
GO TOP
VotGu:={}
Msg2:="Pulse Tecla para Comenzar..."
Color:=SETCOLOR()
SETCOLOR("W+/N")
@ 22, (80-LEN(Msg2))/2 SAY Msg2
SETCOLOR(Color)
KEYSEC(299, 60, -1, .T.)
INKEY(0)
@ 22, 0 CLEAR TO 22, 79

DO WHILE .NOT. CATEGO->(EOF())
	OPCAN:={}
	IF CATEGO->ESCREF=="11"
		SELECT CANDI
		DBSEEK(CATEGO->NIV)
		IF FOUND()
			Conte:=&(INDEXKEY(0))
			Lcont:=LEN(Conte)-2
			AADD(VotGu, {NIV, SUBSTR(Conte, 3, Lcont-2), NIL, NIL, 0})
			DO WHILE CANDI->NIV==CATEGO->NIV
				AADD(OPCAN, TRIM(NOMBRE))
				CANDI->(DBSKIP())
			ENDDO
			AADD(OPCAN, "Abstenci¢n")
		ENDIF
	ELSE
		CATALOG->(DBSEEK(CATEGO->ESCREF))
		SELECT (CATALOG->NOM_ARCH)
		Clave:=INDEXKEY(0)
		Conte:=&(INDEXKEY(0))
		SELECT CANDI
		LOCATE FOR NIV==CATEGO->NIV .AND. &Clave==Conte
		IF FOUND()
			Conte1:=&(INDEXKEY(0))
			Lcont:=LEN(Conte1)-2
			AADD(VotGu, {NIV, SUBSTR(Conte1, 3, Lcont-2), NIL, NIL, 0})
			DO WHILE FOUND()
				AADD(OPCAN, TRIM(NOMBRE))
				CONTINUE
			ENDDO
			AADD(OPCAN, "Abstenci¢n")
		ENDIF
	ENDIF
	IF LEN(OPCAN)>0
		WOPEN(3, 10, 15, 53, .T.)
		WBOX(1)
		@ 0, 0 SAY CENTER("ELIJA CANDIDATO A "+TRIM(CATEGO->CATEG))
		@ 1, 0 TO 1, 42
		Clr:=SETCOLOR()
		SETCOLOR("")
		FOR k=2 TO MIN(LEN(OPCAN)+1, 10)
			@ k, 41 SAY CHR(176)
		NEXT k
		SETCOLOR("W+/N")
		@  2, 41 SAY CHR(24)
		@ MIN(LEN(OPCAN)+1, 10), 41 SAY CHR(25)
		SETCOLOR(Clr)
		C:=0
		DO WHILE C==0
			C:=ACHOICE( 2, 2, 19, 40, OPCAN)
			IF VotEm
				RETURN .T.
			ENDIF
			IF C>0
				k:=LEN(VotGu)
				C1:=LTRIM(STR(C))
				IF(LEN(C1)=1, VotGu[k, 3]:="0"+C1, VotGu[k, 3]:=C1)
				Fila:=ROW()+WROW()
				@ ROW(), 0 SAY CHR(205)+CHR(16)
				IF C<LEN(OPCAN) .AND. SELECT("PART_GRP")<>0
					OPPAR:={}
					OPCPA:={}
					VlPt:=VotGu[k, 1]+VotGu[k, 2]+VotGu[k, 3]
					INTERM->(DBSEEK(VlPt))
					ClPt:=CANDI->(INDEXKEY(0))
					Atra:=ALIAS()
					SELECT INTERM
					DO WHILE &ClPt==VlPt
						AADD(OPPAR, TRIM(PART_GRP->SIGLAS))
						AADD(OPCPA, PART_GRP->NO)
						INTERM->(DBSKIP())
					ENDDO
					SELECT (Atra)
					FilTp:=(LEN(OPPAR)+3)/2
					FilFn:=LEN(OPPAR)+3-FilTp
					WOPEN(Fila-FilTp, 54, Fila+FilFn, 73, .T.)
					WBOX(1)
					@ 0, 0 SAY CENTER("Elija Partido")
					@ 1, 0 TO 1, 61
					IF LEN(OPPAR)>1
						Clr:=SETCOLOR()
						SETCOLOR("")
						FOR j=2 TO LEN(OPPAR)+1
							@ j, 17 SAY CHR(176)
						NEXT j
						SETCOLOR("W+/N")
						@  2, 17 SAY CHR(24)
						@ LEN(OPPAR)+1, 17 SAY CHR(25)
						SETCOLOR(Clr)
					ENDIF
					P:=0
					DO WHILE P==0
						P:=ACHOICE( 2, 2, 16, 16, OPPAR)
						IF VotEm
							RETURN .T.
						ENDIF
						IF P>0
							@ ROW(), 0 SAY CHR(205)+CHR(16)
							VotGu[k, 4]:=OPCPA[p]
							VotGu[k, 5]:=p
						ENDIF
					ENDDO
					WCLOSE()
				ENDIF
			ENDIF
		ENDDO
		WCLOSE()
	ENDIF
	CATEGO->(DBSKIP())
ENDDO
KEYSEC()
RETURN (VotGu)

STATIC FUNCTION VOTESC()
IF LEN(READVAR())>0
	KEYSEC()
	VotEm:=.T.
ENDIF
KEYBOARD CHR(13)
RETURN

STATIC FUNCTION TotMes(k1)
Eti:={}
SELECT CATALOG
CATALOG->(DBGOTOP())
DO WHILE .NOT. CATALOG->(EOF())
	IF FILE(CATALOG->NOM_ARCH+".DBF")
		SELECT (CATALOG->NOM_ARCH)
	ENDIF
	IF .NOT. EOF()
		AADD(Eti, {CATALOG->NOMBRE, SPACE(2), CATALOG->ESCREF, SUBSTR(LTRIM(CATALOG->NOMBRE), 1, 1)+CATALOG->ESCREF, CATALOG->TIPO})
	ENDIF
	CATALOG->(DBSKIP())
ENDDO
CATALOG->(DBGOBOTTOM())
NomSal:=TRIM(CATALOG->NOMBRE)+SPACE(1)
Pr:=LEN(Eti)
Vtana:=.F.
IF k1<>1
	Vtana:=.T.
	WOPEN(10, 10, 15, 70, .T.)
	WBOX(1)
	@ 0,  0 SAY CENTER("Impresi¢n de Escrutinios por "+TRIM(CATALOG->NOMBRE))
	SETCURSOR(1)
	DO WHILE .T.
		@ 2, 10 SAY "N§ de Copias:" GET k1 PICT "99" VALID IF(k1<=0, .F., .T.)
		READ
		IF k1>0
			SETCURSOR(0)
			EXIT
		ENDIF
	ENDDO
ENDIF
DO WHILE .NOT. ISPRINTER()
	ALERT("Prepare la Impresora para Generar Reporte")
ENDDO
vent:=WSELECT()
WSELECT(0)
VtAct:=SAVESCREEN(24, 0, 24, 79)
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Estado de Impresi¢n Activado,... Espere un Momento")
WSELECT(vent)

FOR l=1 TO K1
	CATEGO->(DBGOTOP())
	DO WHILE .NOT. CATEGO->(EOF())
		Timp:="Total de Votos por "+TRIM(CATALOG->NOMBRE)+" para "+TRIM(CATEGO->CATEG)
		CANDI->(DBSEEK(CATEGO->NIV))
		IF(CANDI->(FOUND()), ESCRUTINIO(), .T.)
		CATEGO->(DBSKIP())
	ENDDO
NEXT l
CATALOG->(DBGOBOTTOM())
SELECT (CATALOG->NOM_ARCH)
vent:=WSELECT()
WSELECT(0)
@ 24, 0 CLEAR TO 24, 79
RESTSCREEN(24, 0, 24, 79, VtAct)
WSELECT(vent)
IF(Vtana, WCLOSE(), .T.)
RETURN