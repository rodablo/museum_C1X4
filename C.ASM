;
;******  Central Telefonica 1 x 4 + portero version 1.0      21 abr 88  ******
;*                                                                           *
;*       Segmento: HEAD.SEG                                                  *
;******  Funcion : Declaraciones e inicializacion.                      ******
;
;
KIT     EQU    0                        ;KIT 1=SI/0=NO

;------------------------------ DEF PARA EL MICRO

    IF  KIT EQ 0
PDA     EQU             0               ;DATA A
PDB     EQU             1               ;DATA B
PDC     EQU             2               ;DATA C
DDRA    EQU             4               ;DDR A
DDRB    EQU             5               ;DDR B
DDRC    EQU             6               ;DDR C
ADDROFF EQU             0               ;RAM=$10, EPROM=$80
TDLY            EQU     225   ;242      ;TIMER DELAY DATA
        ORG     $784
        FCB     %11000100               ;MOR=CLK RC,TIMER FIJO,PRSCALER%16
        ORG     $7F8
        FDB     TIN                     ;INIT VECTOR TIMER
        FDB     EIN                     ;INIT VECTOR INTERRUPCION EXT.
        FDB     START                   ;INIT VECTOR SWI
        FDB     START                   ;INIT VECTOR RESET
    ENDIF

;------------------------------ DEF PARA EL KIT

    IF  KIT EQ 1
PDA     EQU             $F2             ;DATA A
PDB     EQU             $F3             ;DATA B
PDC     EQU             $F4             ;DATA C
DDRA    EQU             $F6             ;DDR A
DDRB    EQU             $F7             ;DDR B
DDRC    EQU             $F8             ;DDR C
ADDROFF EQU             $80             ;RAM=$90, EPROM=$100
TDLY            EQU     150             ;TIMER DELAY DATA
    ENDIF

;------------------------------ DEF COMUNES

PDAIN   EQU             %00010000       ;INICIALIZACION DEL PUERTO A
DDRAIN  EQU             %11010111       ;CONFIG DE I/O
DATA            EQU     0               ;DATA MATRIZ
STROBE          EQU     1               ;CLOCK MATRIZ
RELE            EQU     2               ;RELE LINEA
RINGDET         EQU     3               ;DETECCION DE LLAMADA
MUSIC           EQU     4               ;MUSICA SI/NO
PORTERL         EQU     6               ;RELE PORTERO
PORTECR         EQU     7               ;CERRADURA DEL PORTERO

TD      EQU             8               ;TIMER DATA REG.
TC      EQU             9               ;TIMER CONTROL REG.
TMSK            EQU     6               ;TIMER INT. MASK BIT
TREQ            EQU     7               ;TIMER INT. REQUEST BIT

;------------------------------ CONSTANTES

SPCL    EQU     7                       ;21MS T MIN INTER PULSO (- = TRANS.)
SPCH    EQU     18                      ;54MS T MAX INTER PULSO (TID)
MRKL    EQU     10                      ;30MS T MIN PULSO (- = TRANSITORIO)
MRKH    EQU     26                      ;78MS T MAX PULSO (+ = COLGADO)
TO.NOTO EQU             $FF             ;TONO NULO
TO.DISC EQU             $0              ;TONO CONTINUO
TO.LLAM EQU             %11000010       ;TONO LLAMADA
TO.OCUP EQU             %00010000       ;TONO OCUPADO
TO.AVIS EQU             %11111100       ;TONO AVISO
CA.INTE EQU             %11010000       ;CAMPANA INTERNA
CA.EXTE EQU             %11000000       ;CAMPANA EXTERNA
CA.AVIS EQU             %11110000       ;TONO AVISO

        ORG             $10+ADDROFF
FG      RMB             1               ;FLAGS COMUNES
CAPEXTE         EQU     0               ;PARA CAPTURA DE LINEA
BARR0B          EQU     1               ;INDICA CANAL1 OCUPADO
ENTRE25         EQU     2               ;PARA COMANDOS
WA              EQU     3               ;ESPERA POR INTERRUPCION
LINEACT         EQU     4
CONFERE         EQU     5               ;
IGNOCUP         EQU     6
PORTEOC         EQU     7               ;PORTERO ATENDIDO

;------------------------------ PARA LOS INTERNOS

L0      RMB             1               ;WORKAREA DE FLAG0
D0      RMB             1               ;WORKAREA DESTINO FLAG0
F0      RMB             4               ;FLAGS DE INTERNO
PPE             EQU     0               ;PULSO PENDIENTE
DPE             EQU     1               ;DIGITO PENDIENTE
DVA             EQU     2               ;DIGITO VALIDO
TID             EQU     3               ;TIEMPO INTER DIGITO OK
COL             EQU     4               ;COLGADO
BPRQ            EQU     5               ;BEEP
BPOK            EQU     6               ;BEEP EN EJECUCION
NOTO            EQU     7               ;DISPONIBLE

