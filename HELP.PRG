* PROGRAMA HELP.PRG
* 11/05/95

parameters p, l, v
WOPEN(0, 0, 24, 79,.T.)
WBOX(2)
CANCREF()
Escur:=SETCURSOR()
SETCURSOR(0)
DO CASE
CASE P=="TITULOS"
TEXT



          ESTE MENU LE PERMITE A USTED CONFIGURAR SU AMBIENTE ELECTORAL
          DE TAL MANERA QUE LA INFORMACION QUE INTRODUZCA  AQUI SERA LA
          QUE IDENTIFIQUE LOS INFORMES DE SALIDA, REPORTES Y  PANTALLAS
          DEL SISTEMA POSTERIORMENTE.
          El nombre del Universo  se refiere a la entidad Institucional,
          Geogr fica, etc.. que agrupa a todos los electores que  han de
          participar en el proceso. Ej. Universidad de Los Andes.
          El  nombre de la Instituci¢n  encargada del proceso se refiere
          al organismo o persona encargada de arbitrar, dirigir y llevar
          a cabo el proceso electoral. Ej. Comisi¢n Electoral.
          El T¡tulo del Proceso se trata de la  referencia a la candida-
          tura de mayor relevancia  del  proceso  as¡ como la referencia
          cronol¢gica de dicho Proceso. Ej. Equipo Rectoral.


                     | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="MENU_PRIN" .OR. P=="DESP_SUBM"
TEXT

          ESTA ES LA PANTALLA DE PRESENTACION DEL SISTEMA DE INFORMACION
          ELECTORAL.

          En la parte superior de la pantalla se encontrar   un  men£  de
          Opciones  que  le permitir n  Administrar el funcionamiento del
          Sistema seg£n los mensajes de Ayuda mostrados en la l¡nea final
          de la Pantalla.

          Es recomendable  que  configure  la computadora de la siguiente
          manera:

          En el Archivo CONFIG.SYS ..... La opci¢n FILES=100
	 
          En el Archivo AUTOEXEC.BAT ... La instrucci¢n SET CLIPPER=F90

          Luego RESETEAR para que el Sistema las lea.



                      | Pulse tecla para volver al Sistema |


ENDTEXT

CASE P=="ENTCAT"
TEXT

          AQUI  PODRA ESTABLECER  LAS CATEGORIAS  DE CANDIDATURAS PARA LAS 
          CUALES DESEA INICIAR EL SISTEMA.
          El encabezado CATEGORIAS A ELEGIR trata sobre el tema  de esta 
          pantalla. 
          Cada categor¡a corresponde a un tipo de candidatura a  participar
          en  el proceso. Se diferencia una  categor¡a de   otra en  cuanto
          al cargo que est  en disputa mediante el proceso.  En el  caso de
          que el proceso electoral sea mixto (Listas y Uninominal) simult -
          neamente se ha de establecer una categor¡a para cada caso, siendo
          recomendable darle relevancia a aquella  que agrupa  mayor n£mero
          de electores. Ej En un estado cualquiera se eligen Diputados a la
          asamblea   legislativa,   en  un proceso electoral mixto de puede
          elegir la mitad de ellos mediante v¡a Uninominal entonces se divi-
          de el territorio de dicho estado seg£n el n£mero  de Diputados  a 
          elegir mediante v¡a Uninominal, mientras la  otra mitad  a trav‚s 
          listas de cada partido y correspondiendo a la  poblaci¢n de  todo 
          el estado. En este caso se establecen las categor¡as de la sigui-
          ente manera:
                           i - DIP. ASAMBLEA LISTA
                          ii - DIP. ASAMBLEA UNINOMINAL

                     | Pulse tecla para volver al Sistema |
ENDTEXT

CASE P=="ENTDIV"
TEXT

          ESTE MENU PERMITE INFORMARLE AL SISTEMA ACERCA DEL PARTICIONA-
          MIENTO  JERARQUICO  QUE SE DEFINE  SOBRE EL UNIVERSO ELECTORAL
          CON LA FINALIDAD  DE:
          a) ESTABLECER CATEGORIAS DE  CANDIDATURAS DIFERENTES  A LA QUE
          ABARCA A TODO EL UNIVERSO ELECTORAL Y b) PARA GENERAR REPORTES
          DE TOTALIZACION SOBRE UN SUBCONJUNTO DEL UNIVERSO.
          Cada divisi¢n  o  partici¢n del Universo est  contenida en por 
          lo  menos  otra  siendo el primer nivel de  partici¢n definida
          directamente sobre el conjunto universo.
          La columna denominada Nivel se refiere al nivel jer rquico  de
          partici¢n.  nivel=1  se  refiere al conjunto universo mientras
          que nivel=2 significa que la partici¢n est  siendo hecha sobre
          el conjunto universo y as¡ sucesivamente.
          Referencia es solo un identificador de cada subdivisi¢n o par-
          tici¢n.
          TIPO se define .T. verdadero  si la  divisi¢n corresponde a una 
          divisi¢n Nominada  (si existe,  debe haber una y solo  una  por
          nivel y debe tener referencia 1)
          Tipo se define .F. falso  si  la  subdivisi¢n corresponde a una 
          divisi¢n Numerada. El valor por defecto de TIPO ser  .T.

                     | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="ASIGN"

