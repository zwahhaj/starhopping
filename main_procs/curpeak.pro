;; Pixel intensity view range
;; May 12, 2010 , ZW : added aperture phot too
;; Sept 2, 2010 , ZW: added force keyword, accepts given centroid.
;; Written by Zahed Wahhaj

pro curpeak, im, x, y, peak, fw, vrange=vrange, aphot=aphot, rin=rin, flux=flux, eflux=eflux, faps=faps, efaps=efaps, force=force, subsky=subsky, nodisp=nodisp, silent=silent, guess=guess, simple=simple,fixed=fixed

  sz = (size(im))[1]
  
  if n_elements(guess) then begin
     xc = x & yc = y
     finddippeak, im, x, y, x, y, box=4, peak=peak
     ;if im[x,y] lt median(im[x-2:x+2,y-2:y+2]) then begin 
     ;   print,'====ASSUMING NEGATIVE PEAK====='
     ;   im2 = im
     ;   mask = im2*0+(max(im2))[0] & mask[x-2:x+2,y-2:y+2] = 0
     ;   im2 = im2+mask
     ;   junk = min(im2,w)
     ;   x = w[0] mod sz & y = w[0]/sz
     ;endif else begin 
     ;   im2 = im
     ;   bscentrd, im2, x, y, x, y
     ;endelse
     if sqrt((x-xc)^2 + (y-yc)^2) gt 2.0 then begin
        x = xc
        y = yc
     endif
     peak = interpolate(im,x,y,cubic=-0.5)
     goto, phot_l
  endif
  
  if n_elements(nodisp) eq 0 then begin
     temp = im & w = where(finite(temp,/nan)) 
     if w[0] ne -1 then temp(w)=0.0
     if n_elements(vrange) eq 0 then display,asinh_stretch(temp,/skysimp) $
     else display, im, min=vrange[0], max=vrange[1]
  endif

 
  if n_elements(force) ne 0 then goto, forced_L

  cursor, x0, y0,/down
  x0=nint(x0)
  y0=nint(y0)
  window,xs=800,ys=800


  if x0 lt sz/10. and y0 lt sz/10. then begin 
     x = 0
     y = 0
     peak = 0
     return
  endif

  imext,im,im2,x0,y0,100
  
  if n_elements(nodisp) eq 0 then begin
     ;;if n_elements(vrange) eq 0 then display,im2 $
     if n_elements(vrange) eq 0 then display,asinh_stretch(im2,/skysimp) $
     else display, im2, min=vrange[0], max=vrange[1]
  endif
  
  cursor, x, y,/down
  x00=x+50 & y00=y+50

  window,xs=800,ys=800
  if n_elements(simple) then goto, forced_L
  ;;endif
  ;;print,im2[x,y] & pause
  
  finddippeak, im2, x, y, x, y, box=4, peak=peak
  ;if im2[x,y] lt median(im2[x-2:x+2,y-2:y+2]) then begin 
  ;   print,'====ASSUMING NEGATIVE PEAK====='
  ;   sz2 = (size(im2))[1]
  ;   mask = im2*0+(max(im2))[0] & mask[x-2:x+2,y-2:y+2] = 0
  ;   im2 = im2+mask
  ;   junk = min(im2,w)
  ;   x = w[0] mod sz2 & y = w[0]/sz2
  ;   ;atv, im2
  ;   ;stop
  ;endif else begin
  ;   bscentrd, im2, x, y, x, y
  ;endelse

  forced_L:
  if n_elements(force) eq 0 then begin
     peak = interpolate(im2,x,y,cubic=-0.5)
     radplotf,im2,x,y,out,fw,sky=0.0,outrad=10,/silent
     if n_elements(silent) eq 0 then begin
        ;;print, 'peak=',peak
        print, 'x=',x-50+x0
        print, 'y=',y-50+y0
        ;;print, 'fwhm=',fw
     endif
     x = x-50+x0
     y = y-50+y0
  endif else begin
     peak = interpolate(im,x,y,cubic=-0.5)
     radplotf,im,x,y,out,fw,sky=0.0,outrad=10,/silent
     if n_elements(fixed) ne 0 then begin
        x=x00
        y=y00
     endif
     if n_elements(silent) eq 0 then begin
        print, 'peak=',peak
        print, 'x=',x
        print, 'y=',y
        print, 'fwhm=',fw
     endif
  endelse
  phot_l:
  if n_elements(aphot) then begin
     if n_elements(rin) eq 0 then rin=3
     if n_elements(subsky) eq 0 then aper, im, x, y, flux, eflux, sky, skyerr, 1, [rin], /nan, /exact, /flux, setsky=0,/silent $
     else aper, im, x, y, flux, eflux, sky, skyerr, 1, [rin], [rin*1.3,rin*1.5], /nan, /exact, /flux,/silent
  endif
  
  if arg_present(faps) then begin
     aper, im, x, y, flux1, eflux1, sky, skyerr, 1, [1.], /nan, /exact, /flux, setsky=0,/silent   
     aper, im, x, y, flux2, eflux2, sky, skyerr, 1, [2.], /nan, /exact, /flux, setsky=0,/silent   
     aper, im, x, y, flux3, eflux3, sky, skyerr, 1, [3.], /nan, /exact, /flux, setsky=0,/silent   
     aper, im, x, y, flux4, eflux4, sky, skyerr, 1, [4.], /nan, /exact, /flux, setsky=0,/silent   
     aper, im, x, y, flux5, eflux5, sky, skyerr, 1, [5.], /nan, /exact, /flux, setsky=0,/silent   
     faps = [peak,flux1,flux2,flux3,flux4,flux5]
     efaps = [eflux1,eflux1,eflux2,eflux3,eflux4,eflux5]
     eflux = eflux3
  endif

end
