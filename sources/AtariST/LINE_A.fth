\ *** Block No. 0 Hexblock 0 
\\                  *** Line-A Graphic ***           cas20130106
                                                                
This file contains the LINE-A graphic routines. While being     
sometimes faster than VDI Routines, LINE-A Functions are not    
supported on some newer Atari ST machines.                      
                                                                
It is recommended to only use VDI functions in new programs.    
This library is provided for compatibility reasons to be able   
to compile old source code. the programs will probablt not work 
on newer Atari machines.                                        
                                                                
                                                                
Examples for the use of LINE-A routines can be found in the file
DEMO.FB                                                         
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ Line A - Graphics   Loadscreen                     cas20130106
                                                                
Onlyforth                                                       
\needs Code  include assemble.fb                                
                                                                
.( use of LINE-A is deprecated and will not work on newer )     
.( Atari machines. Please use VDI routines instead!       )     
                                                                
Vocabulary Graphics   Graphics also definitions                 
                                                                
1 $10 +thru                                                     
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ Table offsets                                        26oct86we
                                                                
base @  decimal                                                 
 0 >label v_planes            2 >label v_lin_wr                 
 4 >label _cntrl                                                
 8 >label _intin             12 >label _ptsin                   
16 >label _intout            20 >label _ptsout                  
24 >label _fg_bp_1           26 >label _fg_bp_2                 
28 >label _fg_bp_3           30 >label _fg_bp_4                 
32 >label _lstlin            34 >label _ln_mask                 
36 >label _wrt_mode          38 >label _x1                      
40 >label _y1                42 >label _x2                      
44 >label _y2                46 >label _patptr                  
50 >label _patmsk            52 >label _multifill               
54 >label _clip              56 >label _xmn_clip                
58 >label _ymn_clip          60 >label _xmx_clip                
\ *** Block No. 3 Hexblock 3 
\ Table offsets                                        26oct86we
                                                                
 62 >label _ymx_clip          64 >label _xacc_dda               
 66 >label _dda_inc           68 >label _t_sclsts               
 70 >label _mono_status       72 >label _sourcex                
 74 >label _sourcey           76 >label _destx                  
 78 >label _desty             80 >label _delx                   
 82 >label _dely              84 >label _fbase                  
 86 >label _fwidth            90 >label _style                  
 92 >label _litemask          94 >label _skewmask               
 96 >label _weight            98 >label _r_off                  
100 >label _l_off            102 >label _scale                  
104 >label _chup             106 >label _text_fg                
108 >label _scrtchp          112 >label _scrpt2                 
114 >label _text_bg          116 >label _copytran               
base !                                                          
\ *** Block No. 4 Hexblock 4 
\ Variable                                           cas20130106
                                                                
Variable xmin_clip          Variable xmax_clip                  
Variable ymin_clip          Variable ymax_clip                  
Variable multi_fill           0 multi_fill !                    
Variable linemask         $FFFF linemask !      \ solid line    
Variable plane1               1 plane1 !        \ black         
Variable plane2               1 plane2 !        \ on            
Variable plane3               0 plane3 !        \ white         
Variable plane4               0 plane4 !                        
Variable cur_x                0 cur_x !                         
Variable cur_y                0 cur_y !                         
Variable wr_mode              0 wr_mode !       \ overwrite     
Variable scr_res              2 scr_res !       \ Hires         
                                                                
                                                                
\ *** Block No. 5 Hexblock 5 
\ arrays                                               17sep86we
                                                                
Variable pat_mask      1 pat_mask !                             
Variable pattern                                                
                                                                
Create   nopattern     0 , 0 ,                                  
Create   fullpattern   $FFFF , $FFFF ,    fullpattern pattern ! 
                                                                
Variable checking      checking on                              
Variable clipping      clipping off                             
                                                                
Create a_fonts  4 allot                                         
Create a_base   4 allot                                         
                                                                
                                                                
                                                                
