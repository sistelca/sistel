* PROGRAMA DE TOTALIZACION Y GENERACION DE REPORTES
* DE ESCRUTINIOS PARA SISTEL
* 11/05/95

@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Abriendo Archivos...")
WOPEN(3, 2, 10, 75, .T.)
WBOX(0)
@ 0, 0 SAY CENTER("Totalizaci�n y Generaci�n de Reportes de Escrutinios")
IF .NOT. ABREARCH()
	CLOSE ALL
	WCLOSE()
	RETURN
ENDIF
CATALOG->(DBGOTOP())
CATALOG->(DBSKIP())
SELECT (CATALOG->NOM_ARCH)
IF CATALOG->L_INF==FCOUNT()
	OJO()
	WCLOSE()
	CLOSE ALL
	RETURN
ENDIF

Acum:=ARRAY(FCOUNT()-CATALOG->L_INF)
Prueba:=0
FOR i=CATALOG->L_INF+1 TO FCOUNT()
	Prueba+=FIELDGET(i)
NEXT i

CANCREF()
CATALOG->(DBGOBOTTOM())
NomSal:=TRIM(CATALOG->NOMBRE)+SPACE(1)

IF Prueba=0 && El sistema solo trabaja en redes
	DO WHILE CATALOG->(RECNO())>2
		vent:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("Totalizando Informaci�n de Nivel "+TRIM(CATALOG->NOMBRE))
		WSELECT(vent)
		Nult:=CATALOG->(RECNO())
		SELECT (CATALOG->NOM_ARCH)
		Ultimo:=ALIAS()
		SELECT CATALOG
		nESC:=ESCAL
		LOCATE FOR VAL(ESCAL)=VAL(nESC)-1 .AND. TIPO
		Nsig:=CATALOG->(RECNO())
		DO WHILE VAL(CATALOG->ESCAL)=VAL(nESC)-1
			SELECT (CATALOG->NOM_ARCH)
			Asum:=ALIAS()
			Nsum:=CATALOG->(RECNO())
			Clave:=INDEXKEY(0)
			SELECT (Ultimo)
			FOR i=1 TO 15
				IF INDEXKEY(i)==Clave
					EXIT
				ENDIF
			NEXT i
			DBSETORDER(i)
			SELECT (Asum)
			DBSETRELATION((Ultimo), {|| &Clave}, &Clave)
			DBGOTOP()
			CATALOG->(DBGOTO(Nsum))
			DO WHILE .NOT. EOF()
				FOR i=1 TO LEN(Acum)
					Acum[i]:=0
				NEXT i
				Valor:=&(INDEXKEY(0))
				CATALOG->(DBGOTO(Nult))
				SELECT (CATALOG->NOM_ARCH)
				DO WHILE &Clave==Valor
					FOR i=1 TO LEN(Acum)
						Acum[i]+=FIELDGET(CATALOG->L_INF+i)
					NEXT i
					DBSKIP()
				ENDDO
				CATALOG->(DBGOTO(Nsum))
				SELECT (CATALOG->NOM_ARCH)
				FOR i=1 TO CATALOG->L_INF
					IF FIELDSIZE(i)>=30
						EXIT
					ENDIF
				NEXT i
				IF(i<CATALOG->L_INF, j:=i, j:=CATALOG->L_INF-1)
				@ 2, 0 SAY TRIM(CATALOG->NOMBRE)+SPACE(2)+FIELDGET(j)
				FOR i=1 TO LEN(Acum)
					FIELDPUT(CATALOG->L_INF+i, Acum[i])
				NEXT i
				DBSKIP()
			ENDDO
			@ 2, 0 CLEAR TO 2, 50
			DBCLEARREL()
			CATALOG->(DBGOTO(Nult))
			SELECT (CATALOG->NOM_ARCH)
			DBSETORDER(1)
			CATALOG->(DBGOTO(Nsum))
			CATALOG->(DBSKIP())
		ENDDO
		CATALOG->(DBGOTO(Nsig))
	ENDDO
ENDIF

FOR i=1 TO LEN(Acum)
	Acum[i]:=0
