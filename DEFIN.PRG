* PROGRAMA DEFIN.PRG
* RUTINAS PARA CREAR Y EDITAR 
* UN AMBIENTE ELECTORAL
* 11/05/95

DO CASE
     CASE OPC=1
	  TITULOS()
     CASE OPC=2
	  ENTCAT()
     CASE OPC=3
	  ENTDIV()
     CASE OPC=4
	  ASIGN()
     CASE OPC=5
	  INFOR()
ENDCASE

FUNCTION TITULOS()
PRIVATE MEN, VAR[3], IND:=0
IF .NOT. FILE("TITULOS.DBF")
     CREA:={}
     AADD(CREA, {"Titulo", "C", 50, 0})
     DBCREATE("TITULOS", CREA)
     IND:=1
ENDIF
USE TITULOS
FOR I=1 TO 3
     IF IND=1
	  VAR[I]:=SPACE(50)
	  APPEND BLANK
     ELSE
	  VAR[I]:=Titulo
	  SKIP
     ENDIF
NEXT
GO TOP
WOPEN(3, 2, 22, 75, .T.)
WBOX()
MEN:="TITULOS DEL PROCESO ELECTORAL"
@  1, 0 SAY CENTER(MEN)
@  3, 3 SAY "Introduzca los T¡tulos que se le solicitan a continuaci¢n.."
@  6, 3 SAY "NOMBRE DEL UNIVERSO QUE AGRUPA A LA POBLACION DE VOTANTES"
@  9, 3 SAY "NOMBRE DEL ORGANISMO ENCARGADO DEL PROCESO ELECTORAL"
@ 12, 3 SAY "TITULO DEL PROCESO ELECTORAL"
JJ:=1
FOR J=7 TO 13 STEP 3
     @ J, 0 SAY LTRIM(STR(JJ))+"§"
     @ J, 3 GET VAR[JJ] PICT "@!"
     JJ+=1
NEXT
TEM:=GETLIST
GETLIST:={}

DO WHILE .T.
     WOPEN(8, 35, 12, 52, .T.)
     WBOX(1)
     @ 0, 0 SAY CENTER("Men£")
     @ 1, 0 PROMPT " Editar"
     @ 2, 0 PROMPT " Guardar y Salir"
     MENU TO TIMEN
     WCLOSE()
     IF TIMEN=1
	  GETLIST:=TEM
	  READ
	  FOR I=1 TO 3
	       REPLACE Titulo WITH VAR[I]
	       SKIP
	  NEXT
     ELSE
     WCLOSE()
     CLOSE ALL
     RETURN
     ENDIF
ENDDO
CLOSE ALL
RETURN

FUNCTION ENTCAT()
PRIVATE P, TEM, K, VAR:=.F.
I:=0
WOPEN(3, 2, 22, 75, .T.)
WBOX()
IF .NOT. FILE("CATEGO.DBF")
CREA:={}
AADD(CREA, {"NIV", "C", 2, 0})
AADD(CREA, {"CATEG", "C", 30, 0})
AADD(CREA, {"ESCREF", "C", 2, 0})
AADD(CREA, {"FSIM", "N", 4, 0})
AADD(CREA, {"FACU", "N", 4, 0})

DBCREATE("CATEGO", CREA)
ENDIF
USE CATEGO
I1:=4
F:=0
@ 0, 0 SAY CENTER("CATEGORIAS DE CARGOS A ELEGIR")
K:=1
P:={}

DO WHILE .NOT. EOF()
AADD(P, {VAL(NIV), CATEG})
@ I1, F SAY P[K,1] PICT "99" 
@ I1, F+3 GET P[K,2] PICT "@!"
PANTA()
K+=1
SKIP
ENDDO

LEA:=GETLIST
TEM:=K-1

SET MESSAGE TO 17 CENTER

Atra:=ALIAS()
Candi:=.T.
IF FILE("CANDI.DBF")
	USE CANDI NEW
	Candi:=EOF()
	CLOSE CANDI
