* RUTINA PARA CONTROL DE ACCESO
* A VOTACION
* 05/06/95

REQUEST DBFCDX
SET WRAP ON
SET SCOREBOARD OFF
SET DELETED ON
SET DATE BRITISH
SET DEFAULT TO \SISTEL\DATOS\
SETCANCEL(.F.)
SETCLEARB(177)
SETCURSOR(0)

CLEAR
@ 0, 0 SAY "Sistema de Control de Acceso a Votaci¢n "
@ 0, 54 SAY YEAR(DATE()) PICT "9,999"
SHOWTIME(0, 70, .F., "N/W", .T., .T.)

IF ISCOLOR()
	SETCOLOR("W+/B, R+/W, N, , GR+/W")
ELSE
	SETCOLOR("N/W, W+/N, N, , W/N")
ENDIF

CONF1:=SPACE(55)
CONF2:="ÛÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛÛ"
CONF3:="ÛÛ     ÛÛ ÛÛ       ÛÛ       ÛÛ       ÛÛ       ÛÛ     ÛÛ"
CONF4:="ÛÛÛÛÛÛÛÛÛ ÛÛ       ÛÛ       ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛÛ ÛÛ     ÛÛ"
CONF5:="ÛÛ     ÛÛ ÛÛ       ÛÛ       ÛÛ             ÛÛ ÛÛ     ÛÛ"
CONF6:="ÛÛ     ÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛÛ"
@  9, INT((80-LEN(CONF1))/2) SAY CONF1
@ 10, INT((80-LEN(CONF2))/2) SAY CONF2
@ 11, INT((80-LEN(CONF3))/2) SAY CONF3
@ 12, INT((80-LEN(CONF4))/2) SAY CONF4
@ 13, INT((80-LEN(CONF5))/2) SAY CONF5
@ 14, INT((80-LEN(CONF6))/2) SAY CONF6
@ 15, INT((80-LEN(CONF1))/2) SAY CONF1
SETCLEARB(255)
@ 1, 0 CLEAR TO 1, 79
@ 24, 0 CLEAR TO 24, 79
WSETSHADOW("N+")
Decont:={"Continuar", "Cancelar"}
ContiSi:=ALERT("Este programa debe ser ejecutado en; un ambiente de red de  rea local", Decont)

IF ContiSi=2
	SETCOLOR("")
	SHOWTIME()
	CLS
	QUIT
ENDIF

@ 24, 0 SAY CENTER("Abriendo Archivos. Espere un Momento...")

IF ABRECOM()
	CATALOG->(DBSEEK("21"))
	DO WHILE .NOT. CATALOG->(EOF())
		SELECT (CATALOG->NOM_ARCH)
		IF FCOUNT()==CATALOG->L_INF .OR. EOF() 
			SALIR()
			SETCOLOR("")
			SHOWTIME()
			CLS
			QUIT
		ENDIF
		CATALOG->(DBSKIP())
	ENDDO
ELSE
	SALIR()
	SETCOLOR("")
	SHOWTIME()
	CLS
	QUIT
ENDIF

RELACION()

@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Introduzca Datos...")
@ 24, 0 SAY "<F1> Ayuda"
@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"

* Saltar proximo bloque si hubo caida del sistema

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
		SETCOLOR("")
		SHOWTIME()
		CLS
		QUIT
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
			@ 4, 0 CLEAR TO 4, 70
			LOOP
		ENDIF
	ENDIF
ENDDO
WCLOSE()
* Fin bloque

WOPEN(0, 0, 24, 79, .T.)
WBOX(0)
USE TITULOS SHARED NEW
IF NETERR()
	SALIR()
	SETCOLOR("")
	SHOWTIME()
	CLS
	QUIT
ENDIF
FOR i=1 TO 3
	@ i-1, 0 SAY CENTER(TRIM(TITULO))
	SKIP
NEXT i
i+=1
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
		Control:=INDEXKEY(0)
		Klave:=""
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
		Control:=INDEXKEY(0)
		Klave:=&(INDEXKEY(0))
	ELSE
		@ i, 22 SAY REPLICATE("=", 10)
	ENDIF
	SELECT CATALOG
	i+=1
	SKIP
ENDDO

USE ELECTOR SHARED NEW VIA "DBFCDX"
IF !NETERR()
	SET INDEX TO ELECTOR
	SET FILTER TO &Control==Klave
	DBGOTOP()
	DO WHILE .NOT. EOF()
		IF RLOCK()
			REPLACE CLV1 WITH "0", CLV2 WITH "0"
		ELSE
			ALERT("Otro usuario a Bloqueado registro; Intente Ejecuci¢n de nuevo...")
			WCLOSE()
			CLOSE ALL
			SETCOLOR("")
			SHOWTIME()
			CLS
			QUIT
		ENDIF
		SKIP
	ENDDO
ELSE
	SALIR()
	SETCOLOR("")
	SHOWTIME()
	CLS
	QUIT
