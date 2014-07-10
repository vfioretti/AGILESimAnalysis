; agilesim_gpssource_test.pro - Description
; ---------------------------------------------------------------------------------
; Processing the BoGEMMS AGILE simulation in order to test the input energy distribution:
; ---------------------------------------------------------------------------------
; Output:
; - Plot of the input particle energy spectrum
; ---------------------------------------------------------------------------------
; copyright            : (C) 2013 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; agilesim_gpssource_test
; ---------------------------------------------------------------------------------
; Notes:
; 


pro agilesim_gpssource_test


; Variables initialization
N_in = 0UL            ;--> Number of emitted photons
n_fits = 0           ;--> Number of FITS files produced by the simulation

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

read, agile_version, PROMPT='% - Enter AGILE release (e.g. V1.4):'
read, sim_type, PROMPT='% - Enter simulation type [0 = general, 1 = Chen, 2: Vela, 3: Crab]:'
read, py_list, PROMPT='% - Enter the Physics List [0 = QGSP_BERT_EMV, 100 = ARGO, 300 = FERMI]:'
read, N_in, PROMPT='% - Enter the number of emitted photons:'
read, n_fits, PROMPT='% - Enter number of FITS files:'
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

if (sim_type EQ 0) then begin
   sim_name = ''
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

run_path = GETENV('BGRUNS')

filepath = run_path + '/AGILE'+agile_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+'/'+ene_type+'MeV.'+sim_name+'.'+strtrim(string(theta_type),1)+'theta.'+strtrim(string(N_in),1)+'ph'
print, 'BoGEMMS simulation path: ', filepath

ene_in = -1.
for ifile=0, n_fits-1 do begin
    print, 'Reading the BoGEMMS file.....', ifile+1

    filename = filepath+'/inout.'+strtrim(string(ifile), 1)+'.fits.gz'
    struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'agile inout', $
                     /unsigned)

    for k=0l, n_elements(struct)-1l do begin 
      if (k EQ 0) then begin
          ene_in = [ene_in, struct(k).EVT_KE]
      endif else begin
        if ((struct(k).VOLUME_ID EQ 0) AND (struct(k).DIRECTION EQ 1) AND (struct(k-1).EVT_ID NE struct(k).EVT_ID)) then begin
          ene_in = [ene_in, struct(k).EVT_KE]
        endif
      endelse
    endfor
    
    
endfor
 
ene_in = ene_in[1:*]
ene_in = ene_in/1000.  ; from keV to MeV

if (sim_type EQ 1) then begin
 Emin_sim = 100.
 Emax_sim = 141.
 deltaE_sim = Emax_sim - Emin_sim
endif
if ((sim_type EQ 2) OR (sim_type EQ 3)) then begin
 Emin_sim = ene_min
 Emax_sim = ene_max
 deltaE_sim = Emax_sim - Emin_sim
endif


if not keyword_set(nopsp) then begin
  PS_Start, /encapsulated, FILENAME='agilesim_gps_test_'+sim_name+'.eps', $
  FONT=0, CHARSIZE=1., nomatch=1, xsize=9., yoffset=9.6, ysize=7 
  bits_per_pixel=8
endif
RED   = [0, .5, 1, 0, 0, 1, 1, 0]
GREEN = [0, .5, 0, 1, 0, 1, 0, 1]
BLUE  = [0, 1., 0, 0, 1, 0, 1, 1]
TVLCT, 255 * RED, 255 * GREEN, 255 * BLUE

xt = 'Energy [MeV]' 
yt = 'phot. MeV!A-1!N' 
xr = [Emin_sim - 10, Emax_sim + 10]
yr = [100, 5000]

plot, /ylog,/xlog,[1], xtitle=xt, ytitle=yt, xrange=xr, yrange=yr, xstyle=1, ystyle=1,xmargin=[10,3], $
    xcharsize=1, ycharsize=1,charsize = 1, charthick=1.5,$
    title= 'AGILESim - '+ene_type+' MeV - '+sim_name, /nodata
    