ENDIF
SELECT (Atra)

DO WHILE .T.

GA=0
@ 16,  0
IF .NOT. VAR
	@ 16,  5 PROMPT "Insertar"  MESSAGE "Agregar Categor¡a"
ELSE
	@ 16,  5 SAY "Insertar"
ENDIF
@ 16, 16 PROMPT "Borrar";
	 MESSAGE "        Borrar Categor¡a      "
@ 16, 25 PROMPT "Editar";
	 MESSAGE "        Editar Categor¡a      "
@ 16, 35 PROMPT "Ordenar";
	 MESSAGE "Reordenar dos o m s Categor¡as"
@ 16, 47 PROMPT "Guardar";
	 MESSAGE "  Guardar Informaci¢n y Salir "
@ 16, 59 PROMPT "Suspender";
	 MESSAGE "      Suspender y Salir       "
MENU TO GA
GETLIST:={}
IF .NOT. Candi
	CAMBIOS()
	WCLOSE()
	CLOSE ALL
	RETURN
ENDIF

DO CASE

CASE (GA=1 .AND. .NOT. VAR)
* INSERTAR CATEGORIA
AADD(P, {K, SPACE(30)})
@ I1, F SAY P[K,1] PICT "99"
@ I1, F+3 GET P[K,2] PICT "@!"
AADD(LEA, GETLIST[1])
READ
IF P[K,2]=SPACE(30)
ADEL(P, K)
ASIZE(P, K-1)
ADEL(LEA, K)
ASIZE(LEA, K-1)
@ I1, F CLEAR TO I1, 73
ELSE
K+=1
PANTA()
ENDIF

CASE (GA=2 .AND. .NOT. VAR) .OR. (GA=1 .AND. VAR)
* BORRAR CATEGORIA
NUM:=0
WOPEN(19, 12, 21, 46, .T.)
WBOX(1)
@ 0, 0 SAY "   Introduzca N§ a Borrar:" GET NUM PICT "99" RANGE 0, K-1
READ
WCLOSE()
IF NUM>0
ADEL(P, NUM)
ADEL(LEA, NUM)
ASIZE(P, K-2)
ASIZE(LEA, K-2)
K-=1
I1=4
F=0
VAR:=.F.
@ 4, 0 CLEAR TO 15, 73
FOR J=1 TO K-1
P[J,1]:=J
@ I1, F SAY P[J,1] PICT "99"
@ I1, F+3 GET P[J,2] PICT "@!"
PANTA()
NEXT
LEA:=GETLIST
ENDIF

CASE (GA=3 .AND. .NOT. VAR) .OR. (GA=2 .AND. VAR)
* EDITAR PANTALLA
GETLIST:=LEA
READ

CASE (GA=4 .AND. .NOT. VAR) .OR. (GA=3 .AND. VAR)
* REORDENAR
FOR J11=1 TO 2
I1=4
F=0
@ 4, 0 CLEAR TO 15, 73
FOR J=1 TO K-1
IF J11=1
@ I1, F GET P[J,1] PICT "99" RANGE 1, K-1
@ I1, F+3 SAY P[J,2]
ELSE
P[J,1]:=J
@ I1, F SAY P[J,1] PICT "99"
@ I1, F+3 SAY P[J,2]
ENDIF
PANTA()
NEXT J
READ
P11:=P
P:= ASORT(P11,,, { |x, y| x[1]<y[1] })
p11:={}
NEXT J11

CASE (GA=5 .AND. .NOT. VAR) .OR. (GA=4 .AND. VAR)
* GUARDAR INFORMACION
USE CATEGO
GO TOP
FOR J=1 TO MIN(LEN(P), TEM)
CNIV:=LTRIM(STR(P[J,1]))
IF(LEN(CNIV)=2, P[J,1]:=CNIV, P[J,1]:="0"+CNIV)
REPLACE NIV WITH P[J, 1], CATEG WITH LTRIM(P[J,2])
SKIP
NEXT
IF LEN(P)>TEM
   FOR I=J TO LEN(P)
     APPEND BLANK
     CNIV:=LTRIM(STR(P[I,1]))
     IF(LEN(CNIV)=2, P[I,1]:=CNIV, P[I,1]:="0"+CNIV)
     REPLACE NIV WITH P[I,1], CATEG WITH LTRIM(P[I,2])
   NEXT I