TEXT



          MEDIANTE ESTE PROCEDIMIENTO PODRA ASIGNAR CADA UNA DE LAS CATE-
          GORIAS  DE CANDIDATURAS AL RESPECTIVO SUBGRUPO DE LA  POBLACION 
          VOTANTE QUE PARTICIPARA EN LA ELECCION.
          Hay que tomar en cuenta que a este nivel las categor¡as de Can-
          didaturas representan la diversidad de cargos que  esta en dis-
          puta diferenci ndose entre ellas, por el cargo. Si  dos  cargos
          son  iguales  entonces  deben ser diferenciados en la opci¢n de
          Categor¡as del Men£ titulado "Iniciar". A cada categor¡a le co-
          rresponde un segmento gen‚rico de la poblaci¢n de votantes, tal
          que dos categor¡as pueden  estar asignadas  a la misma subdivi-
          si¢n de la poblaci¢n, pero una categor¡a solo puede ser asigna-
          da a una y solo una subdivisi¢n de la poblaci¢n.

                     | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="VISION"

TEXT

              Alt+Flechas de Desplazmt para Mover Ventana Activa
              hasta lugar preferido.
              Es  recomendable  colocarla en  las primeras lineas
              visibles de la pantalla.

                 Alt+F1 => Regresa a Ventana Anterior


              NO OLVIDE QUE LA INFORMACION ACERCA DE LAS  ACTIVIDADES
              QUE PUEDE REALIZAR ESTE PROCESO ESTA EN LA ULTIMA LINEA
              VISIBLE DE LA PANTALLA.
              Para ejecutar cualquier tarea dentro de ventana activa,
              pulse  Alt  seguido de la tecla  se¤alada dentro de los 
              s¡mbolos < >.

              Recorra la tabla utilizando las teclas de Desplazamiento
              del cursor.

                      | Pulse tecla para volver al Sistema |


ENDTEXT

CASE P=="RSUB" .OR. P=="IMPRDIV"

TEXT

              IMPRIMIR Imprime la lista de Subdivisiones espec¡ficas
              seg£n el men£ POR.

              La pantalla con t¡tulo  escogido le permite asignar  la
              restricci¢n de su preferencia; si no recuerda el C¢digo
              solicitado por  el Sistema entonces P£lse la tecla F10,
              como se indica en la £ltima linea de la ventana.

              Para confirmar si las restricciones elegidas son correc-
              tas presione S, en caso contario  pulse  cualquier  otra
              tecla para volver a asignarla. 
              Con la tecla <ESC> puede abortar esta actividad.


                       | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="GENF"

TEXT

               En este m¢dulo se generan en forma autom tica,  las listas
               de subdivisiones que fueron catalogadas como TIPO = .F. en
               Iniciar - Subdiv....

               El proceso consiste en escoger del men£ que aparece en pan-
               talla, la subdivisi¢n a generar.

               Este proceso puede ser lento, debe ser paciente.


               CUALQUIER INFORMACION ADICIONAL RECURRA AL MANUAL DE USUARIO


                        | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="PARG"

TEXT


             En esta opci¢n se genera la lista de los partidos pol¡ticos
             o grupos electorales que han de participar en la contienda.

             Si en el proceso electoral que se est  configurando, no hay
             participaci¢n de  partidos pol¡ticos o grupos, simplemente,
             no almacene nombres en la tabla que aparece en pantalla y si
             contiene alguno(s), borrelos.

             Se recomienda  que las siglas sean todas diferentes al igual
             que la informaci¢n aportada en la columna titulada No.

             OBSERVE LAS OPCIONES QUE APARECEN EN LA ULTIMA LINEA VISIBLE
             DE LA PANTALLA.

                           | Pulse tecla para volver al Sistema |  

ENDTEXT

CASE P=="CAND"

TEXT


             A trav‚s de este men£ podr  ubicar el directorio de candi-
             datos de las diferentes categor¡as para AGREGAR, BORRAR,
             EDITAR, ASIGNAR tal como aparecer  especificado.

             Recuerde que solo despu‚s de haber realizado las activida-
             des de las opciones anteriores a ‚sta se asegura un ¢ptimo
             estado de la Informaci¢n.

                       | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="EDICION"

TEXT


             Cuando la Categor¡a de Candidatura elegida corresponda en 
             cobertura  a un Subconjunto del Universo Electoral, (esto
             es, para cada elemento  de la partici¢n  hecha,  existir 
             una lista diferente e independiente de Candidatos) enton-
             ces el sistema solicita la  informaci¢n sobre los c¢digos
             de  ubicaci¢n ( Subdivisiones ). Si no recuerda  consulte 
             con F10.

             RECUERDE QUE ESTA ACTIVIDAD SOLO TIENE SENTIDO SI Y SOLO
             SI YA SE HA DETERMINADO COMPLETAMENTE LAS SUBDIVISIONES

                     | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="BRPRIN"

