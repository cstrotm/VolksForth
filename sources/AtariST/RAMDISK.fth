\ *** Block No. 0 Hexblock 0 
    HOW TO USE THE RAMDISK                            bp 17Aug86
                                                                
Die Ramdisk ist im Prinzip ein erweiterter Buffermechanismus,   
der Buffer au�erhalb des Forth-Systems verwaltet. Die Organi-   
sation ist analog, mit der Ausnahme, da� es kein Updateflag     
gibt, ge�nderte Bl�cke also sofort auf die Diskette zur�ckge-   
schrieben werden. Die Benutzung ist v�llig transparent, am      
Anfang mu� nur einmal INITRAMDISK aufgerufen werden.            
                                                                
Die Struktur der Buffer wird auf Screen 3 dargestellt.          
                                                                
Die Ramdisk allokiert ihren Speicher mit MALLOC.                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ loadscreen for more buffers                         bp 17Aug86
                                                                
\needs 2over                    include double.scr              
                                                                
Onlyforth                                                       
                                                                
\needs 4dup                     : 4dup    2over 2over ;         
\needs 4drop                    : 4drop   2drop 2drop ;         
\needs user'                    : user'   ' >body c@ ;          
\needs d>                       : d>      2swap d< ;            
                                                                
2 $B +thru                                                      
                                                                
  1 +load    \ patch ramdisk into system                        
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ patch ramdisk into System                           bp 17Aug86
                                                                
| : ((close  ( fcb -- fcb ...)   \ word for patch (CLOSE !!     
    dup flushramfile  [ Dos ' (close    >body @ , ]  ;          
                                                                
| : (empty-buffers   ( -- ...)   \ word for patching EMPTY-BUFFE
    emptyramdisk      [ ' empty-buffers >body @ , ]  ;          
                                                                
                                                                
' ramdiskr/w is r/w                                             
' ((close          Dos ' (close     >body !                     
' (empty-buffers   ' empty-buffers  >body !                     
                                                                
save                                                            
initramdisk                                                     
                                                                
\ *** Block No. 3 Hexblock 3 
\ Variables and Constants                             bp 10Aug86
                                                                
2Variable ramprev     0. ramprev 2!   \ points to first buffer  
2Variable ramfirst    0. ramfirst 2!  \ start of buffer area    
2Variable ramsize     0. ramsize 2!   \ length of buffer area   
                                                                
$408 Constant b/rambuf                                          
                                                                
| Code link>file   ( d1 -- d2 )   .l 4 SP ) addq                
                                  Label >next  Next  end-code   
| Code link>block       .l 6 SP ) addq  >next bra  end-code     
| Code link>data        .l 8 SP ) addq  >next bra  end-code     
                           \\                                   
structure of a buffer:                                          
| link to next buffer | file | block | data .... |              
+0                    +4     +6       +8           +1032        
\ *** Block No. 4 Hexblock 4 
\ search for a buffer                                 bp 24Aug86
\ D0:blk   D1:file   A0:bufadr  A1:Vorgaenger                   
Label thisbuffer?                                               
   4 A0 D) D1 cmp   0= IF  6 A0 D) D0 cmp   THEN  rts           
                                                                
Code rambuf?  ( blk file -- dadr tf \ blk file )                
   2 SP D) D0 move   SP ) D1 move                               
   .l ramprev r#) A0 move .w  thisbuffer? bsr                   
   0= IF   Label blockfound  .l 8. # A0 adda  A0 SP ) move .w   
                true # SP -) move  Next  THEN                   
   BEGIN  .l A0 A1 move   A1 ) A0 move   0. # A0 cmpa   .w      
          0= IF   false # SP -) move  Next   THEN               
          thisbuffer? bsr   0= UNTIL                            
   .l A0 ) A1 ) move                                            
      ramprev r#) A0 ) move   A0 ramprev r#) move  .w           
   blockfound bra   end-code                                    
\ *** Block No. 5 Hexblock 5 
\ read and write buffers                              b28sep86we
                                                                
