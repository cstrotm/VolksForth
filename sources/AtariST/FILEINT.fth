\ *** Block No. 0 Hexblock 0 
\\                  *** File-Interface ***             25may86we
                                                                
Dieses File enth�lt das File-Interface.                         
Damit wird der Zugriff auf normale GEM-Dos Files m�glich. Wenn  
ein File mit  USE  benutzt wird, beziehen sich alle Worte, die  
mit dem Massenspeicher arbeiten, auf dieses File. Ebenfalls un- 
terst�tzt das File-Interface Subdirectories, sogar mit mehr     
M�glichkeiten als unter GEM-Dos.                                
                                                                
Da es normalerweise im Direktzugriff geladen wird, m�ssen die   
View-Felder der Worte anschlie�end gepatched werden             
(s. STARTUP.SCR)                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ File interface load and patch block                  13oct86we
                                                                
Onlyforth                                                       
                                                                
1   3 +thru   \ savesystem, always needed                       
4 $21 +thru   \ Fileinterface                                   
                                                                
' (makeview     Is makeview                                     
' remove-files  Is custom-remove                                
' filer/w       Is r/w                                          
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 2 Hexblock 2 
\ File functions for save-system                     cas20130105
                                                                
: arguments ( n -- )                                            
     depth 1- > abort" not enough Parameters" ;                 
                                                                
| Code (createfile   ( C$ -- handle )                           
   0 # A7 -) move               \ normal file, no protection    
   SP )+ D6 move   D6 reg) A0 lea   .l A0 A7 -) move            
   .w $3C # A7 -) move   1 trap   8 A7 addq                     
   D0 SP -) move   Next   end-code                              
                                                                
| Code (closefile    ( handle -- f )                            
   SP )+  A7 -) move                                            
   $3E # A7 -) move   1 trap   4 A7 addq                        
   D0 SP -) move   Next   end-code                              
                                                                
\ *** Block No. 3 Hexblock 3 
\ write into file                                    cas20130105
                                                                
| Code (filewrite  ( buff len handle -- n )                     
   SP )+ D0 move   .l D2 clr  .w  SP )+ D2 move                 
   SP )+ D6 move   D6 reg) A0 lea                               
   .l  A0 A7 -) move           \ buffer adress                  
       D2 A7 -) move           \ buffer length                  
   .w  D0 A7 -) move           \ handle                         
    $40 # A7 -) move           \ call  WRITE                    
   1 trap    $0C # A7 adda                                      
   D0 SP -) move               \ errorflag, num written Bytes   
   Next  end-code                                               
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 4 Hexblock 4 
\ save-system                                        cas20130105
                                                                
: save-system       save   flush    \ Filename follows          
   bl word count   dup     0= abort" missing filename"          
   over + off    (createfile  dup >r   0< abort" no device "    
   $601A 0 !  align  here $1C - $04 !   0 , 0 ,                 
   0  here r@ (filewrite  here - abort" write error"            
   r> (closefile  0< abort" close error" ;                      
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 5 Hexblock 5 
\ disk errors                                          13oct86we
                                                                
Vocabulary Dos   Dos also definitions                           
                                                                
| ' 2-   Alias body>            \ just for style                
                                                                
                                                                
                                                                
                                                                
                                                                
| : 2digits   ( n -- adr len )                                  
    base push  decimal   extend <# # # #> ;                     
                                                                
| 0 Constant #adr                                               
        \ will hold the adr of "00" in following abort" ..."    
                                                                
\ *** Block No. 6 Hexblock 6 
\ disk errors                                        cas20130105
                                                                
: .diskerror  ( -n -- )     negate                              
    &13 case? abort" disk is proteced"                          
    &33 case? abort" file not found"                            
    &34 case? abort" path not found"                            
    &36 case? abort" access denied"                             
    &37 case? abort" illegal handle#"                           
    &46 case? abort" illegal drive num"                         
    2digits  #adr swap   cmove                                  
    true     [ here 2+      ( adress of counted string )   ]    
    abort" Dos-Error #00"                                       
             [ count +  2-  ' #adr >body !  ( adr of "00") ] ;  
                                                                
: ?diskabort   ( -n -- )    dup 0< IF .diskerror  THEN  drop ;  
                                                                
\ *** Block No. 7 Hexblock 7 
\ File control block structure                         09sep86we
                                                                
| : Fcbyte ( n len -- n' )   \ defining word for fcb contents   
    Create over c, +  does>  c@ + ;                             
                                                                
&25 Constant filenamelen      \ only SHORT pathes will fit !    
|  0  2 Fcbyte nextfile       \ link to next file               
filenamelen Fcbyte filename       \ name of file                
      4 Fcbyte filesize       \ size in Bytes ,  low..high      
      2 Fcbyte filehandle     \ handle from GEMdos              
      2 Fcbyte fileno         \ fileno. for VIEW                
    Constant b/fcb            \ bytes per file                  
                                                                
: handle        ( -- n )  isfile@ filehandle @ ;                
                                                                
\ *** nextfile must be the first field !                        
\ *** Block No. 8 Hexblock 8 
\ position into block                                  13oct86we
                                                                
Code lseek      ( d handle n -- d' )                            
   SP )+ A7 -) move    SP )+ A7 -) move    .l SP )+ A7 -) move  
   .w $42 # A7 -) move   1 trap    $0A # A7 adda                
   .l D0 SP -) move   Next  end-code                            
                                                                
: position      ( d handle -- f )                               
   0 lseek   0< ?exit   drop false ;                            
                                                                
: position?     ( handle -- d )                                 
   0 0 rot  1  lseek   dup 0<  IF  ?diskabort  THEN ;           
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 9 Hexblock 9 
\ read and write a memory area                       cas20130105
                                                                
