pro finddippeak,img,xc0,yc0,xc,yc,box=box,peak=peak
  ;; Written by Zahed Wahhaj. Jan 30, 2011
  ;; try and find neg dip (saturated peak)
  ;; if neg dip not found then find pos dip
  highpeak = 1e-30
  lowpeak = 1e30
  flag = 0
  if n_elements(box) eq 0 then box= 6
  ds = box/2
  for i=xc0-ds,xc0+ds do begin      ;;find the neg dip a box around the given pixel
     for j=yc0-ds,yc0+ds do begin
        x = nint(i)
        y = nint(j)
        
        c1 = img[x,y] le img[x+1,y+1] 
        c2 = img[x,y] le img[x-1,y+1] 
        c3 = img[x,y] le img[x,y+1] 
        c4 = img[x,y] le img[x+1,y-1] 
        c5 = img[x,y] le img[x-1,y-1] 
        c6 = img[x,y] le img[x,y-1] 
        c7 = img[x,y] le img[x+1,y] 
        c8 = img[x,y] le img[x-1,y]
        
        surr = img[x+1,y+1] + img[x-1,y+1] + img[x,y+1] + img[x+1,y-1] + img[x-1,y-1] + img[x,y-1] + img[x+1,y] +  img[x-1,y] 
        if c1 and c2 and c3 and c4 and c5 and c6 and c7 and c8 then begin
           temp = -img+max(img)
           peak = -1
           if img[x,y] lt 0 then if surr lt lowpeak then begin  ;; if there's a negative dip choose that
              lowpeak = surr              
              print,xc0,yc0,x,y 
              ;;bscentrd,temp,x,y,xt,yt
              xt = x & yt = y
              if sqrt( (x-xt)^2 + (y-yt)^2 ) lt 1. then begin 
                 xc = xt & yc = yt 
              endif else begin 
                 xc = x & yc = y
              endelse
              print,xc,yc 
              flag = 1
              print, 'NEG1!!'
           endif 
           
           if flag ne 1 and img[x,y] ge 0 then if surr gt highpeak then begin ;; if there's a neg dip ignore the pos dip
              highpeak = surr              
              print,xc0,yc0,x,y 
              ;;bscentrd,temp,x,y,xt,yt
              xt = x & yt = y
              if sqrt( (x-xt)^2 + (y-yt)^2 ) lt 1. then begin 
                 xc = xt & yc = yt 
              endif else begin 
                 xc = x & yc = y
              endelse
              print,xc,yc 
              flag = 2
              print, 'NEG2!!'
           endif           
        endif

     endfor
  endfor
  if flag ne 0 then return
  
  for i=xc0-ds,xc0+ds do begin     ;;look for the pos dip now, since neg dip failed.
     for j=yc0-ds,yc0+ds do begin
        x = nint(i)
        y = nint(j)
        
        c1 = img[x,y] ge img[x+1,y+1] 
        c2 = img[x,y] ge img[x-1,y+1] 
        c3 = img[x,y] ge img[x,y+1] 
        c4 = img[x,y] ge img[x+1,y-1] 
        c5 = img[x,y] ge img[x-1,y-1] 
        c6 = img[x,y] ge img[x,y-1] 
        c7 = img[x,y] ge img[x+1,y] 
        c8 = img[x,y] ge img[x-1,y]
 
        if c1 and c2 and c3 and c4 and c5 and c6 and c7 and c8 then begin
           bscentrd,img,x,y,xc,yc
           peak= interpolate(img,xc,yc,c=-0.5)
           print, 'POS!!'
           return
        endif
     endfor
  endfor

  xc = xc0
  yc = yc0
end
