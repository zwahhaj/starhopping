;; Written by Zahed Wahhaj
;; Inserts fake companions into a ifs data cube.
;; The formula is simple: 
;;    comp_ifs_flux = star_ifs_flux / contrast
;; But if we start with an actual spectra: comp_real_flux
;;    comp_ifs_flux = comp_real_flux * star_ifs_flux/star_real_flux
;; so, contrast = star_real_flux/comp_real_flux.
;;
;; spec_con_save : a save file with the star_spec/planet_spec contrast spectra (flux vs lambda)
;;                 the brightest (lowest contrast) channel is set to one
;;-------------------
;; 
;; Insert fake planets based on FAKE CONTRAST CURVE -
;; If the following 2 prams are given, a fake contrast curve is made by
;; interpolating betweeen these:
;;    rhof  = array of 3 seps in asecs
;;    dmagf = array of 3 delt mags 
;;
;; This contrast curve is used with sigma_level to create the fake
;; planets.
;;------------------
;;
;; Mar 29, 2020 - ZWa. Added 'rhos phis dmags' for direct input of
;;                     fake planets. Sigma_level is forced to 5.
;;                     WARNING!!!! 'phis' used for planet_PAs, 'pas'
;;                     used for SKY_PAs
;;                     rhos is in PIXELS!
;; July 12, 2021 - ZWa. Separated defaults for rhos, phis, dmags of
;;                fakes

pro sph_fakes_ifs, imc_save = imc_save, dr=dr, dpa=dpa, con_save=con_save, flux_save=flux_save, $
                   spec_con_save= spec_con_save, sigma_level=sigma_level, tag=tag, $
                   out_imc_save=out_imc_save, out_fakes_save=out_fakes_save, dmagf=dmagf, $
                   rhof=rhof, rhos=rhos, phis=phis, dmags=dmags
  
pix  = 0.00745
  
if n_elements(sigma_level) eq 0 then sigma_level=5.0 ;; fake at sigma_level while contrast curve at 5 sigma

if n_elements(dr) eq 0 then dr=0.1/pix ;; pix = 0.00745 asec
if n_elements(dpa) eq 0 then dpa=90

if n_elements(imc_save) eq 0 then imc_save='imcbasic.save'
restore,file=imc_save
num = (size(imc))[3]
sz = (size(imc))[1]
cc = (sz-1)/2.0

if n_elements(spec_con_save) ne 0 then begin
   zrestore, file=spec_con_save, st=pcon
   spec_con = pcon.fs_by_fp
   spec_con /= (min(spec_con))[0]
endif else spec_con = replicate(1,num)

if n_elements(rhof) ne 0 then begin
   rho_asec = rangegen(0.1,rhof[2],10,/log)
   rho  = rho_asec/pix
   rhofe = rangegen(rho[9]*1.1,20.0/pix,10,/log) ;; extend and flatten out the curve to rho=20"
   dmagfe = rangegen(dmagf[2]+0.2, dmagf[2]+0.5, 10)
   dmag = interpol(dmagf , rhof, rho_asec) ;; make sure curve is flat between last rho and 20 asec.
   dmag = [dmag, dmagfe]
   rho = [rho, rhofe]
endif else begin
   if n_elements(con_save) eq 0 then con_save='contrast.save'
   if n_elements(dmags) eq 0 then restore,file=con_save
endelse

if n_elements(flux_save) eq 0 then flux_save='flux_ifs.save'
zrestore,file=flux_save, st=flux
numf = (size(flux.fluximc))[3]

rms = fltarr(num)

deg2rad = !pi/180.0


;; if fake props not defined=============================
numj = floor(cc/1.3/dr)
if n_elements(phis) eq 0 then begin
   phis = fltarr(numj-1)
   for j=1, numj-1 do phis[j-1] = (dpa*j)      
endif
if n_elements(rhos) eq 0 then begin
   rhos = fltarr(numj-1)
   for j=1, numj-1 do rhos[j-1] = j*dr
endif
if n_elements(dmags) eq 0 then begin
   dmags = fltarr(numj-1)
   for j=1, numj-1 do dmags[j-1] = interpol(dmag, rho, rhos[j-1])
endif

if n_elements(dmags) ne 0 then sigma_level = 5.0

fakes = flux.fluximc*0
fake = fakes[*,*,0]
for i=0, numf-1 do begin
   fluximg = flux.fluximc[*,*,i]
   fake *= 0
   for j=0, n_elements(rhos)-1 do begin
 
      dx = rhos[j] * sin(phis[j]*deg2rad)* (-1)
      dy = rhos[j] * cos(phis[j]*deg2rad)
      
      confac = 10^(0.4 * dmags[j])*spec_con[i] ;; spec_con is the spectral contrast
      contrast = confac * (5.0/sigma_level) 
      fake += shift_sub(fluximg, dx, dy)*flux.peaks[i]*dits[i]/contrast
      
      if i eq 0 then begin
         push, pas_fake, phis[j]
         push, rhos_fake, rhos[j]
         push, dmags_fake, logm(contrast)
      endif
      print, rhos[j], contrast
   endfor
   fakes[0,0,i] = fake
endfor

for i=0, num-1 do begin
   junk = min(abs(lambdas[i]-flux.lambdas),linx) & linx = linx[0]
   rfake = rot(fakes[*,*,linx],-pas[i],1,cc,cc,cub=-0.5,/piv)
   imc[0,0,i] = imc[*,*,i] + rfake  
endfor

if n_elements(tag) eq 0 then begin
   out_imc_save=zfile(imc_save,4)+'_fakes.save' 
   out_fakes_save ='fakes.save'
endif else begin
   out_imc_save =zfile(imc_save,4)+tag+'.save' 
   out_fakes_save ='fakes'+tag+'.save'
endelse

save, file=out_imc_save, imc, pas, dits, lambdas, lambdas0, pas_fake, rhos_fake, dmags_fake, peaks 
save, file=out_fakes_save, pas_fake, rhos_fake, dmags_fake, fakes 


end

