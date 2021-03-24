* PROGRAMA REPCON.PRG
* 11/05/95

FUNCTION RSUB()
* REPORTES DE SUBDIVISIONES
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Generar Listado de Divisiones")
@ 24, 0 SAY "<F1> Ayuda"
@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
Rpt:=.F.
RpLs:={}
RpPr:={}
IF FILE("CATALOG.DBF ")
	USE CATALOG
	IF FILE("DIVCATE.NTX")
		SET INDEX TO DIVCATE
	ELSE
		INDEX ON ESCREF TO DIVCATE
	ENDIF
	IF LASTREC()>=4
		AADD(RpPr, {NOMBRE, ESCAL, REFER})
		DBSEEK(21)
		DO WHILE .NOT. EOF()
			IF FILE(NOM_ARCH+".DBF")
				USE (NOM_ARCH) NEW
				Nrg:=EOF()
				SELECT CATALOG
				CLOSE (NOM_ARCH)
				IF .NOT. Nrg
					Rpt:=.T.
					AADD(RpPr, {NOMBRE, ESCAL, REFER})
				   IF TIPO
					AADD(RpLs, {Plr(NOMBRE), ESCAL})
				   ENDIF
				ENDIF
				SKIP
			ELSE
				EXIT
			ENDIF
		ENDDO
	ENDIF
ENDIF

IF Rpt
WOPEN(3, 20, LEN(RpLs)+5, 41, .T.)
WBOX(1)
DO WHILE .T.
	Vnt:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Elija una Opci¢n")
	@ 24, 0 SAY "<F1> Ayuda"
	@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
	WSELECT(Vnt)
	@ 0, 0 SAY CENTER("IMPRIMIR")
	FOR j=1 TO LEN(RpLs)
		@ j, 0 PROMPT RpLs[j, 1]
	NEXT j
	MENU TO Lst
	IF Lst>0
		Tmp1:=ACLONE(RpPr)
		Fp:=RpLs[Lst, 2]
		FOR j=1 TO LEN(RpPr)
			IF VAL(RpPr[j, 2])>=VAL(Fp)
				ADEL(RpPr, j)
				ASIZE(RpPr, LEN(RpPr)-1)
				j-=1
			ENDIF
		NEXT j
		WOPEN(3+Lst, 35, Lst+LEN(RpPr)+5, 56, .T.)
		WBOX(1)
		DO WHILE .T.
			Vnt:=WSELECT()
			WSELECT(0)
			@ 24, 0 CLEAR TO 24, 79
			@ 24, 0 SAY CENTER("Elija una Opci¢n")
			@ 24, 0 SAY "<F1> Ayuda"
			@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
			WSELECT(Vnt)
			@ 0, 0 SAY CENTER("POR")
			FOR j=1 TO LEN(RpPr)
				@ j, 0 PROMPT RpPr[j, 1]
			NEXT j
			MENU TO Prt
			IF Prt>0
				EscLs:=RpLs[Lst,2]+"1"
				EscPr:=RpPr[Prt,2]+RpPr[Prt,3]
				CLOSE ALL
				IMPRDIV(EscLs,EscPr)
			ELSE
				WCLOSE()
				RpPr:=ACLONE(Tmp1)
				EXIT
			ENDIF
		ENDDO
	ELSE
		WCLOSE()
		EXIT
	ENDIF
ENDDO
ELSE
	ALERT("La Informaci¢n Contenida en los Archivos de datos; es Insuficiente, Ejecute los Procedimientos; Anteriores", {"oK"})
ENDIF
CLOSE ALL
RETURN

FUNCTION Plr(Caden)
LOCAL Vcls:="aeiou ‚¡¢£", Sb1, Sb2, p
p:=AT(" ", Caden)
Sb1:=SUBSTR(Caden, 1, p-1)
Sb2:=SUBSTR(Caden, p, LEN(Caden))
IF(SUBSTR(Sb1, p-1, 1)$Vcls, Sb1+="s", Sb1+="es")
CadRt:=Sb1+Sb2
RETURN (CadRt)

