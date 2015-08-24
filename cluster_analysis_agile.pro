pro cluster_analysis_agile


; Geometry:
N_tray = 13l
N_layer = 2l
N_strip = 3072l

; Variables initialization
N_in = 0UL            ;--> Number of emitted photons

agile_version = ''
sim_type = 0
py_list = 0
ene_range = 0
ene_type = 0
ene_min = 0
ene_max = 0
theta_type = 0
phi_type = 0
source_g = 0
ene_min = 0
ene_max = 0

read, agile_version, PROMPT='% - Enter AGILE release (e.g. V1.4):'
read, sim_type, PROMPT='% - Enter simulation type [0 = Mono, 1 = Chen, 2: Vela, 3: Crab, 4: G400, 5 = SS]:'
read, py_list, PROMPT='% - Enter the Physics List [0 = QGSP_BERT_EMV, 100 = ARGO, 300 = FERMI, 400 = ASTROMEV]:'
read, N_in, PROMPT='% - Enter the number of emitted photons:'
read, ene_range, PROMPT='% - Enter energy distribution [0 = mono, 1 = range]:'
if (ene_range EQ 0) then begin
  read, ene_type, PROMPT='% - Enter energy [MeV]:'
  ene_type = strtrim(string(ene_type),1)
endif
if (ene_range EQ 1) then begin
    read, ene_min, PROMPT='% - Enter miminum energy [MeV]:' 
    read, ene_max, PROMPT='% - Enter maximum energy [MeV]:'
    ene_type = strtrim(string(ene_min),1)+'.'+strtrim(string(ene_max),1)
endif
read, theta_type, PROMPT='% - Enter theta:'
read, phi_type, PROMPT='% - Enter phi:'
read, source_g, PROMPT='% - Enter source geometry [0 = Point, 1 = Plane]:'

if (py_list EQ 0) then begin
   py_dir = 'QGSP_BERT_EMV'
   py_name = 'QGSP_BERT_EMV'
endif
if (py_list EQ 100) then begin
   py_dir = '100List'
   py_name = '100List'
endif
if (py_list EQ 300) then begin
   py_dir = '300List'
   py_name = '300List'
endif
if (py_list EQ 400) then begin
   py_dir = 'ASTROMEV'
   py_name = 'ASTROMEV'
endif

if (sim_type EQ 0) then begin
   sim_name = 'MONO'
endif
if (sim_type EQ 1) then begin
   sim_name = 'CHEN'
endif
if (sim_type EQ 2) then begin
   sim_name = 'VELA'
endif
if (sim_type EQ 3) then begin
   sim_name = 'CRAB'
endif
if (sim_type EQ 4) then begin
   sim_name = 'G400'
endif
if (sim_type EQ 5) then begin
   sim_name = 'SS'
endif

if (source_g EQ 0) then begin
 sdir = '/Point'
 sname = 'Point'
endif
if (source_g EQ 1) then begin
 sdir = '/Plane'
 sname = 'Plane'
endif

read, isStrip, PROMPT='% - Strip activated?:'
read, repli, PROMPT='% - Strips replicated?:'

if (isStrip EQ 0) then stripDir = 'NoStrip/'
if ((isStrip EQ 1) AND (repli EQ 0)) then stripDir = 'StripNoRepli/'
if ((isStrip EQ 1) AND (repli EQ 1)) then stripDir = 'StripRepli/'

if (isStrip EQ 0) then stripname = 'NOSTRIP'
if ((isStrip EQ 1) AND (repli EQ 0)) then stripname = 'STRIP'
if ((isStrip EQ 1) AND (repli EQ 1)) then stripname = 'STRIP.REPLI/'



run_path = GETENV('BGRUNS')

filepath = './AGILE'+agile_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+'/'+sim_name+'/'+ene_type+'MeV/'+strtrim(string(N_in),1)+'ph/'
print, 'LEVEL0 file path: ', filepath

event_id = -1l
vol_id = -1l
moth_id = -1l
tray_id = -1l
Si_id = -1l
Strip_id = -1l
strip_type = -1l
pos = -1.
zpos = -1.
energy_dep = -1.