ELSEIF LEN(P)<TEM
   FOR I=J TO TEM
     DELETE
     SKIP
   NEXT
   PACK
ENDIF
WCLOSE()
CLOSE ALL
RETURN

CASE ((GA=6 .OR. GA=0) .AND. .NOT. VAR) .OR. ((GA=0 .OR. GA=5) .AND. VAR)
* SALIR
WCLOSE()
CLOSE ALL
RETURN
ENDCASE
ENDDO
CLOSE ALL
RETURN

FUNCTION PANTA()
I1+=1
IF I1=15 .AND. F<36
I1=4
F+=36
ELSEIF I1=15 .AND. F>=36
VAR:=.T.
ENDIF
RETURN

FUNCTION ENTDIV()
PRIVATE P, TEM, K, VAR:=.F.

IF .NOT. FILE("CATALOG.DBF")
CREA:={}
AADD(CREA, {"ESCAL", "C", 1, 0})
AADD(CREA, {"REFER", "C", 1, 0})
AADD(CREA, {"TIPO", "L", 1, 0})
AADD(CREA, {"NOMBRE", "C", 20, 0})
AADD(CREA, {"NOM_ARCH", "C", 8, 0})
AADD(CREA, {"ESCREF", "C", 2, 0})
AADD(CREA, {"L_INF", "N", 2, 0})
DBCREATE("CATALOG", CREA)
ENDIF
WOPEN(3, 2, 22, 75,.T.)
WBOX()
I1:=5
F:=0
@ 1, 0 SAY CENTER("SUBDIVISIONES DEL UNIVERSO ELECTORAL")
@ 2, 0 SAY "Concepto"
@ 3, 0 SAY "generador³  Nivel ³ Referencia ³ Tipo ³     Nombre            ³"
@ 4, 0 SAY "ÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
K:=1
P:={}
USE CATALOG
UnEl:=.T.
LOCATE FOR ESCAL=="2" .AND. REFER=="1"
IF FILE(NOM_ARCH+".DBF")
	USE (NOM_ARCH) NEW
	UnEl:=EOF()
	CLOSE (CATALOG->NOM_ARCH)
ENDIF
SELECT CATALOG
GO TOP

DO WHILE .NOT. EOF()
AADD(P, { ESCAL, REFER, TIPO, NOMBRE})
@ I1,  4 SAY K PICT "99"
@ I1, 13 GET P[K, 1] PICT "9"
@ I1, 24 GET P[K, 2] PICT "9"
@ I1, 34 GET P[K, 3] PICT "L"
@ I1, 40 GET P[K, 4] PICT "@A"
K+=1
I1+=1
SKIP
ENDDO
LEA:=GETLIST
TEM:=K-1
SET MESSAGE TO 17 CENTER
DO WHILE .T.
IF .NOT. VAR
@ 16, 5 PROMPT "Insertar"  MESSAGE    "  Agregar Concepto Generador  "
ELSE
@ 16, 5 SAY "Insertar"
ENDIF
@ 16, 18 PROMPT "Borrar"      MESSAGE "   Borrar Concepto Generador  "
@ 16, 29 PROMPT "Editar"      MESSAGE "  Editar  Concepto Generador  "
@ 16, 39 PROMPT "Guardar"     MESSAGE "  Guardar Informaci¢n y Salir "
@ 16, 56 PROMPT "Suspender"   MESSAGE "      Suspender y Salir       "
MENU TO GA

GETLIST:={}
IF .NOT. UnEl
	CAMBIOS()
	WCLOSE()
	CLOSE ALL
	RETURN