STATIC FUNCTION IMPRDIV(Ls,Pr)
ABREARCH()
Timp:="Listado de "
DBSEEK(Ls)
Timp+=TRIM(Plr(NOMBRE))
DBSEEK(Pr)
IF VAL(ESCAL)>1
	Timp+=" "+"por "+TRIM(NOMBRE)
ENDIF
DBSEEK("21")
RutImp:={}
DO WHILE VAL(ESCAL)<VAL(SUBSTR(Pr,1,1))
	IF TIPO
		AADD(RutImp, {ESCREF, TIPO, .T., NIL, NIL})
	ENDIF
	SKIP
ENDDO
DBSEEK(Pr)
AADD(RutImp, {ESCREF, TIPO, .T., NIL, NIL})
DBSEEK(LTRIM(STR(VAL(SUBSTR(Pr,1,1))+1))+"1")
DO WHILE VAL(ESCAL)<=VAL(SUBSTR(Ls,1,1))
	IF TIPO
		AADD(RutImp, {ESCREF, TIPO, .F., NIL, NIL})
	ENDIF
	SKIP
ENDDO
IF RutImp[1,1]<>"11"
	SET KEY -9 TO MUESTRA
	WOPEN(INT((25-(LEN(RpPr)+5))/2)-3, 11, INT((25+(LEN(RpPr)+5))/2)-3, 68, .T.)
	WBOX(1)
	@ 0, 0 SAY CENTER(Timp)
	Vnt:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("F10 Consultar")
	@ 24, 0 SAY "<F1> Ayuda"
	@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
	WSELECT(Vnt)
	FOR i=1 TO LEN(RutImp)
		IF RutImp[i, 3]
			DBSEEK(RutImp[i, 1])
			@ i+1, 0 SAY SPACE(20-LEN(TRIM(NOMBRE)))+TRIM(NOMBRE)+":"
			EntPr:="VAR"+LTRIM(STR(i))
			&EntPr:=SPACE(2)
			@ i+1, 21 GET &EntPr PICT "99" VALID IF(EMPTY(&EntPr), .F., BUSCA())
			GETLIST[i]:cargo:={i, NIL}
		ENDIF
	NEXT
	GETEM:=ACLONE(GETLIST)
	@ i+2, 0  SAY CENTER("F10 Consultar")
	SETCURSOR(1)
	READ
	SET KEY -9 TO
	@ i+2, 0 SAY SPACE(60)
	IF LASTKEY()==27
		SETCURSOR(0)
		WCLOSE()
		RETURN
	ENDIF
	Cnf:=SPACE(1)
	DO WHILE Cnf<>"S"
		@ i+1, 15 SAY "Confirmar (S)" GET Cnf PICT "!" VALID IF(EMPTY(Cnf), .F., .T.)
		READ
		IF Cnf<>"S"
			SET KEY -9 TO MUESTRA
			@ i+2, 0 SAY CENTER("F10 Consultar")
			GETLIST:=ACLONE(GETEM)
			READ
			SET KEY -9 TO
			@ i+2, 0 SAY SPACE(60)
			IF LASTKEY()==27
				SETCURSOR(0)
				WCLOSE()
				RETURN
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO
	SETCURSOR(0)
ELSE
	RutImp[1, 4]:=""
	RutImp[1, 5]:=".NOT. EOF()"
