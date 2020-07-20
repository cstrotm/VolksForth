\ *** Block No. 0 Hexblock 0 
\\                                                     26oct86we
                                                                
Diese File enth�lt Worte, mit denen die Speicheraufteilung      
des volksFORTH ver�ndert werden kann.                           
                                                                
RELOCATE  setzt  R0  und  S0  neu, beachten Sie dazu auch die   
Ausf�hrungen im Handbuch.                                       
                                                                
Mit  BUFFERS  kann man die Anzahl der Diskbuffer ver�ndern.     
Standardm��ig ist das System auf &10 Buffer eingestellt. Reicht 
der Platz im Dictionary bei sehr gro�en Programmen nicht aus,   
kann man hier am ehesten Speicherplatz einsparen.               
Umgekehrt erh�ht sich der Arbeitskomfort beim Editieren, wenn   
m�glichst viele Diskbuffer vorhanden sind, um Diskettenzugriffe 
zu minimieren.                                                  
                                                                
\ *** Block No. 1 Hexblock 1 
\ Relocate a system                                    26oct86we
                                                                
| : relocate-tasks   ( mainup -- )    up@ dup                   
     BEGIN  2+ under @  2dup - WHILE  rot drop  REPEAT  2drop ! 
     up@ 2+ @  origin 2+ ! ;                                    
                                                                
: relocate   ( stacklen rstacklen -- )                          
   2dup +   limit origin -   b/buf -   2-                       
       u> abort" kills all buffers"                             
   over  pad $100 +  origin - u< abort" cuts the dictionary"    
   dup  udp @ $40 +                                             
       u< abort" kills returnstack"                             
   flush  empty  over +  origin +  origin &12 + !    \ r0       
   origin +  dup  relocate-tasks                 \ multitasking 
   6 -  origin &10 + !                               \ s0       
   cold ;                                          -->          
\ *** Block No. 2 Hexblock 2 
\ bytes.more  buffers                                  15sep86we
                                                                
| : bytes.more   ( n+-  -- )                                    
     up@  origin -  +  r0 @ up@ -  relocate ;                   
                                                                
: buffers      ( +n   -- )                                      
    b/buf *  4+  limit  r0 @ -  swap  -  bytes.more ;           
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
