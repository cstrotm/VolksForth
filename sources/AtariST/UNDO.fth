\ *** Block No. 0 Hexblock 0 
\\ Undo for the VolksForth command line             cas2013apr05
                                                                
The tool extends the VolksForth "decode" function               
with an UNDO. If there was a typo in the previous line          
pressing the UNDO key will re-fetch the last entered line so    
that it can be edited                                           
                                                                
Published in VD 3/87 by Bernd Pennemann                         
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ Undo for Atari ST                                 cas2013apr05
Onlyforth                                                       
                                                                
| $6100 Constant #undo                                          
                                                                
: undoSTdecode ( addr pos1 key -- addr pos2 )                   
  over 0= if                                                    
    #undo case? if at? >r >r                                    
                   over #tib @  dup span ! type                 
                   r> r> at exit then then                      
  STdecode ;                                                    
                                                                
Input: keyboard  STkey STkey? undoSTdecode STexpect ;           
                                                                
keyboard save                                                   
                                                                
\ *** Block No. 2 Hexblock 2 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
