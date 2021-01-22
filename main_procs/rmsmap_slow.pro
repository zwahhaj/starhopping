;;Written by Zahed Wahhaj.
function rmsmap_slow, im, dia=dia, not_robust=not_robust
  sz = (size(im))[1]
  map = fltarr(sz,sz)
  xc = (sz-1)/2.0
  yc = (sz-1)/2.0
  
  map[*]=1.0

  dist_circle, dd, [sz, sz], xc, yc
  
  orad=sz/2.0
  ;;if n_elements(dia) eq 0 then dia=1.5 
  if n_elements(dia) eq 0 then dia=2 
  
  for i=0, orad-1, 1 do begin
     ;w = where(dd gt i and dd le i+dia)
     w = where(dd ge i and dd le (i+dia < orad), cnt)
     if cnt ne 0 then begin
        if n_elements(not_robust) eq 0 then rms = robust_sigma(im[w]) $
        else rms = stddev(im[w])
        map[w]=rms
     endif
  endfor

  ;wc = where(dd lt dia*5)
  ;wc2 = where(dd gt dia*5 and dd lt dia*7)
  ;map[wc] = mean(map[wc2])
  
  return, map
  
end
