;; written by Zahed Wahhaj. oct 15, 2017
;; flag bad images in a cube, by checking the RMS near the center
;;    after subtracting the median
;;
;; INPUTS:
;; cut_factor = if the image has rms greater than the median by this
;;              factor it will be selected as not good.

function get_good_images,imc,inrad=inrad,outrad=outrad, cut_factor=cut_factor, wb=wb, rms_arr=rms_arr,nodisp=nodisp

  num = (size(imc))[3]
  sz = (size(imc))[1]

  if n_elements(outrad) eq 0  then outrad=10 < sz/4.0 
  if n_elements(inrad) eq 0  then inrad=0

  med = median(imc,dim=3)
  rms = fltarr(num)
  rms2=rms
  
  for i=0, num-1 do begin
     img = imc[*,*,i]
     win = getrgn(img,inrad,outrad)
     temp = zscalediff(med,img, wm=win)
     rms[i] = stddev(temp[win])
     ;wr = getrgn(med,outrad,outrad*1.5)
     ;rms2[i] = robust_sigma(img[wr])/median(img[wr])
  endfor

  winf = where(1-finite(rms))
  if winf[0] ne -1 then rms[winf] = -999

  med=(median(rms))[0]
  frms = abs(rms)/med
  ;frms = rms/median(rms)
  ;plothist,rms,bin=1.1

  ;;which images to reject? define
  if n_elements(cut_factor) eq 0 then begin
     sig = robust_sigma(rms)
     thres = med+5.0*sig
     cut_factor = thres/med
  endif
  
  print, 'med_rms, cut_factor :', median(rms), cut_factor

  fcomp = frms lt cut_factor
  wg = where(fcomp)
  wb = where(1-fcomp)
  rms_arr = rms

  if n_elements(nodisp) eq 0 then begin
     inx = indgen(num)
     plot, inx,rms
     oplot, inx[wg],rms[wg], psym=symcat(16),symsize=2
     legend,['good points'],psym=symcat(16),/top,/right,box=0,chars=2,symsize=2
  endif
  return, wg
end