NEXT i
CATALOG->(DBGOTO(2))
SELECT (CATALOG->NOM_ARCH)
vent:=WSELECT()
WSELECT(0)
@ 24, 0 CLEAR TO 24, 79
@ 24, 0 SAY CENTER("Totalizando Informaci�n de Nivel "+TRIM(CATALOG->NOMBRE))
WSELECT(vent)

DBGOTOP()
DO WHILE .NOT. EOF()
	FOR i=1 TO LEN(Acum)
		Acum[i]+=FIELDGET(CATALOG->L_INF+i)
	NEXT i
	SKIP
ENDDO
LLAMREF()
WCLOSE()
DBGOTOP()

Ptd:=.T.
IF FILE("INTERM.DBF")
	USE INTERM NEW
	Ptd:=EOF()
	CLOSE INTERM
ENDIF

USE CATEGO INDEX CATEGO NEW
SET RELATION TO ESCREF INTO CATALOG

Atra:=ALIAS()
USE CANDI INDEX CANDI NEW
IF .NOT. Ptd
	USE PART_GRP INDEX PART_GRP NEW
	USE INTERM INDEX INTERM NEW
	SET RELATION TO NO INTO PART_GRP
ENDIF
SELECT CANDI
IF .NOT. Ptd
	CaIn:=INDEXKEY(0)
	DBSETRELATION("INTERM", {|| &CaIn}, &CaIn)
ENDIF
SELECT (Atra)

WOPEN(3, 14, 5+CATEGO->(LASTREC()), 45, .T.)
WBOX(1)
@ 0, 0 SAY CENTER("Reportes de Totalizaci�n")
DO WHILE .T.
	vent:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Elija una Opci�n")
	@ 24, 0 SAY "<F1> Ayuda"
	@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
	WSELECT(vent)        
	
	SELECT CATEGO
	CATEGO->(DBGOTOP())
	i:=1
	DO WHILE .NOT. EOF()
		@ i, 0 PROMPT TRIM(CATEGO->CATEG)
		DBSKIP()
		i+=1
	ENDDO
	MENU TO RTot
	IF LASTKEY()==27
		WCLOSE()
		CLOSE ALL
		RETURN
	ENDIF

	IF(LEN(LTRIM(STR(RTot)))=1, RTot:="0"+LTRIM(STR(Rtot)), RTot:=LTRIM(STR(RTot)))
	CATEGO->(DBSEEK(RTot))
	nTIP:=CATALOG->TIPO
	nREG:=CATALOG->(RECNO())
	nESC:=CATALOG->ESCAL
	WOPEN(3, 46, 5+CATALOG->(LASTREC()), 52+22, .T.)
	WBOX(1)
	@ 0, 0 SAY CENTER("POR")

	DO WHILE .T.
		vent:=WSELECT()
		WSELECT(0)
		@ 24, 0 CLEAR TO 24, 79
		@ 24, 0 SAY CENTER("Elija una Opci�n")
		@ 24, 0 SAY "<F1> Ayuda"
		@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
		WSELECT(vent)

		i:=1
		CATALOG->(DBGOTOP())
		Eti:={}
		DO WHILE .NOT. CATALOG->(EOF())
			GnEs:=SPACE(2)
			IF(VAL(CATEGO->ESCREF)>VAL(CATALOG->ESCREF), GnEs+="(Gral)", GnEs+="(Esp)")
			IF nTIP .OR. ((CATALOG->TIPO .AND. CATALOG->ESCAL<>nESC) .OR.;
			 CATALOG->(RECNO())=CATALOG->(LASTREC()) .OR.;
			 CATALOG->(RECNO())=nREG)
				@ i, 0 PROMPT TRIM(CATALOG->NOMBRE)+GnEs
				IF(CATALOG->(RECNO())=CATALOG->(LASTREC())-1, j:=5, j:=2)
				AADD(Eti, {TRIM(CATALOG->NOMBRE), SPACE(j), CATALOG->ESCREF, SUBSTR(LTRIM(CATALOG->NOMBRE), 1, 1)+CATALOG->ESCREF, CATALOG->TIPO})
				i+=1
			ENDIF
			CATALOG->(DBSKIP())
		ENDDO
		MENU TO Pr
		IF LASTKEY()=27
			WCLOSE()
			EXIT
		ENDIF
		
		ASIZE(Eti, Pr)
		FOR i=LEN(Eti) TO 1 STEP -1
			IF ((.NOT. Eti[i, 5]) .AND. i<>Pr .AND. CATEGO->ESCREF<>Eti[i, 3]) .OR.;
			    (i<>Pr .AND. SUBSTR(Eti[i, 3], 1, 1)==SUBSTR(Eti[Pr, 3], 1, 1))
				ADEL(Eti, i)
				ASIZE(Eti, LEN(Eti)-1)
				Pr:=LEN(Eti)
			ENDIF
		NEXT i
		Pr:=LEN(Eti)
		REPTOT()
	ENDDO
	LOOP
