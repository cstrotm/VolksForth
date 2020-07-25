\ *** Block No. 0 Hexblock 0 
\\                 *** Printer-Interface ***           10oct86we
                                                                
Dieses File enth�lt das Printer-Interface. Die Definitionen f�r 
die Druckersteuerung m�ssen ggf. an Ihren Drucker angepa�t wer- 
den.                                                            
                                                                
PRINT  lenkt alle Ausgabeworte auf den Drucker um, mit  DISPLAY 
wird wieder auf dem Bildschirm ausgegeben.                      
                                                                
Zum Ausdrucken der Quelltexte gibt es die Worte                 
                                                                
   pthru      ( from to -- )   druckt Screen from bis to        
   document   ( from to -- )  wie pthru, aber mit Shadow-Screens
   printall   ( -- )   wie pthru, aber druckt das ganze File    
   listing    ( -- )   wie document, aber f�r das ganze File    
                                                                
\ *** Block No. 1 Hexblock 1 
\ Printer Interface Epson RX80\FX80                    21oct86we
                                                                
Onlyforth                                                       
                                                                
\needs file?            ' noop  | Alias file?                   
\needs capacity         ' blk/drv Alias capacity                
                                                                
Vocabulary Printer   Printer definitions also                   
                                                                
 1 &13 +thru                                                    
                                                                
Onlyforth  \ clear                                              
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ Printer  p! and controls                             18nov86we
                                                                
' bcostat | Alias ready?   ' 0 | Alias printer                  
                                                                
: p!  ( n -- )                                                  
   BEGIN  pause  printer ready?  UNTIL  printer bconout ;       
                                                                
                                                                
| : ctrl:  ( 8b -- )   Create c,   does>  ( -- )   c@ p! ;      
                                                                
 07   ctrl: BEL      $7F | ctrl: DEL       $0D | ctrl: RET      
$1B | ctrl: ESC      $0A   ctrl: LF        $0C   ctrl: FF       
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 3 Hexblock 3 
\ Printer controls                                     09sep86re
                                                                
| : esc:  ( 8b -- )   Create c,   does>  ( -- )   ESC c@ p! ;   
                                                                
| : esc2  ( 8b0 8b1 -- )   ESC p! p! ;                          
                                                                
| : on:  ( 8b -- )  Create c,  does>  ( -- )  ESC c@ p!  1 p! ; 
                                                                
| : off: ( 8b -- )  Create c,  does>  ( -- )  ESC c@ p!  0 p! ; 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 4 Hexblock 4 
\ Printer Escapes Epson RX-80/FX-80                    12sep86re
                                                                
