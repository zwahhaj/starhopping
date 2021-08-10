;;

pro sph_filter, imc_save = imc_save, flux_save=flux_save,rayfilt=rayfilt,azfilt=azfilt, peaks=peaks, $
                outrad=outrad, out_imc_save=out_imc_save, out_flux_save=out_flux_save, peaknorm=peaknorm, $
                unsharp=unsharp, flatten=flatten, maskrad=maskrad, fwhm=fwhm

if n_elements(imc_save) eq 0 then imc_save='imcbasic.save'
restore,file=imc_save

num = (size(imc))[3]
sz = (size(imc))[1]

if n_elements(fwhm) eq 0 then fwhm=4
if n_elements(outrad) eq 0 then outrad=sz/2.0*1.44
if n_elements(maskrad) ne 0 then w0 = getrgn(imc[*,*,0],0,maskrad)

;;if n_elements(flatten) ne 0 then imcp = imc

for i=0, num-1 do begin
   img = imc[*,*,i]
   if n_elements(maskrad) ne 0 then img[w0] = 0
   if n_elements(azfilt) ne 0 then submedprof,img
   if n_elements(rayfilt) ne 0 then subray,img,/fixcen 
   if n_elements(unsharp) ne 0 then getfreq, img, fwhm, img, /unsharp 
   if n_elements(unsharp) eq 0 and n_elements(azfilt) eq 0 and n_elements(rayfilt) eq 0 $
      and n_elements(flatten) eq 0 then $
      getfreq, img, fwhm, img
   if n_elements(flatten) ne 0 then begin
      img = img/flatten
      ;temp = img
      ;submedprof, temp, ar=20, /mean
      ;prof = img-temp
      ;img = img/prof
      ;imcp[0,0,i] = prof ;; need to multiply with this to get true values back.
      ;atv, img
   endif
   imc[0,0,i] = img 
endfor

out_imc_save = fname_addtag(imc_save,'filt')
save, file=out_imc_save,  imc, pas, dits, lambdas, normsci
;;if n_elements(flatten) ne 0 then save, file=fname_addtag(imc_save,'profs'), imcp 

if n_elements(flux_save) eq 0 then flux_save='flux.save'

if file_test(flux_save) ne 0 then begin
   restore,file=flux_save

   fluximg1 = fluximc[*,*,0]
   fluximg2 = fluximc[*,*,1]

   if n_elements(unsharp) ne 0 then begin
      getfreq,fluximc[*,*,0],fwhm,fluximg1,/unsharp
      getfreq,fluximc[*,*,1],fwhm,fluximg2,/unsharp
   endif
   if n_elements(unsharp) eq 0  and n_elements(azfilt) eq 0 and n_elements(rayfilt) eq 0 then begin
      getfreq,fluximc[*,*,0],fwhm,fluximg1
      getfreq,fluximc[*,*,1],fwhm,fluximg2
   endif
   
   fluximc[0,0,0] = fluximg1
   fluximc[0,0,1] = fluximg2
   cc = ((size(fluximg1))[1]-1)/2.
   curpeak, fluximg1,cc,cc,peak1,/guess
   curpeak, fluximg2,cc,cc,peak2,/guess
   peaks = [peak1, peak2]

   out_flux_save = fname_addtag(flux_save,'filt')
   if n_elements(normsci) ne 0 then peaknorm = peaks*normflux/normsci
   comment='Estimated peak in the filtered science images.'
   save,file=out_flux_save, peaks, fluximc, flambdas, normflux, peaknorm, comment
endif

end

