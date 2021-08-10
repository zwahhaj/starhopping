;; Written by Zahed Wahhaj, May 28, 2021.
;; Displays image with controllable HSV stretching.
pro zcdisp, img, paper = paper,nodisp=nodisp 
  device, decomposed=0
    
  h = fltarr(256)
  s = fltarr(256)
  v = fltarr(256)

  ;;finding limits of image
  ;;saving corrected image in temp
  med = median(img)
  minv = med-3*robust_sigma(img)
  lev2 = med+2*robust_sigma(img)
  ws = where(img gt lev2) ;; where signal
  lev3 = median(img[ws])+4*robust_sigma(img[ws]) ;; top ~30%
  temp = img > minv

  ;; dont know I have to subtract, but it does not work nicely otherwise.
  ;temp -=minv
  
  maxv = (max(temp))[0]
  
  maxi = 255d
  
  si = [minv,lev2,lev3,maxv]*1d
  li = findgen(4)/4.0*maxv

  i1 = si*0
  i1 = floor((si-minv)*1d/(maxv-minv)*maxi)
  
  sf = deltas(si)/deltas(li)
  cf = [0.1,0.8,0.1] ;; fraction of dyn range per inten tertile.

  cf = cf*sf[0:2]
  cf /= total(cf)
  
  ;sh = [0.57,0.7,1.0,0.5]*360.0 ;; start/end inten at each tertile
  ;ss = [0.65,0.75,0.4,0.0] ;; start/end inten at each tertile
  ;sv = [0.55,0.6,0.90,1.0] ;; start/end inten at each tertile

  sh = (0+[0.5,0.65,1.0,1.05])*360.0 ;; start/end inten at each tertile
  ;sh = [0.8,0.90,1.1,1.2]*360.0 ;; start/end inten at each tertile
  ;sh =([0.5, 0.7,  1.1,   1.2]+0.1)*360.0 ;; start/end inten at each tertile
  ss = [0.9, 0.75, 0.45,  0.0] ;; start/end inten at each tertile
  ;sv = [0.2, 0.55, 0.9,  1.0] ;; start/end inten at each tertile
  sv = [0.4, 0.5, 0.85,  1.0] ;; start/end inten at each tertile

  ;sh = [0.4,0.7,1.0,0.5]*360.0 ;; start/end inten at each tertile
  ;ss = [0.8,0.7,0.5,0.0] ;; start/end inten at each tertile
  ;sv = [0.3,0.6,0.9,1.0] ;; start/end inten at each tertile

  ;i1 = 0
  for ii = 0,2 do begin
     ;;for j =1d, 0.1d, -(1-0.1)/nv do begin
     ;;for i =1d, 0.1d, -(1-0.1)/ns do begin
     ;;for k =0d,359d,360/nh do begin
     ;i2 = floor(i1+cf[ii]*maxi) < maxi
     num = 1d*(i1[ii+1]-i1[ii])
     nn=0 ;; index for this tertile
     for inx=i1[ii],i1[ii+1]  do begin
        dv = (sv[ii+1]-sv[ii])/num ;; val inc for tetile ii
        ds = (ss[ii+1]-ss[ii])/num ;; val inc for tetile ii
        dh = (sh[ii+1]-sh[ii])/num ;; val inc for tetile ii
        v[inx] = sv[ii]+dv*nn        
        ;h[inx] = 359; sh[ii]+dh*nn
        h[inx] = sh[ii]+dh*nn
        s[inx] = ss[ii]+ds*nn
        ;;if nint(alog(inx)) mod 3 eq 0 then print, inx, h[inx], s[inx],v[inx],minv+inx*(maxv-minv)/maxi
        if inx mod 20 eq 0 then print, inx, h[inx], s[inx],v[inx],minv+inx*(maxv-minv)/maxi
        nn++
     endfor
     ;print, i1,i2, v[i1], v[i2]
     ;i1=i2+1
endfor

;    ;; col000 = white
;  h[0] = max-1
;  s[0] = 0
;  v[0] = 1

;  ;; col001 = black
;  h[1] = max-1
;  s[1] = 1
;  v[1] = 0

;    ;; col001 = white
  h[255] = maxi-1
  s[255] = 0
  v[255] = 1

  win = getrgn(temp,0,6)
  temp[win]=0
  tvlct, h, s, v, /hsv
  ;atv, temp, /al
  ;cindex
  zdisp, temp,z=1.5,/orglim
  ;display, temp
end