ENDDO
RETURN

STATIC FUNCTION REPTOT()
* REPORTES TOTALIZACION
Timp:="Totalizaci�n para "+TRIM(CATEGO->CATEG)+" "
Desglosa:=.F.
IF Eti[Pr, 3]<>"11"
	vent:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Introduzca Datos")
	@ 24, 0 SAY "<F1> Ayuda"
	@ 24, 79-LEN("<Esc> Salir") SAY "<Esc> Salir"
	WSELECT(vent)

	SET KEY -9 TO CDMUES
	Timp+="por "+Eti[Pr, 1]
	WOPEN(3, 2, 8+LEN(Eti), 75, .T.)
	WBOX(1)
	@ 0, 0 SAY CENTER(Timp)
	FOR i=2 TO Pr
		CATALOG->(DBSEEK(Eti[i, 3]))
		@ i,  0 SAY SPACE(20-LEN(TRIM(CATALOG->NOMBRE)))+TRIM(CATALOG->NOMBRE)+":"
		@ i, 21 GET Eti[i, 2] PICT REPLICATE("9", LEN(Eti[i, 2])) VALID CDBUSC()
		GETLIST[i-1]:cargo:={i-1, nil, i-1}
	NEXT i
	GETEM:=ACLONE(GETLIST)
	@ i+2, 0 SAY CENTER("F10 Consultar")
	SETCURSOR(1)
	READ
	SETCURSOR(0)
	SET KEY -9 TO
	@ i+2, 0 SAY SPACE(70)
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
			SETCURSOR(1)
			READ
			SETCURSOR(0)
			SET KEY -9 TO
			@ i+2, 0 SAY SPACE(70)
			IF LASTKEY()==27
				WCLOSE()
				RETURN
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO
Desglosa:=.T.
ENDIF

ALERT("Prepare la Impresora para Generar Reporte", {"oK"})
IF ISPRINTER()
	vent:=WSELECT()
	WSELECT(0)
	@ 24, 0 CLEAR TO 24, 79
	@ 24, 0 SAY CENTER("Estado de Impresi�n Activado,... Espere un Momento")
	WSELECT(vent)

	ESCRUTINIO()
ELSE
	ALERT("Impresora no Preparada para Reporte..")
ENDIF

IF Desglosa
	WCLOSE()
ENDIF
RETURN

FUNCTION ESCRUTINIO()
IF(PTD, y:=20, y:=0)

IF SELECT("TITULOS")=0
	USE TITULOS NEW
ELSE
	SELECT TITULOS
	GO TOP
ENDIF

Pag:=1
SET DEVICE TO PRINT
@ 0, 0 SAY " "
FOR i=1 TO LASTREC()
	@ i-1, INT((80-LEN(TRIM(TITULO)))/2) SAY TRIM(TITULO)
	IF i=1
		@ i-1, 64 SAY "P�gina:"
		@ i-1, 71 SAY Pag PICT "999"
	ELSEIF i=2
		@ i-1, 65 SAY "Fecha:"
		@ i-1, 71 SAY DATE()
	ELSEIF i=3
		@ i-1, 65 SAY " Hora:"
		@ i-1, 71 SAY HORA()
	ENDIF
	SKIP
NEXT i
@ i-1, 71 SAY CHAREVEN(Ident)
i:=4
@ i, INT((80-LEN(TRIM(Timp)))/2) SAY CHR(27)+"E"+TRIM(Timp)+CHR(27)+"F"
i+=2
SIN:=CENTER(REPLICATE("*", 30))