| : readrambuf    ( adr daddr -- )   \ copy from daddr to adr   
     rot >absaddr  b/blk  lcmove ;                              
                                                                
| : writerambuf   ( adr daddr --)    \ copy from adr to daddr   
     rot >absaddr 2swap b/blk lcmove ;                          
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 6 Hexblock 6 
\ search for empty buffer                             bp 10Aug86
                                                                
\ : takerambuf    ( -- daddr )       \ get last buffer          
\    ramprev  2@                                                
\    BEGIN  2dup link>file l@  1+   ( empty buffer ? )          
\    WHILE  2dup l2@ or             ( last buffer ? )           
\    WHILE  l2@   REPEAT ;                                      
                                                                
| Code takerambuf  ( -- daddr )                                 
     .l  ramprev r#) A0 move                                    
  Label takeloop    .w -1  4 A0 D) cmpi                         
       0<> IF  .l A0 ) tst 0<>                                  
              IF   A0 ) A0 move  takeloop bra  THEN THEN        
  A0 SP -) move  Next  end-code                                 
                                                                
                                                                
\ *** Block No. 7 Hexblock 7 
\ allocate a buffer                                   bp 24Aug86
                                                                
| 2Variable (daddr                                              
                                                                
\ | : markrambuf    ( blk file daddr  -- daddr )                
\     2dup (daddr 2!  link>file l!  (daddr 2@ link>block l!     
\     (daddr 2@ ;                                               
                                                                
| Code markrambuf   ( blk file daddr  -- daddr )  .l            
   SP )+ A0 move        .w  SP )+ 4 A0 D) move                  
   SP )+ 6 A0 D) move   .l A0 SP -) move        Next  end-code  
                                                                
| : makerambuf    ( adr blk file -- )  \ create a buffer        
    BEGIN  rambuf? 0= WHILE 2dup  takerambuf markrambuf         
                            2drop  REPEAT       writerambuf ;   
                                                                
\ *** Block No. 8 Hexblock 8 
\ clear buffers                                       bp 10Aug86
                                                                
: clearrambuf   ( laddr -- )    \ clear a buffer                
   link>file  -1 -rot  l! ;                                     
                                                                
: flushramfile  ( fcb -- )      \ clear all buffers of a file   
   >r  ramprev 2@                                               
   BEGIN  2dup or                                               
   WHILE  2dup link>file l@  r@ =  IF  2dup clearrambuf  THEN   
              l2@  REPEAT  2drop rdrop ;                        
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 9 Hexblock 9 
\ allocate all buffers                                bp 10Aug86
                                                                
| : nextbuf       ( d1 -- d2)     \ adr of next buffer          
    b/rambuf extend d+ ;                                        
                                                                
| : ramfull?      ( daddr -- f)   \ true if more buffers        
    nextbuf  ramsize 2@  ramfirst 2@ d+  d> 0= ;                
                                                                
: emptyramdisk  ( -- )          \ initialize ramdisk            
  0. ramprev 2!   ramfirst 2@                                   
  BEGIN   2dup ramfull?                                         
  WHILE   2dup  clearrambuf         ( clear buffer )            
          ramprev 2@  2over  l2!    ( chain to list )           
          2dup ramprev 2!           ( store last buffer )       
          nextbuf  REPEAT  2drop ;                              
                                                                
\ *** Block No. 10 Hexblock A 
\ Interactive memory allocation                       bp 17Aug86
                                                                
: #in           ( -- n)  query name number drop ;               
                                                                
: initramdisk   ( -- )                                          
   [ Dos ]  0. ramprev 2!                                       
   ramfirst 2@ or  IF  ramfirst 2@ mfree                        
                       drop ?diskabort   0. ramfirst 2!  THEN   
   cr  ."  Wie viele Kilos sollen es sein ? "   #in             
   b/rambuf um*  2. d+  2dup malloc     ( 2 Angstbytes zus.)    
     dup 0< IF drop ?diskabort THEN     ( Fehler !)             
     dup 0= abort" Speicher voll !!"    ( DR sei Dank gesagt !) 
   ramfirst 2!  ramsize 2!                                      
   emptyramdisk ;                                               
                                                                
                                                                
