* PROGRAMA PARTID.PRG
* 11/05/95

* PARG -> Inscripci¢n, actualizaci¢n de directorio de
*         partidos o grupos electorales
FUNCTION PARG()
	Crea:={}
	AADD(Crea, {"No", "C", 3, 0})
	AADD(Crea, {"Siglas", "C", 15, 0})
	AADD(Crea, {"Nombre", "C", 30, 0})
IF .NOT. FILE("PART_GRP.DBF")
	DBCREATE("PART_GRP", Crea)
	USE PART_GRP
	INDEX ON No TO PART_GRP
ENDIF
USE PART_GRP INDEX PART_GRP
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY "Alt+     <A>gregar     <B>orrar     <E>ditar     <I>mprimir       || <Esc> Salir"
WOPEN(3, 10, 21, 70, .T.)
WBOX(0)
@ 0, 0 SAY CENTER("Partidos o Grupos")
Clr:=SETCOLOR()
SETCOLOR("")
FOR k=4 TO 15
	@ k, 0 SAY CHR(176)
NEXT k
SETCOLOR("W+/N")
@  4, 0 SAY CHR(24)
@ 15, 0 SAY CHR(25)
SETCOLOR(Clr)
oTAB:=CREABROWSE(2, 2, 15, 56)
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
		EXIT
	ELSE
		PROTECLA(TECLA)
	ENDIF
ENDDO
WCLOSE()
CLOSE ALL
RETURN

STATIC FUNCTION CREABROWSE(nLINT, nCOLT, nLINB, nCOLB)
LOCAL k
@ nLINT-1, nCOLT-1 TO nLINB+1, nCOLB+1
oTAB:=TBROWSEDB(nLINT, nCOLT, nLINB, nCOLB)
oTAB:HEADSEP:=CHR(205)+CHR(209)+CHR(205)
oTAB:COLSEP:=CHR(32)+CHR(179)+CHR(32)
oTAB:FOOTSEP:=CHR(205)+CHR(207)+CHR(205)

FOR k=1 TO LEN(Crea)
	oTAB:ADDCOLUMN(TBCOLUMNNEW(Crea[k,1], FIELDBLOCK(Crea[k,1], SELE())))
NEXT k

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
     CASE TECLA==28          ;HELP("PARG")
     CASE TECLA==274         ;EDITA(oTAB, 3)
     CASE TECLA==304         ;BORRA(oTAB, 3)
     CASE TECLA==286         ;AGREGA(oTAB)
     CASE TECLA==279         ;IMPRIM()
     CASE TECLA==299         ;REFRES()
     OTHERWISE               ;TONE(125); TONE(300)
ENDCASE
RETURN

STATIC FUNCTION AGREGA(oTAB)
IF EOF()
	Cod_Ag:=1
ELSE
	Nor:=RECNO()
	GO BOTTOM
	Cod_Ag:=VAL(FIELDGET(1))+1
	GO Nor
ENDIF
Cod_Ag:=LTRIM(STR(Cod_Ag))
IF LEN(Cod_Ag)=1
	Cod_Ag:="00"+Cod_Ag
ELSEIF LEN(Cod_Ag)=2
	Cod_Ag:="0"+Cod_Ag
ENDIF
Var1:=Cod_AG
Var2:=SPACE(15)
Var3:=SPACE(30)
WOPEN(9, 22, 14, 68, .T.)
WBOX(1)
@ 0, 0 SAY CENTER("AGREGAR: Partido o Grupo")
@ 1, 0 SAY "N£mero:" GET Var1 PICT "999" WHEN CUANDO()
@ 2, 0 SAY "Siglas:" GET Var2 PICT "@!" VALID IF(EMPTY(Var2), .F., .T.)
@ 3, 0 SAY "Nombre:" GET Var3 PICT "@!" VALID IF(EMPTY(Var3), .F., .T.)
SETCURSOR(1)
READ
SETCURSOR(0)
IF LASTKEY()==27
	WCLOSE()
	RETURN
ELSE
	APPEND BLANK
	FIELDPUT(1, Var1)
	FIELDPUT(2, Var2)
	FIELDPUT(3, Var3)
