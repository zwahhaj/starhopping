;; Written by Zahed Wahhaj, 2019
;; inputs -
;;   imc_save - reduced IFS cube as IDL save file
;;   tag - tag added to file name for all outputs saved
;;   reject_inx - indices of the images to be rejected in each
;;                wavelength cube.
;;   stackfits -  (3-el array for YJH stacks, FITS file names) 
;;   fstackfits - azimuth filtered version of 'stackfits'
;;   spec_save - spectral cube save file

pro stack_simple_ifs, pa_off=pa_off, pafac=pafac, imc_save = imc_save, tag=tag, reject_inx=reject_inx, stackfits=stackfits, fstackfits=fstackfits, spec_save=spec_save

if n_elements(pa_off) eq 0 then pa_off=0  
if n_elements(pafac) eq 0 then pafac=1  
if n_elements(tag) eq 0 then tag=''  
if n_elements(imc_save) eq 0 then imc_save= 'ifs_reduced0.save'

zrestore, file=imc_save, st=s
derotate,imc_save=imc_save,dimc=dimc, pa_off=pa_off,pafac=pafac

img = dimc[*,*,0]
num = (size(dimc))[3]
wb = getrgn(img, 20, 60)
win = getrgn(img,0, 9.4) ;; mask inner 0.07" asec.


;for i=0,num-1 do begin
;   img = dimc[*,*,i]
;   img -= median(img[wb])
;   img[win] = 0
;   dimc[0,0,i] = img
;endfor

imc = dimc[*,*,0:38]*0
imcf = imc
for i=0,38 do begin
   l = s.lambdas[i]
   wl = where(l eq s.lambdas)
   if n_elements(reject_inx) ne 0 then remove, reject_inx, wl 
   med = median(dimc[*,*,wl],dim=3,/even)
   imc[0,0,i] = med
   submedprof, med
   imcf[0,0,i] = med
endfor

lambdas = s.lambdas[0:38]


wy = where(lambdas lt 1.2)
wj = where(lambdas gt 1.2 and lambdas gt 1.34)
wh = where(lambdas gt 1.5)

ymed = median(imc[*,*,wy],dim=3,/even)
jmed = median(imc[*,*,wj],dim=3,/even)
hmed = median(imc[*,*,wh],dim=3,/even)

stackfits = ['y','j','h']+'stack'+tag+'.fits'
writefits,stackfits[0],ymed
writefits,stackfits[1],jmed
writefits,stackfits[2],hmed

ymedf = median(imcf[*,*,wy],dim=3,/even)
jmedf = median(imcf[*,*,wj],dim=3,/even)
hmedf = median(imcf[*,*,wh],dim=3,/even)

fstackfits = ['y','j','h']+'stack_filt'+tag+'.fits'
writefits,fstackfits[0],ymedf
writefits,fstackfits[1],jmedf
writefits,fstackfits[2],hmedf
			      
atv, hmedf

;;save spectral cube, normal and filtered
save, file='spectral_cube'+tag+'.save',imc,lambdas
writefits,'spectral_cube'+tag+'.fits', imc

spec_base = 'spectral_cube_filt'+tag
spec_save = spec_base+'.save'

save, file=spec_save, imcf, lambdas
writefits, spec_base+'.fits', imcf

end
    