Code (fileread   ( buff len handle -- n )                       
   SP )+ D0 move   .l D2 clr  .w  SP )+ D2 move                 
   SP )+ D6 move   D6 reg) A0 lea                               
   .l  A0 A7 -) move           \ buffer adress                  
       D2 A7 -) move           \ buffer length                  
   .w  D0 A7 -) move           \ handle                         
    $3F # A7 -) move           \ call  READ                     
   1 trap    $0C # A7 adda                                      
   D0 SP -) move               \ errorflag or bytes read        
   Next  end-code                                               
                                                                
' (filewrite Alias (filewrite                                   
                                                                
                                                                
\ *** Block No. 10 Hexblock A 
\ (open-file  setdta                                   26oct86we
                                                                
Code (openfile  ( C$ -- handle )                                
   2 # A7 -) move                                               
   SP )+ D6 move   D6 reg) A0 lea   .l A0 A7 -) move            
   .w $3D # A7 -) move   1 trap   8 A7 addq                     
   D0 SP -) move   Next   end-code                              
                                                                
Create dta      &44 allot                                       
                                                                
Code setdta     ( addr -- )                                     
   SP )+ D6 move   D6 reg) A0 lea   .l A0 A7 -) move            
   .w $1A # A7 -) move   1 trap   6 A7 addq   Next   end-code   
                                                                
' (closefile  Alias (closefile                                  
' (createfile Alias (createfile                                 
\ *** Block No. 11 Hexblock B 
\ search for files                                     03oct86we
                                                                
Code search0    ( C$ attr -- f )    \ search for first file     
   SP )+ A7 -) move    SP )+ D6 move   D6 reg) A0 lea           
   .l A0 A7 -) move   .w $4E # A7 -) move   1 trap   8 A7 addq  
   D0 SP -) move    Next  end-code                              
                                                                
Code searchnext    ( -- f )         \ search for next file      
   $4F # A7 -) move   1 trap   2 A7 addq                        
   D0 SP -) move    Next  end-code                              
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 12 Hexblock C 
\ Create a subdir                                   bp 11 oct 86
                                                                
Code (makedir  ( C$ -- f )     \ Create a subdir                
   $39 # D1 move                                                
Label long-adr                                                  
   SP )+ D6 move   D6 reg) A0 lea   .l A0 A7 -) move            
   .w D1 A7 -) move   1 trap   6 A7 addq                        
   D0 SP -) move   Next  end-code                               
                                                                
Code (setdir     ( C$ -- f )                                    
   $3B # D1 move   long-adr bra    end-code                     
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 13 Hexblock D 
\ select drive                                         09sep86we
                                                                
Code setdrive   ( n -- )                                        
   SP )+ A7 -) move                                             
   $0E # A7 -) move   1 trap   4 A7 addq   Next end-code        
                                                                
Code getdrive   ( -- n )                                        
   $19 # A7 -) move   1 trap   2 A7 addq                        
   D0 SP -) move   Next   end-code                              
                                                                
Code getdir     ( addr n -- f )  \ n is drive, string in addr   
   SP )+ A7 -) move   SP )+ D6 move   D6 reg) A0 lea            
   .l A0 A7 -) move   .w $47 # A7 -) move   1 trap   8 A7 addq  
   D0 SP -) move   Next   end-code                              
                                                                
                                                                
\ *** Block No. 14 Hexblock E 
\ file sizes                                          b30aug86we
                                                                
