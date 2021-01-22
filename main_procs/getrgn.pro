;;Written by Zahed Wahhaj
;; returns annular regions
;; Nov 14, 2014. ZW. Allows PA ranges too.

function getrgn,img,rin,rout,sz=sz,xc=xc,yc=yc,dd=dd,show=show, mask=mask, pa0=pa0, pa1=pa1, amax=amax
  if n_elements(sz) eq 0 then sz = (size(img))[1]
  if n_elements(xc) eq 0 then xc = (sz-1)/2.
  if n_elements(yc) eq 0 then yc = (sz-1)/2.
  if n_elements(rin) eq 0 then rin = 5.0
  if n_elements(rout) eq 0 then rout = sz/2.0*1.5

  if n_elements(dd) eq 0 then dist_circle, dd, sz, xc, yc

  
  if n_elements(pa0) ne 0 then begin 
     pa_circle, pp, sz, xc, yc
     ;dpa = anglediff(pa0, pa1)
     ;if n_elements(amax) eq 0 then  $
     ;   mask = dd ge rin and dd le rout and abs(dpa - (anglediff(pa0,pp) + anglediff(pa1,pp))) lt 0.1 $
     ;else mask = dd ge rin and dd le rout and abs(dpa - (anglediff(pa0,pp) + anglediff(pa1,pp))) ge 0.1 

     if n_elements(amax) eq 0 then  $
        mask = dd ge rin and dd lt rout and angle_in(pa0,pa1,pp) $
     else mask = dd ge rin and dd lt rout and 1-angle_in(pa0,pa1,pp) 

  endif else  mask = dd ge rin and dd lt rout

  w = where(mask)
  if n_elements(show) then begin
     temp = img
     temp(w) += (max(temp))[0]*2
     print, 'center=',xc,yc
     zdisp,temp,xc,yc,zoom=4
  endif
  return, w
end