ENDIF
ALERT("Prepare la Impresora para Generar Reporte", {"oK"})
IF ISPRINTER()
	Vnt:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Estado de Impresi¢n Activado")
	WSELECT(Vnt)
	glis:=.T.
	IF SELECT("TITULOS")=0
		USE TITULOS NEW
	ELSE
		SELECT TITULOS
		GO TOP
	ENDIF
	Pag:=1
	SET DEVICE TO PRINT
	@ 0, 0 SAY CHR(15)
	@ 0, 0 SAY " "
	FOR i=1 TO LASTREC()
		@ i-1, INT((132-LEN(TRIM(TITULO)))/2) SAY TRIM(TITULO)
		DO CASE
			CASE i=1        
			   @ i-1, 116 SAY "P gina: "
			   @ i-1, 124 SAY Pag PICT "999"
			CASE i=2
			   @ i-1, 117 SAY "Fecha: "
			   @ I-1, 124 SAY DATE()
			CASE i=3
			   @ i-1, 117 SAY " Hora: "
			   @ I-1, 124 SAY HORA()
		ENDCASE
		SKIP
	NEXT i
	@ i-1, 124 SAY CHAREVEN(Ident)
	i:=4
	@ i, INT((132-LEN(TRIM(Timp)))/2) SAY CHR(27)+"E"+TRIM(Timp)+CHR(27)+"F"
	i+=2
	SELECT CATALOG
	IF LEN(RutImp)>2 .OR. RutImp[1, 1]<>"11"
		IF(RutImp[1, 1]="11", i2:=2, i2:=1)
		FOR i1=i2 TO LEN(RutImp)-1
			DBSEEK(RutImp[i1, 1])
			SELECT(NOM_ARCH)
			IF RutImp[i1, 3]
				nREG:=RECNO()
				aRSEL:=ALIAS()
			ELSE
				RutImp[i1, 4]:=RutImp[i1-1, 4]+"01"
				RutImp[i1, 5]:=INDEXKEY(0)
			ENDIF
			SELECT CATALOG
		NEXT i1
		RELACUP(RutImp)
		DBSEEK(RutImp[LEN(RutImp), 1])
		SELECT (NOM_ARCH)
		IF CATALOG->(RECNO())=CATALOG->(LASTREC())-1
			FOR i1=1 TO 15
				IF INDEXKEY(i1)==RutImp[LEN(RutImp)-1, 5]
					Ord:=i1
					EXIT
				ENDIF
			NEXT i1
			SET ORDER TO Ord
		ENDIF
		SET SOFTSEEK ON
		DBSEEK(RutImp[LEN(RutImp)-1, 4])
		SET SOFTSEEK OFF
		SIN:=SPACE(10)
		IF RutImp[1, 1]<>"11"
			SELECT (aRSEL)
			IF RECNO()<>nREG
				GO nREG
				SIN:="* * * * * * * * * * * * * * * * * * * *"
				glis:=.F.
			ENDIF
		ENDIF
		IF (RutImp[1, 1]="11", i1:=2, i1:=1)
		DO WHILE RutImp[i1, 3]
			SELECT CATALOG
			DBSEEK(RutImp[i1, 1])
			SELECT (NOM_ARCH)
			FOR i2=1 TO CATALOG->L_INF
				IF (FIELDSIZE(i2)>=30 .AND. RutImp[i1, 2])
					i3:=i2
					EXIT
				ELSEIF .NOT. RutImp[i1, 2]
					i3:=CATALOG->L_INF
					EXIT
				ENDIF
			NEXT i2
			IF RutImp[i1, 2]
				DesNom:=FIELDGET(i3)
			ELSE
				DesNom:=SPACE(10)
			ENDIF
			@ i, 30 SAY TRIM(CATALOG->NOMBRE)+REPLICATE(".", 20-LEN(TRIM(CATALOG->NOMBRE)))+": "+FIELDGET(i3-1)+" "+DesNom
			i+=1
			i1+=1
		ENDDO
		@ i, INT((132-LEN(SIN))/2) SAY SIN
		i+=1
	ENDIF
	IF glis
		SELECT CATALOG
		FOR j=1 TO LEN(RutImp)
			DBSEEK(RutImp[j, 1])
			AADD(RutImp[j], NOM_ARCH)
		NEXT j
		FOR j=1 TO LEN(RutImp)
			IF .NOT. RutImp[j, 3]
				RECUR(j)   && UBICACION ORIGINAL EN LINEA 308
				EXIT
			ENDIF
		NEXT j
	ENDIF
	EJECT
	@ 0, 0 SAY CHR(18)
	SET PRINTER TO
	SET DEVICE TO SCREEN
