;; Written by Zahed Wahhaj
;; inputs:
;;   dmag: (optional) array giving 5-delta contrast curve (as fn of pixel separation).
;;         only used to make 5sigma limits
;; outputs:
;;   sn_map
;;   ndet: number of sources detected

pro detect_gen, image, contrast=contrast,sn_map=sn_map, disp=disp, sns_cut=sns_cut, fqs_cut=fqs_cut, fws_cut=fws_cut, dmag=dmag, filebase=filebase, ndet=ndet, peakstar=peakstar, xf=xf, yf=yf,pix_asec=pix_asec

if n_elements(filebase) eq 0 then filebase = 'dets_'

if size(image,/type) eq 7 then out = readfits(image,head) $
else out = image

wnan = where(1-finite(out))
if wnan[0] ne -1 then out[wnan] = 0


sz = (size(out))[1]
cc = (sz-1)/2.0

if n_elements(peakstar) eq 0 then peakstar=1.0
if n_elements(sns_cut) eq 0 then sns_cut=5.0
if n_elements(fws_cut) eq 0 then fws_cut=2.2
if n_elements(fqs_cut) eq 0 then fqs_cut=0.35
if n_elements(disp) eq 0 then disp=0
if  n_elements(dmag) ne 0 then dm = dmag $
else begin
   dm = logm(peakstar/5.0/radprof(out,/rms,/noclip,orad=sz/2.0))
   dm = dm(where(finite(dm)))
endelse

rr = findgen(n_elements(dm))

fout = out
submedprof, fout, inrad=2.0
rmap = rmsmap_slow(fout) > stddev(out)/1e6
sn_map = fout/rmap ;;

;; get only the peaks of the good candidates
csn = (max(sn_map,wc))[0] & wc = wc[0]
temp = sn_map
while csn gt 3 do begin
   wm = where(temp eq csn) & wm=wm[0]
   wc = [wc, wm]
   xm = wm mod sz
   ym = wm / sz
   temp[ (xm-3>0):(xm+3<sz-1), (ym-3>0):(ym+3<sz-1) ]=0
   csn = (max(temp))[0]
endwhile

;;wc = where(sn_map gt 3.0, numc)
numc = n_elements(wc)

fqs = fltarr(numc)
sns = fltarr(numc)
x = fltarr(numc)
y = fltarr(numc)
fws = fltarr(numc)
dmags = fltarr(numc)

for i=0L,numc-1 do begin
   x[i] = wc[i] mod sz
   y[i] = wc[i] / sz
   xc = x[i]
   yc = y[i]
   fqs[i] = 1
   sns[i] = 0
   
   bscentrd,sn_map,xc,yc,xc1,yc1
   if xc1 ne -1 and yc1 ne -1 then begin
      xc = xc1
      yc = yc1
   endif
   ;;if xc gt 3 and yc gt 3 and xc lt sz-3 and yc lt sz-3 then begin
   ;;peak = interpolate(sn_map,xc,yc,c=-0.5)
   fqs[i] = roundness(sn_map, xc, yc, limfw=6,/force, peak=peak,fwhm=fwhm)
   dmags[i] = logm(peakstar/interpolate(out,xc,yc,c=-0.5)/5.0)
   sns[i] = peak
   x[i] = xc
   y[i] = yc
   fws[i] = fwhm
   ;; if match older sources then set signal to noise to zero.
   if i ne 0 then $
      if total(abs(x[i]-x[0:i-1]) lt 0.5 and abs(y[i]-y[0:i-1]) lt 0.5) gt 0 then sns[i]=0 
   ;;end
endfor


;; reject good points close together
wg = where( sns gt sns_cut and fqs lt fqs_cut and fws gt fws_cut, numg)

forprint2, "#Dmags not corrected for systematic error. See 'contrast.txt' created by '/contrast' flag for correction.", textout=filebase+'cands.txt'
if numg eq 0 then goto, SNMAP_L

ch = fltarr(numg)+1
test = sn_map
fws = fws[wg]
xg = x[wg]
yg = y[wg]
snsg = sns[wg]
fqsg = fqs[wg]
dmags = dmags[wg]
rhos = fltarr(numg)
pas = fltarr(numg)

snsg += randomn(seed,numg)/100.0

ii = findgen(numg)
for i=0L,numg-1 do begin
   ;wi = where(i ne ii)
   dist = sqrt((xg[i]-xg)^2 + (yg[i]-yg)^2)
   wx = where(dist lt 5 and snsg[i] gt snsg)
   if wx[0] ne -1 then begin 
      ch[wx]=0
   endif
endfor

