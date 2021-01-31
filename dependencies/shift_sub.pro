function shift_sub, image, x0, y0,missing=missing
;+
; NAME: SHIFT_SUB
; PURPOSE:
;     Shift an image with subpixel accuracies
; CALLING SEQUENCE:
;      Result = shift_sub(image, x0, y0)
;-
;;ZW Dec16,2009; added missing=0 option

s =size(image)
 
if fix(x0)-x0 eq 0. and fix(y0)-y0 eq 0. then begin 
   image2 = shift(image, x0, y0)
   ;;print, 'hello'
   return, image2
endif else begin
   x=findgen(s(1))#replicate(1., s(2))
   y=replicate(1., s(1))#findgen(s(2))
   x1= (x-x0)>0<(s(1)-1.)  
   y1= (y-y0)>0<(s(2)-1.)  
   image2 = interpolate(image, x1, y1, cubic=-0.5, missing=0)
endelse

if n_elements(missing) ne 0 then image2[0:x0 > 0, 0:s(2)-1] =missing  
if n_elements(missing) ne 0 then image2[s(1)+x0 < s(1)-1:s(1)-1, 0:s(2)-1] =missing  
if n_elements(missing) ne 0 then image2[0:s(1)-1, 0:y0 > 0] =missing  
if n_elements(missing) ne 0 then image2[0:s(1)-1, s(2)+y0 < s(2)-1:s(2)-1] =missing  

return, image2

end 
