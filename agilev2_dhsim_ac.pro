pro AGILEV2_DHSim_AC


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
                     structyp = 'agile2_ac', $
                     /unsigned)

    for k=0l, n_elements(struct)-1l do begin                 
     if ((struct(k).VOLUME_ID GE 301) AND (struct(k).VOLUME_ID LE 350)) then begin
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
print, '                  Summing the energy                '
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

N_trig = 0l

event_id_tot = -1l
vol_id_tot = -1l
moth_id_tot = -1l
energy_dep_tot = -1.

j=0l
while (1) do begin
    where_event_eq = where(event_id EQ event_id(j))
    
    N_trig = N_trig + 1
    
    vol_id_temp = vol_id(where_event_eq) 
    moth_id_temp = moth_id(where_event_eq) 
    energy_dep_temp = energy_dep(where_event_eq) 
        
    r = 0l
    while(1) do begin
       where_vol_eq = where(vol_id_temp EQ vol_id_temp(r), complement = where_other_vol)
       event_id_tot = [event_id_tot, event_id(j)]
       vol_id_tot = [vol_id_tot, vol_id_temp(r)]
       moth_id_tot = [moth_id_tot, moth_id_temp(r)]
       energy_dep_tot = [energy_dep_tot, total(energy_dep_temp(where_vol_eq))]
       if (where_other_vol(0) NE -1) then begin
         vol_id_temp = vol_id_temp(where_other_vol)
         moth_id_temp = moth_id_temp(where_other_vol)
         energy_dep_temp = energy_dep_temp(where_other_vol)
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
  energy_dep_tot = energy_dep_tot[1:*]
endif

; AC panel IDs

AC_panel = strarr(n_elements(vol_id_tot))
AC_subpanel = intarr(n_elements(vol_id_tot))

for j=0l, n_elements(vol_id_tot)-1 do begin
 if ((vol_id_tot(j) GE 301) AND (vol_id_tot(j) LE 303)) then begin
    AC_panel(j) = 'S'
    if (vol_id_tot(j) EQ 301) then AC_subpanel(j) = 3
    if (vol_id_tot(j) EQ 302) then AC_subpanel(j) = 2
    if (vol_id_tot(j) EQ 303) then AC_subpanel(j) = 1
 endif
 if ((vol_id_tot(j) GE 311) AND (vol_id_tot(j) LE 313)) then begin
    AC_panel(j) = 'D'
    if (vol_id_tot(j) EQ 311) then AC_subpanel(j) = 3
    if (vol_id_tot(j) EQ 312) then AC_subpanel(j) = 2
    if (vol_id_tot(j) EQ 313) then AC_subpanel(j) = 1
 endif
 if ((vol_id_tot(j) GE 321) AND (vol_id_tot(j) LE 323)) then begin
    AC_panel(j) = 'F'
    if (vol_id_tot(j) EQ 321) then AC_subpanel(j) = 1
    if (vol_id_tot(j) EQ 322) then AC_subpanel(j) = 2
    if (vol_id_tot(j) EQ 323) then AC_subpanel(j) = 3
 endif
 if ((vol_id_tot(j) GE 331) AND (vol_id_tot(j) LE 333)) then begin
    AC_panel(j) = 'B'
    if (vol_id_tot(j) EQ 331) then AC_subpanel(j) = 1
    if (vol_id_tot(j) EQ 332) then AC_subpanel(j) = 2
    if (vol_id_tot(j) EQ 333) then AC_subpanel(j) = 3
 endif
 if (vol_id_tot(j) EQ 340) then begin
    AC_panel(j) = 'T'
    AC_subpanel(j) = 0
 endif
endfor

CREATE_STRUCT, acInput, 'input_ac_dhsim', ['EVT_ID', 'AC_PANEL', 'AC_SUBPANEL', 'E_DEP'], $
'I,A,I,F20.15', DIMEN = n_elements(event_id_tot)
acInput.EVT_ID = event_id_tot
acInput.AC_PANEL = AC_panel
acInput.AC_SUBPANEL = AC_subpanel
acInput.E_DEP = energy_dep_tot


hdr_acInput = ['COMMENT  AGILE V2.0 Geant4 simulation', $
               'N_in     = '+strtrim(string(N_in),1), $
               'Energy     = '+strtrim(string(ene_type),1), $
               'Theta     = '+strtrim(string(theta_type),1), $
               'Phi     = '+strtrim(string(phi_type),1), $
               'Energy unit = GeV']

MWRFITS, acInput, 'G4.AGILE'+agile_version+'.AC.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.fits', hdr_acInput, /create



openw,lun,'G4_GAMS_AGILE'+agile_version+'_AC_'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.dat',/get_lun

gams_AC_panel = AC_panel
;gams_AC_panel = strarr(n_elements(AC_panel))
;for jac=0, n_elements(event_id_tot)-1 do begin
;    if (AC_panel(jac) EQ 'S') then gams_AC_panel(jac) = 'B'
;    if (AC_panel(jac) EQ 'F') then gams_AC_panel(jac) = 'S'
;    if (AC_panel(jac) EQ 'D') then gams_AC_panel(jac) = 'F'
;    if (AC_panel(jac) EQ 'B') then gams_AC_panel(jac) = 'D'    
;    if (AC_panel(jac) EQ 'T') then gams_AC_panel(jac) = 'T'    
;endfor

j=0l
while (1) do begin
    printf, lun, (event_id_tot(j)+1), gams_AC_panel(j), AC_subpanel(j), energy_dep_tot(j), format='(I,5x,A,I,F20.15)'

    if (j LT (n_elements(event_id_tot)-1)) then begin
      j = j+1
    endif else break
endwhile

Free_lun, lun
end