ENDIF

DO CASE
CASE (GA=1 .AND. .NOT. VAR)
* INSERTAR CATEGORIA
@ 16, 5 SAY "Insertar"
AADD(P, {SPACE(1), SPACE(1), .T., SPACE(20)})
@ I1,  4 SAY K PICT "99"
@ I1, 13 GET P[K, 1] PICT "9"
@ I1, 24 GET P[K, 2] PICT "9"
@ I1, 34 GET P[K, 3] PICT "L"
@ I1, 40 GET P[K, 4] PICT "@A"
FOR J=1 TO 4
AADD(LEA, GETLIST[J])
NEXT
READ
IF P[K,1]=SPACE(1) .OR. P[K,2]=SPACE(1) .OR. P[K, 4]=SPACE(20)
ADEL(P, K)
ASIZE(P, K-1)
FOR J=LEN(LEA)-3 TO LEN(LEA)
ADEL(LEA, J)
NEXT
J-=1
ASIZE(LEA, J-4)
@ I1, F CLEAR TO I1, 75
ELSE
K+=1
I1+=1
IF I1>22
VAR:=.T.
ENDIF
ENDIF

CASE (GA=2 .AND. .NOT. VAR) .OR. (GA=1 .AND. VAR)
* BORRAR CATEGORIA
@ 16, 18 SAY "Borrar"
NUM:=0
WOPEN(19, 12, 21, 46,.T.)
WBOX(1)
@ 0, 0 SAY "   Introduzca N§ a Borrar: "
@ 0, 27 GET NUM PICT "99" RANGE 0, K-1
READ
WCLOSE()
IF NUM>0
ADEL(P, NUM)
ASIZE(P, K-2)
K-=1
I1:=5
VAR:=.F.
@ 5, 0 CLEAR TO 15, 79
FOR J=1 TO K-1
@ I1+J-1,  4 SAY J PICT "99"
@ I1+J-1, 13 GET P[J, 1] PICT "9"
@ I1+J-1, 24 GET P[J, 2] PICT "9"
@ I1+J-1, 34 GET P[J, 3] PICT "L"
@ I1+J-1, 40 GET P[J, 4] PICT "@A"
NEXT
I1=I1+K-1
LEA:=GETLIST
ENDIF

CASE (GA=3 .AND. .NOT. VAR) .OR. (GA=2 .AND. VAR)
* EDITAR PANTALLA
@ 16, 29 SAY "Editar"
GETLIST:=LEA
READ

CASE (GA=4 .AND. .NOT. VAR) .OR. (GA=3 .AND. VAR)
* GUARDAR INFORMACION
GO TOP
FOR J=1 TO MIN(LEN(P), TEM)
FOR I=1 TO 4
FIELDPUT(I, P[J, I])
NEXT I
S_RAY:=SUBSTR(NOMBRE, 1,4)+ESCAL+REFER
FIELDPUT(5, STRTRAN(TRIM(S_RAY), " ", "_"))
FIELDPUT(6, ESCAL+REFER)
SKIP
NEXT J
IF LEN(P)>TEM
   FOR I=J TO LEN(P)
     APPEND BLANK
     FOR J1=1 TO 4
     FIELDPUT(J1, P[I, J1])
     NEXT J1
     S_RAY:=SUBSTR(NOMBRE, 1,4)+ESCAL+REFER
     FIELDPUT(5, STRTRAN(TRIM(S_RAY), " ", "_"))
     FIELDPUT(6, ESCAL+REFER)
   NEXT I
ELSEIF LEN(P)<TEM
   FOR I=J TO TEM
     DELETE
     SKIP
   NEXT
   PACK
ENDIF
EXIT

CASE ((GA=5 .OR. GA=0) .AND. .NOT. VAR) .OR. ((GA=0 .OR. GA=4) .AND. VAR)
* SALIR
EXIT

ENDCASE
ENDDO

