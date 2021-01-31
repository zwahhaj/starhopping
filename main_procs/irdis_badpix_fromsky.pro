;; Written by Zahed Wahhaj, 2018

pro irdis_badpix_fromsky, filetxt, iter=iter

  if n_elements(iter) eq 0 then iter=3

readcol,filetxt,filenames,f='A'

sky = readfits(filenames[0],fhead) ;; dit=10

if (size(sky))[0] eq 3 then sky = total(sky,3) 
ssky = medsmooth(sky,10)
sky = sky-ssky

badpix = sky*0+1
for i=0,iter-1 do begin
   sky -= median(sky)
   rms = robust_sigma(sky)
   wbad = where(sky gt 5*rms or sky lt -5*rms)
   badtemp = sky*0+1
   if wbad[0] ne -1 then badtemp[wbad] = 0
   if wbad[0] ne -1 then badpix[wbad]=0 ;; adding more badpix to the previous iter
   fixpix,sky,badtemp,sky
   display, sky
endfor

;badpix[0:50,*] = 0
;badpix[940:1080,*] = 0
;badpix[1960:*,*] = 0
;badpix[*,0:50] = 0
;badpix[*,980:*] = 0

writefits,'badpix_irdis.fits',1-badpix,fhead
;writefits,'badpix_from_sky.fits',badpix,fhead

end
