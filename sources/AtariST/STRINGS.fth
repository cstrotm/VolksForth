\ *** Block No. 0 Hexblock 0 
\\                      *** Strings ***                13oct86we
                                                                
Dieses File enth�lt einige Grundworte zur Stringverarbeitung,   
vor allem ein  SEARCH  f�r den Editor. Ebenfalls sind Worte     
zur Umwandlung von counted Strings (Forth) in 0-terminated      
Strings, wie sie z.B. vom Betriebssystem oft benutzt werden,    
vorhanden.                                                      
                                                                
Beim SEARCH entscheidet die Variable  CAPS  , ob Gro�- und      
Kleinschreibung unterschieden wird oder nicht. Ist  CAPS  ON,   
so werden gro�e und kleine Buchstaben gefunden, die Suche dau-  
ert allerdings l�nger.                                          
                                                                
c>0"  wandelt einen String mit f�hrendem Countbyte in einen     
mit 0 abgschlossenen, wie er vom Betriebssystem oft gebraucht   
wird. 0>c" arbeitet umgekehrt.                                  
\ *** Block No. 1 Hexblock 1 
\ String Functions Loadscreen                          25may86we
                                                                
1 4 +thru                                                       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ -text                                                13oct86we
                                                                
Variable caps   caps off                                        
                                                                
Code -text   ( addr0 len addr1 -- n )                           
   SP )+ D6 move  D6 reg) A1 lea                                
   SP )+ D0 move  0= IF  SP ) clr  Next  THEN  1 D0 subq        
   SP )+ D6 move  D6 reg) A0 lea                                
Label comp                                                      
   .b A0 )+ A1 )+ cmpm  comp  D0 dbne                           
   .w D0 clr  .b A0 -) D0 move  A1 -) D0 sub   .w D0 ext        
      D0 SP -) move   Next end-code                             
                                                                
Label >upper   ( D3 -> D3 )     .b Ascii a D3 cmpi              
   >= IF  Ascii z D3 cmpi  <= IF  bl D3 subi  THEN  THEN  rts   
                                                                
\ *** Block No. 3 Hexblock 3 
\ -capstext compare                                    13oct86we
                                                                
| Code -capstext   ( addr0 len addr1 -- n )                     
   SP )+ D6 move  D6 reg) A1 lea                                
   SP )+ D0 move  0= IF  SP ) clr  Next  THEN  1 D0 subq        
   SP )+ D6 move  D6 reg) A0 lea                                
Label capscomp                                                  
   .b A0 )+ D3 move  >upper bsr  D3 D1 move                     
      A1 )+ D3 move  >upper bsr  D3 D2 move                     
     D1 D2 cmp  capscomp D0 dbne   .w D1 clr                    
   .b A0 -) D3 move  >upper bsr  D3 D1 move                     
      A1 -) D3 move  >upper bsr  D3 D2 move                     
   .b D2 D1 sub  .w D1 SP -) move   Next end-code               
                                                                
: compare   ( addr0 len addr1 -- n )                            
   caps @ IF  -capstext  ELSE  -text  THEN ;                    
\ *** Block No. 4 Hexblock 4 
\ search delete insert                                 10aug86we
                                                                
: search   ( text textlen buf buflen  -- offset flag )          
   over >r  2 pick -  3 pick c@ >r                              
   BEGIN  caps @  0= IF  r@ scan  THEN  ?dup                    
   WHILE  >r >r  2dup r@  compare                               
          0= IF  2drop r> rdrop rdrop r> -  true exit  THEN     
   r> r>  1 /string   REPEAT   -rot 2drop  rdrop  r> - false ;  
                                                                
: delete   ( buffer size count -- )                             
   over min >r  r@ - ( left over )  dup 0>                      
   IF  2dup swap dup  r@ +  -rot  swap  cmove  THEN             
  + r> bl fill ;                                                
                                                                
: insert   ( string length buffer size -- )                     
   rot over min >r  r@ - over dup r@ +  rot cmove>  r> cmove ;  
\ *** Block No. 5 Hexblock 5 
\ String operators                                     13oct86we
                                                                
Variable $sum                   \ pointer to stringsum          
: $add      ( addr len -- )     dup >r                          
   $sum @ count +  swap  move   $sum @  dup c@  r> +  swap c! ; 
                                                                
: c>0"   ( addr -- )                                            
   count >r  dup 1-  under  r@ cmove   r> + 0 swap c!  ;        
: 0>c"   ( addr -- )                                            
   dup >r  true false scan nip negate 1-                        
   r@ dup 1+ 2 pick cmove>  r> c!  ;                            
                                                                
: ,0"   Ascii " parse 1+  here over allot  place                
        0 c,  align ; restrict                                  
: 0"    state @ IF compile (" ,0" compile 1+ exit THEN          
                   here 1+  ,0" ;        immediate              
\ *** Block No. 6 Hexblock 6 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 7 Hexblock 7 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 8 Hexblock 8 
\ -text                                                13oct86we
                                                                
ist CAPS on, wird beim Suchen nicht auf Gro�- Kleinschreibung   
 geachtet.                                                      
addr0 und addr1 sind die Adressen von zwei counted strings, len 
 die Anzahl der Zeichen, die verglichen werden sollen. n liefert
 die Differenz der beiden ersten nicht �bereinstimmenden Zeichen
 Ist n=0, sind beide Strings gleich.                            
                                                                
                                                                
                                                                
                                                                
                                                                
wandelt das Zeichen im Register D3 in den entsprechenden Gro�-  
 buchstaben.                                                    
                                                                
\ *** Block No. 9 Hexblock 9 
\ -capstext compare                                    13oct86we
                                                                
wie -text, jedoch wird beim Vergleich nicht nach Gro�- und Klein
 schreibung unterschieden. Dieser Vergleich erfordert erheblich 
 mehr Zeit und sollte daher nur in Sonderf�llen benutzt werden. 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
wie -text, in Abh�ngigkeit von der Variablen caps wird -text    
 oder -capstext ausgef�hrt.                                     
\ *** Block No. 10 Hexblock A 
\ search delete insert                                 13oct86we
                                                                
Im Text ab Adresse text wird in der L�nge textlen  nach dem     
 String buf mit L�nge buflen gesucht.                           
 Zur�ckgeliefert wird ein Offset in den durchsuchten Text an die
 Stelle, an der der String gefunden wurde sowie ein Flag. Ist   
 flag wahr, wurde der String gefunden, sonst nicht.             
 search ber�cksichtigt die Variable caps bei der Suche.         
                                                                
Im Buffer der L�nge size werden count Zeichen entfernt. Der Rest
 des Buffers wird 'heruntergezogen'.                            
                                                                
                                                                
                                                                
Der string ab Adresse string und der L�nge length wird in den   
 Buffer mit der Gr��e size eingef�gt.                           
\ *** Block No. 11 Hexblock B 
\ String operators                                     13oct86we
                                                                
Ein pointer auf die Adresse des Strings, zu dem ein anderer     
 hinzugef�gt werden soll.                                       
$ADD h�ngt den String ab addr und der L�nge len an den String   
 in $sum an. Der Count wird dabei addiert.                      
wandelt den counted String ab addr in einen 0-terminated String.
                                                                
wandelt den 0-terminated String ab addr in einen counted String.
 Die L�nge der Strings bleibt gleich (Countbyte statt 0).       
                                                                
                                                                
legt einen counted und mit 0 abgeschlossenen String im          
  Dictionary ab.                                                
aufrufendes Wort f�r ,0"; kompiliert zus�tzlich (".             
 0" ist statesmart.                                             