ELSE
	ALERT("Impresora Apagada o No lista para Reporte", {"oK"})
ENDIF
IF RutImp[1, 1]<>"11"
	WCLOSE()
ENDIF
RETURN

STATIC FUNCTION MUESTRA()
LOCAL i, oM, Lg, j, k
oM:=GETACTIVE()
Lg:=oM:cargo[1]
IF RutImp[Lg, 2]
	IF Lg>1
		DBSEEK(RutImp[Lg-1, 1])
		SELECT (NOM_ARCH)
		ClVl:=&(INDEXKEY(0))
		ClVr:=INDEXKEY(0)
		SELECT CATALOG
		DBSEEK(RutImp[Lg, 1])
		SELECT (NOM_ARCH)
		SET FILTER TO &ClVr=ClVl
		GO TOP
	ELSE
		DBSEEK(RutImp[Lg, 1])
		SELECT (NOM_ARCH)
	ENDIF
	FOR i=1 TO CATALOG->L_INF
		IF FIELDSIZE(i)>=30
			j:=i
			EXIT
		ENDIF
	NEXT i
	Etq:={"Cod", "Nombre"}
	Cam:={ j-1, j}
	WOPEN( 4, 36, 21, 76, .T.)
	WBOX(0)
	@  0, 0 SAY CENTER(TRIM(Plr(CATALOG->NOMBRE)))
	Clr:=SETCOLOR()
	SETCOLOR("")    
	FOR k=4 TO 15
		@ k, 0 SAY CHR(176)
	NEXT
	SETCOLOR("W+/N")
	@ 4, 0 SAY CHR(24)
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
	EVAL(oM:BLOCK, FIELDGET(j-1))
	SELECT CATALOG
	KEYBOARD CHR(13)
ENDIF
RETURN

FUNCTION CREALIS(nLINT, nCOLT, nLINB, nCOLB)
LOCAL k
@ nLINT-1, nCOLT-1 TO nLINB+1, nCOLB+1
oTAB:=TBROWSEDB(nLINT, nCOLT, nLINB, nCOLB)
oTAB:HEADSEP:=CHR(205)+CHR(209)+CHR(205)
oTAB:COLSEP:=CHR(32)+CHR(179)+CHR(32)
oTAB:FOOTSEP:=CHR(205)+CHR(207)+CHR(205)

FOR k=1 TO LEN(Etq)
	oTAB:ADDCOLUMN(TBCOLUMNNEW(Etq[k], FIELDBLOCK(FIELDNAME(Cam[k]), SELE())))
NEXT k

RETURN (oTAB)

FUNCTION PROMOV(TECLA)
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
	CASE TECLA==299         ;REFRES()
	OTHERWISE               ;TONE(125); TONE(300)
ENDCASE
RETURN

FUNCTION BUSCA()
LOCAL i, p, Bqd, Vl
oG:=GETACTIVE()
p:=oG:cargo[1]
oG:cargo[2]:=oG:BUFFER
Bqd:=""
FOR i=1 TO p
	Bqd+=GETLIST[i]:cargo[2]
NEXT i
SELECT CATALOG
DBSEEK(RutImp[p, 1])
SELECT (NOM_ARCH)
DBSEEK(Bqd)
IF FOUND()
	RutImp[p, 4]:=Bqd
	RutImp[p, 5]:=INDEXKEY(0)
	FOR i=1 TO CATALOG->L_INF
		IF FIELDSIZE(i)>=30
			EXIT
		ENDIF
	NEXT i
	Vl:=.T.
	IF i<CATALOG->L_INF
		@ oG:row, oG:col+4 SAY FIELDGET(i)
	ELSE
		@ oG:row, oG:col+4 SAY "C¢digo Localizado             "
	ENDIF