L1      RMB             1               ;WORKAREA ORIGEN FLAG1 (8-15)
D1      RMB             1               ;WORKAREA DESTINO FLAG1
F1      RMB             4               ;FLAGS
OCUPADO         EQU     0               ;INTERNO DESCOLGADO O SIENDO LLAMADO
RECIBIR         EQU     1               ;INTERNO ESTA SIENDO LLAMADO
CONECTE         EQU     2               ;PERMISO PARA QUE EL QUE LLAMA CONECTE
LLAMADA         EQU     3               ;INTERNO ESTA LLAMANDO
LOTENGO         EQU     4               ;OCUPACION DE [D] VALIDA
RETENGO         EQU     5               ;INTERNO ESTA RETENIENDO LA LINEA
RETRORQ         EQU     6               ;TESTEA DESTINO LIBRE SI ESTA COLGADO
TOAVISO         EQU     7               ;SUPERPONE BEEP INTERMITENTE
F1L     RMB             1               ;FLAG1 PARA LINEA

L2      RMB             1               ;WORKAREA ORIGEN FLAG2 (16-23)
D2      RMB             1               ;WORKAREA DESTINO FLAG2 (16-23)
F2      RMB             4               ;FLAGS
LINEA           EQU     0               ;CONECCION A LA LINEA
PORTE           EQU     1               ;CONECCION AL PORTERO
BARR1           EQU     2               ;CONECCION A LA BARRA1
BARR0           EQU     3               ;CONECCION A LA BARRA0
DIAL            EQU     4               ;SALTAEA EL DISCOM
PONTONO         EQU     5               ;PONE TONO DE DISCAR
ESLINEA         EQU     6               ;MI [D] ES LA LINEA
TRANVAL         EQU     7               ;NO TRANSFIERE LA LINEA

L3      RMB             1               ;WORKAREA ORIGEN FLAG2 (24-31)
D3      RMB             1               ;WORKAREA DESTINO FLAG2 (24-31)
F3      RMB             4               ;FLAGS
NOMOLES         EQU     0               ;CONDICION DE "NO MOLESTAR"
PRE1            EQU     1               ;SUBSET DE 1X
PRE0            EQU     2               ;SUBSET DE 10X
PRE9            EQU     3               ;SUBSET DE 9X
PREX            EQU     4               ;SUBSET DE 9XX
PASADA1         EQU     5               ;EFECTUA LIBERACION Y AUTOTRANSFERENCIA
PRE8            EQU     6               ;ESTOY CON EL PORTERO

L4      RMB             1               ;WORKAREA CATEGORIA

TSPACE  RMB             4               ;TIMER'S DE LECTURA DE DISCOS
TMARK   RMB             4               ;TIMER'S DE LECTURA DE DISCOS
DIGITO  RMB             4               ;DIGITOS
XL      RMB             1               ;ACA SALVA EL PUNTERO LOCAL
XN      RMB             1               ;VALOR DESTINO PROXIMA PASADA
XD      RMB             4               ;PUNTEROS HACIA EL DESTINO
XDL     RMB             1               ;PUNTEROS HACIA EL DESTINO DE LINEA
XDLAST  RMB             1               ;ULTIMO INTERNO QUE ATENDIO
XDENT   RMB             1               ;PRIMERO EN LA RONDA
XR      RMB             4               ;PUNTEROS HACIA EL DESTINO DE LA RETRO
XI      RMB             4               ;PUNTEROS HACIA LA INDIRECCION
CAT     RMB             4               ;CATEGORIA DE CADA INTERNO
CATI    RMB             1               ;BUFERR DESTINO CATEGORIA
CAD     RMB             4               ;SELECCION DE CADENCIA
CADWD   RMB             1               ;WORKAREA CADENCIA DESTINO
CADG    RMB             4               ;GENERADORES DE CADENCIA
BPBIT           EQU     4               ;DURACION DEL BEEP

;------------------------------ PARA LA LINEA

F4      RMB             1               ;FLAGS FIJOS PARA LA LINEA
DPPE            EQU     1               ;PULSO DISCANDOSE
DTID            EQU     2               ;TIEMPO INTERDISCADO
ONLINEA         EQU     3               ;LINEA CONECTADA
RETENGA         EQU     4               ;ORDEN DE RETENER
XDLASTF         EQU     5               ;LE DA BOLA A XDLAST
WDVA            EQU     6               ;DIGITO ESPERANDO SER DISCADO VALIDO
FIRSTDG         EQU     7               ;YA SE DISCO EL PRIMERO

DTIMER  RMB             1               ;TIMER PARA DISCADO SOBRE LA LINEA
DPOINT  RMB             1               ;PUNTERO DEL BUFFER DE ESPERA
DBUFF0  RMB             1               ;BUFFER PARA EL DIGITO DISCADO
DBUFF1  RMB             1               ;BUFFER DE ESPERA 1
DBUFF2  RMB             1               ;BUFFER DE ESPERA 2
TIMEDIV RMB             1               ;DIVISOR PARA LOS TEMPOS
TIMEOUT RMB             1               ;TIMEOUT LINEA
CAPEXBU RMB             1               ;ORIGEN DE LA CAPTURA EXTERNA