ENDIF
WCLOSE()
oTAB:REFRESHALL()
ESTABILIZE(oTAB)
RETURN

STATIC FUNCTION IMPRIM()
ALERT("Prepare la Impresora para Reporte")
IF ISPRINTER()
	Nreg:=RECNO()
	GO TOP
	IF SELECT("TITULOS")=0
		USE TITULOS NEW
	ELSE
		SELECT TITULOS
		GO TOP
	ENDIF
	Pag:=1
	SET DEVICE TO PRINT
	FOR i=1 TO LASTREC()
		@ i-1, INT((80-LEN(TRIM(TITULO)))/2) SAY TRIM(TITULO) 
		DO CASE
			CASE i=1
				@ i-1, 64 SAY "P gina: "
				@ i-1, 71 SAY Pag PICT "99"
			CASE i=2
				@ i-1, 65 SAY "Fecha: "
				@ i-1, 71 SAY DATE()
			CASE i=3
				@ i-1, 65 SAY " Hora: "
				@ i-1, 71 SAY HORA()
		ENDCASE
		SKIP
	NEXT i
	@ i-1, 71 SAY CHAREVEN(Ident)
	i:=4
	TitPri:="Partidos o Grupos Inscritos"
	@ i, INT((80-LEN(TitPri))/2) SAY CHR(27)+"E"+TitPri+CHR(27)+"F"
	i:=6
	Cl:=0
	SELECT PART_GRP
	FOR j=1 TO LEN(Crea)
		@ i, Cl SAY Crea[j,1]
		Cl+=MAX(LEN(Crea[j,1]), Crea[j,3])+4
	NEXT j
	@ i+1, 0 SAY REPLICATE("=", Cl)
	i+=2
	DO WHILE .NOT. EOF()
		Cl:=0
		FOR j=1 TO LEN(Crea)
			@ i, Cl SAY &(Crea[j,1])
			Cl+=MAX(LEN(Crea[j,1]), Crea[j,3])+4
		NEXT j
		SKIP
		i+=1
		IF(i>50 .AND. RECNO()<=LASTREC()-2, CAMPAG(2), .T.)
	ENDDO
	@ i, 0 SAY REPLICATE("=", Cl)
	EJECT
	SET PRINTER TO
	SET DEVICE TO SCREEN
	GO Nreg
ELSE
	ALERT("Impresora no Lista para Reporte")
ENDIF
RETURN

* RCAN -> Reporte de Directorio de Candidatos
*         y Partidos por Categor¡a.
FUNCTION RCAN()
IF FILE("CANDI.DBF")
	USE CANDI
	Abrt:=EOF()
	CLOSE CANDI
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Abriendo Archivos del Sistema, Espere un momento...")
ELSE
	OJO()
	RETURN
ENDIF

