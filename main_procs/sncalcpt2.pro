;; Written by ZWa, 2019
;; estimate the signal to noise
;; Not used alone. Shape criteria and S/N is used elsewhere to mark as detection.
;; local : If true the background region is centered around the source
;; Aug 3, 2021, ZWa - Added the poisson noise from signal.

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
  endelse

  bck = mean(img[wb])
  npix = n_elements(ws)
  nbck = n_elements(wb)
  sig = total(img[ws])-npix*bck
  eb0 = stddev(img[wb])*sqrt(npix) ;; bgnd stddev in signal area
  eb1 = stddev(img[wb])/sqrt(nbck) ;; uncertainty in background mean.
  es0 = sqrt(sig/2.0) ;; poisson noise for gain = 2.0
  noise = sqrt(eb0^2+eb1^2+es0^2)

  ;;print, 'sncalcpt:',x,y, sig/noise, sig, noise, eb0,eb1,es0, npix, nbck, bck
  
  if n_elements(disp) ne 0 then begin
     temp = img
     temp[ws] += noise*3
     temp[wb] -= noise*3
     zdisp, ( (temp > (-noise*10)) < noise*10)
     pause
  endif
  
  return, sig/noise
end

  
