;; Written by Zahed Wahhaj.
;; ZWa, Jan 28, 2010: Added dmagf, rhof, for setting inserted fake planet
;;      contrast manually (as opposed to contrast file).

pro insert_asdi_fakes, imc_save = imc_save, r0=r0, dr=dr, dpa=dpa, con_save=con_save, flux_save=flux_save, $
                       chan_flux_ratio= chan_flux_ratio, sigma_level=sigma_level, $ 
                       tag=tag, out_imc_save=out_imc_save, out_fakes_save=out_fakes_save, $
                       peaks=peaks, dmagf=dmagf, rhof=rhof, pix=pix

if n_elements(pix) eq 0 then pix  = 0.01225

if n_elements(tag) eq 0 then tag=''
if n_elements(chan_flux_ratio) eq 0 then chan_flux_ratio=10.0 ;; channel two fake has smaller flux
if n_elements(sigma_level) eq 0 then sigma_level=10.0 ;; fake at sigma_level while contrast curve at 5 sigma

if n_elements(r0) eq 0 then r0p= 0.1/pix $
else r0p = r0/pix 

if n_elements(dr) eq 0 then drp=0.1/pix $
else drp = dr/pix

if n_elements(dpa) eq 0 then dpa=90

if n_elements(imc_save) eq 0 then imc_save='imcbasic.save'
restore,file=imc_save

num = (size(imc))[3]
sz = (size(imc))[1]
cc = (sz-1)/2.0


 
;;added ZWa. Jan 28, 2020.
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
   restore,file=con_save
endelse

if n_elements(flux_save) eq 0 then flux_save='flux.save'
zrestore,file=flux_save, struct=flux, vars='fluximc peaks flambdas'
flambdas = flux.flambdas
;; make sure that fluximg is scaled to estimated star peak in science image
peakcalc,'normfac.save',flux_save,peaks=peaks

;;proper ASDI treatment not done. Need something like below.
;if n_elements(peaks) eq 1 then fluximg *= peaks[0]/flux.peaks[0] $
;else fluximg *= peaks/flux.peaks 

numf = (size(flux.fluximc))[3]
lambdamax = flambdas[n_elements(flambdas)-1]

rms = fltarr(num)
;;maxdit = (max(dits))[0] 

deg2rad = !pi/180.0

;;numf looping over fluximc, could be many wavelengths
fakes = flux.fluximc*0
for i=0, numf-1 do begin
   fluximg = flux.fluximc[*,*,i]
   fluximg *= peaks[i]/flux.peaks[i]
   fake= 0*fakes[*,*,i]
   for j=0, floor(cc/1.3/drp) do begin
      rj = r0p+j*drp
      
      confac = 10^(0.4 * interpol(dmag, rho, rj))
      
      phi = (dpa*j)
      dx = (rj) * sin(phi*deg2rad)* (-1)
      dy = (rj) * cos(phi*deg2rad)
      
      contrast = confac * (5.0/sigma_level) ;; *  10^(-0.4 * 6.25*4.0/(rj)) ;; place brighter fakes at smaller seps
      fake += shift_sub(fluximg, dx, dy)/contrast
      
      if i eq 0 then begin
         push, pas_fake, phi
         push, rhos_fake, rj
         push, dmags_fake, logm(contrast)
      endif
      print, i,rj, logm(contrast)
   endfor
   fakes[0,0,i] = fake
   print,i
   stats, fake
   stats, fluximg
endfor
;;stop

if n_elements(uniq(flambdas)) ne 1 then flag_onechan = 1 else flag_onechan = 0

;;looping over the science images.
for i=0, num-1 do begin
   junk = min(abs(lambdas[i]-flambdas),linx) & linx = linx[0]
   if flag_onechan then colfac = 1 + (chan_flux_ratio-1)*(flambdas[linx]-flambdas[0])/(lambdamax-flambdas[0]) else colfac = 1
   rfake = rot(fakes[*,*,linx],-pas[i],1,cc,cc,cub=-0.5,/piv)/colfac
   imc[0,0,i] = imc[*,*,i] + rfake  
endfor

peaks_fake1 = string(peaks[0]/10^(0.4*dmags_fake),f='(E10.1)')
;if n_elements(out_imc_save) eq 0 then out_imc_save ='imcfakes'+tag+'.save' 
;if n_elements(out_fakes_save) eq 0 then out_fakes_save ='fakes'+tag+'.save' 
out_imc_save = fname_addtag(imc_save,'fake')
out_fakes_save ='imcfakes.save'

save, file=out_imc_save, imc, pas, dits, lambdas, pas_fake, rhos_fake, chan_flux_ratio, dmags_fake 
print,'rhos_fake, pas_fake, peaks_fake1, all_chan_flux/chan1_flux, dmags_fake'
;; remember to multiply with stellar flux, chanrat is actually relative contrast.
chanrats = avg(peaks*chan_flux_ratio)/peaks[0]/chan_flux_ratio[0]+0*rhos_fake
chanfluxes = peaks*chan_flux_ratio
;;forprint, rhos_fake, pas_fake, peaks_fake1, chanrats, dmags_fake
forprint, rhos_fake, pas_fake, peaks_fake1, chanrats, dmags_fake,textout='inserted_fakes.txt',/silent

lambdas = flambdas
comment='The fake images are already derotated.'
save, file=out_fakes_save, fakes, pas_fake, rhos_fake, chan_flux_ratio, chanfluxes, peaks_fake1, dmags_fake, lambdas, comment
end