\ *** Block No. 6 Hexblock 6 
\ Initialization                                       17sep86we
                                                                
Create a_setup   Assembler                                      
   $A000 ,  .l A0 a_base R#) move  A1 a_fonts R#) move          
   .w wr_mode R#) _wrt_mode A0 D) move                          
   plane1 R#) _fg_bp_1 A0 D) move                               
   plane2 R#) _fg_bp_2 A0 D) move                               
   plane3 R#) _fg_bp_2 A0 D) move                               
   plane4 R#) _fg_bp_4 A0 D) move                               
   rts  end-code                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 7 Hexblock 7 
\ line                                                 17sep86we
                                                                
Code line   ( x1 y1  x2 y2 -- )                                 
   a_setup bsr                                                  
   -1 # _lstlin A0 D) move    linemask R#) _ln_mask A0 D) move  
   SP )  _y2 A0 D) move    SP )+ cur_y R#) move                 
   SP )  _x2 A0 D) move    SP )+ cur_x R#) move                 
   SP )+ _y1 A0 D) move                                         
   SP )+ _x1 A0 D) move                                         
   $A003 ,  Next end-code                                       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 8 Hexblock 8 
\ rectangle                                            17sep86we
                                                                
Code rectangle  ( x1 y1  width heigth -- )                      
   a_setup bsr    clipping R#) _clip A0 D) move                 
   SP )+ D0 move   2 SP D) D0 add   D0 _y2 A0 D) move           
   SP )+ D0 move   2 SP D) D0 add   D0 _x2 A0 D) move           
   SP )+ _y1 A0 D) move     SP )+ _x1 A0 D) move                
   pattern R#) D6 move    D6 reg) A1 lea                        
   .l A1 _patptr A0 D) move  .w                                 
   pat_mask   R#) _patmsk A0 D) move                            
   multi_fill R#) _multifill A0 D) move                         
   xmin_clip  R#) _xmn_clip  A0 D) move                         
   ymin_clip  R#) _ymn_clip  A0 D) move                         
   xmax_clip  R#) _xmx_clip  A0 D) move                         
   ymax_clip  R#) _ymx_clip  A0 D) move                         
   $A005 ,  Next end-code                                       
\ *** Block No. 9 Hexblock 9 
\ Maus-Functions                                       17sep86we
                                                                
Code show_mouse                                                 
   a_setup bsr   .l _cntrl A0 D) A1 move                        
   .w 2 A1 D) clr   1 # 6 A1 D) move                            
   .l _intin A0 D) A1 move   A1 ) clr   $A009 ,  Next end-code  
                                                                
Code hide_mouse     $A00A ,  Next end-code                      
                                                                
Code form_mouse    ( addr -- )                                  
   a_setup bsr   .l _intin A0 D) A1 move                        
   .w SP )+ D6 move   D6 reg) A0 lea                            
   A0 )+ A1 )+ move   A0 )+ A1 )+ move    1 # A1 )+ move        
     0 # A1 )+ move     1 # A1 )+ move                          
   $10 D0 moveq   D0 DO   .l A0 )+ A1 )+ move   LOOP            
   $A00B ,   Next end-code                                      
\ *** Block No. 10 Hexblock A 
\ copyraster                                          bp 12oct86
                                                                
cr  .( For copyraster use VDI-Functions !!)  cr                 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\\                                                              
                                                                
$10 loadfrom gem\vdi.scr                                        
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 11 Hexblock B 
\ Checking                                           cas20130106
                                                                
| Create g_limits   &320 , &200 ,  &640 , &200 ,  &640 , &400 , 
                                                                
Code get_res   ( -- flag )                                      
   4 # A7 -) move  $0E trap   2 A7 addq   D0 SP -) move         
   Next end-code                                                
                                                                