\ *** Block No. 11 Hexblock B 
\ new r/w                                             bp 10Aug86
                                                                
' r/w >body @ Alias oldr/w                                      
                                                                
: ramdiskr/w    ( adr blk file rw/f -- f )                      
   ramprev 2@ or 0=  IF  oldr/w exit  THEN                      
   dup >r                                                       
   IF rambuf?  IF  readrambuf  rdrop false  exit  THEN THEN     
   r>   4dup oldr/w                                             
   IF  4drop  true exit  THEN   \ disk error !                  
   drop makerambuf false ;      \ create or overwrite buffer    
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 12 Hexblock C 
\ print a list of ram buffers                         bp 10Aug86
                                                                
: .rambufs       ( -- )                                         
   ramprev 2@                                                   
   BEGIN   2dup or                                              
   WHILE   cr  2dup  8 d.r  5 spaces    \ adress                
           2dup link>file l@                                    
           dup 1+ IF  [ Dos ] .file  4 spaces                   
                      2dup link>block l@ 5 .r                   
                  ELSE  drop ." empty" THEN                     
           l2@  stop? UNTIL  2drop ;                            
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 13 Hexblock D 
\ Wichtige Worte sind                                 bp 17Aug86
                                                                
INITRAMDISK   ( -- ) fragt nach der Zahl der Anzahl der         
   anzulegenden Buffer und erzeugt sie.                         
                                                                
EMPTYRAMDISK  ( -- ) l�scht den Inhalt aller Buffer.            
                                                                
RAMBUF?       ( blk file -- dadr tf \ blk file ff )             
   sucht den Buffer blk im File file in der Ramdisk.            
                                                                
CLEARRAMBUF?  ( laddr -- )                                      
   markiert den Ramdiskbuffer bei Adr. laddr als leer.          
                                                                
                                                                
..                                                              
                                                                
\ *** Block No. 14 Hexblock E 
                                                      bp 17Aug86
                                                                
                                                                
                                                                
                                                                
                                                                
Wird in RAMDISKR\W benutzt                                      
                                                                
Gibt Offset einer Uservariablen in der Userarea. Dieses         
  Wort geh�rt eigentlich in den Assembler !                     
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 15 Hexblock F 
                                                      bp 17Aug86
                                                                