IF CATEGO->ESCREF=="11" .AND. Eti[Pr, 3]=="11"
	SELECT CANDI
	DBSEEK(CATEGO->NIV)
	IF FOUND()
		ClIm:=INDEXKEY(0)
		ClIm:=SUBSTR(ClIm, 1, LEN(ClIm)-4)
		VlIm:=&(INDEXKEY(0))
		VlIm:=SUBSTR(VlIm, 1, LEN(VlIm)-2)
		ENCAB()
		i+=3
		TSuma:=SUMVOT(ClIm, VlIm, CANDI->(RECNO()), 1)
		DO WHILE &ClIm==VlIm
			CONTEN(1)
			IF(i>=54, CAMPAG(2), .T.)
			i+=1
			DBSKIP()
		ENDDO

		@ i,  0 SAY "ABSTENCION..."
		@ i, 56-y SAY Acum[CATEGO->FACU-1] PICT "99,999,999"
		@ i, 71-y SAY Acum[CATEGO->FACU-1]*100/TSuma PICT "999.99"
		i+=2
		@ i-1, 0 SAY REPLICATE("=", t1)
		@ i, 40-y SAY "TOTAL VOTOS"
		@ i, 56-y SAY TSuma PICT "99,999,999"
		@ i+2, 20 SAY "N� "+Plr(NomSal)+" Escrutadas= "+LTRIM(STR(Acum[CATEGO->FACU]))
		i+=3
	ELSE
		@ i, 0 SAY SIN
	ENDIF
ELSEIF VAL(CATEGO->ESCREF)<=VAL(Eti[Pr, 3])
	FOR j=2 TO Pr
		CATALOG->(DBSEEK(Eti[j, 3]))
		SELECT (CATALOG->NOM_ARCH)
		IF Eti[j, 3]==CATEGO->ESCREF
			Clave:=INDEXKEY(0)
			Valor:=&(INDEXKEY(0))
		ENDIF
		IF(.NOT. EOF(), UBICACION(), .T.)
	NEXT j
	SELECT CANDI
	IF CATEGO->ESCREF=="11"
		DBSEEK(CATEGO->NIV)
		IF FOUND()
			Clave:=INDEXKEY(0)
			Clave:=SUBSTR(Clave, 1, LEN(Clave)-4)
			Valor:=&(INDEXKEY(0))
			Valor:=SUBSTR(Valor, 1, LEN(Valor)-2)
		ENDIF
	ENDIF

	LOCATE FOR NIV==CATEGO->NIV .AND. &Clave==Valor
	IF FOUND()
		ENCAB()
		i+=3
		TSuma:=SUMVOT(Clave, Valor, CANDI->(RECNO()), 2)
		DO WHILE NIV==CATEGO->NIV .AND. &Clave==Valor
			CONTEN(2)
			IF(i>=45, CAMPAG(2),.T.)
			i+=1
			DBSKIP()
		ENDDO

		SELECT (CATALOG->NOM_ARCH)
		@ i,  0 SAY "ABSTENCION..."
		@ i, 56-y SAY FIELDGET(CATALOG->L_INF+CATEGO->FACU-1) PICT "99,999,999"
		@ i, 71-y SAY FIELDGET(CATALOG->L_INF+CATEGO->FACU-1)*100/TSuma PICT "999.99"
		i+=2
		@ i-1, 0 SAY REPLICATE("=", t1)
		@ i, 40-y SAY "TOTAL VOTOS"
		@ i, 56-y SAY TSuma PICT "99,999,999"
		IF PROCNAME(1)<>"TOTMES"
			@ i+2, 20 SAY "N� "+Plr(NomSal)+" Escrutadas= "+LTRIM(STR(FIELDGET(CATALOG->L_INF+CATEGO->FACU)))
		ENDIF
		i+=3
		SELECT CANDI
	ELSE
		@ i, 0 SAY SIN
	ENDIF