WCLOSE()
CLOSE ALL
RETURN

FUNCTION ASIGN()
* RUTINAS PARA ASIGNAR CANDIDATURAS
* A SEGMENTOS DE LA POBLACION DE 
* VOTANTES
PRIVATE V1:=V2:=0, VAR:={}, CN:=.T.
IF FILE("CATALOG.DBF")
   USE CATALOG NEW
   SET FILTER TO RECNO()<LASTREC()-1
   V1:=LASTREC()
ENDIF
IF FILE("CATEGO.DBF")
   USE CATEGO NEW
   V2:=LASTREC()
ENDIF
IF V1=0 .OR. V2=0
   ALERT("Ejecute las opciones del men£; Iniciar anteriores a esta", {"oK"})
ELSEIF V1>=1 .AND. V2>=2
   Asg:=.T.
   Atra:=ALIAS()
   IF FILE("CANDI.DBF")
	USE CANDI NEW
	Asg:=EOF()
	CLOSE CANDI
   ENDIF
   SELECT (Atra)
   WOPEN(3, 2, 22, 75,.T.)
   WBOX()
   @ 0, 0 SAY CENTER("ASIGNACION DE CATEGORIAS A SUBDIVISIONES")
   @ 2, 0 SAY "     Categor¡a                  Niv+Ref   Subdivisi¢n"
   @ 17, 0 SAY CENTER("<F10> Consultar")
   SET KEY -9 TO LISTA()
   SET ESCAPE OFF
   FOR I=1 TO LASTREC()
      @ I+2, 5 SAY CATEG
      @ I+2, 5+LEN(TRIM(CATEG))+1 SAY REPLICATE(".", 30-(LEN(TRIM(CATEG))+1))
      AADD(VAR, CATEGO->ESCREF)
      @ I+2, 35 GET VAR[I] PICT "99"  WHEN CUANDO() VALID BUSCA()
      SKIP
   NEXT
   POSMENU:=I+7
   LEA:=GETLIST
   READ
   @ 17, 0 CLEAR
   SET KEY -9 TO

   DO WHILE .T.
      WOPEN(POSMENU, 15, POSMENU+2, 55, .T.)
      WBOX(1)
      @ 0,  2 PROMPT "Editar"
      @ 0, 12 PROMPT "Guardar/Salir"
      @ 0, 29 PROMPT "Suspender"
      MENU TO ASI
      WCLOSE()

	IF .NOT. Asg
		CAMBIOS()
		WCLOSE()
		CLOSE ALL
		RETURN
	ENDIF

      IF  ASI=1
	  CN:=.F.
	  SET KEY -9 TO LISTA()
	  GETLIST=LEA
	  @ 17, 0 SAY CENTER("<F10> Consultar")
	  READ
	  SET KEY -9 TO
	  @ 17, 0 CLEAR
      ELSEIF ASI=2
	  SELECT CATEGO
	  GO TOP
	  FOR I=1 TO LASTREC()
	      REPLACE ESCREF WITH VAR[I]
	      SKIP
	  NEXT
	  EXIT
      ELSE
	  EXIT
      ENDIF
   ENDDO
   WCLOSE()
   SET ESCAPE ON
ELSE
   ALERT("Ejecute las opciones del men£; Iniciar anteriores a esta", {"oK"})
ENDIF
CLOSE ALL
RETURN

STATIC FUNCTION BUSCA()
oG:=GETACTIVE()
VL:=NIL
IF EMPTY(oG:BUFFER)
     VL:=.F.
ELSE
     SELECT CATALOG
     LOCATE FOR ESCREF=TRIM(oG:BUFFER)
     IF FOUND()
	  @ oG:ROW, oG:COL+4 SAY NOMBRE
	  VL:=.T.
     ELSE
	  @ oG:ROW, oG:COL+4 SAY "Entrada no v lida"+SPACE(5)
	  VL:=.F.
     ENDIF
     SELECT CATEGO
ENDIF
RETURN (VL)