IF (.NOT. Abrt) .AND. ABREARCH()
	Ptd:=.T.
	IF FILE("INTERM.DBF")
		USE INTERM NEW
		Ptd:=EOF()
		CLOSE INTERM
	ENDIF
	USE CATEGO INDEX CATEGO NEW
	SET RELATION TO ESCREF INTO CATALOG
	IF .NOT. Ptd
		USE PART_GRP INDEX PART_GRP NEW
		USE INTERM INDEX INTERM NEW
		SET RELATION TO NO INTO PART_GRP
	ENDIF
	USE CANDI INDEX CANDI NEW
	IF .NOT. Ptd
		CaIn:=INDEXKEY(0)
		DBSETRELATION("INTERM", {|| &CaIn}, &CaIn)
	ENDIF
	OpIm:={}
	CATEGO->(DBGOTOP())
	AnVnt:=LEN("Imprimir Categor¡a")+4
	FOR i=1 TO CATEGO->(LASTREC())
		CANDI->(DBSEEK(CATEGO->NIV))
		IF CANDI->(FOUND())
			AADD(OpIm, {CATEGO->NIV, TRIM(CATEGO->CATEG), CATEGO->ESCREF})
			IF(LEN(TRIM(CATEGO->CATEG))>AnVnt,;
				AnVnt:=LEN(TRIM(CATEGO->CATEG))+4,;
				AnVnt:=AnVnt)
		ENDIF
		CATEGO->(DBSKIP())
	NEXT i
	WOPEN(4, 12, 6+LEN(OpIm), 15+AnVnt, .T.)
	WBOX(1)
	DO WHILE .T.
		Vnt:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("Elija una Opci¢n")
		@ 24, 0 SAY "<F1> Ayuda"
		@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
		WSELECT(Vnt)
		@ 0, 0 SAY CENTER("Imprimir Categor¡a")
		FOR i=1 TO LEN(OpIm)
			@ i, 0 PROMPT OpIm[i, 2]
		NEXT i
		MENU TO Cat
		IF LASTKEY()==27
			EXIT
		ENDIF
		CATEGO->(DBSEEK(OpIm[Cat, 1]))
		SELECT CATALOG
		nESCREF:=ESCREF
		GO TOP
		Eti:={}
		DO WHILE VAL(ESCAL)<VAL(SUBSTR(nESCREF, 1, 1))
			IF TIPO
				AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
			ENDIF
			SKIP
		ENDDO
		DBSEEK(nESCREF)
		AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
		Tcl:=WCOL()
		Tln:=WROW()
		WOPEN(Tln+Cat, AnVnt+15, Tln+Cat+2+LEN(Eti), AnVnt+35, .T.)
		WBOX(1)
		DO WHILE .T.
			CATEGO->(DBSEEK(OpIm[Cat, 1]))
			SELECT CATALOG
			Vnt:=WSELECT()
			WSELECT(0)
			@ 24, 0 CLEAR TO 24, 79
			@ 24, 0 SAY CENTER("Elija una Opci¢n")
			@ 24, 0 SAY "<F1> Ayuda"
			@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
			WSELECT(Vnt)
			@ 0, 0 SAY CENTER("POR")
			FOR i=1 TO LEN(Eti)
				@ i, 0 PROMPT Eti[i, 1]
			NEXT i
			MENU TO Pr
			IF LASTKEY()==27
				EXIT
			ENDIF
			RUTIMP()
		ENDDO
		WCLOSE()
	ENDDO
	WCLOSE()
ELSE
	@ 24, 0 CLEAR TO 24, 79
	OJO()
	RETURN
ENDIF
CLOSE ALL
RETURN

STATIC FUNCTION RUTIMP()
Timp:="Candidatos a "+TRIM(CATEGO->CATEG)+" "
IF Eti[Pr, 3]<>"11"
	SET KEY -9 TO CDMUES
	Timp+="por "+Eti[Pr, 1]
	WOPEN(-3+(25-(Pr+5))/2, 8, -3+(25+(Pr+5))/2, 72, .T.)
	WBOX(1)
	@ 0, 0 SAY CENTER(Timp)
	FOR i=2 TO Pr
		DBSEEK(Eti[i, 3])
		@ i,  0 SAY SPACE(20-LEN(TRIM(NOMBRE)))+TRIM(NOMBRE)+":"
		@ i, 21 GET Eti[i, 2] PICT "99" VALID CDBUSC()
		GETLIST[i-1]:cargo:={i-1, NIL, i-1}
	NEXT i
	GETEM:=ACLONE(GETLIST)
	@ i+2, 0 SAY CENTER("F10 Consultar")
	SETCURSOR(1)
	READ
	SETCURSOR(0)
	SET KEY -9 TO
	@ i+2, 0 SAY SPACE(60)
	IF LASTKEY()==27
		WCLOSE()
		RETURN
	ENDIF
	Cnf:=SPACE(1)
	DO WHILE Cnf<>"S"
		@ i+1, 15 SAY "Confirmar (S)" GET Cnf PICT "!" VALID IF(EMPTY(Cnf), .F., .T.)
		SETCURSOR(1)
		READ
		SETCURSOR(0)
		IF Cnf<>"S"
			SET KEY -9 TO CDMUES
			@ i+2, 0 SAY CENTER("F10 Consultar")
			GETLIST:=ACLONE(GETEM)
			READ
			SET KEY -9 TO
			@ i+2, 0 SAY SPACE(60)
			IF LASTKEY()==27
				WCLOSE()
				RETURN
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO
ENDIF