| : (check       \ checking @ 0= ?exit                          
  dup  g_limits  scr_res @ 4 * 2+ + @ > abort" Y-Value too big" 
  over g_limits  scr_res @ 4 *   + @ > abort" X-Value too big" ;
                                                                
Code check   ( x y -- x y )                                     
   checking R#) tst 0= IF  NEXT  THEN  ;c:  (check ;            
                                                                
                                                                
\ *** Block No. 12 Hexblock C 
\ relative  set draw clipping                          18sep86we
                                                                
Code relative   ( dx dy  --  x y )                              
   SP )+ D0 move  cur_y R#) D0 add                              
   SP )+ D1 move  cur_x R#) D1 add                              
   D1 SP -) move  D0 SP -) move  Next end-code                  
                                                                
: set     ( x y -- )     check   cur_y !  cur_x ! ;             
: draw    ( x y -- )     check   cur_x @ cur_y @  2swap  line ; 
                                                                
: clip_window   ( x1 y1  x2 y2 -- )                             
    clipping on                                                 
    ymax_clip !   xmax_clip !   ymin_clip !   xmin_clip ! ;     
                                                                
                                                                
                                                                
\ *** Block No. 13 Hexblock D 
\ box                                                  18sep86we
                                                                
Code box   ( width heigth -- )                                  
   cur_y R#) D4 move   D4 D7 move   SP )+ D7 add                
   cur_x R#) D3 move   D3 D5 move   SP )+ D5 add                
   a_setup bsr  D3 _x1 A0 D) move   D4 _y1 A0 D) move           
                D5 _x2 A0 D) move   D4 _y2 A0 D) move   $A003 , 
   a_setup bsr  D5 _x1 A0 D) move   D4 _y1 A0 D) move           
                D5 _x2 A0 D) move   D7 _y2 A0 D) move   $A003 , 
   a_setup bsr  D3 _x1 A0 D) move   D7 _y1 A0 D) move           
                D5 _x2 A0 D) move   D7 _y2 A0 D) move   $A003 , 
   a_setup bsr  D3 _x1 A0 D) move   D4 _y1 A0 D) move           
                D3 _x2 A0 D) move   D7 _y2 A0 D) move   $A003 , 
   Next end-code                                                
                                                                
                                                                
\ *** Block No. 14 Hexblock E 
\ +sprite -sprite                                      11dec86we
                                                                
Code +sprite   ( sprt_def_blk sprt_sav_blk  x y -- )            
   SP )+ D1 move  SP )+ D0 move                                 
   SP )+ D6 move  D6 reg) A2 lea                                
   SP )+ D6 move  D6 reg) A0 lea                                
   .l $1E A7 -) movem>   $A00D ,   $7800 A7 )+ movem<           
   Next end-code                                                
                                                                
Code -sprite   ( sprt_sav_blk  -- )                             
   SP )+ D6 move  D6 reg) A2 lea                                
   .l $1E A7 -) movem>   $A00C ,   $7800 A7 )+ movem<           
   Next end-code                                                
                                                                
                                                                
                                                                
\ *** Block No. 15 Hexblock F 
\ put_pixel get_pixel                                  17sep86we
                                                                
Code put_pixel   ( x y  color -- )                              
   a_setup bsr   .l a_base R#) A0 move                          
      _intin A0 D) A1 move  .w SP )+ A1 ) move                  
   .l _ptsin A0 D) A1 move  .w SP )+ 2 A1 D) move               
                               SP )+ A1 ) move                  
   $A001 ,  Next end-code                                       
                                                                
Code get_pixel   ( x y -- color )                               
   a_setup bsr                                                  
   .l a_base R#) A0 move   _ptsin A0 D) A1 move                 
   .w SP )+ 2 A1 D) move   SP )+ A1 ) move                      
   $A002 ,   D0 SP -) move    Next end-code                     
                                                                
                                                                
\ *** Block No. 16 Hexblock 10 
\ polygon                                              17sep86we
                                                                
