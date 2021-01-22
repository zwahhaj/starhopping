;; Written by Zaheg Wahhaj, May 2014.
;; May 5, ZW: Fixed the bias towards finding smaller fwhm, by the dividing  PSF-fitting residual by distance from center.
;; May 13, ZW: fitting box not varied while finding bestfit. Box size
;;             reset when bestfit found. Gives much better FWHM estimate

PRO gfunct, X, A, F, pder

  F = A[0]+A[1]*(X-A[2])^2

END

function roundness, img0, xco, yco, force=force, diff=diff,fwhm=fwhm, limfw=limfw, xc=xc, yc=yc, peak=peak, edist=edist
  
  imgo = img0
  wx = where(finite(imgo) ne 1)
  if wx[0] ne -1 then imgo(wx) = 0

  if n_elements(limfw) eq 0 then limfw=8.0
 
  sz = (size(imgo))[1]

  if n_elements(xco) eq 0 then begin
     xco= (sz-1)/2.
     yco= (sz-1)/2.
  endif

  
  xc=xco & yc=yco
  edist=0
  if n_elements(force) eq 0 then begin 
     bscentrd,imgo, xco, yco, xc, yc
     edist = sqrt( (xc-xco)^2 + (yc-yco)^2 )
     ;print, 'centers:', xco, yco, xc, yc, edist
     ;if edist gt 2 then return, 1 
  endif

  rness=1e30
  ness = 1e30
  bestfw = 1e30
  ;;for fwhm=2.5,3.5,0.25 do begin
  ;junk = temporary(arr)
  ;junk = temporary(fws)
  for ifw=2.0,limfw,0.1 do begin
     nn=nint(ifw)
     ;;nn=nint(limfw)
     x = rangegen(xc-nn,xc+nn,2*nn+1)
     y = rangegen(yc-nn,yc+nn,2*nn+1)
     ;;dist_circle,dd,2*nn+1,nn,nn
     ;;dd = sqrt(dd > 0.5)
     ;;dd = dd > 0.5

     img = interpolate(imgo,x,y,/grid,cub=-0.5)
     
     psf0 = psf(sz=2*nn+1,fwhm=ifw)
     
     peak = interpolate(img,nn,nn,c=-0.5)
     ;;wm=getrgn(img,0,2)
     wm=getrgn(img,0,5*nn)
     
     diff = zscalediff(img,psf0,wm=wm,fac=fac)
     ;peak = fac

     chflux = total((diff/img)^2) ;;total(abs(diff))/total(abs(img))
     ;;tempv = total((diff/dd)^2)
     tempv = total((diff)^2)
     if ness gt tempv then begin 
        ness = tempv
        rness = chflux
        bestfw = ifw
     endif
     
     ;push,fws, ifw
     ;push,arr,tempv
     ;print, 2*nn+1, total(abs(diff)), total(abs(img))
     ;pause

  endfor
  fwhm = bestfw


  nn=nint(bestfw)
  x = rangegen(xc-nn,xc+nn,2*nn+1)
  y = rangegen(yc-nn,yc+nn,2*nn+1)
  img = interpolate(imgo,x,y,/grid,cub=-0.5)
  psf0 = psf(sz=2*nn+1,fwhm=bestfw)
  wm=getrgn(img,0,5*nn)
  if wm[0] eq -1 then return, 1
  diff = zscalediff(img,psf0,wm=wm,fac=fac)
  ;peak = fac
  rness =  total(abs(diff >0))/total(abs(img > 0))
  
  ;if arg_present(fwhm) ne 0 then begin
  ;   wg = where(fws le bestfw+(bestfw-2.5)+1.0)
  ;   arr = arr[wg]
  ;   fws = fws[wg]
  ;   wt = fws*0+1.0
  ;   prams = [median(arr),ness,bestfw]
  ;   res = curvefit(fws,arr,wt,prams,FUNC='gfunct',/noder)
  ;   fwhm = prams[2]
  ;   stop
  ;endif

  return, rness
end

