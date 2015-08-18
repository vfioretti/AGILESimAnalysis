pro plot_histostyle_vale, x, y, err_y, color=color, linestyle = linestyle, line_thick = line_thick, err_thick = err_thick, err_color = err_color

bin = x(1) - x(0)
;x = [x(0)-bin/2., x + bin/2.]

;oplot, [x,x[n_elements(x)-1]+bin/2.], $
;        [y[0],y,y[n_elements(y)-1]], psym = 10, thick = line_thick, color =color
oplot, x,y, psym = 10, thick = line_thick, color =color
;oploterror, x[1:*], y, err_y, $
;       psym = 3, thick = err_thick, errcolor = err_color

end

pro plot_histostyle_romano, x, y, err_y, color=color, linestyle = linestyle, line_thick = line_thick, err_thick = err_thick, err_color = err_color

  bin = x(1) - x(0)
  ;x = [x(0)-bin/2., x + bin/2.]
  x = [x(0)-bin, x-bin/2.]
  y = [y(0), y]
oplot, x,y, psym = 10, thick = line_thick, color =color

;  oplot, [x,x[n_elements(x)-1]+bin/2.], $
;         [y[0],y,y[n_elements(y)-1]], psym = 10, thick = line_thick, color =color

end

pro plot_cluster_agile


; Variables initialization
N_in = 0            ;--> Number of emitted photons

; Geometry:
N_tray = 13l
N_layer = 2l
N_strip = 3072l


agile_version = ''
ene_type = 0
theta_type = 0
phi_type = 0
source_g = 0

read, agile_version, PROMPT='% - Enter AGILE release (e.g. V1.4):'
read, N_in, PROMPT='% - Enter the number of emitted photons:'
read, ene_type, PROMPT='% - Enter energy:'
read, theta_type, PROMPT='% - Enter theta:'
read, phi_type, PROMPT='% - Enter phi:'
read, source_g, PROMPT='% - Enter source geometry [0 = Point, 1 = Plane]:'

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


filepath = '/home/fioretti/GAMMA400/KALMAN/AGILE'+agile_version+'/DIGI'

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


filename = filepath+'/L0.5.DIGI.AGILE'+agile_version+'.TRACKER.'+strmid(strtrim(string(N_in),1),0,10)+'PH.'+strmid(strtrim(string(ene_type),1),0,10)+'MEV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.FITS'
struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'agilev14_cluster', $
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
      
      strip_start = 0
      for l=0l, n_elements(Strip_id_layer_temp)-1 do begin
       if (l LT (n_elements(Strip_id_layer_temp)-1)) then begin
         if (Strip_id_layer_temp(l+1) NE (Strip_id_layer_temp(l)-2)) then begin
           event_clt = [event_clt, event_id(j)]
           tray_clt = [tray_clt, tray_id_temp(k)]
           Si_id_clt = [Si_id_clt, Si_id_tray_temp(r)]
           N_strip_clt = [N_strip_clt, (l+1) - strip_start]
           energy_dep_layer_temp_clt = energy_dep_layer_temp[strip_start:l]
           max_ene_clt = [max_ene_clt, max(energy_dep_layer_temp_clt)]
           strip_start = l+1
         endif        
       endif else begin
           event_clt = [event_clt, event_id(j)]
           tray_clt = [tray_clt, tray_id_temp(k)]
           Si_id_clt = [Si_id_clt, Si_id_tray_temp(r)]
           N_strip_clt = [N_strip_clt, (l+1) - strip_start]
           energy_dep_layer_temp_clt = energy_dep_layer_temp[strip_start:l]
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


MWRFITS, CLTAGILE2, 'CLUSTER.AGILE'+agile_version+'.TRACKER.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'PH.'+STRMID(STRTRIM(STRING(ENE_TYPE),1),0,10)+'MEV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.FITS', HDR_CLT, /CREATE


;PLOTNAME='CLUSTER.AGILE'+agile_version+'.'+stripname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.ps'
if not keyword_set(nopsp) then begin
  PS_Start, /encapsulated, FILENAME='CLUSTER.AGILE'+agile_version+'.'+stripname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MEV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.eps', $
  FONT=0, CHARSIZE=1., nomatch=1, xsize=9., yoffset=9.6, ysize=7 
  bits_per_pixel=8
endif

RED   = [0, .5, 1, 0, 0, 1, 1, 0]
GREEN = [0, .5, 0, 1, 0, 1, 0, 1]
BLUE  = [0, 1., 0, 0, 1, 0, 1, 1]
TVLCT, 255 * RED, 255 * GREEN, 255 * BLUE

xt = 'Cluster (readout) strip number' 
yt = '' 
xr = [0, +10.]
yr = [1., 10000]

theta_letter = "161B
ge_letter = "263B

plot, [1], xtitle=xt, ytitle=yt, xrange=xr, yrange=yr, xstyle=1, ystyle=1,xmargin=[10,3], $
    xcharsize=1.2, ycharsize=1.2, charthick=2,title='AGILE'+agile_version+' - !9'+string(theta_letter)+'!X = '+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+' deg. - '+stripname+' - '+strmid(strtrim(string(ene_type),1),0,10)+' MeV', /nodata

path_bin=1
plothist, N_strip_clt, N_strip_clt_arr, N_strip, bin=path_bin, /noplot
plot_histostyle_romano, N_strip_clt_arr, N_strip, line_thick = 7, color = 2


PS_End, /PNG

PS_Start, /encapsulated, FILENAME='PULL.AGILE'+agile_version+'.'+stripname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MEV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.eps', $
FONT=0, CHARSIZE=1., nomatch=1, xsize=9., yoffset=9.6, ysize=7 
bits_per_pixel=8

RED   = [0, .5, 1, 0, 0, 1, 1, 0]
GREEN = [0, .5, 0, 1, 0, 1, 0, 1]
BLUE  = [0, 1., 0, 0, 1, 0, 1, 1]
TVLCT, 255 * RED, 255 * GREEN, 255 * BLUE

xt = 'Max charge [keV]' 
yt = '' 
xr = [0, 500.]
yr = [1., 400]

theta_letter = "161B
ge_letter = "263B

plot, [1], xtitle=xt, ytitle=yt, xrange=xr, yrange=yr, xstyle=1, ystyle=1,xmargin=[10,3], $
    xcharsize=1.2, ycharsize=1.2, charthick=2,title='AGILE'+agile_version+' - !9'+string(theta_letter)+'!X = '+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+' deg. - '+stripname+' - '+strmid(strtrim(string(ene_type),1),0,10)+' MeV', /nodata

;max_ene_clt_perc = 100.*(max_ene_clt/(ene_type*1000.))

path_bin=2
;plothist, max_ene_clt_perc, max_ene_clt_perc_arr, N_max, bin=path_bin, /noplot
;plot_histostyle_romano, max_ene_clt_perc_arr, N_max, line_thick = 7, color = 4


plothist, max_ene_clt, max_ene_clt_arr, N_max, bin=path_bin, /noplot
plot_histostyle_romano, max_ene_clt_arr, N_max, line_thick = 7, color = 4

PS_End, /PNG

end

