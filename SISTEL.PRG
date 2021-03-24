* PROGRAMA PRINCIPAL ** SISTEMA DE VOTACION
* SISTEL.PRG
* 11/05/95

STATIC PRI, ITEM:={}, UBIC:={}, MENPRI:={}, MENSJP:={}, IND:=.F.

FUNCTION PRINCIPAL()
PUBLIC OPC
SET WRAP ON
SET SCOREBOARD OFF
SET DELETED ON
SET DATE BRITISH
SET DEFAULT TO \SISTEL\DATOS\
SET PRINTER TO LPT1
SETCANCEL(.F.)
SETCLEARB(177)
CLEAR
@ 0, 0 SAY "Sistema de Informaci¢n Electoral"
@ 0, 35 SAY YEAR(DATE()) PICT  "9,999"
SHOWTIME(0, 70, .F., "N/W", .T., .T.)

/* IF ISCOLOR()
	SETCOLOR("W+/B, R+/W, N, , GR+/W")
ELSE
	SETCOLOR("N/W, W+/N, N, , W/N")
ENDIF */

VAR1:=SPACE(50)
VAR2:=" ÛÛÛÛÛÛÛ  ÛÛ  ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ  ÛÛ      "
VAR3:=" Û        ÛÛ  Û           ÛÛ     ÛÛ       ÛÛ      "
VAR4:=" ÛÛÛÛÛÛÛ  ÛÛ  ÛÛÛÛÛÛÛ     ÛÛ     ÛÛÛÛÛ    ÛÛ      "
VAR5:="      ÛÛ  ÛÛ       ÛÛ     ÛÛ     ÛÛ       ÛÛ      "
VAR6:=" ÛÛÛÛÛÛÛ  ÛÛ  ÛÛÛÛÛÛÛ     ÛÛ     ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ "
@  9, (80-LEN(VAR1))/2 SAY VAR1
@ 10, (80-LEN(VAR2))/2 SAY VAR2 
@ 11, (80-LEN(VAR3))/2 SAY VAR3 
@ 12, (80-LEN(VAR4))/2 SAY VAR4 
@ 13, (80-LEN(VAR5))/2 SAY VAR5 
@ 14, (80-LEN(VAR6))/2 SAY VAR6 
@ 15, (80-LEN(VAR1))/2 SAY VAR1
Color:=SETCOLOR()
SETCOLOR("W+/N")
Var:="Versi¢n 1.x"
@ 17, (80-LEN(VAR))/2 SAY Var
FOR i=19 TO 22
    IF i=19
	Var:=""
    ELSEIF i=20
	Var:=""
    ELSEIF i=21
	Var:=""
    ELSEIF i=22
	Var:=""
    ENDIF
    @ i, (79-LEN(Var))/2 SAY Var
NEXT i
Ident:=CHR(1)+CHR(83)
Ident+=CHR(2)+CHR(73)
Ident+=CHR(3)+CHR(83)

VAR1:=""
VAR2:=""
VAR3:=""
@ 4, (80-LEN(VAR1))/2 SAY VAR1
@ 5, (80-LEN(VAR2))/2 SAY VAR2
@ 6, (80-LEN(VAR3))/2 SAY VAR3

SETCOLOR(Color)
SETCLEARB(255)
@  1, 0 CLEAR TO  1, 79
WSETSHADOW("N+")
WSETMOVE(.F.)
MENPRI:={"Configurar", "Generar Ambiente", "Procesar Escrutinios"}
MENSJP:={"      Define un nuevo escenario electoral       ",;
	 "Entrada de datos al ambiente generado en Iniciar",;
	 " Votaci¢n Directa y Totalizaci¢n de Escrutinios "}
Ident+=CHR(4)+CHR(84)+CHR(5)+CHR(69)+CHR(6)+CHR(76)
Ident+=CHR(7)+CHR(40)+CHR(8)+CHR(41)

DO WHILE .T.
	SET MESSAGE TO 24 CENTER
	SET KEY 27 TO ESC_FIN
	MENU_PRIN()
	IND:=.F.
	IF PRI>0
		SET KEY 27 TO
		SET KEY 19 TO CAMBI
		SET KEY  4 TO CAMBI
		CASOS(PRI)
		DESP_SUBM()
		WCLOSE()
		SET KEY 19 TO
		SET KEY  4 TO
	ENDIF
	IF OPC>0
		DO CASE
			CASE PRI=1
				SETCURSOR(1)
				DEFIN()
			CASE PRI=2
				ADMENU()
			CASE PRI=3
				ENTVOT()
		ENDCASE
		KEYBOARD CHR(13)
	ENDIF
ENDDO
RETURN

STATIC FUNCTION CASOS(A)
IF A=1
	ITEM:={"T¡tulos del Proceso", "Categor¡as de Cargos",;
		"Subdivisiones del Universo Electoral",;
		"Asignar Categor¡as en Subdivisiones", "Informe de Inicio"}
	UBIC:={2, 0, 8, 38}
ELSEIF A=2
	ITEM:={"Subdivisiones" , "Reporte Subdivisiones", "Generar Subdivisiones Enumeradas",;
		"Partidos o Grupos", "Candidatos", "Reporte Candidatos",;
		"Establecer Configuraci¢n"}
	UBIC:={2, 25, 10, 58}
ELSEIF A=3
	ITEM:={"Votaci¢n", "Totalizaci¢n"}
	UBIC:={2, 60, 5, 73}
ENDIF
RETURN

STATIC FUNCTION MENU_PRIN()
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY "<F1> Ayuda"
@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
SETCURSOR(0)
IF IND
	KEYBOARD CHR(13)
ENDIF
PROTEC()
FOR I=1 TO LEN(MENPRI)
	@ 1, 27*(I-1)+INT((27-LEN(MENPRI[I]))/2) PROMPT MENPRI[I];
		MESSAGE MENSJP[I]
NEXT
LLAMREF()
MENU TO PRI
RETURN

STATIC FUNCTION DESP_SUBM()
WOPEN(UBIC[1], UBIC[2], UBIC[3], UBIC[4], .T.)
WBOX(1)
OPC:=ACHOICE(0, 0, LEN(ITEM), UBIC[4]-1, ITEM,,,OPC)
RETURN

FUNCTION ESC_FIN()
SET KEY 27 TO
SAL:=ALERT("SALIR DEL SISTEMA", {"Si", "Cancelar"})
IF SAL=1
	SETCOLOR("")
	CLS
	SHOWTIME()
        RUN CHDIR \
	QUIT
ENDIF
SET KEY 27 TO ESC_FIN
RETURN

STATIC FUNCTION CAMBI()
IF LASTKEY()=19
	IF(PRI=1, PRI:=3, PRI-=1)
ELSEIF LASTKEY()=4
	IF(PRI=3, PRI:=1, PRI+=1)
ENDIF
IND:=.T.
KEYBOARD CHR(27)
RETURN