* PROGRAMA CANDID.PRG
* DIRECTORIO DE CANDIDATOS
* 11/05/95

FUNCTION CAND()
IF FILE("CATEGO.DBF")
	USE CATEGO
ELSE
	OJO()
	RETURN
ENDIF
IF .NOT. EOF()
	INDEX ON NIV TO CATEGO
ELSE
	OJO()
	RETURN
ENDIF
IF ABREARCH()
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Espere un Momento...")
	USE CATEGO INDEX CATEGO NEW
	Form:={}
	DO WHILE .NOT. EOF()
		IF ESCREF<>"11"
			AADD(Form, ESCREF)
		ENDIF
		SKIP
	ENDDO
	ASORT(Form)
	SELECT CATALOG
	DBSEEK("21")
	DO WHILE ESCAL<SUBSTR(Form[LEN(Form)], 1,1)
		IF TIPO
			Vat:=.T.
			FOR i=1 TO LEN(Form)
				IF Form[i]=ESCREF
					Vat:=.F.
					EXIT
				ENDIF
			NEXT i
			IF Vat
				AADD(Form, ESCREF)
			ENDIF
		ENDIF
		SKIP
	ENDDO
	ASORT(Form)
	FOR i=1 TO LEN(Form)-1
		DO WHILE Form[i]=Form[i+1]
			ADEL(Form, i+1)
			c:=LEN(Form)
			ASIZE(Form, c-1)
		ENDDO
	NEXT i
	FOR i=1 TO LEN(Form)
		DBSEEK(Form[i])
		Form[i]:=SUBSTR(LTRIM(NOMBRE),1,1)+Form[i]
	NEXT i
	SELECT CATEGO
	Crea:={}
	AADD(Crea, {"NIV", "C", 2, 0})
	FOR i=1 TO LEN(Form)
		AADD(Crea, {Form[i], "C", 2, 0})
	NEXT i
	AADD(Crea, {"Cod", "C", 2, 0})
	AADD(Crea, {"Nombre", "C", 35, 0})
	AADD(Crea, {"Cedula", "C", 9, 0})
	AADD(Crea, {"Npar", "N", 4, 0})
	AADD(Crea, {"NpSim", "N", 4, 0})
	IF .NOT. FILE("CANDI.DBF")
		DBCREATE("CANDI.DBF", Crea)
		INDCAN()
	ELSE
		USE CANDI NEW
		IF EOF()
			CLOSE CANDI
			DBCREATE("CANDI.DBF", Crea)
			INDCAN()
		ELSE
			CLOSE CANDI
		ENDIF
	ENDIF
	USE CANDI INDEX CANDI NEW
	AnVnt:=LEN("Examinar Categor¡a")+4
	FOR i=1 TO CATEGO->(LASTREC())
		IF(LEN(TRIM(CATEGO->CATEG))>AnVnt,;
			AnVnt:=LEN(TRIM(CATEGO->CATEG))+4,;
			AnVnt:=AnVnt)
		CATEGO->(DBSKIP())
	NEXT i
	WOPEN(4, 12, 4+CATEGO->(LASTREC())+2, 15+AnVnt, .T.)
	WBOX(1)
*       Mostrar Menu de Opciones con Contenido de CATEGO
	DO WHILE .T.
		SELECT CATEGO
		SET RELATION TO ESCREF INTO CATALOG
		Vnt:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("Escoga una Opci¢n")
		@ 24, 0 SAY "<F1> Ayuda"
		@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
		WSELECT(Vnt)
		CATEGO->(DBGOTOP())
		@ 0, 0 SAY CENTER("Examinar Categor¡a")
		i:=1
		DO WHILE .NOT. CATEGO->(EOF())
			@ i, 0 PROMPT TRIM(CATEGO->CATEG)
			CATEGO->(DBSKIP())
			i+=1
		ENDDO
		MENU TO Cat
		IF LASTKEY()==27
			EXIT
		ELSE
			IF(LEN(LTRIM(STR(Cat)))=1, Cat:="0"+ltrim(str(Cat)), Cat:=ltrim(str(Cat)))
			CATEGO->(DBSEEK(Cat))
			EDICION()
		ENDIF
	ENDDO
ELSE
	OJO()
	RETURN
ENDIF
WCLOSE()
CLOSE ALL
RETURN

STATIC FUNCTION INDCAN()
LOCAL Clv
USE CANDI NEW
Clv:="Niv"
FOR i=2 TO FCOUNT()-4
	Clv+="+"+FIELDNAME(i)