filename = filepath+'L0.5.DIGI.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+ene_type+'MeV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.all.fits'

struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'agilev2_cluster', $
                     /unsigned)
                     
for k=0l, n_elements(struct)-1l do begin                 
        event_id = [event_id, struct(k).EVT_ID] 
        vol_id = [vol_id, struct(k).VOLUME_ID] 
        moth_id = [moth_id, struct(k).MOTHER_ID] 
        tray_id = [tray_id, struct(k).TRAY_ID] 
        Si_id = [Si_id, struct(k).TRK_FLAG] 
        strip_id = [strip_id, struct(k).STRIP_ID] 
        strip_type = [strip_type, struct(k).STRIP_TYPE] 
        pos = [pos, struct(k).POS] 
        zpos = [zpos, struct(k).ZPOS] 
        energy_dep = [energy_dep, struct(k).E_DEP] 

endfor

if (n_elements(event_id) GT 1) then begin
 event_id = event_id[1:*]
 vol_id = vol_id[1:*]
 moth_id = moth_id[1:*]
 tray_id = tray_id[1:*]
 Si_id = Si_id[1:*]
 Strip_id = Strip_id[1:*]
 Strip_type = Strip_type[1:*]
 pos = pos[1:*]
 zpos = zpos[1:*]
 energy_dep = energy_dep[1:*]
endif

event_clt = -1l
tray_clt = -1l
Si_id_clt = -1l
N_strip_clt = -1l
max_ene_clt = -1.

j=0l
while (1) do begin
    where_event_eq = where(event_id EQ event_id(j))
    
    vol_id_temp = vol_id(where_event_eq)
    moth_id_temp = moth_id(where_event_eq)
    tray_id_temp  = tray_id(where_event_eq)
    Si_id_temp = Si_id(where_event_eq)
    Strip_id_temp = Strip_id(where_event_eq)
    Strip_type_temp = Strip_type(where_event_eq)
    pos_temp = pos(where_event_eq)
    zpos_temp = zpos(where_event_eq)
    energy_dep_temp = energy_dep(where_event_eq)    

    k=0l
    while (1) do begin
     where_tray_eq = where(tray_id_temp EQ tray_id_temp(k))
     
     vol_id_tray_temp = vol_id_temp(where_tray_eq)
     moth_id_tray_temp = moth_id_temp(where_tray_eq)
     Si_id_tray_temp = Si_id_temp(where_tray_eq)
     Strip_id_tray_temp = Strip_id_temp(where_tray_eq)
     Strip_type_tray_temp = Strip_type_temp(where_tray_eq)
     pos_tray_temp = pos_temp(where_tray_eq)
     zpos_tray_temp = zpos_temp(where_tray_eq)
     energy_dep_tray_temp = energy_dep_temp(where_tray_eq)    
 
     r=0l
     while (1) do begin
      where_layer_eq = where(Si_id_tray_temp EQ Si_id_tray_temp(r))
      
      vol_id_layer_temp = vol_id_tray_temp(where_layer_eq)
      moth_layer_id_temp = moth_id_tray_temp(where_layer_eq)
      Strip_id_layer_temp = Strip_id_tray_temp(where_layer_eq)
      Strip_type_layer_temp = Strip_type_tray_temp(where_layer_eq)
      pos_layer_temp = pos_tray_temp(where_layer_eq)
      zpos_layer_temp = zpos_tray_temp(where_layer_eq)
      energy_dep_layer_temp = energy_dep_tray_temp(where_layer_eq)    
 
      sort_strip_descending = reverse(bsort(Strip_id_layer_temp))
      vol_id_layer_temp_ordered = vol_id_layer_temp[sort_strip_descending]
      moth_layer_id_temp_ordered = moth_layer_id_temp[sort_strip_descending]
      Strip_id_layer_temp_ordered = Strip_id_layer_temp[sort_strip_descending]
      Strip_type_layer_temp_ordered = Strip_type_layer_temp[sort_strip_descending]
      pos_layer_temp_ordered = pos_layer_temp[sort_strip_descending]
      zpos_layer_temp_ordered = zpos_layer_temp[sort_strip_descending]
      energy_dep_layer_temp_ordered = energy_dep_layer_temp[sort_strip_descending]
      
      strip_start = 0
      for l=0l, n_elements(Strip_id_layer_temp_ordered)-1 do begin
       if (l LT (n_elements(Strip_id_layer_temp_ordered)-1)) then begin
         if (Strip_id_layer_temp_ordered(l+1) NE (Strip_id_layer_temp_ordered(l)-2)) then begin
           event_clt = [event_clt, event_id(j)]
           tray_clt = [tray_clt, tray_id_temp(k)]
           Si_id_clt = [Si_id_clt, Si_id_tray_temp(r)]
           N_strip_clt = [N_strip_clt, (l+1) - strip_start]
           energy_dep_layer_temp_clt = energy_dep_layer_temp_ordered[strip_start:l]
           max_ene_clt = [max_ene_clt, max(energy_dep_layer_temp_clt)]
           strip_start = l+1
         endif
       endif else begin
           event_clt = [event_clt, event_id(j)]
           tray_clt = [tray_clt, tray_id_temp(k)]
           Si_id_clt = [Si_id_clt, Si_id_tray_temp(r)]
           N_strip_clt = [N_strip_clt, (l+1) - strip_start]
           energy_dep_layer_temp_clt = energy_dep_layer_temp_ordered[strip_start:l]
           max_ene_clt = [max_ene_clt, max(energy_dep_layer_temp_clt)]
       endelse
      endfor

      N_layer_eq = n_elements(where_layer_eq)
      if where_layer_eq(N_layer_eq-1) LT (n_elements(Si_id_tray_temp)-1) then begin
        r = where_layer_eq(N_layer_eq-1)+1
      endif else break

     endwhile
     
     N_tray_eq = n_elements(where_tray_eq)
     if where_tray_eq(N_tray_eq-1) LT (n_elements(tray_id_temp)-1) then begin
       k = where_tray_eq(N_tray_eq-1)+1
     endif else break
    endwhile

    N_event_eq = n_elements(where_event_eq)
    if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
      j = where_event_eq(N_event_eq-1)+1
    endif else break