Code polygon   ( x1 y1 ... xn yn n )                            
   a_setup bsr                                                  
   clipping  R#) _clip A0 D) move                               
   pattern R#) D6 move    D6 reg) A1 lea                        
   .l A1 _patptr A0 D) move  .w                                 
   pat_mask   R#)    _patmsk A0 D) move                         
   multi_fill R#) _multifill A0 D) move                         
   xmin_clip  R#)  _xmn_clip A0 D) move                         
   ymin_clip  R#)  _ymn_clip A0 D) move                         
   xmax_clip  R#)  _xmx_clip A0 D) move                         
   ymax_clip  R#)  _ymx_clip A0 D) move                         
   .l _cntrl A0 D) A1 move   .w SP ) 2 A1 D) move               
   SP )+ D0 move   2 # D0 asl   2 D0 subq   D0 D5 move          
   $7FFF # D3 move    0 D4 moveq                                
\ *** Block No. 17 Hexblock 11 
\ polygon forts.                                       17sep86we
                                                                
   .l _ptsin A0 D) A1 move                                      
   BEGIN   .w 0 D0 SP DI) D1 move  D1 A1 )+ move  D0 1 # btst   
                 0= IF  D1 D3 cmp  CC IF  D1 D3 move  THEN      
                        D1 D4 cmp  CS IF  D1 D4 move  THEN  THEN
           D0 tst 0<> WHILE  2 D0 subq  REPEAT                  
   0 D5 SP DI) A1 )+ move  2 D5 subq  0 D5 SP DI) A1 ) move     
   4 D5 addq  D5 SP adda                                        
   .l A0 D5 move                                                
   BEGIN   D5 A0 move  .w D3 _y1 A0 D) move   $A006 ,           
           1 D3 addq  D3 D4 cmp  0= UNTIL                       
   Next end-code                                                
                                                                
                                                                
                                                                
\ *** Block No. 18 Hexblock 12 
\                                                               
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 19 Hexblock 13 
\ Line A - Graphics   Loadscreen                                
                                                                
                                                                
Line-A Routinen erhalten ein eigenes Vocabular.                 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 20 Hexblock 14 
\ Table offsets                                        01jan86we
                                                                
Die Definitionen auf diesem Screen enthalten die sogenannten    
Line_A Variablen. Der Aufruf �ber $A000 liefert unter anderem   
die Basisadresse dieser Variablen zur�ck.                       
                                                                
Wenn diese Definitionen in anderen Programmen mitgenutzt werden 
sollen, m�ssen diese beiden Screens mit                         
                                                                
          2 LOADFROM LINE_A.SCR                                 
und       3 LOADFROM LINE_A.SCR                                 
                                                                
eingebunden werden.                                             
                                                                
                                                                
                                                                
\ *** Block No. 21 Hexblock 15 
\ Table offsets                                        01jan86we
                                                                
Die Beschreibung der Line_A Variablen findet man in der ent-    
sprechenden Literatur (hoffentlich bald!!).                     
                                                                
Bei jeder Line_A Routine l��t sich am Quelltext sehen, welche   
Variablen gerade benutzt werden. Allerdings sind unsere Unter-  
lagen (ATARI-Entwicklungspaket) auch nicht besonders aussage-   
f�hig....                                                       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 22 Hexblock 16 
\ Variable                                            bp 12oct86
                                                                
Diese vier Variablen beschreiben das 'Clipping-Window'.  Damit  
 lassen sich alle Ausgaben auf dieses Window beschr�nken.       
Anzahl der Planes f�r F�llmuster                                
Bitmuster f�r Linien ($FFFF = durchgezogen)                     
Mit diesen vier Variablen werden die Farben der Planes fest-    
 gelegt.                                                        
                                                                
                                                                
Hilfsvariable zur Vereinfachung bei Draw. Enth�lt die Endkoordi-
 naten der zuletzt gezeichneten Linie.                          
