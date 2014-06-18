pro AGILEV2_DHSim_CAL


; Variables initialization
N_in = 0            ;--> Number of emitted photons
n_fits = 0           ;--> Number of FITS files produced by the simulation

agile_version = ''
py_list = 0
ene_type = 0
theta_type = 0
phi_type = 0
X_type = 0
source_g = 0

read, agile_version, PROMPT='% - Enter AGILE release (e.g. V1.4):'
read, py_list, PROMPT='% - Enter the Physics List [100 = ARGO, 300 = FERMI]:'
read, N_in, PROMPT='% - Enter the number of emitted photons:'
read, n_fits, PROMPT='% - Enter number of FITS files:'
read, ene_type, PROMPT='% - Enter energy:'
read, theta_type, PROMPT='% - Enter theta:'
read, phi_type, PROMPT='% - Enter phi:'
read, source_g, PROMPT='% - Enter source geometry [0 = Point, 1 = Plane]:'

if (py_list EQ 100) then begin
   py_dir = '/100List'
   py_name = '100List'
endif
if (py_list EQ 300) then begin
   py_dir = '/300List'
   py_name = '300List'
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

filepath = '/dischi/sx01/data1/fioretti/geant4/bin/Linux-g++/BOGEMS/ST/AGILE/Point/theta'+strtrim(string(theta_type),1)+'/AGILE_'+agile_version+py_dir+'/'+stripDir+''+strtrim(string(ene_type),1)+'MeV.'+strtrim(string(theta_type),1)+'theta.'+strtrim(string(N_in),1)+'ph'
print, filepath

event_id = -1l
vol_id = -1l
moth_id = -1l
energy_dep = -1.

ent_x = -1.
ent_y = -1.
ent_z = -1.
exit_x = -1.
exit_y = -1.
exit_z = -1.

theta_ent = -1.
phi_ent = -1.