endwhile

event_clt = event_clt[1:*]
tray_clt = tray_clt[1:*]
Si_id_clt = Si_id_clt[1:*]
N_strip_clt = N_strip_clt[1:*]
max_ene_clt = max_ene_clt[1:*]

CREATE_STRUCT, CLTAGILE2, 'AGILECLT2', ['EVT_ID', 'TRAY_ID','TRK_FLAG', 'N_STRIP', 'E_MAX'], 'J,J,J,J,F20.5', DIMEN = N_ELEMENTS(event_clt)
CLTAGILE2.EVT_ID = event_clt
CLTAGILE2.TRAY_ID = tray_clt
CLTAGILE2.TRK_FLAG = Si_id_clt
CLTAGILE2.N_STRIP = N_strip_clt
CLTAGILE2.E_MAX = max_ene_clt

HDR_CLT = ['Creator          = Valentina Fioretti', $
          'BoGEMMS release  = AGILE '+agile_version, $
          'N_IN             = '+STRTRIM(STRING(N_IN),1)+'   /Number of simulated particles', $
          'ENERGY           = '+STRTRIM(STRING(ENE_TYPE),1)+'   /Simulated input energy', $
          'THETA            = '+STRTRIM(STRING(THETA_TYPE),1)+'   /Simulated input theta angle', $
          'PHI              = '+STRTRIM(STRING(PHI_TYPE),1)+'   /Simulated input phi angle', $
          'ENERGY UNIT      = KEV']


MWRFITS, CLTAGILE2, filepath+'CLUSTER.AGILE'+agile_version+'.TRACKER.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'PH.'+STRMID(STRTRIM(STRING(ENE_TYPE),1),0,10)+'MEV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.FITS', HDR_CLT, /CREATE



end

