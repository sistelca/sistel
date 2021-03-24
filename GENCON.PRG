* PROGRAMA GENCON.PRG
* 11/05/95

FUNCTION GENF()
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Verificando Informaci¢n, Espere un momento...")

IF FILE("CATALOG.DBF") .AND. FILE("DIVCATE.NTX")
	USE CATALOG INDEX DIVCATE
ELSE
	OJO()
	RETURN
ENDIF

IF LASTREC()>=4
	nCAM:={}
	DO WHILE .NOT. EOF()
		IF (.NOT. TIPO ) .AND. RECNO()<LASTREC()
			AADD(nCAM, {LTRIM(NOMBRE), SUBSTR(TRIM(NOMBRE), 1, 1)+ESCREF, ESCREF})
		ELSEIF (.NOT. TIPO) .AND. RECNO()=LASTREC()
			AADD(nCAM, {LTRIM(NOMBRE), "NUM", ESCREF})
		ENDIF
		SKIP
	ENDDO
ELSE
	CLOSE ALL
	OJO()
	RETURN
ENDIF

WOPEN(5, 20, LEN(nCAM)+7, 41, .T.)
WBOX(1)
DO WHILE .T.
	Vnt:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Elija una Opci¢n")
	@ 24, 0 SAY "<F1> Ayuda"
	@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
	WSELECT(Vnt)
	@ 0, 0 SAY CENTER("GENERAR")
	FOR i=1 TO LEN(nCAM)
		@ i, 0 PROMPT nCAM[i, 1]
	NEXT i
	MENU TO Gen
	IF LASTKEY()==27
		WCLOSE()
		EXIT
	ENDIF
	Vdor:=ABREARCH()
	DBSEEK(nCAM[Gen, 3])
	IF VAL(ESCAL)=2 .AND. Vdor
		WOPEN(10, 15, 17, 55, .T.)
		WBOX(1)
		Vnt:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("Introduzca Dato Solicitado por el Sistema")
		@ 24, 0 SAY "<F1> Ayuda"
		@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
		WSELECT(Vnt)
		nF:=0
		cF:=SPACE(1)
		@ 0, 0 SAY CENTER("Generar "+nCAM[Gen, 1])
		SETCURSOR(1)
		@ 2, 5 SAY "N§ de "+nCAM[Gen, 1]+":" GET nF PICT "99" RANGE 1, 30
		@ 4, 5 SAY "Confirmar (S)" GET cF
		READ
		SETCURSOR(0)
		Vnt:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		IF cF=="S"
			SELECT (NOM_ARCH)
			ZAP
			FOR i=1 TO nF
				APPEND BLANK
				s:=FIELDNUM(nCAM[Gen, 2])
				vr:=LTRIM(STR(i))
				IF(LEN(vr)=1, vr:="0"+vr, vr:=vr)
				FIELDPUT(s, vr)
				@ 24, 0 SAY CENTER(nCAM[Gen, 1]+" "+vr)
			NEXT i
			SELECT CATALOG
		ENDIF
		WSELECT(Vnt)
		WCLOSE()
	ELSEIF  VAL(ESCAL)>2 .AND. Vdor
		nESC:=ESCAL
		IF(RECNO()=LASTREC(), vGEN:="N_MESAS", vGEN:="NO"+ESCREF)
		SELECT (CATALOG->NOM_ARCH)
		aGENE:=ALIAS()
		CATALOG->(DBSEEK(LTRIM(STR(VAL(nESC)-1))+"1"))
		SELECT (CATALOG->NOM_ARCH)
		eGENE:=ALIAS()
		LOCATE FOR &vGEN<>0
		IF FOUND()
			WOPEN(9, 17, 15, 60, .T.)
			WBOX(1)
			@ 0, 0 SAY CENTER("Informaci¢n Verificada")
			@ 1, 0 SAY "Generando Informaci¢n, Espere por Favor..."
			SELECT (aGENE)
			ZAP
			SELECT (eGENE)
			DO WHILE FOUND()
				iDE:={}
				FOR i=1 TO CATALOG->L_INF
					IF FIELDNAME(i)$INDEXKEY(0)
						AADD(iDE, {FIELDNAME(i), FIELDGET(i)})
					ENDIF
				NEXT i
				nCT:=&vGEN
				SELECT (aGENE)
				FOR i=1 TO nCT
					APPEND BLANK
					FOR j=1 TO LEN(iDE)
						s:=FIELDNUM(iDE[j,1])
						FIELDPUT(s, iDE[j,2])
					NEXT j
					s:=FIELDNUM(nCAM[Gen,2])
					aRM:=LTRIM(STR(i))
					IF(LEN(aRM)=1, aRM:="0"+aRM, aRM:=aRM)
					FIELDPUT(s, aRM)
				NEXT i
				SELECT (eGENE)
				CONTINUE
			ENDDO
			WCLOSE()
		ELSE
			OJO()
		ENDIF
	ELSEIF .NOT. Vdor
		OJO()
		WCLOSE()
		EXIT
	ENDIF
