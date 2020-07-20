\ *** Block No. 0 Hexblock 0 
\\                       *** Diverses ***              26oct86we
                                                                
In diesem File haben wir Worte untergebracht, die zwar h�ufig   
 gebraucht werden, aber nicht bestimmten Files zugeordnet werden
 k�nnen.                                                        
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ Loadscreen f�r Diverses                              26oct86we
                                                                
Onlyforth                                                       
                                                                
1 2  +thru                                                      
                                                                
' .blk Is .status                                               
                                                                
                                                                
\ 3 +load   setvec                                              
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ H�ufig benutzte Definitionen                         26oct86we
                                                                
: >absaddr   ( addr -- abs_laddr )       0  forthstart d+ ;     
                                                                
: .blk     ( -- )         blk @   ?dup   0= ?exit               
     dup 1 =  IF  cr file?  THEN   ."  Blk " . ?cr ;            
                                                                
: abort(  ( f -- )                                              
   IF  [compile] .(  true abort"  !"  THEN  [compile] ( ;       
                                                                
\needs arguments   abort( use definition in FILEINT.SCR)        
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 3 Hexblock 3 
\ H�ufig benutzte Definitionen II                      26oct86we
                                                                
| Create: cpull                                                 
      rp@ count  2dup + even rp!  r> swap cmove ;               
                                                                
: cpush  ( addr len --)   r> -rot  over >r                      
      rp@ over 2+ -  even dup rp!  place  cpull >r  >r ;        
                                                                
                                                                
: bell                           7 con! ;                       
: blank    ( addr count -- )     bl fill ;                      
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 4 Hexblock 4 
\ TOS-Alerts abschalten                                16oct86we
                                                                
Create oldvec   4 allot                                         
                                                                
Label newvector                                                 
   -8 D1 cmpi  0<> IF  -&13 D1 cmpi  0<>  IF                    
     .l oldvec pcrel) A2 move   A2 ) jmp   THEN  THEN           
   .l D1 D0 move   rts   end-code                               
                                                                
: setvec    $0.0404 l2@  oldvec 2!                              
            newvector >absaddr   $0.0404 l2! ;                  
                                                                
: restvec   oldvec 2@ $0.0404 l2! ;                             
                                                                
: bye       restvec bye ;                                       
                                                                
\ *** Block No. 5 Hexblock 5 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 6 Hexblock 6 
\ Loadscreen f�r Diverses                              26oct86we
                                                                
setzt Searchorder auf     FORTH FORTH ONLY    FORTH             
                                                                
kompiliert die n�chsten 2 Screens.                              
                                                                
.STATUS ist ein 'deferred word', das jeweils beim Kompilieren   
 eines Quelltextscreens aufgerufen wird.                        
                                                                
Screen 4 wird nicht mitkompiliert, denn SETVEC mu� nach jedem   
 Neustart wieder aufgerufen werden. Falls Sie diese Funktion    
 nutzen wollen, m�ssen Sie nach jedem Laden SETVEC eingeben.    
 (Dazu mu� nat�rlich Screen 4 kompiliert worden sein.)          
                                                                
                                                                
                                                                
\ *** Block No. 7 Hexblock 7 
\ H�ufig benutzte Definitionen                         26oct86we
                                                                
>ABSADDR    rechnet eine - relative- Adresse im FORTH-System in 
            eine absolute 32-Bit-Adresse um.                    
.BLK        gibt die Nummer des gerade kompilierten Screens aus,
            bei Screen 1 auch den Filenamen.                    
                                                                
ABORT(      bewirkt das gleiche wie ABORT", ist aber im Direkt- 
            modus zul�ssig.                                     
                                                                
ARGUMENTS   pr�ft, ob eine bestimmte (Mindest-)Anzahl von Werten
            auf dem Stack liegt. Dieses Wort ist bereits im     
            FORTHKER.PRG vorhanden, da es vom File-Interface    
            gebraucht wird.                                     
                                                                
                                                                
\ *** Block No. 8 Hexblock 8 
\ H�ufig benutzte Definitionen II                      26oct86we
                                                                
CPUSH       sorgt im Zusammenspiel mit CPULL daf�r, da� ein     
            String (bzw. ein beliebiger Speicherbereich, z.B.   
            ein Array) nach dem Aufruf einer Funktion wieder    
            die alten Werte erh�lt. Entspricht dem Wort PUSH,   
            aber f�r Strings anstelle von Variablen.            
                                                                
                                                                
BELL        Dieses Wort ist selbsterkl�rend !!!                 
BLANK       f�llt ab addr count Speicherstellen mit Leerzeichen.
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 9 Hexblock 9 
\ TOS-Alerts abschalten                                26oct86we
                                                                
Vielleicht haben Sie es schon einmal bemerkt. Wenn Sie auf eine 
 Diskette schreiben wollen, bei der der Schreibschutz gesetzt   
 ist, erscheint eine Alert-Box, aber ohne Maus, soda� Sie den   
 ABBRUCH-Knopf nur durch geduldiges Experimentieren mit der Maus
 erreichen k�nnen. Diese Box wird vom Betriebssystem ohne unser 
 Zutun und ohne Einwirkungsm�glichkeit erzeugt.                 
NEWVECTOR �ndert den zugeh�rigen Vector (critical error handler)
 so, da� diese Boxen nicht mehr erscheinen, wohl aber die, in   
 denen z.B. zum Diskettenwechsel aufgefordert wird.             
SETVEC und RESTVEC dienen zum Umschalten zwischen altem und     
 neuen Vector.                                                  
Insbesondere mu� BYE den alten Vector wiederherstellen, sonst   
 st�rzt das System gnadenlos ab.                                
Noch keine besonders elegante L�sung, aber besser als keine !!  
