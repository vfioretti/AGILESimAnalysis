; agilev2_geometry.pro - Description
; ---------------------------------------------------------------------------------
; Computing the AGILE tracker strip position and the GPS set-up
; ---------------------------------------------------------------------------------
; copyright            : (C) 2013 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; agilev2_geometry
; ---------------------------------------------------------------------------------
; Notes:
; GPS theta, phi amd height set to 30, 225 and 150
; Tracker geometry based on the AGILE V2.0 mass model


pro AGILEV2_geometry

outdir = './conf/
print, 'Configuration files path: ', outdir

CheckOutDir = DIR_EXIST( outdir)
if (CheckOutDir EQ 0) then spawn,'mkdir -p ./conf'


theta_deg = 30.0d
;phi_deg = 292.5d
phi_deg = 225d
theta = theta_deg*(!PI/180.d)
phi = phi_deg*(!PI/180.d)

; source height
h_s = 150.d  ;cm

; Global Geometry:
N_tray = 13l  
N_layer = 2l
N_strip = 3072l
pitch = 0.121   ;mm
Tray_side = 371.712  ;mm

; Tracker geometry [mm]
Si_t = 0.410
;Glue_t = 0.001
Glue_t = 0.0
K_t = 0.05
CF_t = 0.5
;Conv_t = 0.245
Conv_t = 0.245


plane_distance = 18.7  ;mm
dist_tray = 2.   ;mm

Al_t = plane_distance - dist_tray - (Si_t + Glue_t + K_t + Conv_t) - (K_t + Glue_t + Si_t) - (CF_t*2.)
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '%                AGILE V2.0                    %
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% - Number of trays:', N_tray 
print, '% - Number of strips:', N_strip
print, '% - Pitch [mm]:', pitch
print, '% - Tray side [mm]:', Tray_Side 
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Tracker thicknesses:'
print, '% - Silicon thickness [mm]:', Si_t
print, '% - Glue thickness [mm]:', Glue_t
print, '% - Kapton thickness [mm]:', K_t
print, '% - Carbon fiber thickness [mm]:', CF_t
print, '% - Converter (W) thickness [mm]:', Conv_t
print, '% ----------------------------------------------'
print, '% - Plane distance [mm]:', plane_distance
print, '% - Trays distance [mm]:', dist_tray
print, '% ----------------------------------------------'
print, '% - Computed Al honeycomb thickness [mm]:', Al_t

Lower_module_t = Si_t + Glue_t + K_t + Conv_t
Lower_module_t_NoConv = Si_t + Glue_t + K_t

z_start = lower_module_t_NoConv

Central_module_t = (CF_t*2.) + Al_t
Upper_module_t = K_t + Glue_t + Si_t

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Tracker heights:'
print, '% - Lower module height [mm]:', Lower_module_t
print, '% - Central module height [mm]:', Central_module_t
print, '% - Upper module height [mm]:', Upper_module_t
print, '% - Tray height [mm]:', Lower_module_t + Central_module_t + Upper_module_t


TRK_t = Lower_module_t_NoConv + Central_module_t + Upper_module_t

for k=1l, N_tray -1 do begin
 if (k GT 2) then TRK_t = TRK_t + Lower_module_t + Central_module_t + Upper_module_t + dist_tray else TRK_t = TRK_t + Lower_module_t_NoConv + Central_module_t + Upper_module_t + dist_tray
endfor
TRK_t = TRK_t - Lower_module_t_NoConv - Upper_module_t
z_end = TRK_t + z_start

print, '% - Tracker height [mm]:', TRK_t
print, '% - Tracker Z start [mm]:', z_start
print, '% - Tracker Z end [mm]:', z_end

pos_x = -1.
pos_y = -1.

vol_id_x = -1l
tray_id_x = -1l
Si_id_x = -1l
Strip_id_x = -1l
pos_z_x = -1.

vol_id_y = -1l
tray_id_y = -1l
Si_id_y = -1l
Strip_id_y = -1l
pos_z_y = -1.

; Total number of strips

Total_vol_x = (N_tray-1)*N_strip
Total_vol_y = (N_tray-1)*N_strip

;print, 'Total number of volumes x:', Total_vol_x


