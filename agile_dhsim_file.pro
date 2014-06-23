; agile_dhsim_file.pro - Description
; ---------------------------------------------------------------------------------
; Processing the BoGEMMS AGILE simulation:
; - Tracker
; - AC
; - Calorimeter
; ---------------------------------------------------------------------------------
; Output:
; - all files are created in a self-descripted subdirectory of the current directory. If teh directory is not present it is created by the IDL script.
; ---------> ASCII files
; - G4_GAMS_XPLANE_AGILE<version>_<phys>List_<strip>_<point>_<n_in>ph_<energy>MeV_<theta>_<phi>.<file>.dat
; - G4_GAMS_YPLANE_AGILE<version>_<phys>List_<strip>_<point>_<n_in>ph_<energy>MeV_<theta>_<phi>.<file>.dat
; - G4_GAMS_AC_AGILE<version>_<phys>List_<strip>_<point>_<n_in>ph_<energy>MeV_<theta>_<phi>.<file>.dat
; - G4_GAMS_CAL_AGILE<version>_<phys>List_<strip>_<point>_<n_in>ph_<energy>MeV_<theta>_<phi>.<file>.dat
; - G4.DIGI.GENERAL.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.dat
; - G4.DIGI.KALMAN.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.dat
; - G4.RAW.GENERAL.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.dat
; - G4.RAW.KALMAN.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.dat
; ---------> FITS files
; - G4.RAW.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - L0.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - L0.5.DIGI.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - G4.AC.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - G4.CAL.AGILE<version>.<phys>List.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits 
; ---------------------------------------------------------------------------------
; copyright            : (C) 2013 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; agile_dhsim_file
; ---------------------------------------------------------------------------------
; Notes:
; Each BoGEMMS FITS files individually processed


pro agile_dhsim_file


; Variables initialization
N_in = 0            ;--> Number of emitted photons
n_fits = 0           ;--> Number of FITS files produced by the simulation

agile_version = ''
sim_type = 0
py_list = 0
ene_type = 0
theta_type = 0
phi_type = 0
source_g = 0

read, agile_version, PROMPT='% - Enter AGILE release (e.g. V1.4):'
read, sim_type, PROMPT='% - Enter simulation type [0 = general, 1 = Chen, 2: Vela, 3: Crab]:'
read, py_list, PROMPT='% - Enter the Physics List [0 = QGSP_BERT_EMV, 100 = ARGO, 300 = FERMI]:'
read, N_in, PROMPT='% - Enter the number of emitted photons:'
read, n_fits, PROMPT='% - Enter number of FITS files:'
read, ene_type, PROMPT='% - Enter energy:'
read, theta_type, PROMPT='% - Enter theta:'
read, phi_type, PROMPT='% - Enter phi:'
read, source_g, PROMPT='% - Enter source geometry [0 = Point, 1 = Plane]:'

if (py_list EQ 0) then begin
   py_dir = 'QGSP_BERT_EMV'
   py_name = 'QGSP_BERT_EMV'
endif
if (py_list EQ 100) then begin
   py_dir = '/100List'
   py_name = '100List'
endif
if (py_list EQ 300) then begin
   py_dir = '/300List'
   py_name = '300List'
endif

if (sim_type EQ 0) then begin
   sim_name = ''
endif
if (sim_type EQ 1) then begin
   sim_name = 'CHEN'
endif
if (sim_type EQ 2) then begin
   sim_name = 'Vela'
endif
if (sim_type EQ 2) then begin
   sim_name = 'Crab'
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

; setting specific agile version variables 
if (agile_version EQ 'V2.0') then begin
    ; --------> volume ID
    tracker_vol_start = 1000000
    tracker_y_vol_start = 1090000
    tracker_x_y_diff = 90000
    cal_vol_start = 50000
    cal_vol_end = 60014
    cal_vol_y_start = 60000
    ac_vol_start = 301
    ac_vol_end = 350
 
    panel_S = [301, 302, 303]
    panel_D = [311, 312, 313]
    panel_F = [321, 322, 323]
    panel_B = [331, 332, 333]
    panel_top = 340
        
    ; --------> design
    N_tray = 13l
    N_plane = N_tray - 1
    N_layer = 2l
    N_strip = 3072l

    bar_side = 37.3  ; cm  (side of calorimeter bars)
    n_bars = 15  ; number of calorimeter bars for each plane
    ; --------> processing
    ; accoppiamento capacitivo
    acap = [0.035, 0.045, 0.095, 0.115, 0.38, 1., 0.38, 0.115, 0.095, 0.045, 0.035]  
    ; tracker energy threshold (0.25 MIP)
    E_th = 27.   ; keV 
  
    ; calorimeter bar attenuation for diods A and B
    att_a_x = [0.0281,0.0285,0.0281,0.0269,0.0238,0.0268,0.0274,0.0296,0.0272,0.0348,0.0276,0.0243, 0.0312,0.0287,0.0261]  
    att_b_x = [0.0256,0.0286,0.0294,0.0259,0.0235,0.0264,0.0276,0.0295,0.0223,0.0352,0.0293,0.0256,0.0290,0.0289,0.0266]    
    att_a_y = [0.0298,0.0281,0.0278,0.0301,0.0296,0.0242,0.0300,0.0294,0.0228,0.0319,0.0290,0.0304,0.0274,0.0282,0.0267]
    att_b_y = [0.0279,0.0254,0.0319,0.0260,0.0310,0.0253,0.0289,0.0268,0.0231,0.0319,0.0252,0.0242,0.0246,0.0258,0.0268]
    
endif 

filepath = '/Users/fioretti/data/BoGEMMS/AGILE'+agile_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+'/'+strtrim(string(ene_type),1)+'MeV.'+sim_name+'.'+strtrim(string(theta_type),1)+'theta.'+strtrim(string(N_in),1)+'ph'
print, 'BoGEMMS simulation path: ', filepath

outdir = './AGILE'+agile_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir
print, 'BoGEMMS outdir path: ', outdir

CheckOutDir = DIR_EXIST( outdir)
if (CheckOutDir EQ 0) then spawn,'mkdir -p ./AGILE'+agile_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir



