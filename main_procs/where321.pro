;; Written by Zahed Wahhaj, Sep 4, 2019
;; Given a cube and a region in the 1st slice
;;    returns a 2D array, which is the region as a 1d array for each slice
;;    OR if w3=TRUE, returns the indices for the original cube.
function where321, cube, w, w3=w3
  sz = size(cube)
  sl = n_elements(w)
  out = fltarr(sl,sz[3])
  ninx = sz[1]*sz[2] ;; number of indices per slice.
  
  for i=0, sz[3]-1 do begin
     temp = (cube[*,*,i])[w]
     out[0,i]=reform(temp)
     if n_elements(w3) ne 0 then begin
        if i eq 0 then w3=w $
        else w3=[w3,w+ninx*i]
     endif
  endfor
  
  if n_elements(w3) ne 0 then return, w3 $
  else return, out
end