ALERT("Prepare la Impresora para Generar Reporte", {"oK"})
IF ISPRINTER()
	IF SELECT("TITULOS")=0
		USE TITULOS NEW
	ELSE
		SELECT TITULOS
		GO TOP
	ENDIF
	Pag:=1
	Vnt:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Estado de Impresi¢n Activado, Espere Reporte...")
	WSELECT(Vnt)
	SET DEVICE TO PRINT
	@ 0, 0 SAY " "
	FOR i=1 TO LASTREC()
		@ i-1, INT((80-LEN(TRIM(TITULO)))/2) SAY TRIM(TITULO)
		DO CASE
			CASE i=1
				@ i-1, 64 SAY "P gina:"
				@ i-1, 71 SAY Pag PICT "999"
			CASE i=2
				@ i-1, 65 SAY "Fecha:"
				@ i-1, 71 SAY DATE()
			CASE i=3
				@ i-1, 65 SAY " Hora:"
				@ i-1, 71 SAY HORA()
		ENDCASE
		SKIP
	NEXT i
	@ i-1, 71 SAY CHAREVEN(Ident)
	i:=4
	@ i, INT((80-LEN(TRIM(Timp)))/2) SAY CHR(27)+"E"+TRIM(Timp)+CHR(27)+"F"
	i+=2
	CATEGO->(DBSEEK(OpIm[Cat, 1]))
	ETIQ:={ {"N§", "COD"}, {"Nombres y Apellidos", "NOMBRE"}, {"C‚dula", "CEDULA"}}
	IF .NOT. Ptd
		AADD(ETIQ, {"Partido o Grupo", "PART_GRP->SIGLAS"})
	ENDIF
	SIN:="*** S I N  I N F O R M A C I O N ***"
	IF OpIm[Cat, 3]=="11"
		SELECT CANDI
		DBSEEK(OpIm[Cat, 1])
		IF FOUND()
			ClIm:=INDEXKEY(0)
			ClIm:=SUBSTR(ClIm, 1, LEN(ClIm)-4)
			VlIm:=&(INDEXKEY(0))
			VlIm:=SUBSTR(VlIm, 1, LEN(VlIm)-2)
			ENCAB()
			i+=3
			DO WHILE &ClIm==VlIm
				t1:=0
				CONTEN()
				i+=1
				IF(i>=54, CAMPAG(2), .T.)
				SKIP
			ENDDO
			@ i, 0 SAY REPLICATE("=", t1)
		ELSE
			@ i, INT((80-LEN(SIN))/2) SAY SIN
		ENDIF
	ELSEIF OpIm[Cat, 3]==Eti[Pr, 3]
		FOR j=2 TO Pr
			CATALOG->(DBSEEK(Eti[j, 3]))
			SELECT (CATALOG->NOM_ARCH)
			UBICACION()
		NEXT j
		Clave:=INDEXKEY(0)
		Valor:=&(INDEXKEY(0))
		SELECT CANDI
		LOCATE FOR NIV==OpIm[Cat, 1] .AND. &Clave==Valor
		IF FOUND()
			ENCAB()
			i+=3
			DO WHILE FOUND()
				t1:=0
				CONTEN()
				i+=1
				IF(i>=45, CAMPAG(2), .T.)
				CONTINUE
			ENDDO
			@ i, 0 SAY REPLICATE("=", t1)
		ELSE
			@ i, INT((80-LEN(SIN))/2) SAY SIN
		ENDIF
	ELSEIF Eti[Pr, 3]=="11"
		CATALOG->(DBSEEK(Eti[Pr+1, 3]))
		SELECT (CATALOG->NOM_ARCH)
		GO TOP
		DO WHILE .NOT. EOF()
			IF(i>=45, CAMPAG(2), .T.)
			UBICACION()
			Clave:=INDEXKEY(0)
			Valor:=&(INDEXKEY(0))
			BaseTra:=ALIAS()
			RECUR(Pr+2, Clave, Valor)
			CATALOG->(DBSEEK(Eti[Pr+1, 3]))
			SELECT (BaseTra)
			SKIP
		ENDDO
	ELSEIF Eti[Pr, 3]<>"11"
		FOR j=2 TO Pr
			CATALOG->(DBSEEK(Eti[j, 3]))
			SELECT (CATALOG->NOM_ARCH)
			UBICACION()
		NEXT j
		Clave:=INDEXKEY(0)
		Valor:=&(INDEXKEY(0))
		RECUR(Pr+1, Clave, Valor)
	ENDIF
	EJECT
	SET PRINTER TO
	SET DEVICE TO SCREEN