NEXT i
DBCREATEINDEX("CANDI", Clv, {|| &Clv})
CLOSE CANDI
RETURN

STATIC FUNCTION EDICION()
LOCAL Clv, i
WOPEN(3, 3, 22, 76, .T.)
WBOX(1)
@ 0, 0 SAY CENTER("Categor¡a: "+CATEGO->CATEG)
IF CATALOG->ESCREF<>"11"
	SELECT (CATALOG->NOM_ARCH)
	Clv:=INDEXKEY(0)
ELSE
	Clv:=REPLICATE("X", 20)
ENDIF
Eti:={}
Lc:=.F.
SELECT CANDI
FOR i=2 TO FCOUNT()-5
	IF FIELDNAME(i)$Clv
		AADD(Eti, {NIL, SPACE(2), SUBSTR(FIELDNAME(i), 2, 2)})
		Lc:=.T.
	ELSE
		AADD(Eti, {NIL, "00", NIL})
	ENDIF
NEXT i
IF Lc
	DO WHILE .T.
		Vnt:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("F10 Consultar")
		@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
		@ 24, 0 SAY "<F1> Ayuda"
		WSELECT(Vnt)
		SET KEY -9 TO CDMUES
		j:=1
		SETCURSOR(1)
		FOR i=1 TO LEN(Eti)
			IF Eti[i, 2]==SPACE(2) .OR. VAL(Eti[i, 2])>0
				CATALOG->(DBSEEK(Eti[i, 3]))
				Nes:=20-LEN(TRIM(CATALOG->NOMBRE))
				@ j+1, 10 SAY SPACE(Nes)+TRIM(CATALOG->NOMBRE)+":"
				@ j+1, 31 GET Eti[i, 2] PICT "99" VALID CDBUSC()
				GETLIST[j]:cargo:={j, NIL, i}
				j+=1
			ENDIF
		NEXT i
		READ
		SETCURSOR(0)
		SET KEY -9 TO
		IF LASTKEY()==27
			WCLOSE()
			Lc:=.F.
			EXIT
		ELSE
			BRPRIN()
		ENDIF
	ENDDO
ELSE
	j:=1
	BRPRIN()
	WCLOSE()
ENDIF
RETURN

STATIC FUNCTION BRPRIN()
Cat:=CATEGO->NIV
FOR i=1 TO LEN(Eti)
	Cat+=Eti[i, 2]
NEXT i
* TBROWSE PARA CANDIDATOS
SELECT CANDI
j+=3
Vnt:=WSELECT()
WSELECT(0)
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY "Alt+     <A>gregar     <B>orrar     <E>ditar   ||  <F7> Asignar   <Esc> Salir"
WSELECT(Vnt)
Clr:=SETCOLOR()
SETCOLOR("")
FOR k=j+2 TO 16
	@ k, 3 SAY CHR(176)
NEXT k
SETCOLOR("W+/N")
@  j+2, 3 SAY CHR(24)
@ 16, 3 SAY CHR(25)
SETCOLOR(Clr)
DBSEEK(Cat)
Filtro:=SUBSTR(INDEXKEY(0), 1, LEN(INDEXKEY(0))-4)
SET FILTER TO &Filtro==Cat
GO TOP
oTAB:=CREABROWSE(j, 5, 17, 65, Cat)

DO WHILE .NOT. oTAB:STABILIZE()
ENDDO

DO WHILE .T.
	DO WHILE NEXTKEY()==0 .AND. .NOT. oTAB:STABILIZE()
	ENDDO
	IF oTAB:HITTOP .OR. oTAB:HITBOTTOM
		TONE(2000)
	ENDIF
	TECLA:=INKEY(0)
	IF TECLA==27
		SET FILTER TO
		EXIT
	ELSE
		PROTECLA(TECLA)
	ENDIF
ENDDO
RETURN

STATIC FUNCTION CREABROWSE(nLINT, nCOLT, nLINB, nCOLB, Cat)
@ nLINT-1, nCOLT-1 TO nLINB+1, nCOLB+1
oTAB:=TBROWSEDB(nLINT, nCOLT, nLINB, nCOLB)

oTAB:HEADSEP:=CHR(205)+CHR(209)+CHR(205)
oTAB:COLSEP:=CHR(32)+CHR(179)+CHR(32)
oTAB:FOOTSEP:=CHR(205)+CHR(207)+CHR(205)