ELSEIF Eti[Pr, 3]=="11"
	SELECT CATALOG
	LOCATE FOR VAL(ESCAL)=VAL(SUBSTR(Eti[Pr, 3], 1, 1))+1
	DO WHILE VAL(ESCAL)<VAL(SUBSTR(CATEGO->ESCREF, 1, 1))
		IF TIPO
			AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
		ENDIF
		SKIP
	ENDDO
	DBSEEK(CATEGO->ESCREF)
	AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
	CATALOG->(DBSEEK(Eti[Pr+1, 3]))
	SELECT (CATALOG->NOM_ARCH)
	DBGOTOP()
	DO WHILE .NOT. EOF()
		IF(i>=45, CAMPAG(2), .T.)
		i+=1
		UBICACION()
		Clave:=INDEXKEY(0)
		Valor:=&(INDEXKEY(0))
		BaseTra:=ALIAS()
		RECUR(Pr+2, Clave, Valor)
		CATALOG->(DBSEEK(Eti[Pr+1, 3]))
		SELECT (BaseTra)
		SKIP
	ENDDO

ELSEIF VAL(Eti[Pr, 3])>11
	SELECT CATALOG
	LOCATE FOR VAL(ESCAL)=VAL(SUBSTR(Eti[Pr, 3], 1, 1))+1
	DO WHILE VAL(ESCAL)<VAL(SUBSTR(CATEGO->ESCREF, 1, 1))
		IF TIPO
			AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
		ENDIF
		SKIP
	ENDDO
	DBSEEK(CATEGO->ESCREF)
	AADD(Eti, {TRIM(NOMBRE), SPACE(2), ESCREF, SUBSTR(LTRIM(NOMBRE), 1, 1)+ESCREF})
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
RETURN

STATIC FUNCTION ENCAB()
PUBLIC t1
t1:=0
Enca:=ARRAY(4)
Enca[1]:=CENTER("Candidato", 35, .T.)
IF(Ptd, Enca[2]:="", Enca[2]:=CENTER("Partido o Grupo", 20, .T.))
Enca[3]:=" N� Votos "
Enca[4]:="  % Votos "
FOR t=1 TO LEN(Enca)
	@ i+1, t1 SAY CHR(27)+"E"+Enca[t]+CHR(27)+"F"
	t1+=LEN(Enca[t])+1
NEXT t
@ i+2, 0 SAY REPLICATE("=", t1)
RETURN

STATIC FUNCTION CONTEN(Alc)
@ i,  0 SAY CANDI->NOMBRE
IF Alc=2
	ResCan:=CATALOG->L_INF+CATEGO->FACU-CATEGO->FSIM+CANDI->NPar-CANDI->NpSim
	SELECT (CATALOG->NOM_ARCH)
	@ i, 56-y SAY FIELDGET(ResCan) PICT "99,999,999"
	@ i, 71-y SAY FIELDGET(ResCan)*100/TSuma PICT "999.99"
ELSEIF Alc=1
	ResCan:=CATEGO->FACU-CATEGO->FSIM+CANDI->NPar-CANDI->NpSim

	@ i, 56-y SAY Acum[ResCan] PICT "99,999,999"
	@ i, 71-y SAY Acum[ResCan]*100/TSuma PICT "999.99"
ENDIF
SELECT CANDI
IF .NOT. Ptd
	Lcav:=CANDI->(INDEXKEY(0))
	Lval:=&(Lcav)
	SELECT INTERM
	i1:=1
	DO WHILE &Lcav==Lval
		i+=1
		@ i, 38 SAY PART_GRP->SIGLAS
		IF Alc=2
			SELECT (CATALOG->NOM_ARCH)
			@ i, 56-y SAY FIELDGET(ResCan+i1) PICT "99,999,999"
			@ i, 71-y SAY FIELDGET(ResCan+i1)*100/TSuma PICT "999.99"
		ELSEIF Alc=1
			@ i, 56-y SAY Acum[ResCan+i1] PICT "99,999,999"
			@ i, 71-y SAY Acum[ResCan+i1]*100/TSuma PICT "999.99"
		ENDIF
		SELECT INTERM
		i1+=1
		SKIP
	ENDDO
ENDIF
@ i+1, 0 SAY REPLICATE("-", t1)
i+=1
SELECT CANDI
RETURN

STATIC FUNCTION UBICACION()
IF CATALOG->TIPO
	FOR i2=1 TO CATALOG->L_INF
		IF FIELDSIZE(i2)>=30
			i3:=i2
			EXIT
		ENDIF
	NEXT i2