TEXT


          CONSULTE LA ULTIMA LINEA VISIBLE DE LA PANTALLA PARA CONSULTA

          Atl+<A> Presione la tecla Alt y manteni‚ndola presionada pre-
                  sione la tecla "A"; para Agregar un Candidato.

          Alt+<B> ...........; para Borrar un Candidato.

          Alt+<E> ...........; para Editar.

          F7 Presione la tecla F7 para Asignar partidos o grupos electo-
             rales a candidatos.
             Esta actividad s¢lo tiene sentido si hay partidos pol¡ticos
             o grupos electorales inscritos.

             (Consulte Men£ Configurar -> Partidos o Grupos)

                         | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="ASIGNAC"

TEXT


              Pulse <Enter>  para Asignar  o Eliminar  partido o grupo
              electoral de Candidato. El S¡mblo û que aparece a la de-
              recha  de la  opci¢n  de  partidos o grupos electorales,
              quiere decir que esa opci¢n est   asignada al  candidato
              actual en ventana anterior (de fondo). 
              Las  opciones en  video inverso con letra blanca opaca,
              significa que ese partido a sido asignado a otro candi-
              dato y por lo tanto no puede ser asignado al actual.

              Movi‚ndose en el Men£ a trav‚s de las teclas de movimie-
              nto cursor podr  reconocer las opciones v lidas en video
              inverso pero con letra blanca resaltada.



                      | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="RCAN" .AND. V=="CAT"

TEXT

              Mediante este Men£ de Opciones podr  Imprimir los candi-
              datos correspondientes a alguna de las Categor¡as desee,
              siempre y cuando, existan candidatos en dicha Categor¡a,
              ya que si no existen el men£  de Opciones  no presentar 
              la opci¢n para la cual no se hayan inscrito candidatos.

              Si el Sistema tiene registrado Partidos Pol¡ticos o Gru-
              pos Electorales, el Reporte a generar  a trav‚s de  este
              men£ presentar  adem s de datos personales del Candidato
              los partidos o grupos que  fueron asignados al Candidato
              al  momento  de  su  inscripci¢n;  si  tal asignaci¢n no
              hubiera sido hecha, y hay partidos pol¡ticos, el sistema
              reportar  en la columna encabezada Partido o Grupo: 
              "Sin Asignar".

              <Esc> Salir de Men£

                          | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="RCAN" .AND. V=="PR"


TEXT

              Escoja a que nivel quiere el reporte, esto es, puede
              pedir  el reporte para diferentes niveles de agrupa-
              ci¢n, seg£n lo indica este men£.

              Las opciones de este men£ dependen de la  asignaci¢n
              de Categor¡as a Subdivisiones hecha en Opcion:
                   Iniciar - Asignar Categ. a Subdiv.

                   <Esc> Devolver a men£ Anterior

                      | Pulse tecla para volver al Sistema |


ENDTEXT

CASE P=="RUTIMP" .OR. P=="REPTOT"

TEXT



             Indique el C¢digo solicitado para Generar reporte si no
             lo recuerda presione F10 para Consultar.
 
             El sistema env¡a mensajes de validaci¢n al lado derecho
             de las columnas de c¢digos.

             <Esc> Salir

                       | Pulse tecla para volver al Sistema |

ENDTEXT

CASE PROCNAME(6)=="ENTVOT"

TEXT

            Mediante la introducci¢n de los datos aqu¡ solicitados,
            el  sistema  dar   inicio  al proceso de votaci¢n; debe
            tener presente que la informaci¢n que  debe suministrar
            consiste en c¢digos que se supone son del  conocimiento
            de  la(s)  persona(s)  que manejan el sistema para este
            momento de apertura de mesa o equivalente.

            <Esc> Salir

                          | Pulse tecla para volver al Sistema |

ENDTEXT

CASE P=="TOTALZ" .AND. READVAR()=="RTOT"

TEXT


             Elija la Categor¡a acerca de la cual requiera infor-
             maci¢n resultante del proceso de votaci¢n.

             <Esc> Salir

                         | Pulse tecla para volver al Sistema |


ENDTEXT

CASE P=="TOTALZ" .AND. READVAR()=="PR"

TEXT

            Elija a que nivel requiere la informaci¢n  solicitada
            para la categor¡a que escogi¢.

             (Gral) Al lado derecho de la opci¢n quiere decir  que
                    se generan varios reportes.

             (Esp)  Al lado derecho de  la opci¢n quiere decir que
                    se genera un solo reporte en particular.


             <Esc> Salir


                         | Pulse tecla para volver al Sistema |
ENDTEXT

OTHERWISE
	KEYBOARD CHR(13)

ENDCASE

INKEY(0)
SETCURSOR(Escur)
LLAMREF()
WCLOSE()