FOR i=FCOUNT()-4 TO FCOUNT()-2
    oTAB:ADDCOLUMN(TBCOLUMNNEW(FIELDNAME(i), FIELDWBLOCK(FIELDNAME(i), SELE())))
NEXT

RETURN (oTAB)

STATIC FUNCTION PROTECLA(TECLA)
DO CASE
     CASE TECLA==5           ;oTAB:UP()
     CASE TECLA==24          ;oTAB:DOWN()
     CASE TECLA==19          ;oTAB:LEFT()
     CASE TECLA==26          ;oTAB:PANLEFT()
     CASE TECLA==4           ;oTAB:RIGHT()
     CASE TECLA==2           ;oTAB:PANRIGHT()
     CASE TECLA==18          ;oTAB:PAGEUP()
     CASE TECLA==31          ;oTAB:GOTOP()
     CASE TECLA==3           ;oTAB:PAGEDOWN()
     CASE TECLA==30          ;oTAB:GOBOTTOM()
     CASE TECLA==1           ;oTAB:HOME()
     CASE TECLA==29          ;oTAB:PANHOME()
     CASE TECLA==6           ;oTAB:END()
     CASE TECLA==23          ;oTAB:PANEND()
     CASE TECLA==28          ;HELP("BRPRIN")
     CASE TECLA==274         ;EDITA(oTAB, 2)
     CASE TECLA==304         ;BORRA(oTAB, 2)
     CASE TECLA==286         ;AGREGA(oTAB)
     CASE TECLA==-6          ;ASIGNAC()
     CASE TECLA==299         ;REFRES()
     OTHERWISE               ;TONE(125); TONE(300)
ENDCASE
RETURN

STATIC FUNCTION AGREGA(oTAB)
WOPEN(6, 17, 13, 63, .T.)
WBOX(1)
@ 0, 0 SAY CENTER("Inscribir")
@ 1, 0 TO 1, 46
SETCURSOR(1)
IF EOF()
	Cod_Ag:=1
ELSE
	Nor:=RECNO()
	GO BOTTOM
	FOR j=1 TO FCOUNT()
		IF FIELDSIZE(j)>=30
			EXIT
		ENDIF
	NEXT j
	Cod_Ag:=VAL(FIELDGET(j-1))+1
	GO Nor
ENDIF
Cod_Ag:=LTRIM(STR(Cod_Ag))
IF(LEN(Cod_Ag)=1, Cod_Ag:="0"+Cod_ag, Cod_ag:=Cod_Ag)
VAR1:=Cod_Ag
VAR2:=SPACE(35)
VAR3:=SPACE(9)
@ 2, 0 SAY "C¢digo:" GET VAR1 PICT "99" WHEN CUANDO()
@ 3, 0 SAY "Nombre:" GET VAR2 PICT "@!" VALID IF(EMPTY(VAR2), .F., .T.)
@ 4, 0 SAY "C‚dula:" GET VAR3 PICT "@!"
READ
IF LASTKEY()==27
	WCLOSE()
	SETCURSOR(0)
	RETURN
ELSE
SELECT CANDI
APPEND BLANK
FOR i=1 TO FCOUNT()-5
	FIELDPUT(i, SUBSTR(Cat, -1+(2*i), 2))
NEXT i
REPLACE COD WITH VAR1, NOMBRE WITH VAR2, CEDULA WITH VAR3
WCLOSE()
SETCURSOR(0)
oTAB:REFRESHALL()
ESTABILIZE(oTAB)
ENDIF
RETURN

FUNCTION CDBUSC()
LOCAL i, p, Bqd, Vl, c, q
oG:=GETACTIVE()
IF(PROCNAME(1)=="(b)EDICION", c:=0, c:=1)
p:=oG:cargo[1]
q:=oG:cargo[3]
oG:cargo[2]:=oG:BUFFER
Bqd:=""

IF LEN(oG:cargo[2])=2
	FOR i=1 TO p
		Bqd+=GETLIST[i]:cargo[2]
	NEXT i
	mas:=0
ELSE
	mas:=3
	Bqd:=oG:cargo[2]
ENDIF

CATALOG->(DBSEEK(Eti[q+c, 3]))
Atra:=ALIAS()
SELECT (CATALOG->NOM_ARCH)
IF CATALOG->(RECNO())=CATALOG->(LASTREC())
	Bqd:=""
	FOR i=LEN(GETLIST)-1 TO LEN(GETLIST)
		Bqd+=GETLIST[i]:cargo[2]
	NEXT i
ENDIF