Glob_vol_id_x = lonarr(Total_vol_x) 
Glob_pos_x = dblarr(Total_vol_x) 
Glob_z_x = dblarr(Total_vol_x) 
Glob_moth_id_x = lonarr(Total_vol_x) 
Glob_Strip_id_x = lonarr(Total_vol_x) 
Glob_Strip_type_x = lonarr(Total_vol_x) 
Glob_Si_id_x = lonarr(Total_vol_x) 
Glob_tray_id_x = lonarr(Total_vol_x) 
Glob_energy_dep_x = dblarr(Total_vol_x) 

Glob_vol_id_y = lonarr(Total_vol_y) 
Glob_pos_y = dblarr(Total_vol_y) 
Glob_z_y = dblarr(Total_vol_y) 
Glob_moth_id_y = lonarr(Total_vol_y) 
Glob_Strip_id_y = lonarr(Total_vol_y) 
Glob_Strip_type_y = lonarr(Total_vol_y) 
Glob_Si_id_y = lonarr(Total_vol_y) 
Glob_tray_id_y = lonarr(Total_vol_y) 
Glob_energy_dep_y = dblarr(Total_vol_y) 

; if strip = readout -> Glob_Strip_type_x = 1 
; if strip = floating -> Glob_Strip_type_x = 2 

CentralModule_t = (2.0*CF_t) + Al_t
UpperModule_t = Si_t + Glue_t + K_t
LowerModule_t = Conv_t + Glue_t + K_t + Si_t
;TotalModule_t = LowerModule_t + CentralModule_t + UpperModule_t;

; ----> X layer

FirstTrayConv = 3
SummedTotalModule_t_inTray = Glue_t + K_t + Si_t + Central_module_t + Upper_module_t

 for t=1l, N_tray-1 do begin
      ConverterTray_t_inTray = Conv_t
      
      if (t LT FirstTrayConv) then begin
         ConverterTray_t_inTray = 0.;
      endif

      LowerModule_t_inTray = ConverterTray_t_inTray + Glue_t + K_t + Si_t    
      LowerModulePos_z = (SummedTotalModule_t_inTray) + (t*dist_tray) + (LowerModule_t_inTray/2.)
      pos_z_x = LowerModulePos_z -(LowerModule_t_inTray/2.) + Si_t/2.
      ;print, pos_z_x
      copyM = 1000000l + 1000000l*t
      for s=0l, N_strip-1 do begin
        Glob_moth_id_x[(t-1)*N_strip + s] = 0
        Glob_tray_id_x[(t-1)*N_strip + s] = t+1
        Glob_Si_id_x[(t-1)*N_strip + s] = 0
        Glob_Strip_id_x[(t-1)*N_strip + s] = s
        if ((s mod 2) EQ 0) then Glob_Strip_type_x[(t-1)*N_strip + s] = 1 else Glob_Strip_type_x[(t-1)*N_strip + s] = 2
        Glob_energy_dep_x[(t-1)*N_strip + s] = 0.
        Glob_vol_id_x[(t-1)*N_strip + s] = copyM + s

        Strip_pos_x = -(Tray_side/2.0) + (pitch/2.) + (pitch*s)
        Glob_pos_x[(t-1)*N_strip + s] = Strip_pos_x/10.  ;cm
        Glob_z_x[(t-1)*N_strip + s] = pos_z_x/10.
      endfor
 
   LastTotalModule_t_inTray = LowerModule_t_inTray + CentralModule_t + UpperModule_t;
   SummedTotalModule_t_inTray = SummedTotalModule_t_inTray + LastTotalModule_t_inTray;
 
 endfor

SummedTotalModule_t_inTray = 0.

 for t=0l, N_tray-2 do begin
      ConverterTray_t_inTray = Conv_t
      
      if (t LT FirstTrayConv) then begin
         ConverterTray_t_inTray = 0.;
      endif

      LowerModule_t_inTray = ConverterTray_t_inTray + Glue_t + K_t + Si_t          
      UpperModulePos_z = (SummedTotalModule_t_inTray) + (t*dist_tray) + (LowerModule_t_inTray + CentralModule_t + (UpperModule_t/2.))

      Strip_pos_z = UpperModulePos_z -(UpperModule_t/2.) + K_t + Glue_t + Si_t/2.
  
      copyM = 1000000l + 1000000l*t
      for s=0l, N_strip-1 do begin
        Glob_moth_id_y[(t)*N_strip + s] = 0
        Glob_tray_id_y[(t)*N_strip + s] = t+1
        Glob_Si_id_y[(t)*N_strip + s] = 1
        Glob_Strip_id_y[(t)*N_strip + s] = s
        if ((s mod 2) EQ 0) then Glob_Strip_type_y[(t)*N_strip + s] = 1 else Glob_Strip_type_y[(t)*N_strip + s] = 2
        Glob_energy_dep_y[(t)*N_strip + s] = 0.
        Glob_vol_id_y[(t)*N_strip + s] = (copyM + 90000l) + s

        Strip_pos_y = -(Tray_side/2.0) + (pitch/2.) + (pitch*s)
        Glob_pos_y[(t)*N_strip + s] = Strip_pos_y/10. ;cm
        Glob_z_y[(t)*N_strip + s] = Strip_pos_z/10.   ;cm
      endfor
 
   LastTotalModule_t_inTray = LowerModule_t_inTray + CentralModule_t + UpperModule_t;
   SummedTotalModule_t_inTray = SummedTotalModule_t_inTray + LastTotalModule_t_inTray;
 
 endfor
 