ELSE
	Vl:=.F.
	@ oG:row, oG:col+4 SAY "C¢digo no Encontrado          "
ENDIF
SELECT CATALOG
RETURN (Vl)

STATIC FUNCTION RELACUP(Camino)
LOCAL j, k
SELECT CATALOG
IF(Camino[1,1]="11", k:=2, k:=1)
FOR j=k TO LEN(Camino)-1
	DBSEEK(Camino[j,1])
	SELECT (NOM_ARCH)
	RELAC:=ALIAS()
	CLAV:=INDEXKEY(0)
	SELECT CATALOG
	DBSEEK(Camino[j+1,1])
	SELECT (NOM_ARCH)
	DBSETRELATION((RELAC), {|| &CLAV}, &CLAV)
	SELECT CATALOG
NEXT j
RETURN

STATIC FUNCTION RECUR(j)
LOCAL k, nREGI
ETIQ:={}
FOR k=j TO LEN(RutImp)

	IF RutImp[k-1, 1]="11" .AND. LEN(RutImp)=2
		ENCABE(k)
		i+=2
		DO WHILE .NOT. EOF()
			t1:=0
			FOR t=1 TO LEN(ETIQ)
				@ i, t1 SAY &(ETIQ[t, 2])
				s:=FIELDNUM(ETIQ[t, 2])
				t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+4
			NEXT t
			i+=1
			IF(i>=54, CAMPAG(1), .T.)
			SKIP
		ENDDO

	ELSEIF RutImp[k-1, 1]="11"
		SELECT (RutImp[k, 6])
		GO TOP
		DO WHILE .NOT. EOF()
			ENCABE(k)
			t1:=0
			i+=2
			FOR t=1 TO LEN(ETIQ)
				@ i, t1 SAY &(ETIQ[t, 2])
				s:=FIELDNUM(ETIQ[t, 2])
				t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+4
			NEXT t
			i+=2
			nREGI:=RECNO()
			RECUR(k+1)
			SELECT (RutImp[k, 6])
			GO nREGI
			SKIP
			IF(i>=44, CAMPAG(1), .T.)
		ENDDO

	ELSEIF RutImp[k-1, 1]<>"11" .AND. k<LEN(RutImp)
		SELECT (RutImp[k, 6])
		LOCATE FOR &(RutImp[k-1, 5])=RutImp[k-1, 4]
		IF FOUND()
			DO WHILE FOUND()
				ENCABE(k)
				t1:=0
				i+=2
				FOR t=1 TO LEN(ETIQ)
					@ i, t1 SAY &(ETIQ[t, 2])
					s:=FIELDNUM(ETIQ[t, 2])
					t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+4
				NEXT t
				i+=2
				nREGI:=RECNO()
				RECUR(k+1)
				SELECT (RutImp[k, 6])
				GO nREGI
				IF(i>=44, CAMPAG(1), .T.)
				CONTINUE
			ENDDO
		ELSE
			@ i, 0 SAY "* * * S I N  I N F O R M A C I O N * * *"
			i+=1
		ENDIF
		r1:=LEN(RutImp[k-1, 4])
		r2:=LTRIM(STR(VAL(SUBSTR(RutImp[k-1, 4], r1-1, 2))+1))
		IF(LEN(r2)=1, r2:="0"+r2, r2:=r2)
		RutImp[k-1, 4]:=SUBSTR(RutImp[k-1, 4], 1, r1-2)+r2
		FOR r1=k TO LEN(RutImp)-1
			RutImp[r1, 4]:=RutImp[r1-1,4]+"01"
		NEXT r1
		RETURN

	ELSEIF RutImp[k-1, 1]<>"11" .AND. k=LEN(RutImp)
		SELECT (RutImp[k, 6])
		LOCATE FOR &(RutImp[k-1, 5])=RutImp[k-1, 4]
		IF FOUND()
			ENCABE(k)
			i+=2
			DO WHILE FOUND()
				t1:=0
				IF(CATALOG->(RECNO())=CATALOG->(LASTREC())-1, t11:=2, t11:=4)
				FOR t=1 TO LEN(ETIQ)
					@ i, t1 SAY &(ETIQ[t, 2])
					s:=FIELDNUM(ETIQ[t, 2])
					t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+t11
				NEXT t
				i+=1
				IF(i>=54, CAMPAG(1), .T.)
				CONTINUE
			ENDDO
		ELSE
			@ i, 0 SAY "* * * S I N  I N F O R M A C I O N * * *"
			i+=1
		ENDIF
		r1:=LEN(RutImp[k-1, 4])
		r2:=LTRIM(STR(VAL(SUBSTR(RutImp[k-1, 4], r1-1, 2))+1))
		IF(LEN(r2)=1, r2:="0"+r2, r2:=r2)
		RutImp[k-1, 4]:=SUBSTR(RutImp[k-1, 4], 1, r1-2)+r2
		i+=2
		RETURN
	ENDIF