DBSEEK(Bqd)
IF FOUND()
	FOR i=1 TO CATALOG->L_INF
		IF FIELDSIZE(i)>=30
			EXIT
		ENDIF
	NEXT i
	Vl:=.T.
	IF i<CATALOG->L_INF
		@ oG:row, oG:col+4+mas SAY FIELDGET(i)
	ELSE
		@ oG:row, oG:col+4 SAY "C¢digo Localizado             "
	ENDIF
ELSE
	Vl:=.F.
	@ oG:row, oG:col+4 SAY "C¢digo no Encontrado          "
ENDIF
SELECT (Atra)
RETURN (Vl)

FUNCTION CDMUES(Pro)
LOCAL i, oM, Lg, Ps, j, k, c
oM:=GETACTIVE()
IF(Pro=="EDICION", c:=0, c:=1)
Lg:=oM:cargo[3]+c
j:=oM:cargo[3]
Atra:=ALIAS()
CATALOG->(DBSEEK(Eti[Lg, 3]))
IF CATALOG->TIPO
	IF Lg>1+c
		Ps:=GETLIST[j-1]:cargo[3]+c
		CATALOG->(DBSEEK(Eti[Ps, 3]))
		SELECT (CATALOG->NOM_ARCH)
		ClVl:=&(INDEXKEY(0))
		ClVr:=INDEXKEY(0)
		CATALOG->(DBSEEK(Eti[Lg, 3]))
		SELECT (CATALOG->NOM_ARCH)
		SET FILTER TO &ClVr=ClVl
		GO TOP
	ELSE
		CATALOG->(DBSEEK(Eti[Lg, 3]))
		SELECT (CATALOG->NOM_ARCH)
	ENDIF
	FOR i=1 TO CATALOG->L_INF
		IF FIELDSIZE(i)>=30
			j:=i
			EXIT
		ENDIF
	NEXT i
	Etq:={"Cod", "Nombre"}
	Cam:={j-1, j}
	WOPEN(4, 38, 21, 78, .T.)
	WBOX(0)
	@ 0, 0 SAY CENTER(TRIM(Plr(CATALOG->NOMBRE)))
	Clr:=SETCOLOR()
	SETCOLOR("")
	FOR k=4 TO 15
		@ k, 0 SAY CHR(176)
	NEXT k
	SETCOLOR("W+/N")
	@  4, 0 SAY CHR(24)
	@ 15, 0 SAY CHR(25)
	SETCOLOR(Clr)
	oTAB:=CREALIS(2, 2, 15, 40)
	DO WHILE .NOT. oTAB:STABILIZE()
	ENDDO
	
	DO WHILE .T.
		DO WHILE NEXTKEY()==0 .AND. .NOT. oTAB:STABILIZE()
		ENDDO
		IF oTAB:HITTOP .OR. oTAB:HITBOTTOM
			TONE(2000)
		ENDIF
		TECLA:=INKEY(0)
		IF TECLA==13
			EXIT
		ELSE
			PROMOV(TECLA)
		ENDIF
	ENDDO
	WCLOSE()
	SET FILTER TO
	oM:VarPut(FIELDGET(j-1))
	SELECT (Atra)
	KEYBOARD CHR(13)
ENDIF
RETURN

STATIC FUNCTION ASIGNAC()
* ASIGNACION DE PARTIDOS O GRUPOS
* A CANDIDATOS
LOCAL Lcre:=LEN(Crea)
Sar:=ALIAS()
IF .NOT. FILE("PART_GRP.DBF")
	RETURN
ELSE
	USE PART_GRP INDEX PART_GRP NEW
ENDIF

