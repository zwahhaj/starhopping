;;Written by Zahed Wahhaj.

function get_w, im, rin, rout, xc, yc

sz = (size(im))[1]

if  n_elements(xc) eq 0 then xc = sz/2.
if n_elements(yc) eq 0 then yc = sz/2.
if n_elements(rin) eq 0 then rin = 25.
if n_elements(rout) eq 0 then rout = 40.

;;print, rin, rout
dist_circle,dd,sz,xc,yc
w = where(dd ge rin and dd le rout)
return, w
end
