;;Written by Zahed Wahhaj, 2021
;;outputs -
;; peaks - array of estimated peaks for all lambdas
;; hpeak = peak estimate for h-band
;; jpeak = peak estimate for j-band
;; ypeak = peak estimate for y-band

pro peakcalc_ifs, peaks=peaks, hpeak=hpeak, jpeak=jpeak, ypeak=ypeak

  if file_test("peaks.save") eq 0 then begin
     zrestore,file='imcbasic1.save',st=s
     zrestore,file='flux_ifs.save',st=f
     peaks = f.peaks*median(s.dits,/even)
     lambdas = f.lambdas
  endif else begin
     restore, file='peaks.save'
  endelse
  
  wy = where(lambdas lt 1.2)
  wj = where(lambdas gt 1.2 and lambdas gt 1.34)
  wh = where(lambdas gt 1.5)

  if wh[0] ne -1 then hpeak = mean(peaks[wh])
  if wj[0] ne -1 then jpeak = mean(peaks[wj])
  if wy[0] ne -1 then ypeak = mean(peaks[wy])

  comment='Estimated stellar peak in science images.'
  if file_test("peaks.save") eq 0 then $
     save, file='peaks.save', peaks, hpeak, jpeak, ypeak, lambdas, comment

end
