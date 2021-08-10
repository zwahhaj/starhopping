;;Written by Zahed Wahhaj, 2015

pro sph_confake, imgs, fakes_save=fakes_save,tag=tag,pscale=pscale,simple=simple, fwhm=fwhm, disp=disp, maskrad=maskrad
  
if n_elements(tag) eq 0 then tag=''
if n_elements(fwhm) eq 0 then fwhm=4
if n_elements(pscale) eq 0 then pscale=0.01225
if n_elements(fakes_save) eq 0 then fakes_save='imcfakes.save'

restore,file=fakes_save
dmsf = dmags_fake
rhosf = rhos_fake
pasf = pas_fake


img = readfits(imgs,head)
;img = filter_image(img0,fwhm=fwhm/2.)

smap = img/rmsmap_slow(img)
if n_elements(maskrad) ne 0 then begin
   wmask = getrgn(img,0,maskrad)
   img[wmask]=0
endif

;wout = getrgn(smap,sz*0.42,sz)
;smap[wout]=0
;img[wout]=0

sz = (size(img))[1]
rout = sz/2.0

if n_elements(rout) ne 0 then begin
   wout = getrgn(img, rout,2*rout)
   img(wout) = 0
   smap(wout) = 0
endif

   cc = (sz-1)/2.0
   d2r = !pi/180.0
   num = n_elements(rhosf)
   consf = fltarr(num)
   epos = fltarr(num)
   fqs = fltarr(num)
   sns = fltarr(num)
   for i=0,num-1 do begin
      dx= -rhosf[i]*sin(pasf[i]*d2r)
      dy= rhosf[i]*cos(pasf[i]*d2r)
      x = cc+dx
      y = cc+dy
      wb = getrgn(img,xc=x,yc=y,0,5)
      temp = img
      smap = snmap(temp, rgnblock=wb)

      peak=0
      if n_elements(simple) ne 0 then begin
         ;;curpeak,smap,x,y,peak,/guess
         fqs[i] = roundness(img, x, y, limfw=5,xc=xc,yc=yc,edist=edist)
         if fqs[i] gt 0 and fqs[i] le 0.9 then $
            peak = sncalcpt2(img, xc, yc, fwhm, disp=disp)
         epos[i]=edist
         ;;fqs[i] = 0.5
      endif else fqs[i] = roundness(smap, x, y, limfw=4,/force, peak=peak,fwhm=fwhm,edist=edist)
      sns[i] = peak
      ;consf[i]= 0
      consf[i] = dmsf[i]+logm(sns[i]/5.0)
      ;print, 'sph_confake:', x, y, dmsf[i], sns[i], peak
      ;if n_elements(simple) eq 0 $
      ;then if fqs[i] gt 0.85 or sns[i] lt 3.5 then consf[i] = -1 $
      ;else if sns[i] lt 3.5 then consf[i] = -1
   endfor
   
   wg = where(fqs lt 0.85 and sns gt 3.5 and epos lt fwhm/2.0 or (sns gt 6 and fqs lt 0.6 and  epos lt fwhm/1.33) ) ;; only allow good shapes
   writefits,'snmap'+tag+'.fits',smap
   forprint, "Warning: at small IWA, SNMAP underpredicts SNR, b/c of easily recog. wave structure. Using orig. image instead.", textout='contrast_fakes'+tag+'.txt'
   
   if wg[0] ne -1 then begin
      forprint2, rhosf[wg]*pscale, consf[wg], textout='contrast_fakes'+tag+'.txt',f='F7.2,F7.2',/update
      rho=rhosf[wg] & dmag=consf[wg]
      save,file='contrast_fakes'+tag+'.save',rho,dmag
      
      forprint, "   rhosf, consf, sns,   fqs,  epos ", textout='contrast_fakes_all'+tag+'.txt'
      forprint2, rhosf*pscale, consf, sns,fqs, epos, textout='contrast_fakes_all'+tag+'.txt',f='F7.2,F7.2,F7.2,F7.2,F7.2',/update
   endif
   
end
