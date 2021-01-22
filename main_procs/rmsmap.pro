;;Written by Zahed Wahhaj.

function rmsmap, im, box=box, res=res, proper=proper, smart=smart,xc=xc,yc=yc,orad=orad,dia=dia,std=std
  sz1 = (size(im))[1]
  sz2 = (size(im))[2]
  map = fltarr(sz1,sz2)
  rms0 = robust_sigma(im(where(im ne 0)))
  if n_elements(orad) eq 0 then orad=sz1/2-10
  if n_elements(dia) eq 0 then dia=5

  if n_elements(xc) eq 0 then begin
     xc = sz1/2
     yc = sz2/2
  endif

  if n_elements(proper) ne 0 or n_elements(smart) ne 0 then begin
     if n_elements(std) then rf = radprof(im, dia=dia, /rms, orad=orad,xc=xc,yc=yc) $ 
     else rf = radprof(im, dia=dia, /rms, /robust, orad=orad,xc=xc,yc=yc) 
     dist_circle, dd, [sz1,sz2], xc, yc
     rmsmap = rf(dd)
     if n_elements(smart) eq 0 then return, rmsmap
  endif
  
  if n_elements(box) eq 0 then box = 15
  if n_elements(res) eq 0 then res = 3
  s = box/2
  ;stop
  for x=0, sz1-1-res,res do begin
     for y=0, sz2-1-res,res do begin
        xl = x-s > 0
        xh = x+s < sz1-1
        yl = y-s > 0
        yh = y+s < sz2-1
        rms = robust_sigma(im[xl:xh,yl:yh])
        ;rms = stddev(im[xl:xh,yl:yh])
        map[x:x+res-1,y:y+res-1] = rms
     endfor
  endfor
  ;stop
  map = map > rms0
  if n_elements(smart) eq 0 then return, map
  
  finmap = rmsmap
  w = where(dd gt 250)
  finmap(w) = map(w) 
  return, finmap
  
end
