;; Written by Zahed Wahhaj.
;; return a guassian psf
function psf, xc,yc,sz=sz,fwhm=fwhm,peak=peak,norm=norm

if n_elements(sz) eq 0 then sz=1024
if n_elements(xc) eq 0 then xc=(sz-1)/2.
if n_elements(yc) eq 0 then yc=(sz-1)/2.
if n_elements(fwhm) eq 0 then fwhm=3.
if n_elements(peak) eq 0 then peak=1.

sz0 = sz
if n_elements(norm) eq 0 then im= psf_gaussian(npix=sz0,cen=[xc,yc],FWHM=fwhm)*peak $
else im= psf_gaussian(npix=sz0,cen=[xc*1d,yc*1d],FWHM=fwhm*1d,/norm)*peak 
return, im

end
