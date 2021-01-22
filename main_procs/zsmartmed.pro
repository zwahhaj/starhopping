;; Written by Zahed Wahhaj
function zsmartmed, imc, rin, rout, peaks=peaksA

  num = (size(imc))[3]
  rmsA = fltarr(num)
  img = imc[*,*,0]
  if n_elements(peaksA) eq 0 then peaksA=fltarr(num)+1.0
  w = getrgn(img, rin, rout)
  for i=0, num-1 do begin
     img = imc[*,*,i]
     rmsA[i] = robust_sigma(img[w])
  endfor
  wtsA = peaksA/rmsA

  o = sort(wtsA)
  flag = 1
  cnt =0
  meds = imc*0
  for i=0,num-1 do begin
     if flag then begin
        i0=i
        flag = 0
     endif else begin
        rat = wtsA[o[i]]/wtsA[o[i0]]
        if rat gt 1.2 and (i-i0) gt 4 then begin
           meds[0,0,cnt] = median(imc[*,*,o[i0:i]],dim=3)
           cnt++
           flag=1
        endif
        ;print, i, rat, flag, cnt
     endelse
  endfor
  if num-i0 gt 1 then meds[0,0,cnt] = median(imc[*,*,o[i0:num-1]],dim=3,/even) $
  else meds[0,0,cnt] = imc[*,*,o[num-1]]
  
  meds = meds[*,*,0:cnt]

 
  for i=cnt,0,-1 do begin
     if i eq cnt then begin
        fmed = meds[*,*,cnt]
        rms0 =  robust_sigma(fmed[w])
     endif else begin
        rms =  robust_sigma((meds[*,*,i])[w])
        wt = rms0/rms
        temp = meds[*,*,i]
        ;fmed = [ [[fmed]], [[cmreplicate(meds[*,*,i], wt)]] ]
        fmed += temp*wt^2
     endelse
  endfor

  ;fimg = median(fmed, dim=3)
  return, fmed/cnt
  
end