: (capacity  ( fcb -- n)             \ calculates size in blocks
   filesize 2@   2dup or  0= IF  drop exit  THEN                
   b/blk  um/mod  swap  IF  1+  THEN ;  \ add 1 block for rest  
                                                                
| : in-range  ( block fcb -- f) \ makes sure, block is in file  
     (capacity  u< not &36 * ;    \ Errorcode -&36              
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 15 Hexblock F 
\ read and write into files                         bp 11 oct 86
                                                                
| : set-pos   ( block handle -- f)                              
      >r  b/blk um*  r>  position ;                             
                                                                
| : fileaccess   ( buff block fcb -- buff len handle/ errorcode)
      2dup  in-range  ?dup IF >r 2drop drop r> rdrop exit THEN  
      filehandle @   under  set-pos                             
                      ?dup IF >r 2drop      r> rdrop exit THEN  
      b/blk swap ;                                              
                                                                
| : fileread     ( buff block fcb -- ff / errorcode )           
      fileaccess  (fileread  dup 0>  IF  drop false  THEN ;     
                                                                
| : filewrite    ( buff block fcb -- ff / errorcode )           
      fileaccess  (filewrite  dup 0>  IF  drop false  THEN ;    
\ *** Block No. 16 Hexblock 10 
\ twiggling the file variables                      bp 11 oct 86
                                                                
: scan-name     ( C$ -- adr len')  \ length of "C"-string       
     $1000 over swap  0 scan  drop  over - ;                    
                                                                
: .file ( fcb --)                  \ print only filename        
     ?dup 0=  IF  ." DIRECT ! " exit  THEN  body> >name .name ; 
                                                                
: .fcb      ( fcb -- )             \ print filename             
     dup filehandle @ 2 .r   dup filesize 2@  6 d.r   3 spaces  
     dup .file  2 spaces  filename scan-name type ;             
                                                                
: !files   ( fcb -- )              \ set file and isfile        
      dup  isfile !  fromfile ! ;                               
                                                                
                                                                
\ *** Block No. 17 Hexblock 11 
\ PATHes                                            bp 11 oct 86
                                                                
| &30 Constant pathlen          \ max. len of all pathes        
                                                                
Variable  pathes  pathlen allot \ counted string of pathes      
     pathes off                                                 
                                                                
: pathes?       ( -- )          \ print a list of the pathes    
     cr  3 spaces  pathes count type ;                          
                                                                
: setpath       ( adr len --)   \ set's the list of pathes      
     pathlen min   pathes place                                 
     Ascii ;  pathes count + c!   pathes c@ 1+ pathes c! ;      
                                                                
\\ PATH : see elsewhere in this file                            
                                                                
\ *** Block No. 18 Hexblock 12 
\ search for files                                  bp 11 oct 86
                                                                
Variable workspace    &64 allot       \ place for c$            
                                                                
| : try.path   ( adr len fcb attr -- f )                        
    2swap   workspace swap   2dup + >r   move                   
    swap   filename  r>  filenamelen cmove                      
    workspace   swap  search0 0= ;                              
                                                                
| : makec$     ( adr len -- c$ )        \ make adr len to a c$  
    workspace swap  2dup + >r   move                            
    r> off  ( make a c$ ) workspace ;                           
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 19 Hexblock 13 
\ "                                                 bp 11 oct 86
                                                                
| Variable sfile                       \ "dirty" variable       
| 7 Constant defaultattr               \ find all filetypes     
                                                                
| : path@       ( adr len -- adr len1 adr len2) \ isolate a path
     Ascii ; skip   2dup  2dup  Ascii ; scan   nip -  ;         
                                                                
: (searchfile   ( fcb -- ff/ C$ f)     \ search for file in path
   sfile !    pathes count             \ and in act. directory  
   BEGIN   path@  sfile @  defaultattr   try.path               
                  IF  2drop  workspace true  exit  THEN         
           Ascii ; scan   dup 0=  UNTIL  nip ;                  
                                                                
: searchfile   ( fcb -- C$ )   \ file was found in path         
   (searchfile ?exit    -&33 ?diskabort ;                       
\ *** Block No. 20 Hexblock 14 
\ open a file, filer/w                                b26oct86we
                                                                
| : @length       ( -- d)          dta  &26 +   2@ ;            
| : copylength    ( fcb --)        @length  rot filesize 2! ;   
                                                                
: (open         ( fcb --)       \ open file                     
     dup  filehandle @  IF  drop exit  THEN                     
     dta setdta  dup searchfile  over copylength    (openfile   
          dup ?diskabort   swap filehandle ! ;                  
                                                                
Forth definitions                                               
                                                                
: capacity      ( -- n)                                         
    isfile@ ?dup  IF  dup (open (capacity  exit THEN  blk/drv ; 
                                                                
Dos definitions                                                 
\ *** Block No. 21 Hexblock 15 
\ filer/w, Create a file                            bp 11 oct 86
                                                                
: filer/w       ( buff block fcb f -- f)                        
     over  0= IF  STr/w exit  THEN                              
     over (open                                                 
     IF  fileread  ELSE  filewrite  THEN  dup ?diskabort ;      
                                                                
: createfile    ( fcb --)       \ create a file in fcb          
   dup filename (createfile     dup ?diskabort                  
   over filehandle !      0 0 rot filesize  2!                  
   offset off ;                                                 
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 22 Hexblock 16 
\ store names for files                             bp 11 oct 86
                                                                
| : !name       ( adr len --)      \ store name in record       
   2dup erase     >r  name count                                
   dup  r>   < not abort" string too long"                      
   >r swap r> cmove ;                                           
                                                                
: !fcb          ( fcb --)          \ next word is filename      
   dup filehandle off   filename  filenamelen !name ;           
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 23 Hexblock 17 
\ print dta and directory                              26oct86we
                                                                
| : .dtaname      ( addr --)       \ addr is addr of name       
      dup  BEGIN  dup c@  ?dup  WHILE  emit  1+  REPEAT         
       -  &15 +  spaces ;                                       
                                                                
: .dta          ( --)           \ print contents of dta         
     cr  dta &21 +  c@ $10 and                                  
     IF  Ascii D  ELSE  bl  THEN emit   space                   
     dta &30 +  .dtaname   @length  &10 d.r ;                   
                                                                
: (dir          ( attr adr len --)   \ given a match string     
     makec$  swap   dta setdta   search0                        
     BEGIN  0=  WHILE  stop? 0= WHILE .dta  searchnext  REPEAT ;
                                                                
                                                                
\ *** Block No. 24 Hexblock 18 
\ primitives for fcb's                                bp 18May86
                                                                
User file-link   file-link off    \ list thru files             
                                                                
| : #file       ( -- n)         \ View number of next file      
   file-link @ dup  IF  fileno @  THEN  1+ ;                    
                                                                
                                                                
: forthfiles         ( --)      \ print a list of :             
    file-link @             \ forthword,filename,handle,len     
    BEGIN  dup  WHILE                                           
       cr   dup .fcb     @  stop? UNTIL drop ;                  
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 25 Hexblock 19 
\ Close a file                                        bp 18May86
                                                                
|  ' save-buffers  >body $C  + @  Alias backup                  
                                                                
| : filebuffer?        ( fcb -- fcb bufaddr/flag)               
   prev  BEGIN  @ dup  WHILE  2dup  2+ @  =  UNTIL ;            
                                                                
| : flushfile          ( fcb -- )       \ flush file buffers    
   BEGIN  filebuffer?  ?dup  WHILE                              
          dup backup  emptybuf  REPEAT  drop ;                  
                                                                
: (close        ( fcb --)       \ close file in fcb             
   dup flushfile                                                
   filehandle dup @   ?dup 0= IF  drop exit THEN   swap off     
   (closefile -$41 case? ?exit  ?diskabort  ;                   
                                                                
\ *** Block No. 26 Hexblock 1A 
\ Create fcb's                                      bp 11 oct 86
                                                                
Forth definitions                                               
                                                                
                                                                
: File          ( -- )          \ Create a fcb                  
     Create  here  b/fcb allot   dup b/fcb erase                
             #file  over fileno !                               
             file-link @   over file-link !  swap !             
    does>  !files  ;                                            
                                                                
: direct        0 !files ;      \ switch to direct access       
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 27 Hexblock 1B 
\ flush buffers & misc.                                bp 8jun86
                                                                
: flush         ( --)           flush  file-link                
   BEGIN  @ ?dup  WHILE  dup (close  REPEAT ;                   
                                                                
: file?    isfile@  .file ;        \ print current file         
                                                                
: list          ( n --)                                         
   3 spaces  file?  list ;                                      
                                                                
: path          ( -- )          \ this is a smart word !        
   name count                                                   
   dup 0=   IF  2drop  pathes?  exit  THEN                      
   dup 1 =  IF  over c@  Ascii ;  =                             
                 IF  2drop  pathes off  exit  THEN  THEN        
   setpath ;                                                    
\ *** Block No. 28 Hexblock 1C 
\ File Interface User words                            26oct86we
                                                                
| : isfile?     ( adr -- adr f)  \ is adr a fcb ?               
   file-link  BEGIN  @ dup 0= ?exit  2dup 2- = UNTIL drop true ;
                                                                
| : ?isfile@   isfile@ body>                                    
               isfile? 0= abort" not in direct mode"   >body ;  
                                                                
: open         ?isfile@ (open   offset off ;                    
: close        ?isfile@ (close ;                                
: assign       close  isfile@ !fcb  open ;                      
: make         ?isfile@ dup !fcb  createfile ;                  
                                                                
: use          >in @  name find  \ create a fcb if not present !
   IF  isfile?  IF execute drop  exit THEN THEN drop            
   dup >in ! File    dup >in ! ' execute    >in !  assign ;     
\ *** Block No. 29 Hexblock 1D 
\ File Interface User words                         bp 11 oct 86
                                                                
: makefile     >in @  file  dup >in ! ' execute  >in ! make ;   
                                                                
: from         isfile push  use ;         \ sets only fromfile  
: loadfrom     ( n --)                    \ load 1 scr from file
               isfile push  fromfile push   use load   close ;  
: include      1 loadfrom ;                                     
                                                                
: eof           ( -- f)                   \ end of file ?       
   isfile@  dup  filehandle @  position?                        
             rot  filesize  2@  d= ;                            
                                                                
: files         $10   " *.*"   count  (dir ;                    
: files"        $10 Ascii "  word count (dir ;                  
                                                                
\ *** Block No. 30 Hexblock 1E 
\ extend files                                      bp 11 oct 86
                                                                
| : >fileend    isfile@ filesize 2@   handle  position          
                ?diskabort ;                                    
                                                                
| : addsize     isfile@ filesize dup  2@ b/blk 0 d+  rot 2! ;   
                                                                
| : addblock    ( n --)         \ add block n to file           
    buffer b/blk  2dup bl fill  >fileend  handle (filewrite     
    dup ?diskabort   b/blk -                                    
    IF  close  abort" Disk voll" THEN  addsize ;                
                                                                
: (more   ( n --)                                               
    capacity swap bounds ?DO  I addblock  LOOP ;                
                                                                
: more    ( n --)     ?isfile@  (open  (more  close ;           
\ *** Block No. 31 Hexblock 1F 
\ make,kill and set directories                     bp 11 oct 86
                                                                
| : dir$        ( -- adr )      name count   makec$ ;           
                                                                
: makedir       dir$ (makedir ?diskabort ;                      
                                                                
: dir           name count                                      
                0 case? IF  getdrive 2dup 1+ getdir ?diskabort  
                            cr 3 spaces  Ascii A + emit   ." :" 
                            scan-name type exit  THEN           
                makec$ (setdir ?diskabort ;                     
                                                                
| : driveset    Create c,  Does>  c@ setdrive ;                 
0 driveset A:   1 driveset B:   2 driveset C:   3 driveset D:   
                                                                
                                                                
\ *** Block No. 32 Hexblock 20 
\ words for VIEWing                                 bcas20130105
                                                                
| $200 Constant viewoffset      \ max. &512 kbyte long files    
                                                                
| : (makeview     ( -- n)       \ calc. view field for a name   
   blk @  dup  0= ?exit                                         
   loadfile @  ?dup  IF  fileno @  viewoffset *   +  THEN  ;    
                                                                
: (view         ( blk -- blk')  \ select file and leave block   
   dup  0= ?exit                                                
   viewoffset  u/mod  file-link                                 
   BEGIN  @ dup  WHILE  2dup fileno @ = UNTIL                   
   dup  searchfile drop   \ file not found : abort              
   !files  drop  ;                                              
                                                                
                                                                
\ *** Block No. 33 Hexblock 21 
\ ugly FORGETing of files                           bp 11 oct 86
                                                                
: remove?            ( dic symb addr -- dic symb addr f)        
   dup heap?  IF  2dup u>  exit  THEN  2 pick  over 1+ u< ;     
                                                                
| : remove-files ( dic symb -- dic symb)   \ flush files !      
   isfile   @ remove?  nip  IF  0 !files      THEN              
   fromfile @ remove?  nip  IF  fromfile off  THEN              
   file-link                                                    
   BEGIN  @ ?dup  WHILE  remove?  IF  dup (close  THEN  REPEAT  
   file-link remove ;                                           
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 34 Hexblock 22 
\ convey for files                                  bp 11 oct 86
                                                                
| : togglefiles    ( -- )      \ changes isfile and fromfile    
     isfile@  fromfile @   isfile !  fromfile ! ;               
                                                                
: convey           ( [blk1 blk2] [to.blk --)                    
   3 arguments   >r  2dup swap -  >r                            
   togglefiles       dup capacity 1- >                          
   togglefiles  r> r@ +  capacity 1- >                          
    or abort" wrong range!"                                     
   r>  convey ;                                                 
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 35 Hexblock 23 
\ print a list of all blocks                           bp 9Apr86
                                                                
: .blocks                                                       
   prev BEGIN  @ ?dup WHILE  stop? abort" stopped"              
               cr dup u.  dup 2+ @  dup 1+                      
                IF ."    Block :" over  4+ @ 5 .r               
                   ."     File : "  [ Dos ] .file               
                   dup 6 + @ 0< IF ."    updated" THEN          
                ELSE ." Block empty" drop  THEN  REPEAT  ;      
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 36 Hexblock 24 
\ create a file of direct blocks                    bcas20130105
                                                                
Dos also                                                        
                                                                
| File outfile                                                  
                                                                
: blocks>file   ( from to -- )    \ name of file follows        
   ?isfile@  -rot  outfile make                                 
   1+ swap ?DO  I over (block   b/blk  handle (filewrite        
                         b/blk - abort" write error"            
            LOOP  close   isfile ! ;                            
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 37 Hexblock 25 
                                                       bp 4oct86
                                                                
                                                                
                                                                
                                                                
                                                                
MAKEVIEW        erzeugt aus ISFILE und BLK das Viewfeld         
CUSTOM-REMOVE   erlaubt das FORGETten von eig. Datenstrukturen  
R/W             setzt Forthbl�cke in Disksektoren um ....       
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 38 Hexblock 26 
                                                       13oct86we
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 39 Hexblock 27 
                                                       13oct86we
                                                                
ARGUMENTS       liefert etwas Sicherheit ...                    
                                                                
                                                                
(CREATEFILE     erzeugt ein File, dessen Namen in C$ steht, im  
   aktuellen oder im durch den Pfadnamen angegebenen Directory. 
   HANDLE ist die Handle des Files oder ein Fehlerflag.         
   Es wird immer ein "ganz normales" File erzeugt.              
                                                                
(CLOSEFILE      Schlie�t das File mit der Handle HANDLE. Dabei  
  sollten alle TOS-Buffer zur�ckgeschrieben und das Directory   
  gesichert werden. F ist ein Fehlerflag. Die Handle ist        
  anschlie�end ung�ltig.                                        
                                                                
                                                                
\ *** Block No. 40 Hexblock 28 
                                                       13oct86we
                                                                
(FILEWRITE      schreibtLEN Bytes in das File HANDLE. Die Bytes 
   werden ab Adresse BUFF im Speicher geholt.                   
   N ist die Zahl der geschriebenen Bytes oder eine             
   Fehlernummer, wenn N zwischen -66 und -1 liegt.              
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 41 Hexblock 29 
                                                     cas20130105
                                                                
SAVE-SYSTEM speichert ein FORTH-System im aktuellen Zustand auf 
 Diskette ab.                                                   
                                                                
Voodoo-Code f�r den GEMDOS-Fileheader; keine Relokatinsinfos    
                                                                
Mit SAVE-SYSTEM lassen sich eigene Arbeitssysteme oder auch     
 Applikationen erstellen, denen man ihre FORTH-Herkunft nicht   
 mehr ansieht.                                                  
 Stellen Sie ein System nach Ihren W�nschen zusammen, und spei- 
 chern Sie es dann mit  SAVE-SYSTEM MYPROG.PRG  ab.             
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 42 Hexblock 2A 
                                                       13oct86we
                                                                
DOS             enth�lt die "unwichtigen" Worte des             
                Fileinterfaces                                  
                                                                
BODY>           ( cfa -- pfa )   Kompilationsadresse in         
                 Parameterfeldadresse umwandeln ...             
                                                                
                                                                
                                                                
Diese Worte werden f�r die �ble Patcherei in .diskabort benutzt.
 Nur so kann die Dos-Fehlernummer in der abort" -Meldung unter- 
 gebracht werden. Bei einer Ausgabe mit . w�re keine Umleitung  
 �ber ERRORHANDLER m�glich.                                     
                                                                
                                                                
\ *** Block No. 43 Hexblock 2B 
                                                       13oct86we
                                                                
-n ist die Fehlernummer; es wird der zugeh�rige Text ausgedruckt
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
 Ist die Fehlernummer nicht in den CASE-Anweisungen zu finden,  
 wird Dos-Error #   ausgegeben. Die Fehlernummer wird dann in   
 den abort" String gepatched. Dieses Verfahren ist zwar �u�erst 
 h��lich, nichtsdestoweniger aber sehr effektiv.                
                                                                
Pr�ft, ob ein Fehler vorliegt und druckt ggf. den Text aus und  
  ABORTed anschlie�end.                                         
\ *** Block No. 44 Hexblock 2C 
                                                       bp 4oct86
                                                                
Definierendes Wort f�r die Benamsung der Felder eines           
  File control blocks  ( FCB bzw. FILE in den Stackkommentaren) 
                                                                
                                                                
Zeiger auf den n�chsten FCB                                     
Platz f�r max. 24 Zeichen f�r den TOS-Filenamen                 
L�nge des Files in Bytes                                        
Handlenummer, die das TOS beim �ffnen eines Files liefert.      
Eine eigene Nummer, die in das VIEW-Feld eingetragen wird.      
L�nge eines FCB wird auch berechnet...                          
                                                                
Liefert die Handle des aktuellen Files. Null, falls das         
 File nicht offen .                                             
                                                                
\ *** Block No. 45 Hexblock 2D 
                                                       bp 4oct86
                                                                
LSEEK           N ist ein Flag, das angibt, ob relativ zum      
   Fileanfang, zum Fileende oder zur aktuellen Position im File 
   positioniert werden soll. HANDLE ist die Handle des Files, in
   dem positioniert wird und D die neue Position im File.       
   D' ist die neue Position.                                    
POSITION        positioniert auf das Byte d, gez�hlt vom Anfang 
   des Files mit der Handle HANDLE .                            
                                                                
POSITION?       liefert die Position des zuletzt gelesenen,     
   geschriebenen oder mit POSITION bzw. LSEEK angew�hlten Bytes.
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 46 Hexblock 2E 
                                                       13oct86we
                                                                
FILEREAD        liest LEN Bytes aus dem File HANDLE. Die Bytes  
   werden ab Adresse BUFF im Speicher abgelegt.                 
   N ist die Zahl der gelesenen Bytes oder eine Fehlernummer,   
   wenn N zwischen -66 und -1 liegt.                            
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
Das headerlose (FILEWRITE bekommt nun einen Header im Vocabulary
 Dos.                                                           
                                                                
\ *** Block No. 47 Hexblock 2F 
                                                       26oct86we
                                                                
OPENFILE        �ffnet ein File. Der Name steht im String C$.   
  C$ ist durch ein $00-Byte begrenzt. HANDLE ist die diesem     
  File zugeordnete Handle oder eine Fehlernummer.               
                                                                
                                                                
                                                                
DTA             ist ein 44 Byte gro�er Buffer, in dem einige    
  Fileinformationen vom GEMDOS gehalten werden.                 
SETDTA          ADDR ist die Adresse der 'disk transfer area'.  
                                                                
                                                                
                                                                
(CLOSEFILE und (CREATEFILE erhalten Header im Vocabulary Dos.   
                                                                
\ *** Block No. 48 Hexblock 30 
                                                       13oct86we
                                                                
SEARCH0         SEARCH0 sucht ein File. C$ ist der Name des File
   mit Pfad usw. . C$ wird, wie immer, durch ein $00-Byte       
   begrenzt. ATTR ist ein Attributwort, das z.B. bestimmt, ob   
   auch Subdirectories gefunden werden. F ist ein Fehlerflag.   
   Die DTA enth�lt anschlie�end Filenamen, -l�nge usw.          
SEARCHNEXT      sucht das n�chste File mit dem bei SEARCH0      
   angegeben Namen...                                           
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 49 Hexblock 31 
                                                       13oct86we
                                                                
(MAKEDIR        erzeugt �hnlich (CREATEFILE ein Subdirectory.   
   C$ ist der Name des Directories, F ist ein Fehlerflag.       
                                                                
                                                                
                                                                
                                                                
                                                                
(SETDIR         setzt das durch C$ angegeben Subdirectory als   
   das "Aktuelle", auf das sich alle Such- und "Erzeugungs-"    
   operationen ohne eigenen Pfadnamen beziehen.                 
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 50 Hexblock 32 
                                                       bp 4oct86
                                                                
SETDRIVE        N ist die Nummer des aktuellen Laufwerkes, auf  
  das sich alle Operationen ohne eigenen Pfadnamen beziehen.    
  Vergleiche (SETDIR.   Laufwerk A: hat die Nummer 0 !          
                                                                
GETDRIVE        N ist die Nummer des bei SETDRIVE genannten     
  Laufwerks.                                                    
                                                                
                                                                
GETDIR          Das durch (SETDIR gesetzte Subdirectory wird    
  ab Adresse ADDR als C$ im Speicher abgelegt. N ist die Nummer 
  des Laufwerkes ( Laufwerk A: hat die Nummer 1 !!!! ), denn    
  verschiedene Laufwerke k�nnen verschiedene aktuelle Sub-      
  directories haben.                                            
                                                                
\ *** Block No. 51 Hexblock 33 
                                                       bp 4oct86
                                                                
(CAPACITY       FCB ist die Adresse des FCB des Files, von      
   dem die L�nge in Blocks bestimmt werden soll. N ist dann     
   die Zahl der Bl�cke in diesem File.                          
                                                                
IN-RANGE        pr�ft, ob sich ein Block mit der Nummer BLOCK   
   im File FCB befindet. Ist das nicht der Fall, wird als       
   Fehlernummer -36 geliefert. Siehe auch ?DISKABORT            
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 52 Hexblock 34 
                                                       13oct86we
                                                                
SET-POS         positioniert im File mit der Handle HANDLE auf  
   den Anfangs des Blocks BLOCK. F ist ein Fehlerflag.          
                                                                
FILEACCESS      wird in FILEREAD und FILEWRITE ben�tigt.        
                                                                
                                                                
                                                                
                                                                
                                                                
FILEREAD        liest den Block BLOCK an die Adresse BUFF aus   
   dem File FCB. Hinterl��t eine Fehlernummer.                  
                                                                
FILEWRITE       �berschreibt den Block BLOCK mit den Daten ab   
   Adresse BUFF im File FCB. Hinterl��t eine Fehlernummer.      
\ *** Block No. 53 Hexblock 35 
                                                       bp 4oct86
                                                                
SCAN-NAME       'LEN ist die L�nge eines durch ein $00-Byte     
   begrenzten C$.                                               
                                                                
.FILE           druckt den Forthnamen des Files mit der Adresse 
   FCB.                                                         
                                                                
.FCB            druckt Forthnamen, TOS-Namen, Handle und L�nge  
   des Files mit der Adresse FCB aus.                           
                                                                
!FILES          setzt die Variable ISFILE und FROMFILE (darin   
   steht das File, aus dem bei COPY und CONVEY gelesen wird)    
   auf das File mit der Adresse FCB.                            
                                                                
                                                                
\ *** Block No. 54 Hexblock 36 
                                                       bp 4oct86
                                                                
PATHES          Hier ist Platz f�r den durch SETPATH angegeben  
   String, der die Namen der zu durchsuchenden Laufwerke und    
   Directories enth�lt.                                         
PATHES?         Druckt den Inhalt von PATHES aus.               
                                                                
SETPATH         Setzt PATHES auf den String ab der Adresse ADR, 
   dessen L�nge LEN ist. Anschlie�end wird noch ein ; angef�gt, 
   um auch den letzten Path korrekt zu beenden.                 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 55 Hexblock 37 
                                                       bp 4oct86
                                                                
WORKSPACE       Hier wird aus File- und Pathnamen ein C$        
  zusammengebastelt.                                            
                                                                
TRY.PATH        ADR und LEN enthalten den Pfadnamen (aus        
  PATHES mit PATH@ extrahiert), FCB ist die Adresse des Files   
  und ATTR ein Attribut (siehe SEARCH0). Aus Pfadnamen und FCB  
  wird in WORKSPACE ein String zusammengebastelt, der dann mit  
  SEARCH0 gesucht wird. F gibt an, ob wir erfolgreich waren.    
                                                                
MAKEC$          konvertiert einen durch ADR und LEN definierten 
  String in einen C$ (durch ein $00-Byte begrenzt) und          
  hinterl��t dessen Adresse.                                    
                                                                
                                                                
\ *** Block No. 56 Hexblock 38 
                                                       bp 4oct86
                                                                
SFILE           enth�lt die Adresse des FCB des gesuchten Files.
DEFAULTATTR     enstpricht "Suche alle Files, egal welches ATTR"
                                                                
PATH@           extrahiere aus dem noch nicht zum Suchen verwen-
   deten Teil von PATHES, der durch ADR und LEN angegeben wird, 
   den n�chsten zu durchsuchenden Pfad ADR LEN1.                
(SEARCHFILE     durchsucht alle in PATHES stehenden Pfade nach  
   dem in FCB stehenden Filenamen. Aufgeh�rt wird, wenn das File
   gefunden wurde oder alle Pfade durchsucht wurden.            
   Am Schlu� wird auch der leere Pfad (L�nge Null) durchsucht,  
   der dem aktuellen Directory (siehe SETDIR) entspricht.       
                                                                
SEARCHFILE      Sucht das File FCB in allen Pfaden und im akt.  
   Directory. Hinterlassen wird der vollst�ndige Pfad des Files.
\ *** Block No. 57 Hexblock 39 
                                                       bp 4oct86
                                                                
@LENGTH         holt die L�nge des zuletzt gefundenen Files     
COPYLENGTH      kopiert die L�nge des zuletzt gefundenen Files  
   in den Fcb FCB.                                              
(OPEN           �ffnet das durch FCB angegebene File            
   und speichert LEN dort die Handle und L�nge. Dazu mu� es     
   nat�rlich erst gesucht werden, denn nur dann steht die L�nge 
   in der DTA.                                                  
                                                                
                                                                
                                                                
CAPACITY        N ist die Zahl der Bl�cke im aktuellen (durch   
  ISFILE angegeben) File. Ist ISFILE Null, so wird die Kapazit�t
  der Diskette im Direktzugriff angegeben.                      
                                                                
\ *** Block No. 58 Hexblock 3A 
                                                       bp 4oct86
                                                                
FILER/W         ist das zentrale Wort f�r den Zugriff auf Files.
    BUFF ist die Adresse des Blocks BLOCK im Speicher, FCB die  
    Nummer des Files (0 hei�t Direktzugriff) und R/W gibt an, in
    welcher Richtung die Daten zu transportieren sind.          
    F ist true, falls ein Fehler auftrat.                       
                                                                
CREATEFILE      erzeugt ein File, dessen Name im Fcb FCB steht. 
    Handle und Filel�nge werden korrigiert.                     
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 59 Hexblock 3B 
                                                       bp 4oct86
                                                                
!NAME           speichert einen auf !NAME folgenden String      
   ab Adresse ADR mit maximaler L�nge LEN im Speicher ab.       
   Der String wird durch $00-Bytes begrenzt.                    
                                                                
                                                                
!FCB            speichert einen auf !FCB folgenden String im    
   Fcb FCB ab. Die Handle wird gel�scht, weil das               
   so zugewiesene File noch nicht ge�ffnet worden ist.          
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 60 Hexblock 3C 
                                                       13oct86we
                                                                
.DTANAME        druckt den Filenamen, er ab Adresse d in der DTA
   steht, linksb�ndig in einem Feld der Breite 15 aus.          
                                                                
                                                                
.DTA            druckt den Inhalt der DTA formattiert aus.      
  Zun�chst wird ein "D" ausgegeben, das anzeigt, ob es sich     
  um ein Subdirectory handelt, anschlie�end der Name gefolgt    
  von der L�nge des Files.                                      
                                                                
(DIR            druckt alle Files aus, auf die der String ADR   
   LEN und das Attribut ATTR "passt". Die Ausgabe kann wie      
   �blich angehalten und abgebrochen werden.                    
                                                                
                                                                
\ *** Block No. 61 Hexblock 3D 
                                                       bp 4oct86
                                                                
FILE-LINK       enth�lt einen Zeiger auf den FCB des            
   zuletzt definierten Files.                                   
#FILE           N ist die Nummer, die in das Viewfeld des       
   n�chsten zu definierenden Files eingetragen werden soll.     
                                                                
                                                                
FORTHFILES      druckt die Forth- und TOS-Namen mit Handle und  
   L�nge aller definierten Files aus. Dazu wird FILE-LINK       
   benutzt. Die Ausgabe kann wie �blich angehalten oder beendet 
   werden.                                                      
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 62 Hexblock 3E 
                                                       bp 4oct86
                                                                
FILEBUFFER?     guckt nach, ob zu dem File FCB noch ein Block-  
   puffer exisitiert. Liefert false, falls keiner vorhanden ist.
                                                                
FLUSHFILE       sichert alle zum File FCB geh�renden Blockpuffer
   auf dem Massenspeicher und l�scht sie anschlie�end.          
                                                                
                                                                
(CLOSE          sichert alle Blockpuffer, schlie�t anschlie�end 
   das File, falls es nicht schon geschlossen war und ignoriert 
   den Fehler mit der Nummer -65, weil der so oft auftritt...   
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 63 Hexblock 3F 
                                                       bp 4oct86
                                                                
FILE            ist ein definierendes Wort, da� einen FCB       
   erzeugt. Wird der FCB sp�ter ausgef�hrt, so tr�gt er sich    
   als aktuelles File und als FROMFILE ein.                     
                                                                
                                                                
                                                                
DIRECT          ein "spezieller FCB" f�r den Direktzugriff.     
   Der Direktzugriff ist immer dann interessant, wenn man       
   einen Diskmonitor braucht, ihn aber gerade verliehen hat...  
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 64 Hexblock 40 
                                                       bp 4oct86
                                                                
FLUSH           schlie�t zus�tzlich alle Files..                
                                                                
                                                                
FILE?           druckt den Namen des aktuellen Files aus.       
                                                                
LIST            druckt zus�tzlich den Filenamen aus...          
                                                                
                                                                
PATH            druckt PATHES aus               oder            
                l�scht PATHES                   oder            
                setzt PATHES auf einen anderen String.          
                                                                
                                                                
                                                                
\ *** Block No. 65 Hexblock 41 
                                                       13oct86we
                                                                
ISFILE?         F ist wahr, falls ADR die Kompilationsadresse   
   eines FCB ist (also durch FILE erzeugt wurde...).            
                                                                
?ISFILE@        steht in ISFILE �berhaupt ein File ?            
                                                                
OPEN            �ffnet das aktuelle File.                       
CLOSE           schlie�t es.                                    
ASSIGN          Anderer Filename in aktuellen FCB eintragen.    
MAKE            Neu erzeugter Filename in aktuellen FCB..       
                                                                
USE             Erzeuge FCB (mit Filenamen !), falls Name nicht 
   schon vorhanden. Wenn Name vorhanden, pr�fe ob es File ist.  
   Trage dann FCB in ISFILE ein.                                
                                                                
\ *** Block No. 66 Hexblock 42 
                                                       13oct86we
                                                                
MAKEFILE        erzeugt FCB und File gleichen Namens.           
                                                                
FROM            setzt FROMFILE f�r COPY und CONVEY              
LOADFROM        l�dt den Screen N vom File, dessen Name auf     
   LOADFROM folgt.   z.B.    1 loadfrom forth_83.scr            
INCLUDE         l�dt den Loadscreen des Files...                
                                                                
EOF             F ist wahr, falls wir am Ende des Files         
   angekommen sind.                                             
                                                                
                                                                
FILES           liefert Inhaltsverzeichnis des akt. Directories.
FILES"          erlaubt Pfad- und Filenamen                     
                                                                
\ *** Block No. 67 Hexblock 43 
                                                       bp 4oct86
                                                                
>FILEEND        springe ans Ende des aktuellen Files            
                                                                
                                                                
ADDSIZE         erh�ht die L�ngenangabe im aktuellen FCB um     
  1024 Bytes.                                                   
ADDBLOCK        f�gt den Block N am Fileende an.                
  Au�erdem wird ein leerer Buffer mit dieser Nummer angelegt.   
                                                                
                                                                
                                                                
(MORE           f�gt n Bl�cke am Fileende an.                   
                                                                
MORE            Wie (MORE, jedoch etwas Sicherheit..            
                                                                
\ *** Block No. 68 Hexblock 44 
                                                       13oct86we
                                                                
DIR$            ADR ist die Adresse eines auf DIR$ folgenden C$.
                                                                
MAKEDIR         erzeugt ein Directory mit dem folgenden Namen.. 
                                                                
DIR             gibt, falls kein Name folgt, das aktuelle Lauf- 
   werk und Subdirectory aus. Folgt ein Name, so wird er als    
   das neue aktuelle Directory an das TOS �bergeben.            
                                                                
                                                                
                                                                
A: B: C: D:     Kurzformen f�r SETDRIVE.                        
                                                                
                                                                
                                                                
\ *** Block No. 69 Hexblock 45 
                                                       13oct86we
                                                                
VIEWOFFSET      teilt das 16-Bit Viewfeld in ein Feld mit der   
    Filenummer und ein Feld mit der Blocknummer. Die unteren 9  
    Bits sind f�r die Blocknummer reserviert.                   
(MAKEVIEW       macht aus BLK und der Nummer des geladenen Files
    LOADFILE eine 16-Bit Zahl, die von CREATE dann als Viewfeld 
    hinterlegt wird.                                            
(VIEW           zerlegt den Inhalt BLK eines Viewfeldes in      
    Filenummer und Blocknummer BLK' . Der zur Filenummer        
    geh�rende FCB wird gesucht, und falls gefunden, in ISFILE   
    und FROMFILE eingetragen. Kann kein FCB gefunden werden,    
    so wird eine Fehlermeldung ausgegeben.                      
                                                                
                                                                
                                                                
\ *** Block No. 70 Hexblock 46 
                                                       bp 4oct86
                                                                
REMOVE?         DIC (SYMB) ist die Adresse im Dictionary (HEAP),
   oberhalb (unterhalb, der Heap w�chst von oben nach unten !)  
   derer alle Worte vergessen werden m�ssen. F gibt an, ob      
   ADDR innerhalb des zu vergessenden Intervalls liegt.         
                                                                
REMOVE-FILES    guckt nach, ob ISFILE oder FROMFILE vergessen   
   werden. Ist das der Fall, so werden sie auf den Direktzugriff
   umgeschaltet.                                                
   Anschlie�end werden alle zu vergessenden Files geschlossen   
   und aus der Liste aller Files FILE-LINK entfernt.            
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 71 Hexblock 47 
                                                       bp 4oct86
                                                                
TOGGLEFILES     vertauscht ISFILE und FROMFILE.                 
                                                                
                                                                
CONVEY          pr�ft, ob die zu bewegenden Bl�cke vorhanden    
   sind und bewegt sie ggf.                                     
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 72 Hexblock 48 
                                                       13oct86we
                                                                
.BLOCKS         listet den Inhalt der Blockpuffer auf.          
   Angegeben werden Adresse, Blocknummer und Filename sowie,    
   ob der Block geUPDATEd wurde.                                
                                                                
Bei der Entwicklung des Fileinterfaces war das ein n�tzliches   
   Hilfsmittel.                                                 
                                                                
                                                                
Dieser und der n�chste Screen werden normalerweise vom Load-    
 screen nicht mitkompiliert.                                    
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 73 Hexblock 49 
                                                       13oct86we
                                                                
                                                                
                                                                
                                                                
                                                                
Mit BLOCKS>FILE l��t sich eine Folge von Diskettenbl�cken in    
 einem File ablegen. Damit k�nnen Disketten, die bisher im      
 Direktzugriff benutzt worden sind, auf das Fileinterface um-   
 gestellt werden.                                               
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
