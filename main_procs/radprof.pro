function radprof, im1, dia=dia, xc=xc, yc=yc, orad=orad, med=med, rms=rms, frms=frms, map=map, cut=cut, robust=robust, noclip=noclip, average=average

;;Written by Zahed Wahhaj  
;; 04/20/09 ZW: Setting minimum rms to 1/3 robust rms of whole map
;; April 18, 09, ZW: Changing default orad to edge of frame
;returns 1 sigma map from residual map
;using rms in a circular region  with a given diameter around each pixel in 
;the given image
;
;; Keywords 
;; noclip : doesn't set minimum rms
;; Feb 23, 2013: ZW. minor change. search date below.

  wnan = where(finite(im1,/nan))
sz = size(im1)
if not(keyword_set(dia)) then dia = 5
if not(keyword_set(xc)) then  xc = sz(1)/2.0
if not(keyword_set(yc)) then yc = sz(1)/2.0
if not(keyword_set(orad)) then orad = max([abs(xc-sz(1)), xc, abs(yc-sz(1)), yc])-2*dia
if (not(keyword_set(frms)) and not(keyword_set(rms))) then med=1 $
else med = 0
if keyword_set(average) ne 0 then med = 0
if n_elements(noclip) eq 0 then rms0 = robust_sigma(im1) $
else rms0 = 0
map = im1
;;print, 'bin width=', dia,', xc=', xc,', yc=', yc,', orad=', orad

prof = fltarr(orad)

if (keyword_set(cut)) then begin 
   rec = findgen(sz(1), sz(1))
   rec[0:sz(1)-1,nint(yc)-2*dia:nint(yc)+2*dia] = 1
endif

dist_circle,dd,sz(1), xc, yc
;w = where(dd gt 100 and dd lt 110)
distordinx, sz(1), brks, inxs, xc = xc, yc = yc
j = 0
for i=fix(xc), fix(xc)+(fix(orad)  < (size(brks))[1]-dia ) , 1 do begin
   rin = j-dia/2.0
   rout = j+dia/2.0
   if (rin lt 0) then rin = 0
   
   ;;if (keyword_set(cut) ne 0) then w = where (rec eq 1 and dd gt rin
   ;;and dd lt rout) $ ;; minor change below. ZW. Feb 23,2013.
   if (keyword_set(cut) ne 0) then w = where (rec eq 1 and dd gt rin and dd le rout and im1 ne 0) $ 
   else begin 
      i1 = brks[nint(rin)]
      i2 = brks[nint(rout)]-1
      w = inxs[i1:i2]
      if wnan[0] ne -1 then w = setdiff(w,wnan)
   endelse
   ;;else w = where(dd gt rin and dd lt rout)
   
   
   if (w[0] ne -1) then begin 
      ;timp = im1 
      ;timp(w) = 0
      ;display, timp
      ;stop
      if med ne 0 then prof[j]=median(im1(w))
      if keyword_set(average) ne 0 then prof[j] = mean(im1(w))
      if (keyword_set(rms) ne 0) then begin
         if (keyword_set(robust)) then prof[j] = robust_sigma(im1(w)) $
         else begin
            iterstat, im1(w), istat, /silent
            prof[j]=istat(3)
         endelse
      endif
      if (keyword_set(frms) ne 0) then begin 
         if (keyword_set(robust) ne 0) then prof[j] = robust_sigma(im1(w))/median(im1(w)) $
         else begin
            iterstat, im1(w), istat, /silent
            prof[j]=istat(3)/median(im1(w))
         endelse
      endif
      ;map(w) = prof[j]
   endif
   j++
endfor

if (keyword_set(rms) ne 0) then return, prof > rms0

return, prof 
end