IF (.NOT. CANDI->(EOF())) .AND. (.NOT. PART_GRP->(EOF()))
	IF .NOT. FILE("INTERM.DBF")
		ASIZE(Crea, Lcre-4)
		AADD(Crea, {"NO", "C", 3, 0})
		DBCREATE("INTERM", Crea)
		Clint:=CANDI->(INDEXKEY(0))+"+"+"NO"
		USE INTERM NEW
		DBCREATEINDEX("INTERM", Clint, {|| &Clint})
		CLOSE INTERM
	ENDIF
	USE INTERM INDEX INTERM NEW
	SET RELATION TO NO INTO PART_GRP
	SELECT CANDI
	SET RELATION TO INDEXKEY(0) INTO INTERM
	ValCan:=&(INDEXKEY(0))
	ValClv:=INDEXKEY(0)
	Vact:=WSELECT()
	WSELECT(0)
	Pan24:=SAVESCREEN(24, 0, 24, 79)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("<Enter> Incluir o Sumprimir                        <Esc> Salir")
	WSELECT(Vact)   
	WOPEN(4, 48, 21, 78, .T.)
	WBOX(1)
	@ 0, 0 SAY CENTER("Partidos o Grupos")
	Clr:=SETCOLOR()
	SETCOLOR("")
	FOR k=2 TO 14
		@ k, 0 SAY CHR(176)
	NEXT k
	SETCOLOR("W+/N")
	@  2, 0 SAY CHR(24)
	@ 14, 0 SAY CHR(25)
	SETCOLOR(Clr)
	@ 1, 1 TO 15, 26 DOUBLE
	SELECT PART_GRP
	DBGOTOP()
	MenPar:={}
	MenAsg:={}
	MenRst:={}
	DO WHILE .NOT. EOF()
		AADD(MenPar, NO+" "+TRIM(SIGLAS))
		AADD(MenRst, {NO, .F., .F.})
		AADD(MenAsg, .T.)
		DBSKIP()
	ENDDO
	SELECT INTERM
	DBSEEK(ValCan)
	IF FOUND()
		DO WHILE &ValClv==ValCan
			FOR i=1 TO LEN(MenPar)
				IF MenRst[i, 1]==PART_GRP->NO
					MenRst[i, 2]:=.T.
					MenRst[i, 3]:=.T.
					MenPar[i]+="  "+CHR(251)
				ENDIF
			NEXT i
			SKIP
		ENDDO
	ENDIF
	ClTip:=SUBSTR(ValClv, 1, LEN(ValClv)-4)
	VlTip:=SUBSTR(ValCan, 1, LEN(ValCan)-2)
	DBSEEK(VlTip)
	IF FOUND()
		DO WHILE &ClTip==VlTip
			IF &ValClv<>ValCan
				FOR i=1 TO LEN(MenPar)
					IF MenRst[i, 1]==PART_GRP->NO
						MenAsg[i]:=.F.
					ENDIF
				NEXT i
			ENDIF
			SKIP
		ENDDO
	ENDIF
	Ent:=1
	DO WHILE .T.
		Opcion:=ACHOICE(2, 3, 14, 25, MenPar, MenAsg,,Ent)
		IF LASTKEY()==13
		    Ent:=Opcion
		    IF CHR(251)$MenPar[Opcion]
			MenPar[Opcion]:=STRTRAN(MenPar[Opcion], CHR(251), "")
			MenRst[Opcion, 3]:=.F.
		    ELSE
			MenPar[Opcion]:=TRIM(MenPar[Opcion])+"  "+CHR(251)
			MenRst[Opcion, 3]:=.T.
		    ENDIF
		ELSEIF LASTKEY()==27
			FOR i=1 TO LEN(MenPar)
				IF .NOT. MenAsg[i]
					k:=LEN(MenPar)
					ADEL(MenPar, i)
					ADEL(MenRst, i)
					ADEL(MenAsg, i)
					ASIZE(MenPar, k-1)
					ASIZE(MenRst, k-1)
					ASIZE(MenAsg, k-1)
				ENDIF
			NEXT i
			FOR i=1 TO LEN(MenPar)
				IF MenRst[i, 2] .AND. (.NOT. MenRst[i, 3])
					DBSEEK(ValCan+MenRst[i, 1])
					DBDELETE()
				ELSEIF (.NOT. MenRst[i, 2]) .AND. MenRst[i, 3]
				   DBAPPEND()
				   Vrem:=ValCan+MenRst[i, 1]
				   FOR j=1 TO FCOUNT()-1
				      IF FIELDNAME(j)$UPPER(INDEXKEY(0))
					Valor:=SUBSTR(Vrem, -1+(2*j), 2)
					FIELDPUT(j, Valor)
				      ENDIF
				   NEXT j
				  j:=FCOUNT()
					IF FIELDNAME(j)$UPPER(INDEXKEY(0))
						Valor:=SUBSTR(Vrem, -1+(2*j), 3)
						FIELDPUT(j, Valor)
					ENDIF
				ENDIF
			NEXT i
			EXIT
		ENDIF
	ENDDO
	WCLOSE()
	Vact:=WSELECT()
	WSELECT(0)
	RESTSCREEN(24, 0, 24, 79, Pan24)
	WSELECT(Vact)
	CLOSE INTERM
ENDIF
CLOSE PART_GRP
SELECT (Sar)
RETURN