Dieses Wort wird in (CLOSE gepatched. FCB ist die Adresse des   
  zu schlie�enden Files. Alle Blockpuffer dieses Files werden   
  gel�scht.                                                     
Dieses Wort wird in EMPTY-BUFFERS gepatched. Es l�scht alle     
  Ramdiskpuffer                                                 
                                                                
                                                                
Neues R/W                                                       
Patche (CLOSE                                                   
Patche EMPTY-BUFFERS                                            
                                                                
                                                                
Frage nach der Gr��e der Ramdisk                                
                                                                
\ *** Block No. 16 Hexblock 10 
                                                      bp 17Aug86
                                                                
Zeiger auf den ersten Buffer in der Ramdisk.                    
Beginn des f�r die Ramdisk allokierten Speicherbereichs         
L�nge   "   "   "     "        "               "                
                                                                
L�nge eines Buffers der Ramdisk                                 
                                                                
Diese Worte erlauben den Zugriff auf die Felder eines           
  Ramdiskbuffers.                                               
                                                                
                                                                
                                                                
Dies ist die Struktur eines Ramdiskbuffers. Alle Buffer befinden
 sich in einer gelinkten Liste, analog zum volksFORTH83-Block=  
 =buffermechanismus.                                            
\ *** Block No. 17 Hexblock 11 
                                                      bp 17Aug86
                                                                
                                                                
                                                                
                                                                
Sucht einen Buffer in der Ramdisk. Gesucht wird der Buffer      
 mit der Nummer BLK aus dem File mit der Nummer FCB.            
Zun�chst wird der erste Eintrag untersucht (weniger Rechenzeit).
 Ist es nicht der oberste, so werden die restlichen Buffer      
 verglichen. Wurde er gefunden, so wird der betreffende Buffer  
 an den Anfang der Liste geh�ngt, so da� die Buffer immer in    
 der Reihenfolge des Zugriffs geordnet sind. Dadurch wird die   
 Zugriffsgeschwindigkeit erh�ht.                                
                                                                
                                                                
                                                                
\ *** Block No. 18 Hexblock 12 
                                                      bp 17Aug86
                                                                
Kopiert den Inhalt des Ramdiskbuffers in den Blockbuffer des    
 volksFORTH-Systems                                             
                                                                
Kopiert den Inhalt des Blockbuffers im System in den Ramdisk=   
 =buffer.                                                       
                                                                
Diese beiden Worte k�nnen noch optimiert werden, da LCMOVE      
 byteweise �bertr�gt, aber auch langwortweise �bertragen        
 werden kann.                                                   
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 19 Hexblock 13 
                                                      bp 17Aug86
                                                                
Dieses Wort sucht einen leeren Ramdiskbuffer. Ist keiner leer,  
 so wird der letzte Buffer in der Liste genommen.               
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 20 Hexblock 14 
                                                      bp 24Aug86
                                                                
Hilfsvariable                                                   
                                                                
Markiert den Ramdiskbuffer DADDR als Buffer f�r den Block BLK   
 im File FILE.                                                  
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
Erzeugt einen Buffer f�r den Blockl BLK des Files FILE in der   
 Ramdisk. Der Inhalt des Buffers steht ab Adresse ADR im System.
 RAMBUF? wird benutzt, um den allokierten Buffer an die erste   
 Stelle zu h�ngen. Der WHILE-Teil wird max. einmal durchlaufen !
\ *** Block No. 21 Hexblock 15 
                                                      bp 17Aug86
                                                                
L�scht den Buffer LADDR.                                        
                                                                
                                                                
L�scht alle Ramdiskbuffer, die zum File FCB geh�ren.            
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 22 Hexblock 16 
                                                      bp 17Aug86
                                                                
Berechnet die Adresse D2 des Ramdiskbuffers, der auf den Buffer 
 mit der Adresse D1 folgt.                                      
                                                                
F ist wahr, falls noch weitere Buffer in der Ramdisk allokiert  
 werden k�nnen.                                                 
                                                                
Initialisiert die Ramdisk. Es werden soviele Buffer angelegt,   
 wie in den durch RAMFIRST und RAMSIZE angegebenen Speicher=    
 =bereich passen. Alle allokierten Buffer werden als leer       
 markiert.                                                      
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 23 Hexblock 17 
                                                      bp 17Aug86
                                                                
Liest eine Zahl von der Tastatur ein                            
                                                                
Erzeugt die Ramdisk. Zun�chst wird der alte Speicherbereich     
 freigegeben, falls einer allokiert war. Dann wird nach der     
 gew�nschten Zahl von Buffern gefragt. Es wird ein Speicher=    
 =bereich vom GEM-Dos angeordert und mit leeren Buffern         
 gef�llt.                                                       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 24 Hexblock 18 
                                                      bp 17Aug86
                                                                
Die alte R/W-Routine wird nat�rlich auch ben�tigt.              
                                                                
Kommuniziert mit den Massenspeichern.                           
 RW/F ist wahr, falls ein Lesezugriff erfolgen soll.            
 Ist die Ramdisk leer, so darf sie nicht angesprochen werden !  
 Sonst wird gepr�ft, ob es sich um einen Lesezugriff handelt    
 und ob der Buffer in der Ramdisk vorliegt. Ist das der Fall,   
 so wird einfach dessen Inhalt kopiert. Andernfalls mu�, falls  
 noch nicht vorhanden, ein Buffer allokiert werden. Der Inhalt  
 des Systembuffers wird dann in die Ramdisk kopiert und steht   
 beim n�chsten Lesezugriff zur Verf�gung.                       
                                                                
                                                                
                                                                
\ *** Block No. 25 Hexblock 19 
                                                      bp 17Aug86
                                                                
Es wird eine Liste mit dem Inhalt aller Ramdiskbuffer ausgegeben
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
