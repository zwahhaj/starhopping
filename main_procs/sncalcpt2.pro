;; Written by Zahed Wahhaj, 2019.
;; local : If true the background region is centered around the source

function sncalcpt2, img, x, y, fwhm, local=local, disp=disp

  ws = getrgn(img, 0, fwhm*0.5, xc=x, yc=y)
  

  sz  = (size(img))[1]
  cc = (sz-1)/2.
  r0 = sqrt( (cc-x)^2 + (cc-y)^2)
  rin = r0-fwhm/2.
  rout = r0+fwhm/2.
  
  if n_elements(local) ne 0 then wb = getrgn(img, fwhm, fwhm+fwhm/2., xc=x, yc=y) $
  else begin
     ;; take background to be arcs on either side of source
     win = getrgn(img, 0, fwhm*2, xc=x, yc=y)
     wout = getrgn(img, fwhm*9, sz/2., xc=x, yc=y)
     wb = getrgn(img, rin, rout)
     wb = setdiff(wb, win)
     wb = setdiff(wb, wout)
     ;temp = img
     ;temp[wb] = 0
     ;atv, temp
     ;pause
  endelse
  ;bck = median(img[wb])
  ;npix = n_elements(ws)
  ;sig = interpolate(img,x,y,c=-0.5)-bck
  ;noise = stddev(img[wb])
  ;print, 'sncalcpt:',x,y, sig/noise, sig, noise, total(img[ws]), npix*bck,stddev(img[wb]),sqrt(npix)
  ;;stop

  bck = median(img[wb])
  npix = n_elements(ws)
  sig = total(img[ws])-npix*bck
  noise = stddev(img[wb])*sqrt(npix)
  ;print, 'sncalcpt:',x,y, sig/noise, sig, noise, total(img[ws]), npix*bck,stddev(img[wb]),sqrt(npix)
  
  if n_elements(disp) ne 0 then begin
     temp = img
     temp[ws] += noise*3
     temp[wb] -= noise*3
     zdisp, ( (temp > (-noise*10)) < noise*10)
     pause
  endif
  
  return, sig/noise
end

  