Schreibmodus: 0=over, 1= trans, 2=exor, 3=invtrans              
Bildschirmaufl�sung: 0=320x200, 1=320x400, 2=640x400            
                                                                
                                                                
\ *** Block No. 23 Hexblock 17 
\ arrays                                               17sep86we
                                                                
Enth�lt die Anzahl - 1 der Worte in Arrays f�r F�llmuster.      
Enth�lt die Adresse des aktuellen F�llmusters.                  
                                                                
Zwei wichtige F�llmuster: Leer                                  
und voll                                                        
                                                                
Flag, ob die Koordinaten �berpr�ft werden sollen (Geschwindigk.)
Flag, ob mit Clipping gearbeitet wird.                          
                                                                
speichert die lange Adresse der Zeichs�tze.                     
speichert die lange Basis-Adresse der Line_A Variablen          
                                                                
                                                                
                                                                
\ *** Block No. 24 Hexblock 18 
\ Initialization                                       17sep86we
                                                                
Wird bei vielen Routinen zu Beginn benutzt.                     
 $A000 �bergibt in A0 a_base, in A1 a_fonts                     
 Schreibmodus                                                   
 und die Farben der Planes �bergeben                            
 Alle diese Werte werden aus den FORTH-Variablen in die ent-    
 sprechenden Line_A Variablen geschrieben.                      
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 25 Hexblock 19 
\ line                                                 17sep86we
                                                                
zeichnet eine Gerade von (x1,y1) nach (x2,y2).                  
 Initialisierung                                                
 Original-Ton ATARI: Set it to -1 and forget it !               
 Die Werte f�r x2,y2 werden auch in cur_x und cur_y gemerkt.    
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 26 Hexblock 1A 
\ rectangle                                            17sep86we
                                                                
zeichnet ein gef�lltes Rechteck mit x1,y1 als oberer linker Ecke
 und width und height als Breite und H�he.                      
 Umrechnung von Breite und H�he in Koordinaten                  
                                                                
                                                                
 Adresse des F�llmusters �bergeben.                             
                                                                
 Anzahl der Worte im F�llmuster                                 
 Anzahl der Planes f�r F�llmuster                               
 Koordinaten des Clipping-Rechtecks                             
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 27 Hexblock 1B 
\ Maus-Functions                                       17sep86we
                                                                
schaltet Maus-Cursor ein                                        
 CONTRL(1) wird gel�scht und CONTRL(3) auf 1 gesetzt (???)      
 INTIN(0) wird gel�scht, sonst wird die Anzahl der hide-Aufrufe 
 ber�cksichtigt (s.a. c-flag beim entsprechenden VDI-Aufruf)    
                                                                
schaltet Maus-Cursor aus.                                       
                                                                
Damit kann eine eigene Mausform entwickelt werden.              
 Adresse enth�lt ein Array mit folgendem Aufbau:                
 Maskenfarbe, Datenfarbe                                        
 16 Worte Maske                                                 
 16 Worte Daten                                                 
                                                                
                                                                
\ *** Block No. 28 Hexblock 1C 
\ copyraster                                          bp 12oct86
                                                                
Die Copyrasterfunktionen verlangen eine sehr komplexe Parameter-
 �bergabe. Diese ist im File VDI.SCR an der entsprechenden      
 Stelle enthalten. Da diese Funktion gegen�ber der VDI-Funktion 
 kaum Geschwindigkeitsvorteile bringt, wurde auf die nochmalige 
 Definition hier verzichtet.                                    
                                                                
Wen's interessiert, m�ge im File VDI.SCR unter Rasterfunctions  
 nachlesen.                                                     
                                                                
So l�dt man den entsprechenden Teil der VDI-Bibliothek !        
 Dieser Teil wird schon vom Editor ben�tigt und ist daher im    
 System normalerweise schon vorhanden.                          
                                                                
                                                                
\ *** Block No. 29 Hexblock 1D 
\ Checking                                             18sep86we
                                                                