RINGVAL RMB             1               ;DETECCION DE LLAMADA
RINGCNT RMB             1               ;ANCHO DEL RING
PORTEDL RMB             1               ;TIMER DE CERRADURA

;------------------------------ COMIENZO DE EPROM

        ORG     $80+ADDROFF
MASK0   FCB     %01000000               ;UBICACION BIT DISCADO
        FCB     %00010000
        FCB     %00000100
        FCB     %00000001
MASK00  EQU     %10101010               ;PUESTA EN INPUT

MASK1   FCB     %10000000               ;UBICACION BIT CAMPANA
        FCB     %00100000
        FCB     %00001000
        FCB     %00000010

CATT    FCB     %00000000               ;CAT 1
        FCB     %00000001               ;CAT 2
        FCB     %00000011               ;CAT 3
        FCB     %00000111               ;CAT 4
        FCB     %00001111               ;CAT 5

;------------------------------ INICIALIZACION PUERTOS

START   SEI
        LDA     #DDRAIN                 ;CARGA CONFIG DEL PUERTO A
        STA     DDRA                    ;PROG EL PUERTO
        LDA     #PDAIN                  ;CARGA INICIALIZACION DEL PUERTO A
        STA     PDA                     ;INICIALIZA
        LDA     #MASK00                 ;CARGA CONFIG PUERTO B
        STA     DDRB                    ;PROG EL PUERTO
        CLR     PDB                     ;CAMPANAS EN 0
        LDA     #$0F                    ;CARGA CONFIG PUERTO C
        STA     DDRC                    ;PROG EL PUERTO

;------------------------------ INICIALIZACION VECTORES DEL KIT

    IF  KIT EQ 1
        LDA     #HIGH EIN               ;INIT VECTOR INTERRUPCION EXT.
        STA     $41
        LDA     #LOW EIN
        STA     $42
        LDA     #HIGH TIN               ;INIT VECTOR TIMER
        STA     $44
        LDA     #LOW TIN
        STA     $45

;------------------------------ INICIALIZACION RAM EN 0

        LDX     #$90                    ;X= ^PRINCIPIO DE LA RAM
CLEARL  CLR     ,X                      ;A 0
        INCX                            ;SIGUIENTE
        CPX     #$F0                    ;OJO LA PIA
        BNE     CLEARL                  ;ES $00? NO, SALTA
    ENDIF

    IF  KIT EQ 0
        LDX     #$10                    ;X= ^PRINCIPIO DE LA RAM
CLEARL  CLR     ,X                      ;A 0
        INCX                            ;SIGUIENTE
        BPL     CLEARL                  ;ES $80? NO, SALTA
    ENDIF

;------------------------------ INICIALIZACION FLAGS Y VARIABLES

        LDA     #%00010000              ;INIT COLGADO
        STA     F0                      ;INT. 2
        STA     F0+1                    ;INT. 3
        STA     F0+2                    ;INT. 4
        STA     F0+3                    ;INT. 5

        LDA     #$FF                    ;CADENCIA
        STA     CAD                     ;INT. 2
        STA     CAD+1                   ;INT. 3
        STA     CAD+2                   ;INT. 4
        STA     CAD+3                   ;INT. 5

        STA     DBUFF0                  ;DESCONEXION FISICA DE LINEA

        LDA     #%1111                  ;INIT DE LA CATEGORIZACION
        STA     CAT                     ;INT. 2
        LDA     #%111
        STA     CAT+1                   ;INT. 3
        STA     CAT+2                   ;INT. 4
        STA     CAT+3                   ;INT. 5

        CLRA                            ;INIT DEL SIGUEME
        STA     XI                      ;INT. 2
        INCA
        STA     XI+1                    ;INT. 3
        INCA
        STA     XI+2                    ;INT. 4
        INCA
        STA     XI+3                    ;INT. 5

;------------------------------ DELEY 4S PARA RINGDET

        LDA     #0-4                    ;4S
        STA     TIMEOUT                 ;SETEA

;------------------------------ ARRANQUE DE TIMER

        LDA     #$44                    ;PRESCALER = 4
        STA     TC                      ;SETEA
        LDA     #TDLY                   ;CARGA DELAY
        STA     TD                      ;SETEA TIMER
        BCLR    TMSK,TC                 ;HABILITA TIMER INT.

;------------------------------ INCLUSIONES DE MODULOS

        INCLUD  MAIN.SEG                ;LOOP PRINCIPAL Y COMUNICA.
        INCLUD  LINE.SEG                ;LINEA
        INCLUD  COMM.SEG                ;ACCIONES DE COMANDO
        INCLUD  RUTI.SEG                ;RUTINAS VARIAS
        INCLUD  EXIN.SEG                ;INTERRUPCION EXTERNA
        INCLUD  TMIN.SEG                ;INTERRUPCION DEL TIMER

        END