ENDDO
CLOSE ALL
RETURN

FUNCTION OJO()
	ALERT("Informaci¢n Insuficiente, proceso Abortado; Realize las actividades Anteriores a esta Opci¢n", "oK")
RETURN

FUNCTION ESCON()
* GENERA MEMORIA DEL SISTEMA
* EN LOS ARCHIVOS DEL CATALOGO

@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Espere un Momento...")

VLD:=.F.
PtGp:=.T.
IF FILE("CANDI.DBF") .AND. FILE("CANDI.NTX")
	USE CANDI INDEX CANDI
	PACK
	VLD:=EOF()
ELSE
	OJO()
	RETURN
ENDIF

IF VLD
	OJO()
	CLOSE ALL
	RETURN
ENDIF

IF FILE("INTERM.DBF")
	USE INTERM INDEX INTERM NEW
	PACK
	PtGp:=EOF()
	USE PART_GRP INDEX PART_GRP NEW
	PACK
	CLOSE PART_GRP
	SELECT INTERM
	GO TOP

	IF .NOT. EOF()
		SELECT CANDI
		CaIn:=INDEXKEY(0)
		DBSETRELATION("INTERM", {|| &CaIn}, &CaIn)
	ELSE
		CLOSE INTERM
	ENDIF
ENDIF

USE CATEGO INDEX CATEGO NEW
WOPEN(7, 3, 17, 76, .T.)
WBOX(1)
@ 0, 0 SAY CENTER("Calculando M xima Frecuencia por Categor¡a")

ACUM:=0
DO WHILE .NOT. EOF()
	Control:=NIV
	SELECT CANDI
	DBSEEK(Control)
	DO WHILE NIV==Control
		MAXFRE:=0
		Clv:=INDEXKEY(0)
		Vlr:=&(INDEXKEY(0))
		Clv:=SUBSTR(Clv, 1, LEN(Clv)-4)
		Vlr:=SUBSTR(Vlr, 1, LEN(Vlr)-2)
		N_PACU:=0
		DO WHILE &Clv==Vlr
			MAXFRE+=1
			N_PAR:=0
			IF .NOT. PtGp
				Clave:=INDEXKEY(0)
				Valor:=&(INDEXKEY(0))
				SELECT INTERM
				IF EOF()
					OJO()
					WCLOSE()
					CLOSE ALL
					RETURN
				ENDIF
				DO WHILE &Clave==Valor
					N_PACU+=1
					N_PAR+=1
					SKIP
				ENDDO
			ENDIF
			N_PACU+=1
			SELECT CANDI
			REPLACE CANDI->Npar WITH N_PACU, CANDI->NpSim WITH N_PAR
			MAXFRE+=N_PAR
			SKIP
		ENDDO
		IF MAXFRE+2>CATEGO->FSIM
			REPLACE CATEGO->FSIM WITH MAXFRE+2      && 2 ACUMULA TARJETAS EN BLANCO
		ENDIF                                           && Y MESA ESCRUTADA
	ENDDO
	SELECT CATEGO
	ACUM+=CATEGO->FSIM
	REPLACE CATEGO->FACU WITH ACUM
	SKIP
ENDDO

* GENERAR MEMORIA DEL SISTEMA A PARTIR DE ACUM
@ 2, 0 SAY CENTER("Generando Memoria del Sistema...")
CLOSE ALL
USE CATALOG INDEX DIVCATE
DBSEEK("21")
DO WHILE .NOT. EOF()
	USE (NOM_ARCH) NEW
	Mem:=DBSTRUCT()
	ASIZE(Mem, CATALOG->L_INF)
	FOR i=1 TO ACUM
		AADD(Mem, {"VOT"+LTRIM(STR(i)), "N", 6, 0})
	NEXT i
	CLOSE (CATALOG->NOM_ARCH)
	DBCREATE("TEMPO", Mem)
	USE TEMPO NEW
	APPEND FROM (CATALOG->NOM_ARCH)
	CLOSE TEMPO
	ERASE ("\SISTEL\DATOS\"+CATALOG->NOM_ARCH+".DBF")
	RENAME \SISTEL\DATOS\TEMPO.DBF TO ("\SISTEL\DATOS\"+CATALOG->NOM_ARCH+".DBF")
	SELECT CATALOG
	SKIP
ENDDO
@ 4, 0 SAY CENTER("Reindexando las Bases de Datos...")
ABREARCH()
DBSEEK("21")
DO WHILE .NOT. EOF()
	SELECT (NOM_ARCH)
	REINDEX
	SELECT CATALOG
	SKIP
ENDDO
@ 6, 0 SAY CENTER("Proceso Terminado û. Pulse tecla para Salir")
INKEY(0)
CLOSE ALL
WCLOSE()
RETURN