for ifile=0, n_fits-1 do begin
    print, 'Reading the BoGEMMS file.....', ifile+1

    ; Tracker
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
    
    ; Calorimeter
    event_id_cal = -1l
    vol_id_cal = -1l
    moth_id_cal = -1l
    energy_dep_cal = -1.
    
    ent_x_cal = -1.
    ent_y_cal = -1.
    ent_z_cal = -1.
    exit_x_cal = -1.
    exit_y_cal = -1.
    exit_z_cal = -1.
    
    theta_ent_cal = -1.
    phi_ent_cal = -1.
    
    theta_exit_cal = -1.
    phi_exit_cal = -1.

    ; AC    
    event_id_ac = -1l
    vol_id_ac = -1l
    moth_id_ac = -1l
    energy_dep_ac = -1.
    
    ent_x_ac = -1.
    ent_y_ac = -1.
    ent_z_ac = -1.
    exit_x_ac = -1.
    exit_y_ac = -1.
    exit_z_ac = -1.
    
    theta_ent_ac = -1.
    phi_ent_ac = -1.
    
    theta_exit_ac = -1.
    phi_exit_ac = -1.

    filename = filepath+'/xyz.'+strtrim(string(ifile), 1)+'.fits.gz'
    struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'agile', $
                     /unsigned)

    for k=0l, n_elements(struct)-1l do begin 
    
    ; Reading the tracker (events with E > 0)                
     if (struct(k).VOLUME_ID GE tracker_vol_start) then begin
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
     ; Reading the calorimeter
     if ((struct(k).VOLUME_ID GE cal_vol_start) AND (struct(k).VOLUME_ID LE cal_vol_end)) then begin
      if (struct(k).E_DEP GT 0.d) then begin        
         event_id_cal = [event_id_cal, struct(k).EVT_ID] 
         vol_id_cal = [vol_id_cal, struct(k).VOLUME_ID] 
         if (isStrip EQ 1) then moth_id_cal = [moth_id_cal, struct(k).MOTHER_ID] else moth_id_cal = [moth_id_cal, 0]
         energy_dep_cal = [energy_dep_cal, struct(k).E_DEP] 
        
         ent_x_cal = [ent_x_cal, struct(k).X_ENT]  
         ent_y_cal = [ent_y_cal, struct(k).Y_ENT]  
         ent_z_cal = [ent_z_cal, struct(k).Z_ENT]  
         exit_x_cal = [exit_x_cal, struct(k).X_EXIT]  
         exit_y_cal = [exit_y_cal, struct(k).Y_EXIT]  
         exit_z_cal = [exit_z_cal, struct(k).Z_EXIT]  
        
         theta_ent_cal = [theta_ent_cal, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
         phi_ent_cal = [phi_ent_cal, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

         theta_exit_cal = [theta_exit_cal, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
         phi_exit_cal = [phi_exit_cal, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]        
      endif
     endif
     if ((struct(k).VOLUME_ID GE ac_vol_start) AND (struct(k).VOLUME_ID LE ac_vol_end)) then begin
      if (struct(k).E_DEP GT 0.d) then begin        
         event_id_ac = [event_id_ac, struct(k).EVT_ID] 
         vol_id_ac = [vol_id_ac, struct(k).VOLUME_ID] 
         if (isStrip EQ 1) then moth_id_ac = [moth_id_ac, struct(k).MOTHER_ID] else moth_id_ac = [moth_id_ac, 0]
         energy_dep_ac = [energy_dep_ac, struct(k).E_DEP] 
        
         ent_x_ac = [ent_x_ac, struct(k).X_ENT]  
         ent_y_ac = [ent_y_ac, struct(k).Y_ENT]  
         ent_z_ac = [ent_z_ac, struct(k).Z_ENT]  
         exit_x_ac = [exit_x_ac, struct(k).X_EXIT]  
         exit_y_ac = [exit_y_ac, struct(k).Y_EXIT]  
         exit_z_ac = [exit_z_ac, struct(k).Z_EXIT]  
        
         theta_ent_ac = [theta_ent_ac, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
         phi_ent_ac = [phi_ent_ac, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

         theta_exit_ac = [theta_exit_ac, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
         phi_exit_ac = [phi_exit_ac, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]        
      endif
     endif
     
    endfor
 
    ; Tracker (removing fake starting value)
    event_id = event_id[1:*]
    vol_id = vol_id[1:*]
    moth_id = moth_id[1:*]
    energy_dep = energy_dep[1:*]

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

    ; Calorimeter (removing fake starting value)
    event_id_cal = event_id_cal[1:*]
    vol_id_cal = vol_id_cal[1:*]
    moth_id_cal = moth_id_cal[1:*]
    energy_dep_cal = energy_dep_cal[1:*]

    ent_x_cal = (ent_x_cal[1:*])/10.
    ent_y_cal = (ent_y_cal[1:*])/10.
    ent_z_cal = (ent_z_cal[1:*])/10.
    exit_x_cal = (exit_x_cal[1:*])/10.
    exit_y_cal = (exit_y_cal[1:*])/10.
    exit_z_cal = (exit_z_cal[1:*])/10.

    theta_ent_cal = theta_ent_cal[1:*]
    phi_ent_cal = phi_ent_cal[1:*]

    theta_exit_cal = theta_exit_cal[1:*]
    phi_exit_cal = phi_exit_cal[1:*]

    ; AC (removing fake starting value)
    event_id_ac = event_id_ac[1:*]
    vol_id_ac = vol_id_ac[1:*]
    moth_id_ac = moth_id_ac[1:*]
    energy_dep_ac = energy_dep_ac[1:*]

    ent_x_ac = (ent_x_ac[1:*])/10.
    ent_y_ac = (ent_y_ac[1:*])/10.
    ent_z_ac = (ent_z_ac[1:*])/10.
    exit_x_ac = (exit_x_ac[1:*])/10.
    exit_y_ac = (exit_y_ac[1:*])/10.
    exit_z_ac = (exit_z_ac[1:*])/10.

    theta_ent_ac = theta_ent_ac[1:*]
    phi_ent_ac = phi_ent_ac[1:*]

    theta_exit_ac = theta_exit_ac[1:*]
    phi_exit_ac = phi_exit_ac[1:*]

    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ;                             Processing the tracker 
    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ; From Tracker volume ID to strip and tray ID
    Strip_id = dblarr(n_elements(vol_id))
    Si_id = intarr(n_elements(vol_id))
    tray_id = intarr(n_elements(vol_id))

    Si_X_arr = dblarr(N_tray)
    Si_Y_arr = dblarr(N_tray)

    for j=0l, n_elements(Si_X_arr)-1 do begin
       Si_X_arr(j) = tracker_vol_start + tracker_vol_start*j
       Si_Y_arr(j) = tracker_y_vol_start + tracker_vol_start*j
    endfor

    ; Si_id: 0 = x, 1 = y
    for j=0l, n_elements(vol_id)-1 do begin

     if (isStrip EQ 0) then begin   ;--------> STRIP = 0
       div_id = (vol_id(j))/tracker_vol_start
       div_type = vol_id(j) mod tracker_vol_start
       if (div_type EQ 0) then begin
           Si_id(j) = 0 
           tray_id(j) = div_id  
       endif else begin
            Si_id(j) = 1
            tray_id(j) = (vol_id(j)-tracker_x_y_diff)/tracker_vol_start
       endelse
            Strip_id(j) = 0
      endif else begin
       if (Repli EQ 1) then begin    ;--------> STRIP = 1, REPLI = 1
                    div_id = (moth_id(j))/tracker_vol_start
                    div_type = moth_id(j) mod tracker_vol_start
                    Strip_id(j) = vol_id(j) - tracker_vol_start  
                    if (div_type EQ 0) then begin
                     Si_id(j) = 0 
                     tray_id(j) = div_id
                    endif else begin
                     Si_id(j) = 1
                     tray_id(j) = (vol_id(j)-tracker_x_y_diff)/tracker_vol_start
                    endelse
       endif else begin    ;--------> STRIP = 1, REPLI = 0
                     where_greater_X = where(Si_X_arr GT vol_id(j))
                     where_greater_Y = where(Si_Y_arr GT vol_id(j))
                          
                     if (where_greater_X(0) NE -1) then begin
                      tray_id_temp = where_greater_X(0)
                      if (where_greater_X(0) EQ where_greater_Y(0)) then Si_id_temp = tracker_x_y_diff else Si_id_temp = 0
                     endif else begin
                      Si_id_temp = 0              
                      tray_id_temp = n_elements(Si_X_arr)
                     endelse

                     tray_id(j) = tray_id_temp
                     if (Si_id_temp EQ 0) then Si_id(j) = 0 else Si_id(j) = 1
                 
                     Strip_id_temp = vol_id(j) - tray_id_temp*tracker_vol_start - Si_id_temp       
                     Strip_id(j) = Strip_id_temp
         endelse
      endelse
    endfor
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                             Tracker   '
    print, '           Saving the Tracker raw hits (fits and .dat)      '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    ; Conversion from tray ID (starting from bottom) to plane ID (starting from the top)   
    plane_id = intarr(n_elements(tray_id))
    
    for j=0l, n_elements(tray_id)-1 do begin
     if (Si_id(j) EQ 0) then begin
        temp_plane_x = tray_id(j) - N_plane
        if (temp_plane_x GT 0) then plane_id(j) = temp_plane_x else plane_id(j) = (-1.*temp_plane_x) + 2
     endif
     if (Si_id(j) EQ 1) then begin
        temp_plane_y = tray_id(j) - (N_plane-1)
        if (temp_plane_y GT 0) then plane_id(j) = temp_plane_y else plane_id(j) = (-1.*temp_plane_y) + 2
     endif
    endfor
    
    CREATE_STRUCT, rawData, 'rawData', ['EVT_ID', 'TRK_FLAG', 'TRAY_ID', 'PLANE_ID', 'STRIP_ID', 'E_DEP', 'X_ENT', 'Y_ENT', 'Z_ENT', 'X_EXIT', 'Y_EXIT', 'Z_EXIT'], $
    'I,I,I,I,I,F20.5,F20.5,F20.5,F20.5,F20.5,F20.5,F20.5', DIMEN = n_elements(event_id)
    rawData.EVT_ID = event_id
    rawData.TRK_FLAG = Si_id
    rawData.TRAY_ID = tray_id
    rawData.PLANE_ID = plane_id
    rawData.STRIP_ID = Strip_id
    rawData.E_DEP = energy_dep
    rawData.X_ENT = ent_x
    rawData.Y_ENT = ent_y
    rawData.Z_ENT = ent_z
    rawData.X_EXIT = exit_x
    rawData.Y_EXIT = exit_y
    rawData.Z_EXIT = exit_z
    
    
    hdr_rawData = ['COMMENT  AGILE '+agile_version+' Geant4 simulation', $
                   'N_in     = '+strtrim(string(N_in),1), $
                   'Energy     = '+strtrim(string(ene_type),1), $
                   'Theta     = '+strtrim(string(theta_type),1), $
                   'Phi     = '+strtrim(string(phi_type),1), $
                   'Position unit = cm', $
                   'Energy unit = keV']
    
    MWRFITS, rawData, outdir+'/G4.RAW.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.fits', hdr_rawData, /create
    
    x_pos = dblarr(n_elements(ent_x))
    y_pos = dblarr(n_elements(ent_x))
    z_pos = dblarr(n_elements(ent_x))
    
    for j=0l, n_elements(ent_x)-1 do begin
     x_pos(j) = ent_x(j) + ((exit_x(j) - ent_x(j))/2.)
     y_pos(j) = ent_y(j) + ((exit_y(j) - ent_y(j))/2.)
     z_pos(j) = ent_z(j) + ((exit_z(j) - ent_z(j))/2.)
    endfor
    
    openw,lun, outdir+'/G4.RAW.KALMAN.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event id
    ; - c2 = Silicon layer ID
    ; - c3 = x/y pos [cm]
    ; - c4 = z pos [cm]
    ; - c5 = plane ID
    ; - c6 = strip ID
    ; - c7 = energy dep [keV]
    
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(event_id EQ event_id(j))
        Si_id_temp = Si_id(where_event_eq)
        Strip_id_temp = Strip_id(where_event_eq)
        tray_id_temp  = tray_id(where_event_eq)
        plane_id_temp  = plane_id(where_event_eq)
        energy_dep_temp = energy_dep(where_event_eq)    
        x_pos_temp = x_pos(where_event_eq)
        y_pos_temp = y_pos(where_event_eq)
        z_pos_temp = z_pos(where_event_eq)
    
        ;printf, lun, '; Event:', event_id(j)
        ;printf, lun, '; ', theta_type, phi_type, ene_type   
        
        where_x = where(Si_id_temp EQ 0)
        if (where_x(0) NE -1) then begin
         for r=0l, n_elements(where_x)-1 do begin
            printf, lun, event_id(j), Si_id_temp(where_x(r)), x_pos_temp(where_x(r)), z_pos_temp(where_x(r)), plane_id_temp(where_x(r)), Strip_id_temp(where_x(r)), energy_dep_temp(where_x(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,F10.5)'
         endfor
        endif
        where_y = where(Si_id_temp EQ 1)    
        if (where_y(0) NE -1) then begin
         for r=0l, n_elements(where_y)-1 do begin
            printf, lun, event_id(j), Si_id_temp(where_y(r)), y_pos_temp(where_y(r)), z_pos_temp(where_y(r)), plane_id_temp(where_y(r)), Strip_id_temp(where_y(r)), energy_dep_temp(where_y(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,F10.5)'
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    openw,lun,outdir+'/G4.RAW.GENERAL.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = Silicon layer ID
    ; - c3 = x/y pos [cm]
    ; - c4 = z pos [cm]
    ; - c5 = tray ID
    ; - c6 = plane ID
    ; - c7 = strip ID 
    ; - c8 = energy dep [keV]    
    
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(event_id EQ event_id(j))
        Si_id_temp = Si_id(where_event_eq)
        Strip_id_temp = Strip_id(where_event_eq)
        tray_id_temp  = tray_id(where_event_eq)
        plane_id_temp  = plane_id(where_event_eq)
        energy_dep_temp = energy_dep(where_event_eq)    
        x_pos_temp = x_pos(where_event_eq)
        y_pos_temp = y_pos(where_event_eq)
        z_pos_temp = z_pos(where_event_eq)
     
        
        where_x = where(Si_id_temp EQ 0)
        if (where_x(0) NE -1) then begin
         for r=0l, n_elements(where_x)-1 do begin
            printf, lun, event_id(j), Si_id_temp(where_x(r)), x_pos_temp(where_x(r)), z_pos_temp(where_x(r)), tray_id_temp(where_x(r)), plane_id_temp(where_x(r)), Strip_id_temp(where_x(r)), energy_dep_temp(where_x(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,I5,2x,F10.5)'
         endfor
        endif
        where_y = where(Si_id_temp EQ 1)    
        if (where_y(0) NE -1) then begin
         for r=0l, n_elements(where_y)-1 do begin
            printf, lun, event_id(j), Si_id_temp(where_y(r)), y_pos_temp(where_y(r)), z_pos_temp(where_y(r)), tray_id_temp(where_y(r)), plane_id_temp(where_y(r)), Strip_id_temp(where_y(r)), energy_dep_temp(where_y(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,I5,2x,F10.5)'
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                            Tracker   '
    print, '                  Summing the Tracker energy                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    N_trig = 0l
    
    event_id_tot = -1l
    vol_id_tot = -1l
    moth_id_tot = -1l
    Strip_id_tot = -1l
    Si_id_tot = -1l
    tray_id_tot = -1l
    plane_id_tot = -1l
    energy_dep_tot = -1.
    
    event_array = -1l
    
    if (isStrip EQ 0) then begin
     j=0l
     while (1) do begin
        where_event_eq = where(event_id EQ event_id(j))
        
        N_trig = N_trig + 1
        event_array = [event_array, event_id(j)]
        vol_id_temp = vol_id(where_event_eq) 
        moth_id_temp = moth_id(where_event_eq) 
        Strip_id_temp = Strip_id(where_event_eq) 
        Si_id_temp = Si_id(where_event_eq) 
        tray_id_temp = tray_id(where_event_eq) 
        plane_id_temp = plane_id(where_event_eq) 
        energy_dep_temp = energy_dep(where_event_eq) 
            
        r = 0l
        while(1) do begin
           where_vol_eq = where(vol_id_temp EQ vol_id_temp(r), complement = where_other_vol)
           event_id_tot = [event_id_tot, event_id(j)]
           vol_id_tot = [vol_id_tot, vol_id_temp(r)]
           moth_id_tot = [moth_id_tot, moth_id_temp(r)]
           Strip_id_tot = [Strip_id_tot, Strip_id_temp(r)]
           Si_id_tot = [Si_id_tot, Si_id_temp(r)]
           tray_id_tot = [tray_id_tot, tray_id_temp(r)]
           plane_id_tot = [plane_id_tot, plane_id_temp(r)]
           energy_dep_tot = [energy_dep_tot, total(energy_dep_temp(where_vol_eq))]
           if (where_other_vol(0) NE -1) then begin
             vol_id_temp = vol_id_temp(where_other_vol)
             moth_id_temp = moth_id_temp(where_other_vol)
             Strip_id_temp = Strip_id_temp(where_other_vol)
             Si_id_temp = Si_id_temp(where_other_vol)
             tray_id_temp = tray_id_temp(where_other_vol)
             plane_id_temp = plane_id_temp(where_other_vol)
             energy_dep_temp = energy_dep_temp(where_other_vol)
           endif else break
        endwhile
            
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
     endwhile
    endif else begin
     if (repli EQ 1) then begin   ; -------> STRIP EQ 1, REPLI EQ 1
     
      uniq_vol_id = intarr(n_elements(vol_id))
      for l=0l, n_elements(vol_id)-1 do begin
        if (Si_id(l) EQ 0) then Si_layer = 0 else Si_layer = tracker_x_y_diff
        uniq_vol_id(l) = (tray_id(l)*tracker_vol_start) + Si_layer + Stri_id(l)
      endfor
      
      j=0l
      while (1) do begin
    
         N_trig = N_trig + 1
         event_array = [event_array, event_id(j)]
    
         where_event_eq = where(event_id EQ event_id(j))
         vol_id_temp = uniq_vol_id(where_event_eq) 
         moth_id_temp = moth_id(where_event_eq) 
         Strip_id_temp = Strip_id(where_event_eq) 
         Si_id_temp = Si_id(where_event_eq) 
         tray_id_temp = tray_id(where_event_eq) 
         plane_id_temp = plane_id(where_event_eq) 
         energy_dep_temp = energy_dep(where_event_eq) 
        
         r = 0l
         while(1) do begin
            where_vol_eq = where(vol_id_temp EQ vol_id_temp(r), complement = where_other_vol)
            event_id_tot = [event_id_tot, event_id(j)]
            vol_id_tot = [vol_id_tot, vol_id_temp(r)]
            moth_id_tot = [moth_id_tot, moth_id_temp(r)]
            Strip_id_tot = [Strip_id_tot, Strip_id_temp(r)]
            Si_id_tot = [Si_id_tot, Si_id_temp(r)]
            tray_id_tot = [tray_id_tot, tray_id_temp(r)]
            plane_id_tot = [plane_id_tot, plane_id_temp(r)]
            energy_dep_tot = [energy_dep_tot, total(energy_dep_temp(where_vol_eq))]
            if (where_other_vol(0) NE -1) then begin
              vol_id_temp = vol_id_temp(where_other_vol)
              moth_id_temp = moth_id_temp(where_other_vol)
              Strip_id_temp = Strip_id_temp(where_other_vol)
              Si_id_temp = Si_id_temp(where_other_vol)
              tray_id_temp = tray_id_temp(where_other_vol)
              plane_id_temp = plane_id_temp(where_other_vol)
              energy_dep_temp = energy_dep_temp(where_other_vol)
            endif else break
         endwhile
        
         N_event_eq = n_elements(where_event_eq)
         if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
           j = where_event_eq(N_event_eq-1)+1
         endif else break
      endwhile
     endif else begin   ; -------> STRIP EQ 1, REPLI EQ 0
       
      j=0l
      while (1) do begin
         where_event_eq = where(event_id EQ event_id(j))
    
         N_trig = N_trig + 1
         event_array = [event_array, event_id(j)]
    
         vol_id_temp = vol_id(where_event_eq) 
         moth_id_temp = moth_id(where_event_eq) 
         Strip_id_temp = Strip_id(where_event_eq) 
         Si_id_temp = Si_id(where_event_eq) 
         tray_id_temp = tray_id(where_event_eq) 
         plane_id_temp = plane_id(where_event_eq) 
         energy_dep_temp = energy_dep(where_event_eq) 
        
         r = 0l
         while(1) do begin
            where_vol_eq = where(vol_id_temp EQ vol_id_temp(r), complement = where_other_vol)
            event_id_tot = [event_id_tot, event_id(j)]
            vol_id_tot = [vol_id_tot, vol_id_temp(r)]
            moth_id_tot = [moth_id_tot, moth_id_temp(r)]
            Strip_id_tot = [Strip_id_tot, Strip_id_temp(r)]
            Si_id_tot = [Si_id_tot, Si_id_temp(r)]
            tray_id_tot = [tray_id_tot, tray_id_temp(r)]
            plane_id_tot = [plane_id_tot, plane_id_temp(r)]
            energy_dep_tot = [energy_dep_tot, total(energy_dep_temp(where_vol_eq))]
            if (where_other_vol(0) NE -1) then begin
              vol_id_temp = vol_id_temp(where_other_vol)
              moth_id_temp = moth_id_temp(where_other_vol)
              Strip_id_temp = Strip_id_temp(where_other_vol)
              Si_id_temp = Si_id_temp(where_other_vol)
              tray_id_temp = tray_id_temp(where_other_vol)
              plane_id_temp = plane_id_temp(where_other_vol)
              energy_dep_temp = energy_dep_temp(where_other_vol)
            endif else break
         endwhile
        
         N_event_eq = n_elements(where_event_eq)
         if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
           j = where_event_eq(N_event_eq-1)+1
         endif else break
      endwhile
     endelse
    endelse
    
    
    if (n_elements(event_id_tot) GT 1) then begin
      event_id_tot = event_id_tot[1:*]
      vol_id_tot = vol_id_tot[1:*]
      moth_id_tot = moth_id_tot[1:*]
      Strip_id_tot = Strip_id_tot[1:*]
      Si_id_tot = Si_id_tot[1:*]
      tray_id_tot = tray_id_tot[1:*]
      plane_id_tot = plane_id_tot[1:*]
      energy_dep_tot = energy_dep_tot[1:*]
      event_array = event_array[1:*]
    endif
    
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '      Build the Tracker readout and floating strip          '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    
    ; Total number of strips
    
    Total_vol_x = (N_tray-1)*N_strip
    Total_vol_y = (N_tray-1)*N_strip
    
    print, 'Total number of strips in each Si layer:', Total_vol_x
    print, 'Number of triggered events:', N_trig
    
    Glob_event_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_vol_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_moth_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_Strip_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_Strip_type_x = lonarr(Total_vol_x, N_trig) 
    Glob_Si_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_tray_id_x = lonarr(Total_vol_x, N_trig) 
    Glob_xpos_x = dblarr(Total_vol_x, N_trig) 
    Glob_zpos_x = dblarr(Total_vol_x, N_trig) 
    Glob_energy_dep_x = dblarr(Total_vol_x, N_trig) 
    
    Glob_event_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_vol_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_moth_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_Strip_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_Strip_type_y = lonarr(Total_vol_y, N_trig) 
    Glob_Si_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_tray_id_y = lonarr(Total_vol_y, N_trig) 
    Glob_ypos_y = dblarr(Total_vol_y, N_trig) 
    Glob_zpos_y = dblarr(Total_vol_y, N_trig) 
    Glob_energy_dep_y = dblarr(Total_vol_y, N_trig) 
    
    filename_x = './conf/ARCH.XSTRIP.AGILE'+agile_version+'.TRACKER.FITS'
    filename_y = './conf/ARCH.YSTRIP.AGILE'+agile_version+'.TRACKER.FITS'
    
    struct_x = mrdfits(filename_x,$ 
                           1, $
                           structyp = 'agile_x', $
                           /unsigned)
    
    struct_y = mrdfits(filename_y,$ 
                           1, $
                           structyp = 'agile_y', $
                           /unsigned)
    
    Arch_vol_id_x = struct_x.VOLUME_ID
    Arch_moth_id_x = struct_x.MOTHER_ID
    Arch_Strip_id_x = struct_x.STRIP_ID 
    Arch_Strip_type_x = struct_x.STRIP_TYPE 
    Arch_Si_id_x = struct_x.TRK_FLAG
    Arch_tray_id_x = struct_x.TRAY_ID 
    Arch_xpos_x = struct_x.XPOS 
    Arch_zpos_x = struct_x.ZPOS 
    Arch_energy_dep_x = struct_x.E_DEP 
    
    Arch_vol_id_y = struct_y.VOLUME_ID
    Arch_moth_id_y = struct_y.MOTHER_ID
    Arch_Strip_id_y = struct_y.STRIP_ID 
    Arch_Strip_type_y = struct_y.STRIP_TYPE 
    Arch_Si_id_y = struct_y.TRK_FLAG
    Arch_tray_id_y = struct_y.TRAY_ID 
    Arch_ypos_y = struct_y.YPOS 
    Arch_zpos_y = struct_y.ZPOS 
    Arch_energy_dep_y = struct_y.E_DEP 
    
    
    for i=0, N_trig-1 do begin
    
        Glob_vol_id_x[*,i] = Arch_vol_id_x
        Glob_moth_id_x[*,i] = Arch_moth_id_x
        Glob_Strip_id_x[*,i] = Arch_Strip_id_x 
        Glob_Strip_type_x[*,i] = Arch_Strip_type_x 
        Glob_Si_id_x[*,i] = Arch_Si_id_x
        Glob_tray_id_x[*,i] = Arch_tray_id_x 
        Glob_xpos_x[*,i] = Arch_xpos_x 
        Glob_zpos_x[*,i] = Arch_zpos_x
        Glob_energy_dep_x[*,i] = Arch_energy_dep_x
    
        Glob_vol_id_y[*,i] = Arch_vol_id_y
        Glob_moth_id_y[*,i] = Arch_moth_id_y
        Glob_Strip_id_y[*,i] = Arch_Strip_id_y
        Glob_Strip_type_y[*,i] = Arch_Strip_type_y 
        Glob_Si_id_y[*,i] = Arch_Si_id_y
        Glob_tray_id_y[*,i] = Arch_tray_id_y 
        Glob_ypos_y[*,i] = Arch_ypos_y 
        Glob_zpos_y[*,i] = Arch_zpos_y 
        Glob_energy_dep_y[*,i] = Arch_energy_dep_y 
    
    
    endfor
    
    
     j=0l
     N_ev =0l
     while (1) do begin
        where_event_eq = where(event_id_tot EQ event_id_tot(j))
        
        event_id_temp = event_id_tot(where_event_eq)
        vol_id_temp = vol_id_tot(where_event_eq) 
        moth_id_temp = moth_id_tot(where_event_eq) 
        Strip_id_temp = Strip_id_tot(where_event_eq) 
        Si_id_temp = Si_id_tot(where_event_eq) 
        tray_id_temp = tray_id_tot(where_event_eq) 
        energy_dep_temp = energy_dep_tot(where_event_eq) 
    
        vol_sort_arr = sort(vol_id_temp)
        
        vol_id_temp = vol_id_temp[vol_sort_arr]
        moth_id_temp = moth_id_temp[vol_sort_arr]
        Strip_id_temp = Strip_id_temp[vol_sort_arr]
        Si_id_temp = Si_id_temp[vol_sort_arr]
        tray_id_temp = tray_id_temp[vol_sort_arr]
        energy_dep_temp = energy_dep_temp[vol_sort_arr]
    
        for z=0l, Total_vol_x -1 do begin
          where_hit_x = where(vol_id_temp EQ Glob_vol_id_x(z, N_ev))
          if (where_hit_x(0) NE -1) then Glob_energy_dep_x(z, N_ev) = energy_dep_temp(where_hit_x)
          where_hit_y = where(vol_id_temp EQ Glob_vol_id_y(z, N_ev))
          if (where_hit_y(0) NE -1) then Glob_energy_dep_y(z, N_ev) = energy_dep_temp(where_hit_y)
        endfor
         
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id_tot)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
          N_ev = N_ev + 1
        endif else break
     endwhile
    
    
    
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '              Build the LEVEL 0 output            '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    
    Glob_event_id_test = -1l 
    Glob_vol_id_test = -1l 
    Glob_moth_id_test = -1l 
    Glob_Strip_id_test = -1l 
    Glob_Strip_type_test = -1l 
    Glob_Si_id_test = -1l 
    Glob_tray_id_test = -1l 
    Glob_pos_test = -1.
    Glob_zpos_test = -1. 
    Glob_energy_dep_test = -1.
    
    
    for j=0l, N_trig -1 do begin
       
       where_test_x = where(Glob_energy_dep_x[*,j] GT 0.)
    
       if (where_test_x(0) NE -1) then begin
         Glob_vol_id_x_test_temp = Glob_vol_id_x[where_test_x,j]
         Glob_moth_id_x_test_temp = Glob_moth_id_x[where_test_x,j]
         Glob_Strip_id_x_test_temp = Glob_Strip_id_x[where_test_x,j]
         Glob_Strip_type_x_test_temp = Glob_Strip_type_x[where_test_x,j]
         Glob_Si_id_x_test_temp = Glob_Si_id_x[where_test_x,j]
         Glob_tray_id_x_test_temp = Glob_tray_id_x[where_test_x,j]
         Glob_xpos_x_test_temp = Glob_xpos_x[where_test_x,j]
         Glob_zpos_x_test_temp = Glob_zpos_x[where_test_x,j]
         Glob_energy_dep_x_test_temp = Glob_energy_dep_x[where_test_x,j]
       endif
    
    
       where_test_y = where(Glob_energy_dep_y[*,j] GT 0.)
     
       if (where_test_y(0) NE -1) then begin
         Glob_vol_id_y_test_temp = Glob_vol_id_y[where_test_y,j]
         Glob_moth_id_y_test_temp = Glob_moth_id_y[where_test_y,j]
         Glob_Strip_id_y_test_temp = Glob_Strip_id_y[where_test_y,j]
         Glob_Strip_type_y_test_temp = Glob_Strip_type_y[where_test_y,j]
         Glob_Si_id_y_test_temp = Glob_Si_id_y[where_test_y,j]
         Glob_tray_id_y_test_temp = Glob_tray_id_y[where_test_y,j]
         Glob_ypos_y_test_temp = Glob_ypos_y[where_test_y,j]
         Glob_zpos_y_test_temp = Glob_zpos_y[where_test_y,j]
         Glob_energy_dep_y_test_temp = Glob_energy_dep_y[where_test_y,j]
       endif
    
       if ((where_test_y(0) NE -1) AND (where_test_x(0) NE -1)) then begin
         Glob_vol_id_test_temp = [Glob_vol_id_y_test_temp, Glob_vol_id_x_test_temp]
        Glob_moth_id_test_temp = [Glob_moth_id_y_test_temp, Glob_moth_id_x_test_temp]
        Glob_Strip_id_test_temp = [Glob_Strip_id_y_test_temp, Glob_Strip_id_x_test_temp]
        Glob_Strip_type_test_temp = [Glob_Strip_type_y_test_temp, Glob_Strip_type_x_test_temp]
        Glob_Si_id_test_temp = [Glob_Si_id_y_test_temp, Glob_Si_id_x_test_temp]
        Glob_tray_id_test_temp = [Glob_tray_id_y_test_temp, Glob_tray_id_x_test_temp]
        Glob_pos_test_temp = [Glob_ypos_y_test_temp, Glob_xpos_x_test_temp]
        Glob_zpos_test_temp = [Glob_zpos_y_test_temp, Glob_zpos_x_test_temp]
        Glob_energy_dep_test_temp = [Glob_energy_dep_y_test_temp, Glob_energy_dep_x_test_temp]
       endif else begin
        if ((where_test_y(0) NE -1) AND (where_test_x(0) EQ -1)) then begin
         Glob_vol_id_test_temp = Glob_vol_id_y_test_temp
         Glob_moth_id_test_temp = Glob_moth_id_y_test_temp
         Glob_Strip_id_test_temp = Glob_Strip_id_y_test_temp
         Glob_Strip_type_test_temp = Glob_Strip_type_y_test_temp
         Glob_Si_id_test_temp = Glob_Si_id_y_test_temp
         Glob_tray_id_test_temp = Glob_tray_id_y_test_temp
         Glob_pos_test_temp = Glob_ypos_y_test_temp
         Glob_zpos_test_temp = Glob_zpos_y_test_temp
         Glob_energy_dep_test_temp = Glob_energy_dep_y_test_temp
        endif else begin
         if ((where_test_y(0) EQ -1) AND (where_test_x(0) NE -1)) then begin
          Glob_vol_id_test_temp = Glob_vol_id_x_test_temp
          Glob_moth_id_test_temp = Glob_moth_id_x_test_temp
          Glob_Strip_id_test_temp = Glob_Strip_id_x_test_temp
          Glob_Strip_type_test_temp = Glob_Strip_type_x_test_temp
          Glob_Si_id_test_temp = Glob_Si_id_x_test_temp
          Glob_tray_id_test_temp = Glob_tray_id_x_test_temp
          Glob_pos_test_temp = Glob_xpos_x_test_temp
          Glob_zpos_test_temp = Glob_zpos_x_test_temp
          Glob_energy_dep_test_temp = Glob_energy_dep_x_test_temp
         endif
        endelse
       endelse   
       
       tray_sort_arr = sort(Glob_tray_id_test_temp)
        
       Glob_vol_id_test_temp = Glob_vol_id_test_temp[reverse(tray_sort_arr)]
       Glob_moth_id_test_temp = Glob_moth_id_test_temp[reverse(tray_sort_arr)]
       Glob_Strip_id_test_temp = Glob_Strip_id_test_temp[reverse(tray_sort_arr)]
       Glob_Strip_type_test_temp = Glob_Strip_type_test_temp[reverse(tray_sort_arr)]
       Glob_Si_id_test_temp = Glob_Si_id_test_temp[reverse(tray_sort_arr)]
       Glob_tray_id_test_temp = Glob_tray_id_test_temp[reverse(tray_sort_arr)]
       Glob_pos_test_temp = Glob_pos_test_temp[reverse(tray_sort_arr)]
       Glob_zpos_test_temp = Glob_zpos_test_temp[reverse(tray_sort_arr)]
       Glob_energy_dep_test_temp = Glob_energy_dep_test_temp[reverse(tray_sort_arr)]
    
       vol_id_intray = -1l
       moth_id_intray = -1l
       Strip_id_intray = -1l
       Strip_type_intray = -1l
       Si_id_intray = -1l
       tray_id_intray = -1l
       pos_intray = -1.
       zpos_intray = -1.
       energy_dep_intray = -1.
           
        intray = 0l
        while(1) do begin
           where_tray_eq = where(Glob_tray_id_test_temp EQ Glob_tray_id_test_temp(intray), complement = where_other_tray)
           
           vol_id_extract = Glob_vol_id_test_temp[where_tray_eq]
           moth_id_extract = Glob_moth_id_test_temp[where_tray_eq]
           Strip_id_extract = Glob_Strip_id_test_temp[where_tray_eq]
           Strip_type_extract = Glob_Strip_type_test_temp[where_tray_eq]
           Si_id_extract = Glob_Si_id_test_temp[where_tray_eq]
           tray_id_extract = Glob_tray_id_test_temp[where_tray_eq]
           pos_extract = Glob_pos_test_temp[where_tray_eq]
           zpos_extract = Glob_zpos_test_temp[where_tray_eq]
           energy_dep_extract = Glob_energy_dep_test_temp[where_tray_eq]
           
           where_Y = where(Si_id_extract EQ 1)
           if (where_Y(0) NE -1) then begin
             vol_id_intray = [vol_id_intray, vol_id_extract[where_Y]]
             moth_id_intray = [moth_id_intray, moth_id_extract[where_Y]]
             Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_Y]]
             Strip_type_intray = [Strip_type_intray, Strip_type_extract[where_Y]]
             Si_id_intray = [Si_id_intray, Si_id_extract[where_Y]]
             tray_id_intray = [tray_id_intray, tray_id_extract[where_Y]]
             pos_intray = [pos_intray, pos_extract[where_Y]]
             zpos_intray = [zpos_intray, zpos_extract[where_Y]]
             energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_Y]]         
           endif
           where_X = where(Si_id_extract EQ 0)
           if (where_X(0) NE -1) then begin
             vol_id_intray = [vol_id_intray, vol_id_extract[where_X]]
             moth_id_intray = [moth_id_intray, moth_id_extract[where_X]]
             Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_X]]
             Strip_type_intray = [Strip_type_intray, Strip_type_extract[where_X]]
             Si_id_intray = [Si_id_intray, Si_id_extract[where_X]]
             tray_id_intray = [tray_id_intray, tray_id_extract[where_X]]
             pos_intray = [pos_intray, pos_extract[where_X]]
             zpos_intray = [zpos_intray, zpos_extract[where_X]]
             energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_X]]         
           endif
         N_tray_eq = n_elements(where_tray_eq)
         if where_tray_eq(N_tray_eq-1) LT (n_elements(Glob_tray_id_test_temp)-1) then begin
          intray = where_tray_eq(N_tray_eq-1)+1
         endif else break
        endwhile
        
       
        vol_id_temp = vol_id_intray[1:*]
        moth_id_temp = moth_id_intray[1:*]
        Strip_id_temp = Strip_id_intray[1:*]
        Strip_type_temp = Strip_type_intray[1:*]
        Si_id_temp = Si_id_intray[1:*]
        tray_id_temp = tray_id_intray[1:*]
        pos_temp = pos_intray[1:*]
        zpos_temp = zpos_intray[1:*]
        energy_dep_temp = energy_dep_intray[1:*]
        
        event_id_temp = lonarr(n_elements(vol_id_temp))
        for k=0l, n_elements(vol_id_temp)-1 do begin
         event_id_temp(k) = event_array(j)
        endfor
        
        Glob_event_id_test = [Glob_event_id_test, event_id_temp]
        Glob_vol_id_test = [Glob_vol_id_test, vol_id_temp]
        Glob_moth_id_test= [Glob_moth_id_test, moth_id_temp] 
        Glob_Strip_id_test = [Glob_Strip_id_test, Strip_id_temp]
        Glob_Strip_type_test = [Glob_Strip_type_test, Strip_type_temp]
        Glob_Si_id_test = [Glob_Si_id_test, Si_id_temp]
        Glob_tray_id_test = [Glob_tray_id_test, tray_id_temp]
        Glob_pos_test = [Glob_pos_test, pos_temp]
        Glob_zpos_test = [Glob_zpos_test, zpos_temp]
        Glob_energy_dep_test = [Glob_energy_dep_test, energy_dep_temp]
    
    endfor
    
    Glob_event_id_test = Glob_event_id_test[1:*]
    Glob_vol_id_test =  Glob_vol_id_test[1:*]
    Glob_moth_id_test =  Glob_moth_id_test[1:*]
    Glob_Strip_id_test =  Glob_Strip_id_test[1:*]
    Glob_Strip_type_test =  Glob_Strip_type_test[1:*]
    Glob_Si_id_test =  Glob_Si_id_test[1:*]
    Glob_tray_id_test =  Glob_tray_id_test[1:*]
    Glob_pos_test = Glob_pos_test[1:*]
    Glob_zpos_test = Glob_zpos_test[1:*]
    Glob_energy_dep_test = Glob_energy_dep_test[1:*]
    
    
    ; Conversion from tray ID (starting from bottom) to plane ID (starting from the top)
    
    Glob_plane_id_test = intarr(n_elements(Glob_tray_id_test))
    
    for j=0l, n_elements(Glob_tray_id_test)-1 do begin
     if (Glob_Si_id_test(j) EQ 0) then begin
        temp_plane_x = Glob_tray_id_test(j) - N_plane
        if (temp_plane_x GT 0) then Glob_plane_id_test(j) = temp_plane_x else Glob_plane_id_test(j) = (-1.*temp_plane_x) + 2
     endif
     if (Glob_Si_id_test(j) EQ 1) then begin
        temp_plane_y = Glob_tray_id_test(j) - (N_plane-1)
        if (temp_plane_y GT 0) then Glob_plane_id_test(j) = temp_plane_y else Glob_plane_id_test(j) = (-1.*temp_plane_y) + 2
     endif
    endfor
    
    
    ; Level 0 = energy summed
    ; Level 0 = the events are sorted in tray, and Y before X within the same tray
    
    CREATE_STRUCT, L0TRACKERGLOBAL, 'GLOBALTRACKERL0', ['EVT_ID', 'VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'STRIP_TYPE', 'POS', 'ZPOS','E_DEP'], 'I,J,J,I,I,I,J,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_event_id_test)
    L0TRACKERGLOBAL.EVT_ID = Glob_event_id_test
    L0TRACKERGLOBAL.VOLUME_ID = Glob_vol_id_test
    L0TRACKERGLOBAL.MOTHER_ID = Glob_moth_id_test
    L0TRACKERGLOBAL.TRAY_ID = Glob_tray_id_test
    L0TRACKERGLOBAL.PLANE_ID = Glob_plane_id_test
    L0TRACKERGLOBAL.TRK_FLAG = Glob_Si_id_test
    L0TRACKERGLOBAL.STRIP_ID = Glob_Strip_id_test
    L0TRACKERGLOBAL.STRIP_TYPE = Glob_Strip_type_test
    L0TRACKERGLOBAL.POS = Glob_pos_test
    L0TRACKERGLOBAL.ZPOS = Glob_zpos_test
    L0TRACKERGLOBAL.E_DEP = Glob_energy_dep_test
    
    HDR_L0GLOBAL = ['Creator          = Valentina Fioretti', $
              'BoGEMMS release  = AGILE '+agile_version, $
              'N_IN             = '+STRTRIM(STRING(N_IN),1)+'   /Number of simulated particles', $
              'N_TRIG           = '+STRTRIM(STRING(N_TRIG),1)+'   /Number of triggering events', $
              'ENERGY           = '+STRTRIM(STRING(ENE_TYPE),1)+'   /Simulated input energy', $
              'THETA            = '+STRTRIM(STRING(THETA_TYPE),1)+'   /Simulated input theta angle', $
              'PHI              = '+STRTRIM(STRING(PHI_TYPE),1)+'   /Simulated input phi angle', $
              'ENERGY UNIT      = KEV']
    
    
    MWRFITS, L0TRACKERGLOBAL, outdir+'/L0.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+STRMID(STRTRIM(STRING(ENE_TYPE),1),0,10)+'MeV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.'+strtrim(string(ifile),1)+'.fits', HDR_L0GLOBAL, /CREATE
    
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '       L0.5 - ACCOPPIAMENTO CAPACITIVO '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
     
    
    Glob_vol_id_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_moth_id_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_Strip_id_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_Strip_type_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_Si_id_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_tray_id_x_acap = lonarr(Total_vol_x/2, N_trig) 
    Glob_xpos_x_acap = fltarr(Total_vol_x/2, N_trig) 
    Glob_zpos_x_acap = fltarr(Total_vol_x/2, N_trig) 
    Glob_energy_dep_x_acap = fltarr(Total_vol_x/2, N_trig) 
    
    Glob_vol_id_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_moth_id_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_Strip_id_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_Strip_type_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_Si_id_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_tray_id_y_acap = lonarr(Total_vol_y/2, N_trig) 
    Glob_ypos_y_acap = fltarr(Total_vol_y/2, N_trig) 
    Glob_zpos_y_acap = fltarr(Total_vol_y/2, N_trig) 
    Glob_energy_dep_y_acap = fltarr(Total_vol_y/2, N_trig) 
    
          
    
    for k=0l, N_trig-1 do begin
    
     N_start = 0l
     j=0l
     while (1) do begin
        where_tray_eq_x = where(Glob_tray_id_x(*, k) EQ Glob_tray_id_x(j, k))
        
        Glob_vol_id_x_tray = Glob_vol_id_x[where_tray_eq_x, k]
        Glob_moth_id_x_tray = Glob_moth_id_x[where_tray_eq_x, k]
        Glob_Strip_id_x_tray = Glob_Strip_id_x[where_tray_eq_x, k]
        Glob_Strip_type_x_tray = Glob_Strip_type_x[where_tray_eq_x, k]
        Glob_Si_id_x_tray = Glob_Si_id_x[where_tray_eq_x, k]
        Glob_tray_id_x_tray = Glob_tray_id_x[where_tray_eq_x, k]
        Glob_xpos_x_tray = Glob_xpos_x[where_tray_eq_x, k]
        Glob_zpos_x_tray = Glob_zpos_x[where_tray_eq_x, k]
        Glob_energy_dep_x_tray = Glob_energy_dep_x[where_tray_eq_x, k]
        
        where_layer_x = where(Glob_Si_id_x_tray EQ 0)
        if (where_layer_x(0) NE -1) then begin
          Glob_vol_id_x_tray = Glob_vol_id_x_tray[where_layer_x]
          Glob_moth_id_x_tray = Glob_moth_id_x_tray[where_layer_x]
          Glob_Strip_id_x_tray = Glob_Strip_id_x_tray[where_layer_x]
          Glob_Strip_type_x_tray = Glob_Strip_type_x_tray[where_layer_x]
          Glob_Si_id_x_tray = Glob_Si_id_x_tray[where_layer_x]
          Glob_tray_id_x_tray = Glob_tray_id_x_tray[where_layer_x]
          Glob_xpos_x_tray = Glob_xpos_x_tray[where_layer_x]
          Glob_zpos_x_tray = Glob_zpos_x_tray[where_layer_x]
          Glob_energy_dep_x_tray = Glob_energy_dep_x_tray[where_layer_x] 
    
          Glob_energy_dep_x_tray_fake = [0., 0., 0., 0., 0., Glob_energy_dep_x_tray, 0., 0., 0., 0., 0.]
          Glob_energy_dep_x_tray_fake = convol(Glob_energy_dep_x_tray_fake, acap)
          Glob_energy_dep_x_tray_fake = Glob_energy_dep_x_tray_fake[5:n_elements(Glob_energy_dep_x_tray_fake)-6]
    
          Glob_vol_id_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_moth_id_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_Strip_id_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_Strip_type_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_Si_id_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_tray_id_x_tray_acap = lonarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_xpos_x_tray_acap = dblarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_zpos_x_tray_acap = dblarr(n_elements(Glob_vol_id_x_tray)/2.)
          Glob_energy_dep_x_tray_acap = dblarr(n_elements(Glob_vol_id_x_tray)/2.)
          
          for i=0l, n_elements(Glob_vol_id_x_tray)-1 do begin
            if (Glob_Strip_type_x_tray(i) EQ 1) then begin    
                ro = 1. + (i-1.)/2.
                Glob_vol_id_x_tray_acap[ro-1] = Glob_vol_id_x_tray[i]
                Glob_moth_id_x_tray_acap[ro-1] = Glob_moth_id_x_tray[i]
                Glob_Strip_id_x_tray_acap[ro-1] = Glob_Strip_id_x_tray[i]
                Glob_Strip_type_x_tray_acap[ro-1] = Glob_Strip_type_x_tray[i]
                Glob_Si_id_x_tray_acap[ro-1] = Glob_Si_id_x_tray[i]
                Glob_tray_id_x_tray_acap[ro-1] = Glob_tray_id_x_tray[i]
                Glob_xpos_x_tray_acap[ro-1] = Glob_xpos_x_tray[i]
                Glob_zpos_x_tray_acap[ro-1] = Glob_zpos_x_tray[i]
                Glob_energy_dep_x_tray_acap[ro-1] = Glob_energy_dep_x_tray_fake[i] 
            endif
          endfor
            
            for r=0l, n_elements(Glob_vol_id_x_tray_acap) -1 do begin  
            Glob_vol_id_x_acap[N_start + r, k] = Glob_vol_id_x_tray_acap(r)
            Glob_moth_id_x_acap[N_start + r, k] = Glob_moth_id_x_tray_acap(r)
            Glob_Strip_id_x_acap[N_start + r, k] =  Glob_Strip_id_x_tray_acap(r)
            Glob_Strip_type_x_acap[N_start + r, k] =  Glob_Strip_type_x_tray_acap(r)
            Glob_Si_id_x_acap[N_start + r, k] =  Glob_Si_id_x_tray_acap(r)
            Glob_tray_id_x_acap[N_start + r, k] =  Glob_tray_id_x_tray_acap(r)
            Glob_xpos_x_acap[N_start + r, k] =  Glob_xpos_x_tray_acap(r)
            Glob_zpos_x_acap[N_start + r, k] =  Glob_zpos_x_tray_acap(r)
            Glob_energy_dep_x_acap[N_start + r, k] =  Glob_energy_dep_x_tray_acap(r)
          endfor
     
           N_start = N_start + n_elements(Glob_vol_id_x_tray_acap)
           
        endif
    
          
        N_tray_eq_x = n_elements(where_tray_eq_x)
        if where_tray_eq_x(N_tray_eq_x-1) LT (n_elements(Glob_tray_id_x(*,k))-1) then begin
          j = where_tray_eq_x(N_tray_eq_x-1)+1
        endif else break
     endwhile
    
    endfor
    
    
    for k=0l, N_trig-1 do begin
    
     N_start = 0l
     j=0l
     while (1) do begin
        where_tray_eq_y = where(Glob_tray_id_y(*,k) EQ Glob_tray_id_y(j, k))
        
        Glob_vol_id_y_tray = Glob_vol_id_y[where_tray_eq_y,k]
        Glob_moth_id_y_tray = Glob_moth_id_y[where_tray_eq_y,k]
        Glob_Strip_id_y_tray = Glob_Strip_id_y[where_tray_eq_y,k]
        Glob_Strip_type_y_tray = Glob_Strip_type_y[where_tray_eq_y,k]
        Glob_Si_id_y_tray = Glob_Si_id_y[where_tray_eq_y,k]
        Glob_tray_id_y_tray = Glob_tray_id_y[where_tray_eq_y,k]
        Glob_ypos_y_tray = Glob_ypos_y[where_tray_eq_y,k]
        Glob_zpos_y_tray = Glob_zpos_y[where_tray_eq_y,k]
        Glob_energy_dep_y_tray = Glob_energy_dep_y[where_tray_eq_y,k]
        
        where_layer_y = where(Glob_Si_id_y_tray EQ 1)
        if (where_layer_y(0) NE -1) then begin
          Glob_vol_id_y_tray = Glob_vol_id_y_tray[where_layer_y]
          Glob_moth_id_y_tray = Glob_moth_id_y_tray[where_layer_y]
          Glob_Strip_id_y_tray = Glob_Strip_id_y_tray[where_layer_y]
          Glob_Strip_type_y_tray = Glob_Strip_type_y_tray[where_layer_y]
          Glob_Si_id_y_tray = Glob_Si_id_y_tray[where_layer_y]
          Glob_tray_id_y_tray = Glob_tray_id_y_tray[where_layer_y]
          Glob_ypos_y_tray = Glob_ypos_y_tray[where_layer_y]
          Glob_zpos_y_tray = Glob_zpos_y_tray[where_layer_y]
          Glob_energy_dep_y_tray = Glob_energy_dep_y_tray[where_layer_y] 
    
          Glob_energy_dep_y_tray_fake = [0., 0., 0., 0., 0., Glob_energy_dep_y_tray, 0., 0., 0., 0., 0.]
          Glob_energy_dep_y_tray_fake = convol(Glob_energy_dep_y_tray_fake, acap)
          Glob_energy_dep_y_tray_fake = Glob_energy_dep_y_tray_fake[5:n_elements(Glob_energy_dep_y_tray_fake)-6]
    
          Glob_vol_id_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_moth_id_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_Strip_id_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_Strip_type_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_Si_id_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_tray_id_y_tray_acap = lonarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_ypos_y_tray_acap = dblarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_zpos_y_tray_acap = dblarr(n_elements(Glob_vol_id_y_tray)/2.)
          Glob_energy_dep_y_tray_acap = dblarr(n_elements(Glob_vol_id_y_tray)/2.)
          
          for i=0l, n_elements(Glob_vol_id_y_tray)-1 do begin
            if (Glob_Strip_type_y_tray(i) EQ 1) then begin    
                ro = 1. + (i-1.)/2.
                Glob_vol_id_y_tray_acap[ro-1] = Glob_vol_id_y_tray[i]
                Glob_moth_id_y_tray_acap[ro-1] = Glob_moth_id_y_tray[i]
                Glob_Strip_id_y_tray_acap[ro-1] = Glob_Strip_id_y_tray[i]
                Glob_Strip_type_y_tray_acap[ro-1] = Glob_Strip_type_y_tray[i]
                Glob_Si_id_y_tray_acap[ro-1] = Glob_Si_id_y_tray[i]
                Glob_tray_id_y_tray_acap[ro-1] = Glob_tray_id_y_tray[i]
                Glob_ypos_y_tray_acap[ro-1] = Glob_ypos_y_tray[i]
                Glob_zpos_y_tray_acap[ro-1] = Glob_zpos_y_tray[i]
                Glob_energy_dep_y_tray_acap[ro-1] = Glob_energy_dep_y_tray_fake[i] 
            endif
          endfor
     
          for r=0l, n_elements(Glob_vol_id_y_tray_acap) -1 do begin  
            Glob_vol_id_y_acap[N_start + r, k] = Glob_vol_id_y_tray_acap(r)
            Glob_moth_id_y_acap[N_start + r, k] = Glob_moth_id_y_tray_acap(r)
            Glob_Strip_id_y_acap[N_start + r, k] =  Glob_Strip_id_y_tray_acap(r)
            Glob_Strip_type_y_acap[N_start + r, k] =  Glob_Strip_type_y_tray_acap(r)
            Glob_Si_id_y_acap[N_start + r, k] =  Glob_Si_id_y_tray_acap(r)
            Glob_tray_id_y_acap[N_start + r, k] =  Glob_tray_id_y_tray_acap(r)
            Glob_ypos_y_acap[N_start + r, k] =  Glob_ypos_y_tray_acap(r)
            Glob_zpos_y_acap[N_start + r, k] =  Glob_zpos_y_tray_acap(r)
            Glob_energy_dep_y_acap[N_start + r, k] =  Glob_energy_dep_y_tray_acap(r)
          endfor
     
           N_start = N_start + n_elements(Glob_vol_id_y_tray_acap)
          
        endif
    
          
        N_tray_eq_y = n_elements(where_tray_eq_y)
        if where_tray_eq_y(N_tray_eq_y-1) LT (n_elements(Glob_tray_id_y(*,k))-1) then begin
          j = where_tray_eq_y(N_tray_eq_y-1)+1
        endif else break
     endwhile
    
    endfor
    
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '            0.25 MIP (27 keV) threshold   '
    print, '             L0.5 - X-Y layers merging '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    
    
    Glob_event_id_acap = -1l 
    Glob_vol_id_acap = -1l 
    Glob_moth_id_acap = -1l 
    Glob_Strip_id_acap = -1l 
    Glob_Strip_type_acap = -1l 
    Glob_Si_id_acap = -1l 
    Glob_tray_id_acap = -1l 
    Glob_pos_acap = -1.
    Glob_zpos_acap = -1. 
    Glob_energy_dep_acap = -1.
    
    
    for j=0l, N_trig -1 do begin
       
       where_acap_x = where(Glob_energy_dep_x_acap[*,j] GE E_th)
    
       if (where_acap_x(0) NE -1) then begin
         Glob_vol_id_x_acap_temp = Glob_vol_id_x_acap[where_acap_x,j]
         Glob_moth_id_x_acap_temp = Glob_moth_id_x_acap[where_acap_x,j]
         Glob_Strip_id_x_acap_temp = Glob_Strip_id_x_acap[where_acap_x,j]
         Glob_Strip_type_x_acap_temp = Glob_Strip_type_x_acap[where_acap_x,j]
         Glob_Si_id_x_acap_temp = Glob_Si_id_x_acap[where_acap_x,j]
         Glob_tray_id_x_acap_temp = Glob_tray_id_x_acap[where_acap_x,j]
         Glob_xpos_x_acap_temp = Glob_xpos_x_acap[where_acap_x,j]
         Glob_zpos_x_acap_temp = Glob_zpos_x_acap[where_acap_x,j]
         Glob_energy_dep_x_acap_temp = Glob_energy_dep_x_acap[where_acap_x,j]
       endif
    
    
       where_acap_y = where(Glob_energy_dep_y_acap[*,j] GE E_th)
     
       if (where_acap_y(0) NE -1) then begin
         Glob_vol_id_y_acap_temp = Glob_vol_id_y_acap[where_acap_y,j]
         Glob_moth_id_y_acap_temp = Glob_moth_id_y_acap[where_acap_y,j]
         Glob_Strip_id_y_acap_temp = Glob_Strip_id_y_acap[where_acap_y,j]
         Glob_Strip_type_y_acap_temp = Glob_Strip_type_y_acap[where_acap_y,j]
         Glob_Si_id_y_acap_temp = Glob_Si_id_y_acap[where_acap_y,j]
         Glob_tray_id_y_acap_temp = Glob_tray_id_y_acap[where_acap_y,j]
         Glob_ypos_y_acap_temp = Glob_ypos_y_acap[where_acap_y,j]
         Glob_zpos_y_acap_temp = Glob_zpos_y_acap[where_acap_y,j]
         Glob_energy_dep_y_acap_temp = Glob_energy_dep_y_acap[where_acap_y,j]
       endif
    
       if ((where_acap_y(0) NE -1) AND (where_acap_x(0) NE -1)) then begin
        Glob_vol_id_acap_temp = [Glob_vol_id_y_acap_temp, Glob_vol_id_x_acap_temp]
        Glob_moth_id_acap_temp = [Glob_moth_id_y_acap_temp, Glob_moth_id_x_acap_temp]
        Glob_Strip_id_acap_temp = [Glob_Strip_id_y_acap_temp, Glob_Strip_id_x_acap_temp]
        Glob_Strip_type_acap_temp = [Glob_Strip_type_y_acap_temp, Glob_Strip_type_x_acap_temp]
        Glob_Si_id_acap_temp = [Glob_Si_id_y_acap_temp, Glob_Si_id_x_acap_temp]
        Glob_tray_id_acap_temp = [Glob_tray_id_y_acap_temp, Glob_tray_id_x_acap_temp]
        Glob_pos_acap_temp = [Glob_ypos_y_acap_temp, Glob_xpos_x_acap_temp]
        Glob_zpos_acap_temp = [Glob_zpos_y_acap_temp, Glob_zpos_x_acap_temp]
        Glob_energy_dep_acap_temp = [Glob_energy_dep_y_acap_temp, Glob_energy_dep_x_acap_temp]
       endif else begin
        if ((where_acap_y(0) NE -1) AND (where_acap_x(0) EQ -1)) then begin
         Glob_vol_id_acap_temp = Glob_vol_id_y_acap_temp
         Glob_moth_id_acap_temp = Glob_moth_id_y_acap_temp
         Glob_Strip_id_acap_temp = Glob_Strip_id_y_acap_temp
         Glob_Strip_type_acap_temp = Glob_Strip_type_y_acap_temp
         Glob_Si_id_acap_temp = Glob_Si_id_y_acap_temp
         Glob_tray_id_acap_temp = Glob_tray_id_y_acap_temp
         Glob_pos_acap_temp = Glob_ypos_y_acap_temp
         Glob_zpos_acap_temp = Glob_zpos_y_acap_temp
         Glob_energy_dep_acap_temp = Glob_energy_dep_y_acap_temp
        endif else begin
         if ((where_acap_y(0) EQ -1) AND (where_acap_x(0) NE -1)) then begin
          Glob_vol_id_acap_temp = Glob_vol_id_x_acap_temp
          Glob_moth_id_acap_temp = Glob_moth_id_x_acap_temp
          Glob_Strip_id_acap_temp = Glob_Strip_id_x_acap_temp
          Glob_Strip_type_acap_temp = Glob_Strip_type_x_acap_temp
          Glob_Si_id_acap_temp = Glob_Si_id_x_acap_temp
          Glob_tray_id_acap_temp = Glob_tray_id_x_acap_temp
          Glob_pos_acap_temp = Glob_xpos_x_acap_temp
          Glob_zpos_acap_temp = Glob_zpos_x_acap_temp
          Glob_energy_dep_acap_temp = Glob_energy_dep_x_acap_temp
         endif
        endelse
       endelse   
       
       tray_sort_arr = sort(Glob_tray_id_acap_temp)
        
       Glob_vol_id_acap_temp = Glob_vol_id_acap_temp[reverse(tray_sort_arr)]
       Glob_moth_id_acap_temp = Glob_moth_id_acap_temp[reverse(tray_sort_arr)]
       Glob_Strip_id_acap_temp = Glob_Strip_id_acap_temp[reverse(tray_sort_arr)]
       Glob_Strip_type_acap_temp = Glob_Strip_type_acap_temp[reverse(tray_sort_arr)]
       Glob_Si_id_acap_temp = Glob_Si_id_acap_temp[reverse(tray_sort_arr)]
       Glob_tray_id_acap_temp = Glob_tray_id_acap_temp[reverse(tray_sort_arr)]
       Glob_pos_acap_temp = Glob_pos_acap_temp[reverse(tray_sort_arr)]
       Glob_zpos_acap_temp = Glob_zpos_acap_temp[reverse(tray_sort_arr)]
       Glob_energy_dep_acap_temp = Glob_energy_dep_acap_temp[reverse(tray_sort_arr)]
    
       vol_id_intray = -1l
       moth_id_intray = -1l
       Strip_id_intray = -1l
       Strip_type_intray = -1l
       Si_id_intray = -1l
       tray_id_intray = -1l
       pos_intray = -1.
       zpos_intray = -1.
       energy_dep_intray = -1.
           
        intray = 0l
        while(1) do begin
           where_tray_eq = where(Glob_tray_id_acap_temp EQ Glob_tray_id_acap_temp(intray), complement = where_other_tray)
           
           vol_id_extract = Glob_vol_id_acap_temp[where_tray_eq]
           moth_id_extract = Glob_moth_id_acap_temp[where_tray_eq]
           Strip_id_extract = Glob_Strip_id_acap_temp[where_tray_eq]
           Strip_type_extract = Glob_Strip_type_acap_temp[where_tray_eq]
           Si_id_extract = Glob_Si_id_acap_temp[where_tray_eq]
           tray_id_extract = Glob_tray_id_acap_temp[where_tray_eq]
           pos_extract = Glob_pos_acap_temp[where_tray_eq]
           zpos_extract = Glob_zpos_acap_temp[where_tray_eq]
           energy_dep_extract = Glob_energy_dep_acap_temp[where_tray_eq]
           
           where_Y = where(Si_id_extract EQ 1)
           if (where_Y(0) NE -1) then begin
             vol_id_intray = [vol_id_intray, vol_id_extract[where_Y]]
             moth_id_intray = [moth_id_intray, moth_id_extract[where_Y]]
             Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_Y]]
             Strip_type_intray = [Strip_type_intray, Strip_type_extract[where_Y]]
             Si_id_intray = [Si_id_intray, Si_id_extract[where_Y]]
             tray_id_intray = [tray_id_intray, tray_id_extract[where_Y]]
             pos_intray = [pos_intray, pos_extract[where_Y]]
             zpos_intray = [zpos_intray, zpos_extract[where_Y]]
             energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_Y]]         
           endif
           where_X = where(Si_id_extract EQ 0)
           if (where_X(0) NE -1) then begin
             vol_id_intray = [vol_id_intray, vol_id_extract[where_X]]
             moth_id_intray = [moth_id_intray, moth_id_extract[where_X]]
             Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_X]]
             Strip_type_intray = [Strip_type_intray, Strip_type_extract[where_X]]
             Si_id_intray = [Si_id_intray, Si_id_extract[where_X]]
             tray_id_intray = [tray_id_intray, tray_id_extract[where_X]]
             pos_intray = [pos_intray, pos_extract[where_X]]
             zpos_intray = [zpos_intray, zpos_extract[where_X]]
             energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_X]]         
           endif
         N_tray_eq = n_elements(where_tray_eq)
         if where_tray_eq(N_tray_eq-1) LT (n_elements(Glob_tray_id_acap_temp)-1) then begin
          intray = where_tray_eq(N_tray_eq-1)+1
         endif else break
        endwhile
        
        vol_id_temp = vol_id_intray[1:*]
        moth_id_temp = moth_id_intray[1:*]
        Strip_id_temp = Strip_id_intray[1:*]
        Strip_type_temp = Strip_type_intray[1:*]
        Si_id_temp = Si_id_intray[1:*]
        tray_id_temp = tray_id_intray[1:*]
        pos_temp = pos_intray[1:*]
        zpos_temp = zpos_intray[1:*]
        energy_dep_temp = energy_dep_intray[1:*]
        
        event_id_temp = lonarr(n_elements(vol_id_temp))
        for k=0l, n_elements(vol_id_temp)-1 do begin
         event_id_temp(k) = event_array(j)
        endfor
        
        Glob_event_id_acap = [Glob_event_id_acap, event_id_temp]
        Glob_vol_id_acap = [Glob_vol_id_acap, vol_id_temp]
        Glob_moth_id_acap= [Glob_moth_id_acap, moth_id_temp] 
        Glob_Strip_id_acap = [Glob_Strip_id_acap, Strip_id_temp]
        Glob_Strip_type_acap = [Glob_Strip_type_acap, Strip_type_temp]
        Glob_Si_id_acap = [Glob_Si_id_acap, Si_id_temp]
        Glob_tray_id_acap = [Glob_tray_id_acap, tray_id_temp]
        Glob_pos_acap = [Glob_pos_acap, pos_temp]
        Glob_zpos_acap = [Glob_zpos_acap, zpos_temp]
        Glob_energy_dep_acap = [Glob_energy_dep_acap, energy_dep_temp]
    
    endfor
    
    Glob_event_id_acap = Glob_event_id_acap[1:*]
    Glob_vol_id_acap =  Glob_vol_id_acap[1:*]
    Glob_moth_id_acap =  Glob_moth_id_acap[1:*]
    Glob_Strip_id_acap =  Glob_Strip_id_acap[1:*]
    Glob_Strip_type_acap =  Glob_Strip_type_acap[1:*]
    Glob_Si_id_acap =  Glob_Si_id_acap[1:*]
    Glob_tray_id_acap =  Glob_tray_id_acap[1:*]
    Glob_pos_acap = Glob_pos_acap[1:*]
    Glob_zpos_acap = Glob_zpos_acap[1:*]
    Glob_energy_dep_acap = Glob_energy_dep_acap[1:*]
    
    
    ; Conversion from tray ID (starting from bottom) to plane ID (starting from the top)
    
    Glob_plane_id_acap = intarr(n_elements(Glob_tray_id_acap))
    
    for j=0l, n_elements(Glob_tray_id_acap)-1 do begin
     if (Glob_Si_id_acap(j) EQ 0) then begin
        temp_plane_x = Glob_tray_id_acap(j) - N_plane
        if (temp_plane_x GT 0) then Glob_plane_id_acap(j) = temp_plane_x else Glob_plane_id_acap(j) = (-1.*temp_plane_x) + 2
     endif
     if (Glob_Si_id_acap(j) EQ 1) then begin
        temp_plane_y = Glob_tray_id_acap(j) - (N_plane-1)
        if (temp_plane_y GT 0) then Glob_plane_id_acap(j) = temp_plane_y else Glob_plane_id_acap(j) = (-1.*temp_plane_y) + 2
     endif
    endfor
    
    ; Level 0 = energy summed
    ; Level 0 = the events are sorted in tray, and Y before X within the same tray
    
    CREATE_STRUCT, L05TRACKERGLOBAL, 'GLOBALTRACKERL05', ['EVT_ID', 'VOLUME_ID', 'MOTHER_ID', 'TRAY_ID','PLANE_ID','TRK_FLAG', 'STRIP_ID', 'STRIP_TYPE', 'POS', 'ZPOS','E_DEP'], 'J,J,J,I,I,I,J,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_event_id_acap)
    L05TRACKERGLOBAL.EVT_ID = Glob_event_id_acap
    L05TRACKERGLOBAL.VOLUME_ID = Glob_vol_id_acap
    L05TRACKERGLOBAL.MOTHER_ID = Glob_moth_id_acap
    L05TRACKERGLOBAL.TRAY_ID = Glob_tray_id_acap
    L05TRACKERGLOBAL.PLANE_ID = Glob_plane_id_acap
    L05TRACKERGLOBAL.TRK_FLAG = Glob_Si_id_acap
    L05TRACKERGLOBAL.STRIP_ID = Glob_Strip_id_acap
    L05TRACKERGLOBAL.STRIP_TYPE = Glob_Strip_type_acap
    L05TRACKERGLOBAL.POS = Glob_pos_acap
    L05TRACKERGLOBAL.ZPOS = Glob_zpos_acap
    L05TRACKERGLOBAL.E_DEP = Glob_energy_dep_acap
    
    HDR_L05GLOBAL = ['Creator          = Valentina Fioretti', $
              'BoGEMMS release  = AGILE '+agile_version, $
              'N_IN             = '+STRTRIM(STRING(N_IN),1)+'   /Number of simulated particles', $
              'N_TRIG           = '+STRTRIM(STRING(N_TRIG),1)+'   /Number of triggering events', $
              'ENERGY           = '+STRTRIM(STRING(ENE_TYPE),1)+'   /Simulated input energy', $
              'THETA            = '+STRTRIM(STRING(THETA_TYPE),1)+'   /Simulated input theta angle', $
              'PHI              = '+STRTRIM(STRING(PHI_TYPE),1)+'   /Simulated input phi angle', $
              'ENERGY UNIT      = KEV']
    
    
    MWRFITS, L05TRACKERGLOBAL, outdir+'/L0.5.DIGI.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+'ph.'+STRMID(STRTRIM(STRING(ENE_TYPE),1),0,10)+'MeV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.'+strtrim(string(ifile),1)+'.fits', HDR_L05GLOBAL, /CREATE
    
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '            Saving the Kalman input file   '
    print, '                    DIGI = yes '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    
    openw,lun,outdir+'/G4.DIGI.KALMAN.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = Silicon layer ID
    ; - c3 = x/y pos [cm]
    ; - c4 = z pos [cm]
    ; - c5 = plane ID
    ; - c6 = strip ID
    ; - c7 = energy dep [keV]
 
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(Glob_event_id_acap EQ Glob_event_id_acap(j))
        Glob_Si_id_acap_temp = Glob_Si_id_acap(where_event_eq)
        Glob_Strip_id_acap_temp = Glob_Strip_id_acap(where_event_eq)
        Glob_tray_id_acap_temp  = Glob_tray_id_acap(where_event_eq)
        Glob_plane_id_acap_temp  = Glob_plane_id_acap(where_event_eq)
        Glob_energy_dep_acap_temp = Glob_energy_dep_acap(where_event_eq)    
        Glob_pos_acap_temp = Glob_pos_acap(where_event_eq)
        Glob_zpos_acap_temp = Glob_zpos_acap(where_event_eq)
    
        ;printf, lun, '; Event:', Glob_event_id_acap(j)
        ;printf, lun, '; ', theta_type, phi_type, ene_type   
        
        
        where_x = where(Glob_Si_id_acap_temp EQ 0)
        if (where_x(0) NE -1) then begin
         for r=0l, n_elements(where_x)-1 do begin
            printf, lun, Glob_event_id_acap(j), Glob_Si_id_acap_temp(where_x(r)), Glob_pos_acap_temp(where_x(r)), Glob_zpos_acap_temp(where_x(r)), Glob_plane_id_acap_temp(where_x(r)), Glob_Strip_id_acap_temp(where_x(r)), Glob_energy_dep_acap_temp(where_x(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,F10.5)'
            
         endfor
        endif
        where_y = where(Glob_Si_id_acap_temp EQ 1)    
        if (where_y(0) NE -1) then begin
         for r=0l, n_elements(where_y)-1 do begin
            printf, lun, Glob_event_id_acap(j), Glob_Si_id_acap_temp(where_y(r)), Glob_pos_acap_temp(where_y(r)), Glob_zpos_acap_temp(where_y(r)), Glob_plane_id_acap_temp(where_y(r)), Glob_Strip_id_acap_temp(where_y(r)), Glob_energy_dep_acap_temp(where_y(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,F10.5)'
            
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_acap)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    openw,lun,outdir+'/G4.DIGI.GENERAL.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = Silicon layer ID
    ; - c3 = x/y pos [cm]
    ; - c4 = z pos [cm]
    ; - c5 = tray ID
    ; - c6 = plane ID
    ; - c7 = strip ID 
    ; - c8 = energy dep [keV]    
  
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(Glob_event_id_acap EQ Glob_event_id_acap(j))
        Glob_Si_id_acap_temp = Glob_Si_id_acap(where_event_eq)
        Glob_Strip_id_acap_temp = Glob_Strip_id_acap(where_event_eq)
        Glob_tray_id_acap_temp  = Glob_tray_id_acap(where_event_eq)
        Glob_plane_id_acap_temp  = Glob_plane_id_acap(where_event_eq)
        Glob_energy_dep_acap_temp = Glob_energy_dep_acap(where_event_eq)    
        Glob_pos_acap_temp = Glob_pos_acap(where_event_eq)
        Glob_zpos_acap_temp = Glob_zpos_acap(where_event_eq)
    
        
        where_x = where(Glob_Si_id_acap_temp EQ 0)
        if (where_x(0) NE -1) then begin
         for r=0l, n_elements(where_x)-1 do begin
            printf, lun, Glob_event_id_acap(j), Glob_Si_id_acap_temp(where_x(r)), Glob_pos_acap_temp(where_x(r)), Glob_zpos_acap_temp(where_x(r)), Glob_tray_id_acap_temp(where_x(r)), Glob_plane_id_acap_temp(where_x(r)), Glob_Strip_id_acap_temp(where_x(r)), Glob_energy_dep_acap_temp(where_x(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,I5,2x,F10.5)'
            
         endfor
        endif
        where_y = where(Glob_Si_id_acap_temp EQ 1)    
        if (where_y(0) NE -1) then begin
         for r=0l, n_elements(where_y)-1 do begin
            printf, lun, Glob_event_id_acap(j), Glob_Si_id_acap_temp(where_y(r)), Glob_pos_acap_temp(where_y(r)), Glob_zpos_acap_temp(where_y(r)), Glob_tray_id_acap_temp(where_y(r)), Glob_plane_id_acap_temp(where_y(r)), Glob_Strip_id_acap_temp(where_y(r)), Glob_energy_dep_acap_temp(where_y(r)), format='(I5,2x,I5,2x,F10.5,2x,F10.5,2x,I5,2x,I5,2x,I5,2x,F10.5)'
            
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_acap)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                      Tracker   '
    print, '            Saving the DHSim input file   '
    print, '                    DIGI = yes '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    
    openw,lun,outdir+'/G4_GAMS_YPLANE_AGILE'+agile_version+'_'+py_name+'_'+sim_name+'.'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = plane ID
    ; - c3 = readout strip ID
    ; - c4 = -999
    ; - c5 = -999
    ; - c6 = energy dep in MIP
    ; - c7 = -999
      
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(Glob_event_id_acap EQ Glob_event_id_acap(j))
        Glob_Si_id_acap_temp = Glob_Si_id_acap(where_event_eq)
        Glob_Strip_id_acap_temp = Glob_Strip_id_acap(where_event_eq)
        Glob_tray_id_acap_temp  = Glob_tray_id_acap(where_event_eq)
        Glob_plane_id_acap_temp  = Glob_plane_id_acap(where_event_eq)
        Glob_energy_dep_acap_temp = Glob_energy_dep_acap(where_event_eq)    
        Glob_pos_acap_temp = Glob_pos_acap(where_event_eq)
        Glob_zpos_acap_temp = Glob_zpos_acap(where_event_eq)
        
        ; The strip readout id changed from 0 - 3071 range to 0 - 1536
        Glob_Strip_readout_id_acap_temp = Glob_Strip_id_acap_temp/2
        ; The energy deposit is converted to MIP
        Glob_energy_dep_mip_acap_temp = Glob_energy_dep_acap_temp/108.
        where_x = where(Glob_Si_id_acap_temp EQ 0)
        if (where_x(0) NE -1) then begin
         for r=0l, n_elements(where_x)-1 do begin
            printf, lun, (Glob_event_id_acap(j)+1), Glob_plane_id_acap_temp(where_x(r)), Glob_Strip_readout_id_acap_temp(where_x(r)), -999, -999, Glob_energy_dep_mip_acap_temp(where_x(r)), -999, format='(I5,I5,I5,I5,I5,F10.5,I5)'
            
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_acap)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    openw,lun,outdir+'/G4_GAMS_XPLANE_AGILE'+agile_version+'_'+py_name+'_'+sim_name+'.'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = plane ID
    ; - c3 = readout strip ID
    ; - c4 = -999
    ; - c5 = -999
    ; - c6 = energy dep in MIP
    ; - c7 = -999    
    
    event_start = -1
    j=0l
    while (1) do begin
        where_event_eq = where(Glob_event_id_acap EQ Glob_event_id_acap(j))
        Glob_Si_id_acap_temp = Glob_Si_id_acap(where_event_eq)
        Glob_Strip_id_acap_temp = Glob_Strip_id_acap(where_event_eq)
        Glob_tray_id_acap_temp  = Glob_tray_id_acap(where_event_eq)
        Glob_plane_id_acap_temp  = Glob_plane_id_acap(where_event_eq)
        Glob_energy_dep_acap_temp = Glob_energy_dep_acap(where_event_eq)    
        Glob_pos_acap_temp = Glob_pos_acap(where_event_eq)
        Glob_zpos_acap_temp = Glob_zpos_acap(where_event_eq)
    
        ; The strip readout id changed from 0 - 3071 range to 0 - 1535
        Glob_Strip_readout_id_acap_temp = Glob_Strip_id_acap_temp/2
        ; The energy deposit is converted to MIP
        Glob_energy_dep_mip_acap_temp = Glob_energy_dep_acap_temp/108.
        
        ; Inverting the Yv strip value to obtain the Xk value
        Glob_Strip_GAMS_id_acap_temp = lonarr(n_elements(Glob_Strip_readout_id_acap_temp))
        for jstrip=0, n_elements(Glob_Strip_readout_id_acap_temp)-1 do begin
            Glob_Strip_GAMS_id_acap_temp(jstrip) = ((N_strip/2)-1) - Glob_Strip_readout_id_acap_temp(jstrip)   
        endfor
            
        where_y = where(Glob_Si_id_acap_temp EQ 1)    
        if (where_y(0) NE -1) then begin
         for r=0l, n_elements(where_y)-1 do begin
            printf, lun, (Glob_event_id_acap(j)+1), Glob_plane_id_acap_temp(where_y(r)), Glob_Strip_GAMS_id_acap_temp(where_y(r)), -999, -999, Glob_energy_dep_mip_acap_temp(where_y(r)), -999, format='(I5,I5,I5,I5,I5,F10.5,I5)'
            
         endfor
        endif
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_acap)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    Free_lun, lun


    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ;                             Processing the calorimeter 
    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '          Calorimeter Bar Energy attenuation                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    bar_plane = intarr(n_elements(event_id_cal))
    bar_id = intarr(n_elements(event_id_cal))
    ene_a = dblarr(n_elements(event_id_cal))
    ene_b = dblarr(n_elements(event_id_cal))    
    

    for j=0l, n_elements(event_id_cal) - 1 do begin
     if ((vol_id_cal(j)-cal_vol_start) LT n_bars) then begin
         ; XBAR in the KALMAN system
         bar_plane(j) = 1
         bar_id(j) = (vol_id_cal(j)-cal_vol_start) + 1
         x_pos_cal = ent_y_cal(j) + ((exit_y_cal(j) - ent_y_cal(j))/2.)
         t_b = (bar_side/2.) + x_pos_cal
         t_a = (bar_side/2.) - x_pos_cal
         ene_a(j) = (energy_dep_cal(j))*exp(-(att_a_x(bar_id(j)-1))*t_a)
         ene_b(j) = (energy_dep_cal(j))*exp(-(att_b_x(bar_id(j)-1))*t_b)
     endif else begin
         ; YBAR in the KALMAN system
         bar_plane(j) = 2
         bar_id(j) = (vol_id_cal(j)-cal_vol_y_start) + 1
         y_pos_cal = ent_x_cal(j) + ((exit_x_cal(j) - ent_x_cal(j))/2.)
         t_a = (bar_side/2.) + y_pos_cal
         t_b = (bar_side/2.) - y_pos_cal
         ene_a(j) = (energy_dep_cal(j))*exp(-(att_a_y(bar_id(j)-1))*t_a)
         ene_b(j) = (energy_dep_cal(j))*exp(-(att_b_y(bar_id(j)-1))*t_b)
     endelse
    endfor
    
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                   Calorimeter                '
    print, '              Applying the minimum cut                '
    print, '                Summing the energy                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    N_trig_cal = 0l
    
    event_id_tot_cal = -1l
    vol_id_tot_cal = -1l
    moth_id_tot_cal = -1l
    bar_plane_tot = -1l
    bar_id_tot = -1l
    ene_a_tot = -1.
    ene_b_tot = -1.
    
    j=0l
    while (1) do begin
        where_event_eq = where(event_id_cal EQ event_id_cal(j))
        
        N_trig_cal = N_trig_cal + 1
        
        vol_id_temp_cal = vol_id_cal(where_event_eq) 
        moth_id_temp_cal = moth_id_cal(where_event_eq) 
        bar_plane_temp = bar_plane(where_event_eq) 
        bar_id_temp = bar_id(where_event_eq) 
        ene_a_temp = ene_a(where_event_eq)
        ene_b_temp = ene_b(where_event_eq)
            
        r = 0l
        while(1) do begin
           where_vol_eq = where(vol_id_temp_cal EQ vol_id_temp_cal(r), complement = where_other_vol)
           event_id_tot_cal = [event_id_tot_cal, event_id_cal(j)]
           vol_id_tot_cal = [vol_id_tot_cal, vol_id_temp_cal(r)]
           moth_id_tot_cal = [moth_id_tot_cal, moth_id_temp_cal(r)]
           bar_plane_tot = [bar_plane_tot, bar_plane_temp(r)]
           bar_id_tot = [bar_id_tot, bar_id_temp(r)]
           ene_a_tot = [ene_a_tot, total(ene_a_temp(where_vol_eq))]
           ene_b_tot = [ene_b_tot, total(ene_b_temp(where_vol_eq))]
           if (where_other_vol(0) NE -1) then begin
             vol_id_temp_cal = vol_id_temp_cal(where_other_vol)
             moth_id_temp_cal = moth_id_temp_cal(where_other_vol)
             bar_plane_temp = bar_plane_temp(where_other_vol)
             bar_id_temp = bar_id_temp(where_other_vol)
             ene_a_temp = ene_a_temp(where_other_vol)
             ene_b_temp = ene_b_temp(where_other_vol)
           endif else break
        endwhile
            
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id_cal)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    
    if (n_elements(event_id_tot_cal) GT 1) then begin
      event_id_tot_cal = event_id_tot_cal[1:*]
      vol_id_tot_cal = vol_id_tot_cal[1:*]
      moth_id_tot_cal = moth_id_tot_cal[1:*]
      bar_plane_tot = bar_plane_tot[1:*]
      bar_id_tot = bar_id_tot[1:*]
      ene_a_tot = ene_a_tot[1:*]
      ene_b_tot = ene_b_tot[1:*]
    endif
    
    
    
    CREATE_STRUCT, calInput, 'input_cal_dhsim', ['EVT_ID', 'BAR_PLANE', 'BAR_ID', 'ENERGY_A', 'ENERGY_B'], $
    'I,I,I,F20.15,F20.15', DIMEN = n_elements(event_id_tot_cal)
    calInput.EVT_ID = event_id_tot_cal
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
    
    MWRFITS, calInput, outdir+'/G4.CAL.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.fits', hdr_calInput, /create
    
    openw,lun,outdir+'/G4_GAMS_CAL_AGILE'+agile_version+'_'+py_name+'_'+sim_name+'.'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = bar plane 
    ; - c3 = bar_id
    ; - c4 = 0
    ; - c5 = energy A
    ; - c6 = energy B
    
    ; Invert the BAR id to fit with the GAMS system
    ; BoGEMMS XBARv gives the inverted GAMS YBARk
    ; BoGEMMS YBARv gives the GAMS XBARk
    
    
    gams_bar_plane_tot = intarr(n_elements(bar_plane_tot))
    gams_bar_id_tot = intarr(n_elements(bar_id_tot))
    for jcal=0, n_elements(event_id_tot_cal)-1 do begin
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
        printf, lun, (event_id_tot_cal(j)+1), gams_bar_plane_tot(j), gams_bar_id_tot(j), 0, ene_a_tot(j),ene_b_tot(j);, format='(I5,2x,I5,2x,I5,2x,I5,2x,F10.10,2x,F10.10)'

        if (j LT (n_elements(event_id_tot_cal)-1)) then begin
          j = j+1
        endif else break
    endwhile
    
    Free_lun, lun


    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                          AC'
    print, '                  Summing the energy                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    
    N_trig_ac = 0l
    
    event_id_tot_ac = -1l
    vol_id_tot_ac = -1l
    moth_id_tot_ac = -1l
    energy_dep_tot_ac = -1.
    
    j=0l
    while (1) do begin
        where_event_eq = where(event_id_ac EQ event_id_ac(j))
        
        N_trig_ac = N_trig_ac + 1
        
        vol_id_temp_ac = vol_id_ac(where_event_eq) 
        moth_id_temp_ac = moth_id_ac(where_event_eq) 
        energy_dep_temp_ac = energy_dep_ac(where_event_eq) 
            
        r = 0l
        while(1) do begin
           where_vol_eq = where(vol_id_temp_ac EQ vol_id_temp_ac(r), complement = where_other_vol)
           event_id_tot_ac = [event_id_tot_ac, event_id_ac(j)]
           vol_id_tot_ac = [vol_id_tot_ac, vol_id_temp_ac(r)]
           moth_id_tot_ac = [moth_id_tot_ac, moth_id_temp_ac(r)]
           energy_dep_tot_ac = [energy_dep_tot_ac, total(energy_dep_temp_ac(where_vol_eq))]
           if (where_other_vol(0) NE -1) then begin
             vol_id_temp_ac = vol_id_temp_ac(where_other_vol)
             moth_id_temp_ac = moth_id_temp_ac(where_other_vol)
             energy_dep_temp_ac = energy_dep_temp_ac(where_other_vol)
           endif else break
        endwhile
            
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id_ac)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
    endwhile
    
    
    if (n_elements(event_id_tot_ac) GT 1) then begin
      event_id_tot_ac = event_id_tot_ac[1:*]
      vol_id_tot_ac = vol_id_tot_ac[1:*]
      moth_id_tot_ac = moth_id_tot_ac[1:*]
      energy_dep_tot_ac = energy_dep_tot_ac[1:*]
    endif
    
    ; AC panel IDs
    
    AC_panel = strarr(n_elements(vol_id_tot_ac))
    AC_subpanel = intarr(n_elements(vol_id_tot_ac))
    
    
    for j=0l, n_elements(vol_id_tot_ac)-1 do begin
     if ((vol_id_tot_ac(j) GE panel_S[0]) AND (vol_id_tot_ac(j) LE panel_S[2])) then begin
        AC_panel(j) = 'S'
        if (vol_id_tot_ac(j) EQ panel_S[0]) then AC_subpanel(j) = 3
        if (vol_id_tot_ac(j) EQ panel_S[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_S[2]) then AC_subpanel(j) = 1
     endif
     if ((vol_id_tot_ac(j) GE panel_D[0]) AND (vol_id_tot_ac(j) LE panel_D[2])) then begin
        AC_panel(j) = 'D'
        if (vol_id_tot_ac(j) EQ panel_D[0]) then AC_subpanel(j) = 3
        if (vol_id_tot_ac(j) EQ panel_D[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_D[2]) then AC_subpanel(j) = 1
     endif
     if ((vol_id_tot_ac(j) GE panel_F[0]) AND (vol_id_tot_ac(j) LE panel_F[2])) then begin
        AC_panel(j) = 'F'
        if (vol_id_tot_ac(j) EQ panel_F[0]) then AC_subpanel(j) = 1
        if (vol_id_tot_ac(j) EQ panel_F[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_F[2]) then AC_subpanel(j) = 3
     endif
     if ((vol_id_tot_ac(j) GE panel_B[0]) AND (vol_id_tot_ac(j) LE panel_B[2])) then begin
        AC_panel(j) = 'B'
        if (vol_id_tot_ac(j) EQ panel_B[0]) then AC_subpanel(j) = 1
        if (vol_id_tot_ac(j) EQ panel_B[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_B[2]) then AC_subpanel(j) = 3
     endif
     if (vol_id_tot_ac(j) EQ panel_top) then begin
        AC_panel(j) = 'T'
        AC_subpanel(j) = 0
     endif
    endfor
    
    CREATE_STRUCT, acInput, 'input_ac_dhsim', ['EVT_ID', 'AC_PANEL', 'AC_SUBPANEL', 'E_DEP'], $
    'I,A,I,F20.15', DIMEN = n_elements(event_id_tot_ac)
    acInput.EVT_ID = event_id_tot_ac
    acInput.AC_PANEL = AC_panel
    acInput.AC_SUBPANEL = AC_subpanel
    acInput.E_DEP = energy_dep_tot_ac
    
    
    hdr_acInput = ['COMMENT  AGILE V2.0 Geant4 simulation', $
                   'N_in     = '+strtrim(string(N_in),1), $
                   'Energy     = '+strtrim(string(ene_type),1), $
                   'Theta     = '+strtrim(string(theta_type),1), $
                   'Phi     = '+strtrim(string(phi_type),1), $
                   'Energy unit = GeV']
    
    MWRFITS, acInput, outdir+'/G4.AC.AGILE'+agile_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+'ph.'+strmid(strtrim(string(ene_type),1),0,10)+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.fits', hdr_acInput, /create
    
    openw,lun,outdir+'/G4_GAMS_AC_AGILE'+agile_version+'_'+py_name+'_'+sim_name+'.'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+'ph_'+strmid(strtrim(string(ene_type),1),0,10)+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+strtrim(string(ifile),1)+'.dat',/get_lun
    ; ASCII Columns:
    ; - c1 = event ID
    ; - c2 = AC panel
    ; - c3 = AC subpanel
    ; - c4 = energy deposit

    
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
        printf, lun, (event_id_tot_ac(j)+1),gams_AC_panel(j), AC_subpanel(j), energy_dep_tot_ac(j), format='(I5,2x,A,2x,I5,2x,F20.15)'
    
        if (j LT (n_elements(event_id_tot_ac)-1)) then begin
          j = j+1
        endif else break
    endwhile
    
    Free_lun, lun
    
    endfor
end