;-------> Ploting!
bin_histo_log = 0.01
log_E_in = alog10(ene_in)
plothist, log_E_in,log_Earr_in, N_in_sim, bin=bin_histo_log, /noplot

log_Earr_in_plot = [log_Earr_in(0)-bin_histo_log/2., log_Earr_in, log_Earr_in[n_elements(log_Earr_in)-1] + bin_histo_log/2.]
log_Earr_in = [log_Earr_in(0)-bin_histo_log/2., log_Earr_in + bin_histo_log/2.]
Earr_in = 10.^(log_Earr_in)
Earr_in_plot = 10.^(log_Earr_in_plot)
bin_histo = dblarr(n_elements(Earr_in)-1)
for i=0l, n_elements(bin_histo) -1 do begin
  bin_histo(i) = Earr_in(i+1) - Earr_in(i)
endfor
rate_in = dblarr(n_elements(N_in_sim))
for i=0l, n_elements(rate_in)-1 do begin
  rate_in(i) = N_in_sim(i)/(bin_histo(i))
endfor

;oplot, [Earr_in,Earr_in[n_elements(Earr_in)-1]+bin_histo(n_elements(bin_histo)-1)/2.], $
;       [rate_in[0],rate_in,rate_in[n_elements(rate_in)-1]], psym = 10, thick = 5, color =4
oplot, Earr_in_plot, $
       [rate_in[0],rate_in,rate_in[n_elements(rate_in)-1]], psym = 10, thick = 5, color =4
       
err_rate_in = dblarr(n_elements(N_in_sim))
for i=0l, n_elements(N_in_sim)-1 do begin        
  err_rate_in(i) = (sqrt(N_in_sim(i)))/(bin_histo(i))
endfor
oploterror, Earr_in_plot[1:n_elements(Earr_in_plot)-2], rate_in, err_rate_in, $
       psym = 3, thick = 2, /nohat, errcolor = 4       

oplot, [Earr_in_plot[0], Earr_in_plot[0]], [yr[0], rate_in[0]],thick = 5, color=4
oplot, [Earr_in_plot[n_elements(Earr_in_plot)-1], Earr_in_plot[n_elements(Earr_in_plot)-1]], $
[yr[0], rate_in[n_elements(rate_in)-1]],thick = 5, color=4

if (sim_type EQ 1) then begin
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  for i=0l, n_elements(N_in_sim)-1 do begin
    N_in_model[i] = N_in*(bin_histo(i)/deltaE_sim)
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
if (sim_type EQ 2) then begin
  ph_index = 1.66
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  intE_tot = ((Emax_sim^(1 - ph_index))/(1 - ph_index)) - ((Emin_sim^(1 - ph_index))/(1 - ph_index))
  norm = N_in/intE_tot
  for i=0l, n_elements(N_in_sim)-1 do begin
    E_start = Earr_in[i]
    E_end = Earr_in[i+1]
    intE_delta = ((E_end^(1 - ph_index))/(1 - ph_index)) - ((E_start^(1 - ph_index))/(1 - ph_index))
    prop = intE_delta/intE_tot
    N_in_model[i] = N_in*prop
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
if (sim_type EQ 3) then begin
  ph_index = 2.1
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  intE_tot = ((Emax_sim^(1 - ph_index))/(1 - ph_index)) - ((Emin_sim^(1 - ph_index))/(1 - ph_index))
  norm = N_in/intE_tot
  for i=0l, n_elements(N_in_sim)-1 do begin
    E_start = Earr_in[i]
    E_end = Earr_in[i+1]
    intE_delta = ((E_end^(1 - ph_index))/(1 - ph_index)) - ((E_start^(1 - ph_index))/(1 - ph_index))
    prop = intE_delta/intE_tot
    N_in_model[i] = N_in*prop
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
oplot, Earr_in[1:*], rate_in_model, thick = 3, linestyle=2

lines = [0, 2]
legend,['AGILESim', 'Model'], $
spacing=1.4, thick=2,/top, textcolor=[4,0], linestyle = lines, /right,box=0, outline_color=0, charsize=1., charthick=2.


print, Earr_in, N_in_sim

PS_End, /PNG
end