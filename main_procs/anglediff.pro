;;Written by Zahed Wahhaj
;;Nov 14, 2014. Vectorized.
 
function anglediff, a1, a2, amax=amax
  ;; return the smallest angular offset between to angles
  
  ;;make sure both angle are positive and less than 360.

  n1 = n_elements(a1)
  n2 = n_elements(a2)

  if n1 eq 1 and n2 gt 1 then b1 = cmreplicate(a1,n2) $ 
  else if n2 eq 1 and n1 gt 1 then b2 = cmreplicate(a2,n1) $
  else if n1 ne n2 then return, 'error'
  
  b1 = a1 mod 360  
  b2 = a2 mod 360
 
  ;;print, b1,b2

  w = where(b1 lt 0) 
  if w[0] ne -1 then b1[w] = 360+b1[w]
  w = where(b2 lt 0) 
  if w[0] ne -1 then b2[w] = 360+b2[w]
 
  
  ;print, b1,b2
  off1 = (360-b2)+b1
  off2 = (360-b1)+b2
  off3 = abs(b1-b2)

  nn = (max([n1,n2]))[0]


  if nn gt 1 then begin 
     val = fltarr(nn)
     for i=0L, nn-1 do val[i] = (min([off1[i],off2[i],off3[i]]))[0]
  endif else val = (min([off1,off2,off3]))[0]

  if n_elements(amax) ne 0 then val = 360-val

  return, val
end
