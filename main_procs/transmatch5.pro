function FUNC, P
  common transcom, im1a, im2a, wmatch, best, bestrms, ixc, iyc, noscl, notdisp

  if (noscl eq 1) then P[2] = 1.
  
  sx = P[0] & sy = P[1] & mult = P[2]
  if (n_elements(P) gt 3) then ang = P[3]
  if (n_elements(P) gt 4) then zoom = p[4]
  
  sz = size(im1a)
  
  im1t = im1a
  im2t = im2a

  if (n_elements(P) eq 4) then $
     im2t = rot(im2t, ang, 1, ixc, iyc, cubic=-0.5, /PIVOT, missing=0)
  if (n_elements(P) eq 5) then $ 
     im2t = rot(im2t, ang, zoom, ixc, iyc, cubic=-0.5, /PIVOT, missing=0)

  im2t = shift_sub(im2t, sx, sy)
  
  sub = im1t-im2t*mult
  ;image_statistics, sub(wmatch), stddev=rms
  iterstat, sub(wmatch), istat, /silent
  rms = istat(3)
  ;;brighten fit region
  imt = sub & lavg = avg(imt(wmatch)) & imt(wmatch) += 2*lavg 
  if (notdisp ne 1) then display, imt  
  if (notdisp ne 1) then print, P, rms
  if (rms lt bestrms) then begin 
     bestrms = rms 
     ;best = sub 
     best = P
  endif
  
  RETURN, rms
end

function transmatch5, im1, im2, w, oxc, oyc, mode=mode, pr=pr, ar =ar, sr=sr, zr = zr, pxo=pxo, pyo=pyo, ao=ao, so = so, zo =zo, ftol = ftol, rms = rms, noscale = noscale, nodisp=nodisp, rin=rin, rout=rout

;ar = rotation range
;pr = shifting range
;sr = scaling range
 
common transcom, im1a, im2a, wmatch, best, bestrms, ixc, iyc, noscl, notdisp

if n_elements(rin) ne 0 then w = get_w(im1, rin, rout)

if (n_elements(nodisp) ne 0) then notdisp = 1 $
else notdisp = 0

sz = size(im1)

whereprams, w, sz(1), xmin, xmax, ymin, ymax, xcors, ycors

if not(keyword_set(pr)) then pr = 1.0+sz(1)/50.0 
if not(keyword_set(ar)) then ar = 5.0 
if not(keyword_set(sr)) then sr = 0.5 
if not(keyword_set(zr)) then zr = 0.06 

if not(keyword_set(pxo)) then pxo = 0.0 
if not(keyword_set(pyo)) then pyo = 0.0 
if not(keyword_set(ao)) then ao = 0.0 
if not(keyword_set(so)) then so = 1.0 
if not(keyword_set(zo)) then zo = 1.0 
if not(keyword_set(noscale)) then noscl = 0 else noscl=1 

if not(keyword_set(ftol)) then ftol = 1.0e-6 

if keyword_set(mode) then begin 
   if (mode ne 2) then zr = 0 
endif else zr = 0

if not(keyword_set(mode)) then mode = 0 

ext = fix(pr+zr*sz(1)/4.0)      ; extend the fitting window by this much more
xmin -= ext
xmax += ext
ymin -= ext
ymax += ext

;;make sure box is odd , so it has a pixel center
if ((xmax-xmin)/2.0 - nint((xmax-xmin)/2) ne 0) then xmax ++ 
if ((ymax-ymin)/2.0 - nint((ymax-ymin)/2) ne 0) then ymax ++ 
xc = (xmax-xmin)/2+xmin
yc = (ymax-ymin)/2+ymin
ixc = xc-xmin
iyc = yc-ymin

if (notdisp ne 1) then print,  sz(1), xmin, xmax, ymin, ymax, ext

im1a = im1[xmin:xmax, ymin:ymax]
im2a = im2[xmin:xmax, ymin:ymax]

if (notdisp ne 1) then print, 'little box center (',xc,', ',yc,') =', im2[xc, yc]
if (notdisp ne 1) then print, 'big box center (',xc-xmin,', ',yc-ymin,') =', im2a[xc-xmin, yc-ymin]

bestrms = 1e30

sz2 = size(im1a)

x2cors = xcors-xmin
y2cors = ycors-ymin
wmatch = y2cors*sz2(1)+x2cors

med1 = avg(im1a(wmatch))
med2 = avg(im2a(wmatch))
 
if not(keyword_set(so)) then so = med1/med2

if (mode eq 0)  then $
   r = AMOEBA(ftol, SCALE=[pr, pr, sr], P0 = [pxo, pyo, zo], FUNCTION_VALUE=fval)
if (mode eq 1) then $
   r = AMOEBA(ftol, SCALE=[pr, pr, sr, ar], P0 = [pxo, pyo, so, ao], FUNCTION_VALUE=fval)  
if (mode eq 2) then $
   r = AMOEBA(ftol, SCALE=[pr, pr, sr, ar, zr], P0 = [pxo, pyo, so, ao, zo], FUNCTION_VALUE=fval)  

; Check for convergence:  
;IF N_ELEMENTS(R) EQ 1 THEN MESSAGE, 'AMOEBA failed to converge'  
IF N_ELEMENTS(R) EQ 1 THEN begin 
   print, 'WARNING AMOEBA failed to converge. Using Best value found.'  
   r = best
endif 

sx = r[0] & sy = r[1] & mult = r[2] & ang = 0 & zoom = 1 ;fit parameters

if (arg_present(oxc)) then oxc=xc
if (arg_present(oyc)) then oyc=yc

if (mode eq 1) then begin
   ang = r[3]
   im2 = rot(im2, ang, 1, xc, yc, cubic=-0.5, /PIVOT)
endif 
if (mode eq 2) then begin
   ang = r[3]
   zoom = r[4]
   im2 = rot(im2, ang, zoom, xc, yc , cubic=-0.5, /PIVOT)
endif

if (notdisp ne 1) then print, sx, sy, mult, ang, zoom, xc, yc 
if keyword_set(noscale) then mult = 1

im2 = shift_sub(im2, sx, sy)*mult
tt = im1-im2
;image_statistics, tt(w), stddev=arms
iterstat, tt(w), istat, /silent
arms = istat(3)
if (notdisp ne 1) then print, 'fit rms = ', fval[0],'.  actual rms = ', arms

if keyword_set(rms) then rms = arms
 
;atv, best
return, r
end
