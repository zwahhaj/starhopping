;; Written by Zahed Wahhaj, 2016
pro irdis_make_flux_cube, fluxlist, szn=szn, peaks=peaks, normflux=normflux

readcol,fluxlist,filename,f='A'

numf = n_elements(filename)

for i=0,numf-1 do begin
   imci =  readfits(filename[i],head)   
   if i eq 0 then begin
      imc = imci
   endif else begin
      imc = [ [[imc]], [[imci]] ]
   endelse
endfor
if (size(imc))[0] eq 3 then img = median(imc, dim=3) $
else img = imc


sz = (size(img))[2]
cc = (sz-1)/2.0
pp0 = nint(cc-szn/2.0)

if n_elements(szn) eq 0 then begin
   szn=sz
   pp0 = 0
endif

numc =  (size(img))[0];;(float(esopar(head,'NAXIS3')))[0]
if numc eq 3 then img = total(img,3)/numc

irdis_normfluxfac,fluxlist, normflux, dit, ndfac, flambdas,outsave='normfluxfac.save'      ;; get correction factor for nd_filt, dit and sci_filt_width 

img[0:50,*,*] = 0
img[940:1080,*,*] = 0
img[1960:*,*,*] = 0

flat = readfits('flat_irdis.fits',junk) 
img = img/flat

badpix = 1-readfits('badpix_irdis.fits',junk)
fixpix,img,badpix,img0


wnan = where(1-finite(img0))
if wnan[0] ne -1 then img0[wnan] = 0

qzapboth,img0,img;;, maxiter=16

img1 = img[0:1023,*]
img2 = img[1024:2047,*]

temp = img1
;getfreq,temp,8,temp
wout = getrgn(temp,200,800)
temp(wout) = 0

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
;getfreq,temp,8,temp
wout = getrgn(temp,200,800)
temp(wout) = 0

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

fluximg1 = shift_sub(fluximg1, dx1, dy1)    ;/(dits[i]*maxdit)
fluximg2 = shift_sub(fluximg2, dx2, dy2)    ;/(dits[i]*maxdit)

fluximg1 = fluximg1[pp0:pp0+szn-1,pp0:pp0+szn-1]
fluximg2 = fluximg2[pp0:pp0+szn-1,pp0:pp0+szn-1]

fluximc = [ [[fluximg1]], [[fluximg2]] ]
peaks = [peak1, peak2]
comment='"normflux" should be the divisor to convert image to ND=0, 1um band width, and 1s expo. "peaks" give the unconverted peaks flux of the PSFs.'

;save,file='flux.save', peak1, peak2, fluximg1, fluximg2
save,file='flux.save', peaks, fluximc, flambdas, normflux,comment
;print, dit, ndfac

end
