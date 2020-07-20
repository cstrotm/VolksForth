\ *** Block No. 0 Hexblock 0 
                                                      bp 19Jul86
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 1 Hexblock 1 
\ gem definition macros                                30oct86we
                                                                
Onlyforth                                                       
                                                                
here                                                            
    $600 hallot    heap dp !                                    
                                                                
    : #def      Constant immediate    Does>  @                  
                state @ IF  [compile] Literal  THEN ;           
                                                                
    : #defs         ( start no. -- )                            
          bounds  ?DO  I #def  LOOP ;                           
                                                                
    1 3 +thru                                                   
dp !                                                            
                                                                
\ *** Block No. 2 Hexblock 2 
\ window parts and messages                           bp 19Jul86
                                                                
\  ----   Window attributes for WIND_CREATE ----------------    
 $01 #def :name                  $02 #def :close                
 $04 #def :full                  $08 #def :move                 
 $10 #def :info                  $20 #def :size                 
 $40 #def :uparrow               $80 #def :dnarrow              
$100 #def :vslide               $200 #def :lfarrow              
$400 #def :rtarrow              $800 #def :hslide               
                                                                
\ ------ window attribute inquire flags for  WIND_GET ------    
1 &17 #defs                     :wf_kind        :wf_name        
:wf_info        :wf_workxywh    :wf_currxywh    :wf_prevxywh    
:wf_fullxywh    :wf_hslide      :wf_vslide      :wf_top         
:wf_firstxywh   :wf_nextxywh    :wf_resvd       :wf_newdesk     
:wf_hslize      :wf_vslize      :wf_screen                      
\ *** Block No. 3 Hexblock 3 
\ messages and events                                 bp 19Jul86
                                                                
\ -----   WIND_CALC flags   --------------------------------    
0 #def wc_border:               1 #def wc_work:                 
                                                                
\ -------  Messages, send by Message event :  --------------    
&10 #def :mn_selected                                           
                                                                
&20 &10 #defs                                                   
:wm_redraw      :wm_topped      :wm_closed      :wm_fulled      
:wm_arrowed     :wm_hslid       :wm_vslid       :wm_sized       
:wm_moved       :wm_newtop                                      
                                                                
                                                                
                                                                
                                                                
\ *** Block No. 4 Hexblock 4 
\ misc.                                               bp 19Jul86
                                                                
\ ---------   MULTI_EVENT flags  -------------------------      
$01 #def :mu_keybd              $02 #def :mu_button             
$04 #def :mu_m1                 $08 #def :mu_m2                 
$10 #def :mu_mesag              $20 #def :mu_timer              
                                                                
\ ---------  Form Manager definitions  -------------------      
0 4 #defs                                                       
:fmd_start      :fmd_grow       :fmd_shrink     :fmd_finish     
                                                                
\ ---------  Mouse forms  --------------------------------      
0 8 #defs                                                       
:arrow          :text_crsr      :honey_bee      :point_hand     
:flat_hand      :thin_cross     :thick_cross    :outln_cross    
&255 3 #defs    :user_def       :m_off          :m_on           
\ *** Block No. 5 Hexblock 5 
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