$0F | ctrl: (+17cpi             $12 | ctrl: (-17cpi             
                                                                
Ascii P | esc: (+10cpi          Ascii M | esc: (+12cpi          
Ascii 0   esc: 1/8"             Ascii 1   esc: 1/10"            
Ascii 2   esc: 1/6"             Ascii T   esc: suoff            
Ascii N   esc: +jump            Ascii O   esc: -jump            
Ascii G   esc: +dark            Ascii H   esc: -dark            
\ Ascii 4   esc: +cursive         Ascii 5   esc: -cursive       
                                                                
Ascii W   on:  +wide            Ascii W   off: -wide            
Ascii -   on:  +under           Ascii -   off: -under           
Ascii S   on:  sub              Ascii S   off: super            
                                                                
                                                                
\ *** Block No. 5 Hexblock 5 
\ Printer Escapes Epson RX-80/FX-80                    12sep86re
                                                                
: 10cpi   (-17cpi (+10cpi ;     ' 10cpi   Alias pica            
: 12cpi   (-17cpi (+12cpi ;     ' 12cpi   Alias elite           
: 17cpi   (+10cpi (+17cpi ;     ' 17cpi   Alias small           
                                                                
: lines  ( #.of.lines -- )   Ascii C esc2 ;                     
                                                                
: "long  ( inches -- )   0 lines p! ;                           
                                                                
: american   0 Ascii R esc2 ;                                   
                                                                
: german     2 Ascii R esc2 ;                                   
                                                                
: normal     10cpi  american  suoff  1/6"  &12 "long  RET ;     
                                                                
\ *** Block No. 6 Hexblock 6 
\ Umlaute                                              14oct86we
                                                                
| Create DIN                                                    
Ascii � c,      Ascii � c,      Ascii � c,      Ascii � c,      
Ascii � c,      Ascii � c,      Ascii � c,      Ascii � c,      
                                                                
| Create AMI                                                    
Ascii { c,      Ascii | c,      Ascii } c,      Ascii ~ c,      
Ascii [ c,      Ascii \ c,      Ascii ] c,      Ascii @ c,      
                                                                
here AMI - | Constant tablen                                    
                                                                
| : p!  ( char -- )   dup $80 < IF  p! exit  THEN               
   tablen 0 DO  dup  I DIN + c@  =                              
                IF  drop  I AMI + c@  LEAVE  THEN  LOOP         
   german p! american ;                                         
\ *** Block No. 7 Hexblock 7 
\ Printer Output                                       12sep86re
                                                                
| Variable pcol   pcol off      | Variable prow   prow off      
                                                                
| : pemit  ( 8b -- )    p!  1 pcol +! ;                         
| : pcr  ( -- )         RET LF  1 prow +!  pcol off ;           
| : pdel  ( -- )        DEL  pcol @ 1- 0 max pcol ! ;           
| : ppage  ( -- )       FF  prow off  pcol off ;                
| : pat  ( row col -- )   over  prow @ <  IF  ppage  THEN       
     swap  prow @ -  0 ?DO  pcr  LOOP                           
     dup  pcol @ <  IF  RET  pcol off  THEN  pcol @ - spaces ;  
| : pat?  ( -- row col )   prow @  pcol @ ;                     
| : ptype  ( adr len -- )                                       
     dup pcol +!  bounds ?DO  I c@ p!  LOOP ;                   
                                                                
                                                                
\ *** Block No. 8 Hexblock 8 
\ Printer output                                       18nov86we
                                                                
Output: >printer   pemit pcr ptype pdel ppage pat pat? ;        
                                                                
Forth definitions                                               
                                                                
: print   >printer  normal ;                                    
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 9 Hexblock 9 
\ Variables and Setup                                 bp 12oct86
                                                                
Printer definitions                                             
                                                                
' 0 | Alias logo                                                
                                                                
| : header  ( pageno -- )                                       
     12cpi  +dark  ."   volksFORTH-83    FORTH-Gesellschaft eV "
     -dark  17cpi  ." (c) 1985/86 we/bp/re/ks  "  12cpi +dark   
     file?  -dark  17cpi ."  Seite "  . ;                       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 10 Hexblock A 
\ Print 2 screens across on a page                     26oct86we
                                                                
| : 2lines  ( scr#1 scr#2 line# -- )                            
     cr  dup 2 .r space  c/l * >r                               
     pad  c/l 2* 1+  bl fill  swap                              
     block  r@ +  pad           c/l cmove                       
     block  r> +  pad c/l + 1+  c/l cmove                       
     pad  c/l 2* 1+  -trailing  type ;                          
                                                                
| : 2screens  ( scr#1 scr#2 -- )                                
     cr cr  &30 spaces                                          
     +wide +dark over 4 .r  &28 spaces  dup 4 .r  -wide -dark   
     cr  l/s 0 DO  2dup  I 2lines  LOOP  2drop ;                
                                                                
                                                                
                                                                
\ *** Block No. 11 Hexblock B 
\ print 6 screens on a page                            18sep86we
                                                                
| : pageprint  ( last+1 first pageno -- )                       
     header  2dup - 1+  2/  dup 0                               
     ?DO  >r  2dup under r@ + >                                 
          IF  dup r@ +  ELSE  logo  THEN  2screens 1+ r>  LOOP  
     drop 2drop  page ;                                         
                                                                
| : >shadow   ( n1 -- n2 )                                      
     capacity 2/  2dup < IF + ELSE - THEN ;                     
                                                                
| : shadowprint  ( last+1 first pageno -- )                     
     header  2dup -  0                                          
     ?DO  dup dup >shadow  2screens  1+  LOOP                   
     2drop page ;                                               
                                                                
\ *** Block No. 12 Hexblock C 
\ Printing without Shadows                            b11nov86we
                                                                
Forth definitions  also                                         
                                                                
| Variable printersem    0 printersem !    \ for multitasking   
                                                                
: pthru  ( first last -- )      2 arguments                     
   printersem lock   output push  print                         
   1+  capacity umin  swap  2dup -  6 /mod  swap 0<> -  0       
   ?DO  2dup 6 + min  over  I 1+  pageprint  6 +  LOOP          
   2drop  printersem unlock ;                                   
                                                                
: printall  ( -- )   0 capacity 1- pthru ;                      
                                                                
                                                                
                                                                
\ *** Block No. 13 Hexblock D 
\ Printing with Shadows                               bp 12oct86
                                                                
: document  ( first last -- )                                   
   printersem lock   output push   print                        
   1+  capacity 2/ umin  swap  2dup -  3 /mod  swap 0<> -  0    
   ?DO  2dup 3+ min  over  I 1+  shadowprint  3+  LOOP          
   2drop   printersem unlock ;                                  
                                                                
: listing  ( -- )   0 capacity 2/ 1- document ;                 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 14 Hexblock E 
\ Printerspool                                         14oct86we
                                                                
\needs Task        \\                                           
                                                                
$100 $200 Task spooler                                          
                                                                
: spool'   ( -- )    \ reads word                               
   '  isfile@  offset @  base @   spooler  depth 1-  6 min  pass
   base !  offset !  isfile !  execute                          
   true abort" SPOOL' ready for next job!" stop ;               
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 15 Hexblock F 
\\                 *** Printer-Interface ***           13oct86we
                                                                
Eingestellt ist das Druckerinterface auf Epson und kompatible   
 Drucker. Die Steuersequenzen auf den Screens 2, 4 und 5 m�ssen 
 gegebenenfalls auf Ihren Drucker angepa�t werden. Bei uns gab  
 es mit verschiedenen Druckern allerdings keine Probleme, da    
 sich inzwischen die meisten Druckerhersteller an die Epson-    
 Steuercodes halten.                                            
                                                                
Arbeiten Sie mit einem IBM-kompatiblen Drucker, mu� die Umlaut- 
 wandlung auf Screen 6 wegkommentiert werden.                   
                                                                
Zus�tzliche 'exotische' Steuersequenzen k�nnen nach dem Muster  
 auf den Screens 4 und 5 jederzeit eingebaut werden.            
                                                                
                                                                
\ *** Block No. 16 Hexblock 10 
\ Printer Interface Epson RX80                         13oct86we
                                                                
setzt order auf  FORTH FORTH ONLY   FORTH                       
                                                                
falls das Fileinterface nicht im System ist, werden die ent-    
 sprechenden Worte ersetzt.                                     
                                                                
Printer-Worte erhalten ein eigenes Vocabulary.                  
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 17 Hexblock 11 
\ Printer  p! and controls                             10oct86we
                                                                
nur aus stilistischen Gr�nden. Das Folgende liest sich besser.  
                                                                
Hauptausgabewort; gibt ein Zeichen auf den Drucker aus. Es wird 
 gewartet, bis der Drucker bereit ist. (PAUSE f�r Multitasking) 
                                                                
                                                                
gibt Steuerzeichen an Drucker                                   
                                                                
Steuerzeichen f�r Drucker. Gegebenenfalls anpassen!             
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 18 Hexblock 12 
\ Printer controls                                     10oct86we
                                                                
gibt Escape-Sequenzen an den Drucker aus.                       
                                                                
gibt Escape und zwei Zeichen aus.                               
                                                                
gibt Escape, ein Zeichen und eine 1 an den Drucker aus.         
                                                                
gibt Escape, ein Zeichen und eine 0 an den Drucker aus.         
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 19 Hexblock 13 
\ Printer Escapes Epson RX-80/FX-80                    10oct86we
                                                                
setzt bzw. l�scht Ausgabe komprimierter Schrift.                
                                                                
setzt Zeichenbreite auf 10 bzw. 12 cpi.                         
Zeilenabstand in Zoll.                                          
                                schaltet Super- und Subscript ab
Perforation �berspringen ein- und ausschalten.                  
Es folgen die Steuercodes f�r Fettdruck, Kursivschrift, Breit-  
 schrift, Unterstreichen, Subscript und Superscript.            
 Diese m�ssen ggf. an Ihren Drucker angepa�t werden.            
 Selbstverst�ndlich k�nnen auch weitere F�higkeiten Ihres Druk- 
 kers genutzt werden wie Proportionalschrift, NLQ etc.          
                                                                
                                                                
                                                                
\ *** Block No. 20 Hexblock 14 
\ Printer Escapes Epson RX-80/FX-80                    13oct86we
                                                                
Hier wird die Zeichenbreite eingestellt. Dazu kann man sowohl   
 Worte mit der Anzahl der characters per inch (cpi) als auch    
 pica, elite und small benutzen.                                
                                                                
setzt Anzahl der Zeilen pro Seite; Einstellung:                 
 &66 lines      oder     &12 "long                              
                                                                
                                                                
schaltet auf amerikanischen Zeichensatz.                        
                                                                
schaltet auf deutschen Zeichensatz.                             
                                                                
Voreinstellung des Druckers auf 'normale' Werte; wird beim      
 Einschalten mit PRINT ausgef�hrt.                              
\ *** Block No. 21 Hexblock 15 
\ Umlaute                                             bp 12oct86
                                                                
Auf diesem Screen werden die Umlaute aus dem IBM-(ATARI)-Zeichen
 satz in DIN-Umlaute aus dem deutschen Zeichensatz gewandelt.   
                                                                
Wenn Sie einen IBM-kompatiblen Drucker benutzen, kann dieser    
 Screen mit \\ in der ersten Zeile wegkommentiert werden.       
                                                                
                                                                
                                                                
                                                                
                                                                
p! wird neu definiert. Daher brauchen die folgenden Worte p!    
 nicht zu �ndern, egal, ob mit oder ohne Umlautwandlung gearbei-
 tet wird.                                                      
                                                                
\ *** Block No. 22 Hexblock 16 
\ Printer Output                                       10oct86we
                                                                
aktuelle Druckerzeile und -spalte.                              
Routinen zur Druckerausgabe     entspricht Befehl               
ein Zeichen auf Drucker         emit                            
CR und LF auf Drucker           cr                              
ein Zeichen l�schen (?!)        del                             
neue Seite                      page                            
Drucker auf Zeile und Spalte    at                              
 positionieren; wenn n�tig,                                     
 neue Seite.                                                    
Position feststellen            at?                             
Zeichenkette ausgeben           type                            
                                                                
Damit sind die Worte f�r eine eigene Output-Struktur vorhanden. 
                                                                
\ *** Block No. 23 Hexblock 17 
\ Printer output                                       10oct86we
                                                                
erzeugt die Output-Tabelle >printer.                            
                                                                
Die folgenden Worte sind von FORTH aus zug�nglich.              
                                                                
schaltet Ausgabe auf Printer um. (Zur�ckschalten mit DISPLAY)   
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 24 Hexblock 18 
\ Variables and Setup                                  10oct86we
                                                                
Diese Worte sind nur im Printer-Vokabular enthalten.            
                                                                
Dieser Screen wird gedruckt, wenn es nichts besseres gibt.      
                                                                
Druckt die �berschrift der Seite pageno.                        
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 25 Hexblock 19 
\ Print 2 screens across on a page                     10oct86we
                                                                
druckt nebeneinander die Zeilen line# der beiden Screens.       
 Die komplette Druck-Zeile wird erst in PAD aufbereitet.        
                                                                
                                                                
                                                                
                                                                
                                                                
formatierte Ausgabe der beiden Screens nebeneinander            
 mit fettgedruckten Screennummern. Druck erfolgt mit 17cpi, also
 in komprimierter Schrift.                                      
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 26 Hexblock 1A 
\ print 6 screens on a page                            10oct86we
                                                                
gibt eine Seite aus. Anordnung der Screens auf der Seite:  1 4  
 Wenn weniger als 6 Screens vorhanden sind, werden         2 5  
 L�cken auf der rechten Seite mit dem Logo-Screen (0)      3 6  
 aufgef�llt.                                                    
                                                                
                                                                
berechnet zu Screen n1 den Shadowscreen n2 (Kommentarscreen wie 
 dieser hier).                                                  
                                                                
wie pageprint, aber anstelle der Screens 4, 5 und 6 werden die  
 Shadowscreens zu 1, 2 und 3 gedruckt.                          
                                                                
                                                                
                                                                
\ *** Block No. 27 Hexblock 1B 
\ Printing without Shadows                            b22oct86we
                                                                
Die folgenden Definitionen stellen das Benutzer-Interface dar.  
 Daher sollen sie in FORTH gefunden werden.                     
                                                                
PRINTERSEM ist ein Semaphor f�r das Multitasking, der den Zugang
 auf den Drucker f�r die einzelnen Tasks regelt.                
                                                                
PTHRU gibt die Screens von  from  bis  to  aus.                 
 Ausgabeger�t merken und Drucker einschalten. Multitasking wird,
 sofern es den Drucker betrifft, gesperrt.                      
 Die Screens werden mit pageprint ausgegeben.                   
                                                                
                                                                
wie oben, jedoch wird das komplette File gedruckt.              
                                                                
\ *** Block No. 28 Hexblock 1C 
\ Printing with Shadows                                10oct86we
                                                                
wie pthru, aber mit Shadowscreens.                              
                                                                
                                                                
                                                                
                                                                
                                                                
wie printall, aber mit Shadowscreens.                           
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 29 Hexblock 1D 
\ Printerspool                                         10oct86we
                                                                
Falls der Multitasker nicht vorhanden ist, wird abgebrochen.    
                                                                
Der Arbeitsbereich der Task wird erzeugt.                       
                                                                
Mit diesem Wort wird das Drucken im Hintergrund gestartet.      
Aufruf mit :                                                    
  spool' listing                                                
  spool' printall                                               
  from to spool' pthru                                          
  from to spool' document                                       
Vor (oder auch nach) dem Aufruf von spool' mu� der Multitasker  
 mit multitask eingeschaltet werden.                            
                                                                
                                                                