;; best candidates
wb = where(ch, numb)
test = sn_map
if disp eq 1 then display, test,aspect=1, min=-5.0, max=10
for i=0L,numb-1 do begin
   ;test[ xg[wb[i]],  yg[wb[i]]] += 20
   rhos[wb[i]] = sqrt( (xg[wb[i]]-cc)^2 + (yg[wb[i]]-cc)^2)
   pas[wb[i]] = atan((yg[wb[i]]-cc), (xg[wb[i]]-cc))*180/!pi - 90.0
   ;xyshape,xg[wb[i]],yg[wb[i]],5,/circle,xout=xout,yout=yout
   ;oplot,xout,yout,col=155,thick=1
endfor

wb = where(ch and rhos lt sz/2.0-5.0 and fws gt 1.7 and fws lt 6.0, numb)

ndet=0 ;; just a default value
if numb eq 0 then goto, SNMAP_L

;; final values
xf = xg[wb]
yf = yg[wb]
snsf = snsg[wb]
fqsf = fqsg[wb]
dmags = dmags[wb]
rhosf = rhos[wb]
pasf = pas[wb]
fwf = fws[wb]

o = sort(rhosf)

if disp eq 1 then begin
   for i=0L,numb-1 do  begin 
      xyshape,xf[o[i]],yf[o[i]],5,/circle,xout=xout,yout=yout
      oplot,xout,yout,col=155,thick=1
      xyouts,xf[o[i]]+4,yf[o[i]]+4,strn(i),chars=1.5
   endfor
endif

ord = indgen(numb)

xf = xf[o]
yf = yf[o]
snsf = snsf[o]
fqsf = fqsf[o]
dmags = dmags[o]
rhosf = rhosf[o]
pasf = pasf[o]
fwf = fwf[o]


dmsf = dm(nint(rhosf))+logm(snsf/5.0)

if n_elements(dmag) ne 0 then dmags = dm(nint(rhosf))-logm(snsf/5.0)

forprint2, "#       Num    rho(pix),    PA(deg),     X(pix),      Y(pix),      SNR,       FWHM,        PSF_shape,    5siglim, Dmag", textout=filebase+'cands.txt', /update
forprint2, "#Detections within separation of ", string(sz/2.0-5.0,f='(I3)')," pixels.", textout=filebase+'cands.txt', /update
forprint3, ord, rhosf, pasf, xf, yf, snsf, fwf, fqsf, dmsf, dmags, textout=filebase+'cands.txt', /update
    
forprint2, "#Dmags have to calculated from comparing SN to contrast file. See 'contrast.txt' created by '/contrast' flag for correction.", textout=2
forprint2, "#Detections within separation of ", string(sz/2.0-5.0,f='(I3)')," pixels.", textout=2
forprint2, "#       Num    rho(pix),    PA(deg),     X(pix),      Y(pix),      SNR,       FWHM,      PSF_shape,    5siglim, Dmag", textout=2
forprint3, ord, rhosf, pasf, xf, yf, snsf, fwf, fqsf, dmsf, dmags, textout=2


;; making an eps image where the candidates are tagged

loadct,0
;ps_open,filebase,/enc,/sq
display, (sn_map > (-5)) < 20
for i=0,numb-1 do begin
   xyouts,xf[i]+3,yf[i]+3,trim(i),col=254,chars=0.8
   oplot,[xf[i]],[yf[i]],psym=3,col=254,symsize=0.8
endfor
;ps_close


save,file=filebase+'cands.save', rhosf, pasf, xf, yf, snsf, fwf,  fqsf, dmsf, rr, dm, dmags

ndet = n_elements(rhosf)

;;print, numb

SNMAP_L:
writefits,filebase+'snmap.fits',sn_map

if n_elements(contrast) ne 0 then begin
   dmag = dm 
   rho = findgen(n_elements(dmag))
   forprint2, textout=filebase+'contrast.txt', '# sep(pix)    5sigma-contrast(mags)'
   forprint2, textout=filebase+'contrast.txt', rho, dmag, /update
   ps_open,filebase+'contrast',/enc,/sq
   plot,rho,dmag,xr=[rho[1],(max(rho))[0]],yr=[ median(dmag)+2.0, (min(dmag))[0]-1],xs=1,ys=1, xtit='separation (pixels)', ytit='5-sigma contrast (mags)',chars=1.5, thick=3,/xlog
   ps_close
   save,file=filebase+'contrast.save', rho, dmag
   if n_elements(pix_asec) ne 0 then begin
      ps_open,filebase+'contrast_asec',/enc,/sq
      plot,rho*pix_asec,dmag,xr=[0.1,0.95*(max(rho))[0]*pix_asec],yr=[ median(dmag)+1.0, (min(dmag))[0]],xs=1,ys=1, $
      ;plot,rho*pix_asec,dmag,xr=[0.1,5.0],yr=[ 18, 14.7],xs=1,ys=1, $
           xtit='separation (arcseconds)', ytit='5-sigma contrast (mags)',chars=1.5, thick=3,/xlog
      ps_close
   endif
endif

end

