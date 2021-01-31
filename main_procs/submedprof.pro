pro submedprof, img0, xc0, yc0, ar=ar, inrad=inrad, outrad=outrad, mean=mean, deg=deg;; square=square
  ;; ar is arc length is pixels
  ;; if keyword deg is set then ar is arlength in degrees

  sz0 = (size(img0))[1]
  if n_elements(xc0) eq 0 then xc0= (sz0-1)/2.
  if n_elements(yc0) eq 0 then yc0= (sz0-1)/2.
  
  if n_elements(outrad) then begin
     x0 = nint(xc0)-nint(outrad)-1 > 0
     x1 = nint(xc0)+nint(outrad)+1 < (sz0-1)
     y0 = nint(yc0)-(x1-x0)/2 > 0
     y1 = y0 + (x1-x0) < (sz0-1)
     img = img0[x0:x1,y0:y1]
     xc = xc0-x0
     yc = yc0-y0
     sz = (size(img))[1]
  endif else begin
     img = img0
     xc = xc0
     yc = yc0
     sz = (size(img))[1]
  endelse
  
  x = cmreplicate(findgen(sz),sz)
  y = transpose(x)
  
  if n_elements(ar) eq 0 then ar=30
  res=ar
  
  dx = (x-xc) & dy = (y-yc) 
  rad = sqrt(dx^2+dy^2) 
  ang = atan(dy,dx)
  if n_elements(deg) eq 0 then da = ar/rad*180/!PI  < 360.0 $;;arc length in degrees
  else da = ar
  submap = fltarr(sz,sz,res)
  for i=0,res-1 do begin
     angs= ang+(i*1.0/res*da-da/2)*!PI/180.
     xpos = xc+rad*cos(angs)
     ypos = yc+rad*sin(angs)
     submap[0,0,i] = interpolate(img,xpos,ypos,cubic=-0.5)
  endfor
  if n_elements(mean) eq 0 then img = img-median(submap,dim=3,/even) $
  ;;else img = img-robust_mean(submap,20)
  else img = img-total(submap,3)/res
  
  if n_elements(outrad) eq 0 then begin 
     if n_elements(inrad) then begin
        dist_circle, dd, sz, xc, yc
        ww = where(dd gt inrad)
        img0(ww) = img(ww) 
     endif else img0 = img
  endif else begin
     if n_elements(square) then img0[x0:x1,y0:y1]=img $
     else begin
        if n_elements(inrad) eq 0 then inrad=0
        dist_circle, dd, sz0, xc0, yc0
        ww = where(dd gt inrad and dd lt outrad)
        temp = fltarr(sz0,sz0)
        temp[x0:x1,y0:y1]=img 
        img0(ww) = temp(ww)
     endelse
  endelse
end

;;THE 3D vectorization is slower, but here's how you do it.
  ;x = cmreplicate(x,res)
  ;y = cmreplicate(y,res)
  
  ;dx = (xc-x) & dy = (yc-y) 
  ;rad = sqrt(dx^2+dy^2) 
  ;ang = atan(dy,dx)
  ;da = ar/rad*180/!PI ;;arc length in degrees
  ;ress = findgen(res)
  ;ress = cmreplicate(ress,sz)
  ;ress = cmreplicate(ress,sz)
  ;ress = transpose(ress,[2,1,0])
  ;angs= ang+(ress/res*da-da/2)*!PI/180.
  ;xpos = xc+rad*cos(angs)
  ;ypos = yc+rad*sin(angs)
  ;submap = x
  ;for i=0,res-1 do begin
  ;   submap[0,0,i] = interpolate(img,xpos[*,*,i],ypos[*,*,i],cubic=-0.5)
  ;endfor
  ;img = img-median(submap,dim=3)