Array mit den Grenzen f�r die drei Aufl�sungsstufen.            
                                                                
flag=0 bei 320x200, flag=1 bei 320x400, flag=2 bei 640x400      
                                                                
                                                                
                                                                
�berpr�ft, ob x und y innerhalb des Bildschirms liegen.         
 Ansonsten erfolgt Abbruch. Diese Pr�fung kostet Zeit, erspart  
 aber Systemabst�rze bei falschen Parametern.                   
                                                                
pr�ft x und y, wenn checking eingeschaltet ist.                 
                                                                
                                                                
                                                                
\ *** Block No. 30 Hexblock 1E 
\ relative  set draw clipping                          18sep86we
                                                                
berechnet aus den Offsets dx und dy und den in cur_y und cur_y  
 gespeicherten Werten die neuen Koordinaten x und y.            
                                                                
                                                                
                                                                
setzt cur_x und cur_y                                           
zeichnet eine Linie von (cur_x,cur_y) nach (x,y).               
                                                                
setzt das Clipping-Window und schaltet clipping ein.            
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 31 Hexblock 1F 
\ box                                                  18sep86we
                                                                
zeichnet ein ungef�lltes Rechteck mit der Breite width und H�he 
 height. Die Koordinaten der linken oberen Ecke werden aus      
 cur_x und cur_y entnommen.                                     
 Das ganze besteht aus vier einzelnen Geraden.                  
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 32 Hexblock 20 
\ +sprite -sprite                                      17sep86we
                                                                
zeichnet ein Sprite und speichert den Bildschirm                
sprt_def_blk enth�lt die Sprite-Daten                           
sprt_sav_blk ist die Adresse des Zwischenspeichers f�r den Bild-
 schirm. Es werden pro Plane 64 Byte ben�tigt.                  
(x,y) ist der 'Hotspot' des Sprites.                            
                                                                
l�scht das Sprite und restauriert den Bildschirm.               
                                                                
Der sprt_def_blk hat folgenden Aufbau:                          
 x-offset zum Hotspot, y-offset zum Hotspot                     
 Format-Flag, Hintergrundfarbe, Zeichenfarbe                    
 32 Worte mit Muster:                                           
  Hintergrund 1.Zeile, Vordergrund 1.Zeile                      
  Hintergrund 2.Zeile, Vordergrund 2.Zeile   usw.               
\ *** Block No. 33 Hexblock 21 
\ put_pixel get_pixel                                  17sep86we
                                                                
zeichnet ein Pixel am Punkt (x,y) mit Farbe color.              
                                                                
Man kann definieren:                                            
   : plot   ( x y -- )        1 putpixel ;                      
   : unplot ( x y -- )        0 putpixel ;                      
                                                                
                                                                
color ist die Farbe des Punktes (x,y).                          
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 34 Hexblock 22 
\ polygon                                              17sep86we
                                                                
zeichnet ein n-Eck mit den Eckpunkten (x1,y1) ... (xn,yn).      
                                                                
 Clipping auswerten                                             
 F�llmuster �bergeben                                           
                                                                
 F�llmustermaske                                                
 und Anzahl der Planes �bergeben                                
 Clipping-Window setzen                                         
                                                                
                                                                
                                                                
 Anzahl der Ecken                                               
 Eckpunkte ins ptsin-Array �bernehmen                           
 D3 und D4 enthalten die Koordianten des gr��ten Punktes        
\ *** Block No. 35 Hexblock 23 
\ polygon forts.                                       17sep86we
                                                                
 f�r die F�llfunktion                                           
 Werte �bergeben und D3,D4 ggf updaten.                         
                                                                
                                                                
                                                                
 ersten Punkt wiederholen, vereinfacht die �bergabe             
                                                                
 $A006 so oft aufrufen, bis das n-Eck vollst�ndig gef�llt ist.  
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 36 Hexblock 24 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
