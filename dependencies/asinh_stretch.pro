function asinh_stretch, image, beta, skysimp=skysimp

;+
; apply asinh stretch to images, based on recipe from Aaron Barth
;   (and originally based on Lupton et al)
; uses SKY.PRO from IDL DAOPHOT distribution in Goddard/Astron library
; 03/09/07 M. Liu (IfA/UH)
;
; uses ITERSTAT if SKY failed to measure noise in image
; 01/24/08 MCL
;
; cleaned up logic for user-supplied 'beta' value
; 05/28/08 MCL
;
; Added keyword skysimp for simpler sky calc
; 06/02/2011 ZW
;-

;iterstat, image, iout, /nobad, /silent
;if n_elements(beta) eq 0 then $
;   beta = iout(3)
;minval = iout(2) - 2.*iout(3)


sz = size(image)
if sz(0) eq 2 then $
   nimgs = 1 $
else $
   nimgs = sz(3)


outimgs = bytarr(sz(1), sz(2), nimgs)
for i = 0, nimgs-1 do begin

   if n_elements(skysimp) eq 0 then begin
      sky, image(*, *, i), skymode, skysig, /silent
      if n_elements(beta) eq 0 then begin
         beta = skysig 
      endif else begin
         message, 'using user-defined beta', /info
         skysig = beta
      endelse
      
      if finite(skysig) eq 0 then begin
         iterstat, image(*, *, i), iout, /silent
         beta = iout(3)
      endif
   endif else begin
      temp = image
      w = where(temp ne 0 and finite(temp))
      sky = median(temp(w)) & skysig = robust_sigma(temp(w))
      beta = skysig
      skymode = 0
   endelse

   minval = (skymode-2.*skysig) > min(image(*, *, i))
   ;maxval = (skymode+4.*stdev(image)) < max(image)
   maxval = max(image(*, *, i))

   outimgs(*, *, i) = bytscl(asinh( (image(*, *, i)-minval) / beta), $
                             min = 0, $
                             max = asinh((maxval-minval) / beta), $
                             top = !d.table_size-1, $
                             /nan)
endfor

return, outimgs

end
    
