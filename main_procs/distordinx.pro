pro distordinx, sz, brks, inxs, xc = xc, yc = yc
;; Written by Z. Wahhaj May 21, 2009
;; way to avoid calling 'where' on dist_circle by getting the required
;; indices from a saved file. A lot faster !!!
;;
;; Returns the indices of an image with distances from center going
;; from 0 to 1px, 1 to 2px,... as a series of concatenated arrays in an
;; array called 'INXS', with starting and ending points given in
;; another array called 'BRKS'

  
  sz = long(sz)
  if n_elements(xc) eq 0 then xc = (sz-1)/2.
  if n_elements(yc) eq 0 then yc = (sz-1)/2.
  num = nint(sz/2.*1.415)
  
  inxs = lonarr(sz*sz*1.1)
  brks = lonarr(num)

  spawn,'mkdir ~/temp'
  datfile = '~/temp/'+trim(string(sz))+'-'+trim(string(xc,form='(F7.1)'))+'-'+trim(string(yc,form='(F7.1)'))+'.dat'
  if file_test(datfile) eq 0 then begin
     dist_circle, dd, sz, xc, yc
     k=0l
     l=0l
     for i=0l, num-1 do begin
        w = where(dd ge i-0.5 and dd lt i+0.5)
        ;;if w[0] ne -1 then print, i, mean(dd[w]) $
        ;;else w = where(dd ge i-0.5 and dd lt i+1.5)
        if w[0] eq -1 then w = where(dd ge i-0.5 and dd lt i+1.5)
        num2 = n_elements(w)
        brks[i] = l
        ;;print, l,l+num2-1, w[0], w[num2-1]
        inxs[l:l+num2-1]=w[0:num2-1]
        l = l+num2
     endfor
     
     openw,1,datfile
     writeu,1,brks,inxs
     close,1
     return
  endif
  ;print, systime()
  openr,1,datfile
  readu,1,brks,inxs
  close,1
  
  
  ;;rp = fltarr(num)
  ;;for i=0,num-10 do begin
  ;;  i1 = brks[i]
  ;;   i2 = brks[i+5]-1
  ;;   w = inxs[i1:i2]
  ;;   rp[i] = mean(dd[w])
  ;;endfor
  ;;
  ;;print, systime()
  ;;plot, rp
end