STATIC FUNCTION CUANDO()
IF CN
	KEYBOARD CHR(13)
	RETURN (CN)
ELSE
	RETURN .T.
ENDIF

STATIC FUNCTION LISTA()
oG:=GETACTIVE()
POS:=oG:CARGO
SELECT CATALOG
WOPEN( 3, 41, 20, 73, .T.)
WBOX(1)
SET ESCAPE ON
FLECHADO()
@  0, 0 SAY CENTER("SUBDIVISIONES")
@ 14, 0 SAY CENTER("ÄÄÙ      Esc  ")
@ 15, 0 SAY CENTER("Aceptar   Abortar")
SETCURSOR(0)
oTAB:=CREATABLA(2, 1, 12, 27)
GO TOP
DO WHILE .T.
     oTAB:REFRESHALL()
     DO WHILE NEXTKEY()==0 .AND. .NOT. oTAB:STABILIZE()
     ENDDO
     TECLA:=INKEY(0)
     IF TECLA==27
	  EXIT
     ELSEIF TECLA==13
	  VARIAB:=ESCREF
	  KEYBOARD VARIAB
	  EXIT
     ELSE
	  PROKEY(TECLA)
     ENDIF
ENDDO
SET ESCAPE OFF
WCLOSE()
RETURN

STATIC FUNCTION CREATABLA(nLINT, nCOLT, nLINB, nCOLB)
@ nLINT-1, nCOLT-1 TO nLINB+1, nCOLB+1
oTAB:=TBROWSEDB(nLINT, nCOLT, nLINB, nCOLB)
oTAB:HEADSEP:=CHR(205)+CHR(209)+CHR(205)
oTAB:COLSEP:=CHR(32)+CHR(179)+CHR(32)
oTAB:FOOTSEP:=CHR(205)+CHR(207)+CHR(205)
oTAB:ADDCOLUMN(TBCOLUMNNEW("N§", {||ESCREF}))
oTAB:ADDCOLUMN(TBCOLUMNNEW("Nomb.", {||NOMBRE}))
RETURN (oTAB)

STATIC FUNCTION PROKEY(TECLA)
DO CASE
     CASE TECLA==5           ;oTAB:UP()
     CASE TECLA==24          ;oTAB:DOWN()
     CASE TECLA==18          ;oTAB:PAGEUP()
     CASE TECLA==31          ;oTAB:GOTOP()
     CASE TECLA==3           ;oTAB:PAGEDOWN()
     CASE TECLA==30          ;oTAB:GOBOTTOM()
     OTHERWISE               ;TONE(125); TONE(300)
ENDCASE
RETURN

STATIC FUNCTION FLECHADO()
SETCOLOR("")
FOR J=4 TO 11
     @ J, 29 SAY CHR(176)
NEXT
SETCOLOR("W+/N")
@  4, 29 SAY CHR(24)
@ 11, 29 SAY CHR(25)
SETCOLOR("N/W, W+/N, N")
RETURN

FUNCTION INFOR()
PRIVATE V1:=V2:=0, V3:=.F., TI:={}, P:=PROCNAME()
ALERT("PREPARE LA IMPRESORA PARA GENERAR REPORTE", {"Ok"})
Cursor:=SETCURSOR()
SETCURSOR(0)
IF ISPRINTER()
IF FILE("CATALOG.DBF")
   USE CATALOG NEW
   V1:=LASTREC()
ENDIF
IF FILE("CATEGO.DBF")
   USE CATEGO NEW
   V2:=LASTREC()
ENDIF
IF FILE("TITULOS.DBF")
   USE TITULOS NEW
   FOR I=1 TO 3
	IF(EMPTY(TITULO), V3:=.F., V3:=.T.)
   NEXT
ENDIF
IF V1=0 .OR. V2=0 .OR. (.NOT. V3)
   ALERT("Ejecute las opciones del men£; Iniciar anteriores a esta", {"oK"})