theta_exit = -1.
phi_exit = -1.

  for i=0, n_fits-1 do begin
    print, 'Reading the FITS file.....', i+1


    filename = filepath+'/xyz.'+strtrim(string(i), 1)+'.fits.gz'
    struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'agile2_cal', $
                     /unsigned)

    for k=0l, n_elements(struct)-1l do begin                 
     if ((struct(k).VOLUME_ID GE 50000) AND (struct(k).VOLUME_ID LE 60014)) then begin
      if (struct(k).E_DEP GT 0.d) then begin        
         event_id = [event_id, struct(k).EVT_ID] 
         vol_id = [vol_id, struct(k).VOLUME_ID] 
         if (isStrip EQ 1) then moth_id = [moth_id, struct(k).MOTHER_ID] else moth_id = [moth_id, 0]
         energy_dep = [energy_dep, struct(k).E_DEP] 
        
         ent_x = [ent_x, struct(k).X_ENT]  
         ent_y = [ent_y, struct(k).Y_ENT]  
         ent_z = [ent_z, struct(k).Z_ENT]  
         exit_x = [exit_x, struct(k).X_EXIT]  
         exit_y = [exit_y, struct(k).Y_EXIT]  
         exit_z = [exit_z, struct(k).Z_EXIT]  
        
         theta_ent = [theta_ent, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
         phi_ent = [phi_ent, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

         theta_exit = [theta_exit, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
         phi_exit = [phi_exit, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]        
      endif
     endif
    endfor
  endfor

event_id = event_id[1:*]
vol_id = vol_id[1:*]
moth_id = moth_id[1:*]
energy_dep = (energy_dep[1:*])/1000000.

ent_x = (ent_x[1:*])/10.
ent_y = (ent_y[1:*])/10.
ent_z = (ent_z[1:*])/10.
exit_x = (exit_x[1:*])/10.
exit_y = (exit_y[1:*])/10.
exit_z = (exit_z[1:*])/10.

theta_ent = theta_ent[1:*]
phi_ent = phi_ent[1:*]

theta_exit = theta_exit[1:*]
phi_exit = phi_exit[1:*]

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '                  Energy attenuation                '
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

bar_plane = intarr(n_elements(event_id))
bar_id = intarr(n_elements(event_id))
ene_a = dblarr(n_elements(event_id))
ene_b = dblarr(n_elements(event_id))


att_a_x = [0.0281,0.0285,0.0281,0.0269,0.0238,0.0268,0.0274,0.0296,0.0272,0.0348,0.0276,0.0243, 0.0312,0.0287,0.0261]  
att_b_x = [0.0256,0.0286,0.0294,0.0259,0.0235,0.0264,0.0276,0.0295,0.0223,0.0352,0.0293,0.0256,0.0290,0.0289,0.0266]

att_a_y = [0.0298,0.0281,0.0278,0.0301,0.0296,0.0242,0.0300,0.0294,0.0228,0.0319,0.0290,0.0304,0.0274,0.0282,0.0267]
att_b_y = [0.0279,0.0254,0.0319,0.0260,0.0310,0.0253,0.0289,0.0268,0.0231,0.0319,0.0252,0.0242,0.0246,0.0258,0.0268]


bar_side = 37.3  ; cm
for j=0l, n_elements(event_id) - 1 do begin
 if ((vol_id(j)-50000) LT 20) then begin
     ; XBAR in the KALMAN system
     bar_plane(j) = 1
     bar_id(j) = (vol_id(j)-50000) + 1
     x_pos = ent_y(j) + ((exit_y(j) - ent_y(j))/2.)
     t_b = (bar_side/2.) + x_pos
     t_a = (bar_side/2.) - x_pos
     ene_a(j) = (energy_dep(j))*exp(-(att_a_x(bar_id(j)-1))*t_a)
     ene_b(j) = (energy_dep(j))*exp(-(att_b_x(bar_id(j)-1))*t_b)
 endif else begin
     ; YBAR in the KALMAN system
     bar_plane(j) = 2
     bar_id(j) = (vol_id(j)-60000) + 1
     y_pos = ent_x(j) + ((exit_x(j) - ent_x(j))/2.)
     t_a = (bar_side/2.) + y_pos
     t_b = (bar_side/2.) - y_pos
     ene_a(j) = (energy_dep(j))*exp(-(att_a_y(bar_id(j)-1))*t_a)
     ene_b(j) = (energy_dep(j))*exp(-(att_b_y(bar_id(j)-1))*t_b)
 endelse
endfor

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '                  Applying the minimum cut                '
print, '                  Summing the energy                '
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

N_trig = 0l

event_id_tot = -1l
vol_id_tot = -1l
moth_id_tot = -1l
bar_plane_tot = -1l
bar_id_tot = -1l
ene_a_tot = -1.
ene_b_tot = -1.

j=0l
while (1) do begin
    where_event_eq = where(event_id EQ event_id(j))
    
    N_trig = N_trig + 1
    
    vol_id_temp = vol_id(where_event_eq) 
    moth_id_temp = moth_id(where_event_eq) 
    bar_plane_temp = bar_plane(where_event_eq) 
    bar_id_temp = bar_id(where_event_eq) 
    ene_a_temp = ene_a(where_event_eq)
    ene_b_temp = ene_b(where_event_eq)
        
    r = 0l
    while(1) do begin
       where_vol_eq = where(vol_id_temp EQ vol_id_temp(r), complement = where_other_vol)
       event_id_tot = [event_id_tot, event_id(j)]
       vol_id_tot = [vol_id_tot, vol_id_temp(r)]
       moth_id_tot = [moth_id_tot, moth_id_temp(r)]
       bar_plane_tot = [bar_plane_tot, bar_plane_temp(r)]
       bar_id_tot = [bar_id_tot, bar_id_temp(r)]
       ene_a_tot = [ene_a_tot, total(ene_a_temp(where_vol_eq))]
       ene_b_tot = [ene_b_tot, total(ene_b_temp(where_vol_eq))]
       if (where_other_vol(0) NE -1) then begin
         vol_id_temp = vol_id_temp(where_other_vol)
         moth_id_temp = moth_id_temp(where_other_vol)
         bar_plane_temp = bar_plane_temp(where_other_vol)
         bar_id_temp = bar_id_temp(where_other_vol)
         ene_a_temp = ene_a_temp(where_other_vol)
         ene_b_temp = ene_b_temp(where_other_vol)
       endif else break
    endwhile
        
    N_event_eq = n_elements(where_event_eq)
    if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
      j = where_event_eq(N_event_eq-1)+1
    endif else break
endwhile


if (n_elements(event_id_tot) GT 1) then begin
  event_id_tot = event_id_tot[1:*]
  vol_id_tot = vol_id_tot[1:*]
  moth_id_tot = moth_id_tot[1:*]
  bar_plane_tot = bar_plane_tot[1:*]
  bar_id_tot = bar_id_tot[1:*]
  ene_a_tot = ene_a_tot[1:*]
  ene_b_tot = ene_b_tot[1:*]
endif



CREATE_STRUCT, calInput, 'input_cal_dhsim', ['EVT_ID', 'BAR_PLANE', 'BAR_ID', 'ENERGY_A', 'ENERGY_B'], $
'I,I,I,F20.15,F20.15', DIMEN = n_elements(event_id_tot)
calInput.EVT_ID = event_id_tot
calInput.BAR_PLANE = bar_plane_tot 
calInput.BAR_ID = bar_id_tot
calInput.ENERGY_A = ene_a_tot
calInput.ENERGY_B = ene_b_tot


hdr_calInput = ['COMMENT  AGILE V2.0 Geant4 simulation', $
               'N_in     = '+strtrim(string(N_in),1), $
               'Energy     = '+strtrim(string(ene_type),1), $
               'Theta     = '+strtrim(string(theta_type),1), $
               'Phi     = '+strtrim(string(phi_type),1), $
               'Energy unit = GeV']

MWRFITS, calInput, 'G4.AGILE'+agile_version+'.CAL.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.fits', hdr_calInput, /create

openw,lun,'G4_GAMS_AGILE'+agile_version+'_CAL_'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.dat',/get_lun


; Invert the BAR id to fit with the GAMS system
; BoGEMMS XBARv gives the inverted GAMS YBARk
; BoGEMMS YBARv gives the GAMS XBARk

n_bars = 15

gams_bar_plane_tot = intarr(n_elements(bar_plane_tot))
gams_bar_id_tot = intarr(n_elements(bar_id_tot))
for jcal=0, n_elements(event_id_tot)-1 do begin
    if (bar_plane_tot(jcal) EQ 1) then begin
       gams_bar_plane_tot(jcal) = 1
       ; bar id starts from 1
       gams_bar_id_tot(jcal) = bar_id_tot(jcal)
    endif
    if (bar_plane_tot(jcal) EQ 2) then begin
       gams_bar_plane_tot(jcal) = 2
       gams_bar_id_tot(jcal) = bar_id_tot(jcal)
    endif
endfor


j=0l
while (1) do begin
    printf, lun, (event_id_tot(j)+1), gams_bar_plane_tot(j), gams_bar_id_tot(j), 0, ene_a_tot(j),ene_b_tot(j), format='(I,I,I,I,F20.15,F20.15)'

    if (j LT (n_elements(event_id_tot)-1)) then begin
      j = j+1
    endif else break
endwhile

Free_lun, lun
end