NEXT k
RETURN

STATIC FUNCTION ENCABE(k)
LOCAL j
CATALOG->(DBSEEK(RutImp[k, 1]))
@ i, 7 SAY CATALOG->NOMBRE
ETIQUETA()
t1:=0
SELECT (RutImp[k, 6])
IF(CATALOG->(RECNO())=CATALOG->(LASTREC())-1, j:=2, j:=4)
FOR t=1 TO LEN(ETIQ)
	@ i+1, t1 SAY ETIQ[t, 1]
	s:=FIELDNUM(ETIQ[t, 2])
	t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+j
NEXT t
RETURN

STATIC FUNCTION ETIQUETA()
SELECT CATALOG
ETIQ:={}
nREG:=RECNO()
nESC:=ESCAL
LOCATE FOR VAL(ESCAL)=VAL(nESC)-1
DO WHILE VAL(ESCAL)=VAL(nESC)-1
	IF .NOT. TIPO
		AADD(ETIQ, {TRIM(NOMBRE), SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
	ENDIF
	SKIP
ENDDO
IF nREG<LASTREC()-1
	AADD(ETIQ, {"C¢digo", SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
	AADD(ETIQ, {"Nombre", SUBSTR(LTRIM(NOMBRE), 1, 1)+"DES"})
	LOCATE FOR VAL(ESCAL)=VAL(nESC)+1
	DO WHILE VAL(ESCAL)=VAL(nESC)+1
		IF .NOT. TIPO
			AADD(ETIQ, {"N§ "+TRIM(NOMBRE), "NO"+ESCREF})
		ENDIF
		SKIP
	ENDDO
ELSE
	AADD(ETIQ, {"C¢digo", "CODIGO"})
	AADD(ETIQ, {"Nombre", "DESC"})
	AADD(ETIQ, {"Direcci¢n", "DIRE"})
	AADD(ETIQ, {"N§ Mesas", "N_MESAS"})
ENDIF
GO nREG
RETURN

FUNCTION CAMPAG(AR)
LOCAL c
IF(AR=1, c:=52, c:=0)
Pag+=1
@ 0,   0 SAY "Continuaci¢n......."
@ 0, 64+c+0 SAY "P gina: "
@ 0, 71+c+1 SAY Pag PICT "9999"
@ 1, 65+c+0 SAY "Fecha: "
@ 1, 71+c+1 SAY DATE()
@ 2, 65+c+0 SAY " Hora: "
@ 2, 71+c+1 SAY HORA()
@ 3, 71+c+1 SAY CHAREVEN(Ident)
i:=3
RETURN (.T.)