ELSEIF V1>=1 .AND. V2>=2 .AND. V3
   WOPEN(11, 25, 14, 55,.T.)
   WBOX()
   @ 0, 0 SAY CENTER("ESTADO DE IMPRESION ACTIVADO")
   @ 1, 0 SAY CENTER("Espere un Momento...")
   SELECT CATALOG
   INDEX ON ESCREF TO DIVCATE
   SELECT CATEGO
   SET RELATION TO ESCREF INTO CATALOG
   SELECT TITULOS
   FOR I=1 TO 3
	AADD(TI, TITULO)
	SKIP
   NEXT
   TPRI:="INFORME DE INICIO DEL SISTEMA"
   SET DEVICE TO PRINT
   @ 0,  0 SAY " "
   @ 0, 65 SAY "Fecha:"
   @ 0, 72 SAY DATE()
   @ 1, 65 SAY " Hora:"
   @ 1, 72 SAY HORA()
   @ 1, INT((80-LEN(TPRI))/2)  SAY CHR(27)+"E"+TPRI+CHR(27)+"F"
   @ 2, 72 SAY CHAREVEN(Ident)
   @ 3, 0 SAY "T¡tulo del Proceso: "+TI[3]
   @ 5, 0 SAY "Ente encargado del Proceso: "+TI[2]
   @ 7, 0 SAY "Escenario: "+TI[1]
   @ 9, 0 SAY "Subdivisiones:"
   @ 11, 5 SAY "³  Nivel ³ Referencia ³ Tipo ³     Nombre            ³"
   @ 12, 5 SAY "ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
   MID:="³        ³            ³      ³                       ³"
   SELECT CATALOG   
   GO TOP
   FOR I=1 TO LASTREC()
      @ I+12,  5 SAY MID
      @ I+12,  9 SAY ESCAL
      @ I+12, 20 SAY REFER
      @ I+12, 30 SAY TIPO
      @ I+12, 36 SAY NOMBRE
      SKIP
   NEXT
   I+=14
   SELECT CATEGO   
   GO TOP
   @ I, 0 SAY "Categor¡as con Asignaci¢n a Subdivisiones:"   
   @ I+2, 3 SAY "No   CATEGORIA                  Esc+Ref  SUBDIVISION"
   I+=2
   FOR J=1 TO LASTREC()
	@ I+J, 3 SAY NIV
	@ I+J, 6 SAY CATEG
	@ I+J, 6+LEN(TRIM(CATEG))+1 SAY REPLICATE(".",30-LEN(TRIM(CATEG))+1)
	@ I+J, 38 SAY ESCREF
	IF .NOT. CATALOG->(EOF())
	    @ I+J, 43 SAY CATALOG->NOMBRE
	ELSEIF J>1
	    @ I+J, 43 SAY CHR(27)+"E"+"Categor¡a no Asignada"+CHR(27)+"F"
	ELSE
	    @ I+J, 43 SAY TI[1]
	ENDIF
	SKIP
   NEXT
	@ 54, 15 SAY "******** REPORTE TERMINADO ********"
   EJECT
   SET PRINTER TO
   SET DEVICE TO SCREEN
   WCLOSE()
ELSE
   ALERT("Ejecute las opciones del men£; Iniciar anteriores a esta", {"oK"})
ENDIF
CLOSE ALL
ELSE
ALERT("Impresora No Preparada", {"oK"})
ENDIF
SETCURSOR(Cursor)
RETURN

FUNCTION HORA()
h=int(seconds()/(60^2))
m=int((mod(seconds(),(60^2)))/60)
m1=ltrim(str(m))
if len(m1)=1
m1="0"+m1
endif
ap="am"
if (seconds())>=43200
ap="pm"
endif
if (seconds())>46799
h=h-12
endif
RETURN (ltrim(str(h))+":"+m1+" "+ap)

STATIC FUNCTION CAMBIOS()
ALERT("Cambios no podr n ser realizados; Existe Informaci¢n Dependiente")
RETURN