ENDIF
Msg1:="<<< Control de Acceso a Votaci¢n >>>"
Color:=SETCOLOR()
SETCOLOR("W+/N")
@ 20, (80-LEN(Msg1))/2 SAY Msg1
SETCOLOR(Color)
WOPEN(6, 6, 18, 73, .T.)
WBOX(0)

@ 0,  0 SAY CENTER("Datos del Elector")
@ 1,  0 TO 1, 66

DO WHILE .T.
	CeVot:=SPACE(8)
	@ 2,  0 SAY "Introduzca N§ de C‚dula:"+SPACE(10)
	@ 3,  0 SAY "Nombre(s) y Apellido(s):"+SPACE(45)
	@ 4,  0 SAY "Direcci¢n:"+SPACE(60)
	@ 6,  0 SAY "Cuaderno N§"+SPACE(7)
	@ 6, 25 SAY "P gina:"+SPACE(6)
	@ 7, 25 SAY "  Fila:"+SPACE(4)
	@ 0, 0 SAY "<Esc> Salir"
	@ 2, 27 GET CeVot PICT "99999999" VALID VALELECT()
	SETCURSOR(1)
	READ
	SETCURSOR(0)
	IF LASTKEY()==27
		Sal:={"Salir", "Continuar"}
		Sil:=ALERT("¨ Salir del Sistema ?", Sal)
		IF Sil=1
			WACLOSE()
			CLOSE ALL
			SETCOLOR("")
			SHOWTIME()
			CLS
			QUIT
		ELSE
			LOOP
		ENDIF
	ENDIF

	@ 9,  0 SAY CENTER(" ¨ Dar Acceso a Votaci¢n ?")
	@ 10, 25 PROMPT "Si"
	@ 10, 30 PROMPT "Cancelar"
	Acceso:=0
	MENU TO Acceso
	IF Acceso==1 .AND. ELECTOR->(RLOCK())
		REPLACE ELECTOR->CLV1 WITH "1"
		ELECTOR->(DBCOMMIT())
		ELECTOR->(DBUNLOCK())
		@ 9, 0 CLEAR TO 10, 66
		@ 9, 0 SAY CENTER("<< ACCESO AUTORIZADO >>")
		@ 10, 0 SAY CENTER("Espere por Favor...")
		FnVt:=0
		DO WHILE .T.
			IF(FnVt<=3, FnVt+=1, FnVt:=1) 
			IF FnVt=1
				@ 10, 45 SAY CHR(45)
			ELSEIF FnVt=2
				@ 10, 45 SAY CHR(47)
			ELSEIF FnVt=3
				@ 10, 45 SAY CHR(92)
			ELSEIF FnVt=4
				@ 10, 45 SAY CHR(124)
			ENDIF
			ELECTOR->(DBSEEK(CeVot))
			IF ELECTOR->(FOUND()) .AND. ELECTOR->CLV2=="1"
				@ 10, 45 SAY SPACE(1)
				EXIT
			ENDIF
		ENDDO
		@ 9, 0 CLEAR TO 10, 66
		Color:=SETCOLOR()
		SETCOLOR("W+*/N")
		Msg2:="Pulse Tecla para Continuar..."
		@ 10, (70-LEN(Msg2))/2 SAY Msg2
		INKEY(0)
		SETCOLOR(Color)
	ENDIF
		@ 9, 0 CLEAR TO 10, 66
ENDDO

STATIC FUNCTION VALELECT()
ELECTOR->(DBSEEK(CeVot))
Valet:=.T.
IF FOUND()
	@ 0, 0 SAY SPACE(11)
	@ 2, 0 SAY SPACE(16)
	@ 3, 27 SAY ELECTOR->APELL_NOMB
	@ 4, 13 SAY ELECTOR->DIRECC
	@ 6, 14 SAY ELECTOR->CUADERNO PICT "9999"
	@ 6, 33 SAY ELECTOR->PAGINA PICT "9999"
	@ 7, 33 SAY ELECTOR->LINEA PICT "99"
	IF CLV1=="1" .OR. CLV2=="1"
		Color:=SETCOLOR()
		SETCOLOR("W+*/N")
		@ 10, 20 SAY "Elector ya Voto. Pulse Tecla...."
		INKEY(0)
		SETCOLOR(Color)
		@ 10, 20 SAY SPACE(33)
		@ 2,  0 SAY "Introduzca N§ de C‚dula:"+SPACE(10)
		@ 3,  0 SAY "Nombre(s) y Apellido(s):"+SPACE(45)
		@ 4,  0 SAY "Direcci¢n:"+SPACE(60)
		@ 6,  0 SAY "Cuaderno N§"+SPACE(7)
		@ 6, 25 SAY "P gina:"+SPACE(6)
		@ 7, 25 SAY "  Fila:"+SPACE(4)
		@ 0, 0 SAY "<Esc> Salir"
		Valet:=.F.
	ELSE
		Valet:=.T.
	ENDIF
ELSE
	ALERT("C‚dula No Localizada; Repita Entrada por Favor...")
	Valet:=.F.
ENDIF
RETURN (Valet)

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
WACLOSE()
CLS
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