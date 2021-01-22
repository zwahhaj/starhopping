;;Written by Zahed Wahhaj
;; july 22, 2012. Corrected the step keyword.
function rangegen, x1, x2, pts, log=log, step=step, odd=odd, even=even

  if n_elements(pts) eq 0 then begin
     if n_elements(step) eq 0 then pts = 100.0d $
     else pts = ceil((x2-x1)/step+1.0d)
  endif

  if n_elements(log) then begin 
     range = alog(x2)-alog(x1)
     temp = dindgen(pts)*range/(pts-1d)+alog(x1) 
     return, (2.71829d)^temp 
  endif else begin
     if n_elements(step) ne 0 then range = (pts-1d)*step $
     else range = x2-x1
     temp = dindgen(pts)*range/(pts-1d)+x1 
     if n_elements(odd) ne 0 then temp = temp(where(temp mod 2 ne 0))
     if n_elements(even) ne 0 then temp = temp(where(temp mod 2 eq 0))
     return, temp
  endelse
end