CREATE_STRUCT, AGILE2GridX, 'GridAGILE2X', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID','TRK_FLAG', 'STRIP_ID', 'STRIP_TYPE', 'XPOS', 'ZPOS','E_DEP'], 'J,J,I,I,J,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_vol_id_x)
AGILE2GridX.VOLUME_ID = Glob_vol_id_x
AGILE2GridX.MOTHER_ID = Glob_moth_id_x
AGILE2GridX.TRAY_ID = Glob_tray_id_x
AGILE2GridX.TRK_FLAG = Glob_Si_id_x
AGILE2GridX.STRIP_ID = Glob_Strip_id_x
AGILE2GridX.STRIP_TYPE = Glob_Strip_type_x
AGILE2GridX.XPOS = Glob_pos_x
AGILE2GridX.ZPOS = Glob_z_x
AGILE2GridX.E_DEP = Glob_energy_dep_x

HDR_XGRID = ['Creator          = Valentina Fioretti', $
                'AGILE release    = V2']

MWRFITS, AGILE2GridX, './conf/ARCH.XSTRIP.AGILEV2.0.TRACKER.FITS', HDR_XGRID, /CREATE

CREATE_STRUCT, AGILE2GridY, 'GridAGILE2Y', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID','TRK_FLAG', 'STRIP_ID', 'STRIP_TYPE', 'YPOS', 'ZPOS','E_DEP'], 'J,J,I,I,J,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_vol_id_y)
AGILE2GridY.VOLUME_ID = Glob_vol_id_y
AGILE2GridY.MOTHER_ID = Glob_moth_id_y
AGILE2GridY.TRAY_ID = Glob_tray_id_y
AGILE2GridY.TRK_FLAG = Glob_Si_id_y
AGILE2GridY.STRIP_ID = Glob_Strip_id_y
AGILE2GridY.STRIP_TYPE = Glob_Strip_type_y
AGILE2GridY.YPOS = Glob_pos_y
AGILE2GridY.ZPOS = Glob_z_y
AGILE2GridY.E_DEP = Glob_energy_dep_y

HDR_YGRID = ['Creator          = Valentina Fioretti', $
                'AGILE release    = V2']

MWRFITS, AGILE2GridY, './conf/ARCH.YSTRIP.AGILEV2.0.TRACKER.FITS', HDR_YGRID, /CREATE

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Output FITS files with X and Y strip positions'
print, '% - ARCH.XSTRIP.AGILEV2.0.TRACKER.FITS'
print, '% - ARCH.YSTRIP.AGILEV2.0.TRACKER.FITS'

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% GPS Set-up for the point source position:'
print, '% - theta [deg.]:', theta_deg
print, '% - phi [deg.]:', phi_deg
print, '% - source height [cm]:', h_s
print, '% ----------------------------------------------'

; tracker height
h_t = z_end/10. ; cm

; source height respect to tracker
h_r = h_s - h_t

; source distance from (0,0)
radius = h_r*tan(theta)
x_s = ((cos(phi))*radius)
y_s = ((sin(phi))*radius)


P_x = -sin(theta)*cos(phi)
P_y = -sin(theta)*sin(phi)
P_z = -cos(theta)

print, '% Source position:'
print, '% - X [cm]:', x_s
print, '% - Y [cm]:', y_s
print, '% - Z [cm]:', h_s
print, '% - Source direction:'
print, '% - P_x:', P_x
print, '% - P_y:', P_y
print, '% - P_z:', P_z
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

end