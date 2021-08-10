;; fits vector (or image) b to a by scaling by a single number
;; (returned in fac). The difference of the two vectors is returned in
;; diff.
;; OUTPUT rms : the fractional rms [ (rms of diff)/origal_image ]
;;        mimg : the matched image
;; Written by Zahed Wahhaj
function zscalediff, img1, img2, wm=wm, fac=fac, rms=rms, zoom=zoom, const=const, mimg=mimg

  b = img2
  xc = ((size(b))[1]-1)/2.
  yc = ((size(b))[2]-1)/2.
  
  if n_elements(zoom) ne 0 then b = rot(b,0.0,zoom,xc,yc,c=-0.5,/pivot)
  
  if n_elements(wm) eq 0 then begin
     a = img1
     b=  b
  endif else begin
     a = img1[wm]
     b = b[wm]
  endelse     

  ;;removing medians from both arrays
  meda = median(a)
  a -=meda
  medb = median(b)
  b -= medb

  
  fac = total(a*b)/total(b*b)
  
  mimg = (img2-medb)*fac+meda
  diff=img1-mimg
  const=[meda, medb]
  
  if n_elements(wm) eq 0 then begin
     mincnt =  stddev(diff)/10.0
     if arg_present(rms) ne 0 then rms = stddev(diff)/stddev(img1)
  endif else begin
     mincnt =  stddev(diff[wm])/10.0
     if arg_present(rms) ne 0 then rms = stddev(diff[wm])/stddev(img1[wm])
  endelse

  return,diff
end