ELSEIF CATALOG->(RECNO())<>CATALOG->(LASTREC())
	i3:=CATALOG->L_INF
ELSE
	i3:=CATALOG->L_INF-1
ENDIF

IF CATALOG->TIPO
	DesNom:=SUBSTR(FIELDGET(i3), 1, MIN(52, LEN(TRIM(FIELDGET(i3)))))
ELSE
	DesNom:=SPACE(10)
ENDIF
@ i, 0 SAY TRIM(CATALOG->NOMBRE)+REPLICATE(".", 20-LEN(TRIM(CATALOG->NOMBRE)))+": "+FIELDGET(i3-1)+" "+DesNom
IF CATALOG->(RECNO())=CATALOG->(LASTREC())-1
	@ i+1, 0 SAY "Direcci�n: "+DIRE
	i+=1
ELSEIF CATALOG->(RECNO())=CATALOG->(LASTREC())
	@ i+1, 0 SAY "Acta: "+ACTA
	i+=1
ENDIF
i+=1
RETURN

STATIC FUNCTION RECUR(j, Cl, Vl)
LOCAL k, ArSel
Cl1:=Cl
Vl1:=Vl
FOR k=j TO LEN(Eti)
	CATALOG->(DBSEEK(Eti[k, 3]))
	SELECT (CATALOG->NOM_ARCH)
	ArSel:=ALIAS()
	LOCATE FOR &Cl1==Vl1
	IF FOUND()
		DO WHILE &Cl1==Vl1
			UBICACION()
			Clave:=INDEXKEY(0)
			Valor:=&(INDEXKEY(0))
			RECUR(k+1, Clave, Valor)
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
LOCATE FOR NIV==CATEGO->NIV .AND. &Cl1==Vl1
IF FOUND()
	ENCAB()
	i+=3
	TSuma:=SUMVOT(Cl1, Vl1, CANDI->(RECNO()), 2)
	DO WHILE NIV==CATEGO->NIV .AND. &Cl1==Vl1
		CONTEN(2)
		IF(i>=45, CAMPAG(2), .T.)
		i+=1
		DBSKIP()
	ENDDO
	
	SELECT (CATALOG->NOM_ARCH)
	@ i,  0 SAY "ABSTENCION..."
	@ i, 56-y SAY FIELDGET(CATALOG->L_INF+CATEGO->FACU-1) PICT "99,999,999"
	@ i, 71-y SAY FIELDGET(CATALOG->L_INF+CATEGO->FACU-1)*100/TSuma PICT "999.99"
	i+=2
	@ i-1, 0 SAY REPLICATE("=", t1)
	@ i, 40-y SAY "TOTAL VOTOS"
	@ i, 56-y SAY TSuma PICT "99,999,999"
	@ i+2, 20 SAY "N� "+Plr(NomSal)+" Escrutadas= "+LTRIM(STR(FIELDGET(CATALOG->L_INF+CATEGO->FACU)))
	i+=3
	SELECT CANDI
ELSE
	@ i, 0 SAY SIN
	IF(i>=50, CAMPAG(2), .T.)
	i+=1
ENDIF
i+=2
RETURN

STATIC FUNCTION SUMVOT(p1, p2, p3, p4)
TotSum:=0
DO WHILE CANDI->NIV==CATEGO->NIV .AND. &p1==p2
	Indice:=CATALOG->L_INF+CATEGO->FACU-CATEGO->FSIM+CANDI->NPar-CANDI->NpSim
	IF p4=2
		SELECT (CATALOG->NOM_ARCH)
		TotSum+=FIELDGET(Indice)
		SELECT CANDI
	ELSE
		TotSum+=Acum[Indice]
	ENDIF
	CANDI->(DBSKIP())
ENDDO
IF p4=2
	SELECT (CATALOG->NOM_ARCH)
	TotSum+=FIELDGET(CATALOG->L_INF+CATEGO->FACU-1)
	SELECT CANDI
ELSE
	TotSum+=Acum[CATALOG->L_INF+CATEGO->FACU-1]
ENDIF
CANDI->(DBGOTO(p3))
RETURN (TotSum)