ELSE
	ALERT("Impresora no Preparada para Reporte..")
ENDIF
IF Eti[Pr, 3]<>"11"
	WCLOSE()
ENDIF
RETURN

STATIC FUNCTION RECUR(j, Cl, Vl)
LOCAL k, ArSel
Cl1:=Cl
Vl1:=Vl
FOR k=j TO LEN(Eti)
	CATALOG->(DBSEEK(Eti[k, 3]))
	SELECT (CATALOG->NOM_ARCH)
	ArSel:=ALIAS()
	DBSEEK(Vl)
	IF FOUND()
		DO WHILE &CL1==Vl1
			UBICACION()
			Clave:=INDEXKEY(0)
			Valor:=&(INDEXKEY(0))
			RECUR(k+1,Clave, Valor)
			CATALOG->(DBSEEK(Eti[k, 3]))
			SELECT (ArSel)
			Cl1:=Cl
			Vl1:=Vl
			SKIP
		ENDDO
		RETURN
	ELSE
		i+=1
		SELECT (ArSel)
		RETURN
	ENDIF
NEXT k
SELECT CANDI
LOCATE FOR NIV==OpIm[Cat, 1] .AND. &Cl1==Vl1
IF FOUND()
	ENCAB()
	i+=3
	DO WHILE FOUND()
		t1:=0
		CONTEN()
		i+=1
		IF(i>=45, CAMPAG(2), .T.)
		CONTINUE
	ENDDO
	@ i, 0 SAY REPLICATE("=", t1)
ELSE
	@ i, INT((80-LEN(SIN))/2) SAY SIN
	IF(i>=50, CAMPAG(2), .T.)
ENDIF
i+=2
RETURN

STATIC FUNCTION UBICACION()
FOR i2=1 TO CATALOG->L_INF
	IF FIELDSIZE(i2)>=30 .AND. CATALOG->TIPO
		i3:=i2
		EXIT
	ELSEIF .NOT. CATALOG->TIPO
		i3:=CATALOG->L_INF
		EXIT
	ENDIF
NEXT i2
IF CATALOG->TIPO
	DesNom:=FIELDGET(i3)
ELSE
	DesNom:=SPACE(10)
ENDIF
@ i, 15 SAY TRIM(CATALOG->NOMBRE)+REPLICATE(".", 20-LEN(TRIM(CATALOG->NOMBRE)))+": "+FIELDGET(i3-1)+" "+DesNom
i+=1
RETURN

STATIC FUNCTION ENCAB()
t1:=0
FOR t=1 TO LEN(ETIQ)
	@ i+1, t1 SAY ETIQ[t, 1]
	s:=FIELDNUM(ETIQ[t, 2])
	t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+4
NEXT t
@ i+2 , 0 SAY REPLICATE("=", t1)
RETURN

STATIC FUNCTION CONTEN()
FOR t=1 TO LEN(ETIQ)
	IF t=LEN(ETIQ) .AND. (.NOT. Ptd) .AND. PART_GRP->(EOF())
		@ i, t1 SAY "Sin Asignar"
	ELSEIF t=LEN(ETIQ) .AND. (.NOT. Ptd)
		Lcav:=INDEXKEY(0)
		Lval:=&(INDEXKEY(0))
		SELECT INTERM
		DO WHILE &Lcav=Lval
			@ i, t1 SAY &(ETIQ[t, 2])
			SKIP
			i+=1
		ENDDO
		SELECT CANDI
	ELSEIF Ptd .OR. t<LEN(ETIQ)
		@ i, t1 SAY &(ETIQ[t, 2])
	ENDIF
	s:=FIELDNUM(ETIQ[t, 2])
	t1+=MAX(LEN(ETIQ[t, 1]), FIELDSIZE(s))+4
NEXT t
RETURN
