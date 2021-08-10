;; Written by Zahed Wahhaj, 2021, July 21
;; Changed from irdis_make_flux_cube.pro
;; Get flux and center information from unsaturated exposures.

pro irdis_noco_flux_cen, fluxlist, szn=szn, peaks=peaks, normflux=normflux

readcol,fluxlist,filename,f='A'

numf = n_elements(filename)


;;Load images into one large image cube
for i=0,numf-1 do begin
   imci =  readfits(filename[i],head)   

   if (size(imci))[0] eq 2 then numc = 1
   if (size(imci))[0] eq 3 then numc = (size(imci))[3]
   
   ;;DET SEQ UTC / Sequencer Start Time
   ;;DET FRAM UTC / File Creation Time
   
   t0 = esotime(esopar(head,'DET SEQ UTC'))
   t1 = esotime(esopar(head,'DET FRAM UTC'))
   tstamp0 = rangegen(t0,t1,numc) ;; time_stamp in seconds since year 2000
   
   ra_str = replicate(esopar(head,'TEL TARG ALPHA'), numc)
   dec_str = replicate(esopar(head,'TEL TARG DELTA'), numc)

   posx = float((esopar(head,'INS1 DITH POSX'))[0])
   posy = float((esopar(head,'INS1 DITH POSY'))[0])
   tempx = replicate(posx,numc)
   tempy = replicate(posy,numc)

   irdis_normfluxfac, 'dummy', normfac, dit, ndfac, flambdas, filename=filename[i]
   normfac0 = cmreplicate(normfac,numc)
   
   obsid = replicate(nint(esopar(head,'ESO OBS ID')), numc)

   if i eq 0 then begin
      imc = imci
      posxs = tempx
      posys = tempy
      normfacs = normfac0
      ras = ra_str
      decs = dec_str
      tstamp = tstamp0
      obsids = obsid
   endif else begin
      imc = [ [[imc]], [[imci]] ]
      posxs = [posxs, tempx]
      posys = [posys, tempy]
      normfacs = [[normfacs], [normfac0]]
      ras = [ras, ra_str]
      decs = [decs, dec_str] 
      tstamp = [tstamp, tstamp0]
      obsids = [obsids, obsid]
  endelse
   
endfor

numc =  (size(imc))[3]
sz = (size(imc))[2]
cc = (sz-1)/2.0
pp0 = nint(cc-szn/2.0)


;;dt = (ftime-itime)/numc
detside = intarr(numc)
normfluxes = intarr(numc)
ndfacs = intarr(numc)
lambdas = intarr(numc)

if n_elements(szn) eq 0 then begin
   szn=sz
   pp0 = 0
endif


flat = readfits('flat_irdis.fits',junk) 
badpix = 1-readfits('badpix_irdis.fits',junk)

for i=0,numc-1 do begin

   
   img = imc[*,*,i]
   
   img[0:50,*,*] = 0
   img[940:1080,*,*] = 0
   img[1960:*,*,*] = 0

   img = img/flat
   fixpix,img,badpix,img0
   
   wnan = where(1-finite(img0))
   if wnan[0] ne -1 then img0[wnan] = 0


   img1 = img0[0:1023,*]
   img2 = img0[1024:2047,*]

   ;;undither
   img1 = shift(img1, -posxs[i], -posys[i])
   img2 = shift(img2, -posxs[i], -posys[i])
   
   
   temp = img1
   wout = getrgn(temp,200,800)
   temp(wout) = 0
   qzap,temp,temp, maxiter=1

   max1 = max(temp,w)
   x1 = w[0] mod sz
   y1 = w[0] / sz
   
   curpeak,img1,x1,y1,peak,/guess
   peak1=peak

   wipe = getrgn(img1,10,800,xc=x1,yc=y1)
   fluximg1 = img1
   fluximg1(wipe) = 0 

   print, 'peak counts / sec = ', peak1

   temp = img2
   wout = getrgn(temp,200,800)
   temp(wout) = 0
   qzap,temp,temp, maxiter=1

   max2 = max(temp,w)
   x2 = w[0] mod sz
   y2 = w[0] / sz
   curpeak,img2,x2,y2,peak,/guess
   peak2=peak
   
   wipe = getrgn(img2,10,800,xc=x2,yc=y2)
   fluximg2 = img2
   fluximg2(wipe) = 0 
   
   print, 'peak counts / sec = ', peak2
   
   dx1 = cc-x1
   dy1 = cc-y1
   dx2 = cc-x2
   dy2 = cc-y2
   
   fluximg1 = shift_sub(fluximg1, dx1, dy1) ;/(dits[i]*maxdit)
   fluximg2 = shift_sub(fluximg2, dx2, dy2) ;/(dits[i]*maxdit)

   fluximg1 = fluximg1[pp0:pp0+szn-1,pp0:pp0+szn-1]
   fluximg2 = fluximg2[pp0:pp0+szn-1,pp0:pp0+szn-1]

   if i eq 0 then begin
      fluximc = [ [[fluximg1]], [[fluximg2]] ]
      peaks = [peak1, peak2]
      detside = [0,1]
      lambdas = flambdas
      normflux = normfacs[*,i]*[peak1, peak2]
      tstamps = [tstamp[i], tstamp[i]]
      xcs = [x1, x2]
      ycs = [y1, y2]
      ra_str = [ras[i], ras[i]] 
      dec_str = [decs[i], decs[i]] 
      obsid = [obsids[i], obsids[i]]
   endif else begin
      fluximc = [ [[fluximc]], [[fluximg1]], [[fluximg2]] ]
      peaks = [peaks, peak1, peak2]
      detside = [detside, 0, 1]
      lambdas = [lambdas, flambdas]
      normflux = [normflux, normfacs[*,i]*[peak1, peak2]]
      tstamps = [tstamps, tstamp[i], tstamp[i]]
      xcs = [xcs, x1, x2]
      ycs = [ycs, y1, y2]
      ra_str = [ra_str, ras[i], ras[i]] 
      dec_str = [dec_str, decs[i], decs[i]] 
      obsid = [obsid, obsids[i], obsids[i]]
      ;ndfacs = [ndfacs, ndfac, ndfac]
   endelse
   print, 'size of tstamps =', n_elements(tstamps)
endfor

   comment='"normflux" is the estimated peak for ND=0, 1um band width, and 1s expo. "peaks" give the unconverted peaks flux of the PSFs. The images "fluximc" also have unchanged peaks.'
   
;save,file='flux.save', peak1, peak2, fluximg1, fluximg2
   save,file='cenflux.save', peaks, fluximc, lambdas, normflux,comment, xcs, ycs, detside, tstamps, ra_str, dec_str, obsid

   oid = zuniq(obsid)
   for i=0, n_elements(oid)-1 do begin
      w = where(obsid eq oid[i] and detside eq 0)
      push, xcs1, mean(xcs[w]), i
      push, ycs1, mean(ycs[w]), i

      w = where(obsid eq oid[i] and detside eq 1)
      push, xcs2, mean(xcs[w]), i
      push, ycs2, mean(ycs[w]), i
   endfor
   save,file='cenobid.save', oid, xcs1, ycs1, xcs2, ycs2
;print, dit, ndfac
   
end
