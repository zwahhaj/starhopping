;;
pro sph_flux_ifs, filename, padpix=padpix

imc =  readfits(filename,head)
sz = (size(imc))[2]
cc = (sz-1)/2.0   


numc =  (float(esopar(head,'NAXIS3')))[0]

ndfilter = esopar(head,'INS4 FILT2 NAME')
dit =  float((esopar(head,'DET SEQ1 DIT'))[0])
ndit =  esopar(head,'DET NDIT')


readcol,'/Users/zwahhaj/paranal/sphere_related/trans_curves/SPHERE_CPI_ND.txt',lam, nd0,nd1,nd2,nd3,del=' '
lam /= 1000.0

;wave_calib  = readfits('calib/wave_calib.fits')
;wvs  = reform(wave_calib[1027:1027,1007:1045])
lamb0 = float(esopar(head,'DRS IFS MIN LAMBDA'))
lamb1 = float(esopar(head,'DRS IFS MAX LAMBDA'))
numl = float(esopar(head,'DRS IFS SPEC PIX LEN'))

print, lamb0, lamb1, numl
wvs = rangegen(lamb0,lamb1,numl)

case 1 of
   strmatch(ndfilter,'*1.0*') : ndfac = nd1
   strmatch(ndfilter,'*2.0*') : ndfac = nd2
   strmatch(ndfilter,'*3.5*') : ndfac = nd3
   else: ndfac = nd0
endcase


wnan = where(1-finite(imc))
if wnan[0] ne -1 then imc[wnan] = 0
fluximc = imc
temp = imc[*,*,0]

peak = fltarr(numc)
flux = fltarr(numc)
wout = getrgn(temp,100,200)
wipe = getrgn(temp,10,200)

for i=0,numc-1 do begin
   temp = imc[*,*,i]

   temp(wout) = 0
   max1 = max(temp,w)
   x = w[0] mod sz
   y = w[0] / sz
   curpeak,temp,x,y,pk,/guess
   peak[i]=pk/dit

   zaphot, temp, x, y, flux=flux0, eflux=eflux0,/force
   flux[i] = flux0/dit
   
   dx = cc-x
   dy = cc-y
   temp = shift_sub(temp, dx, dy)/pk
   temp[wipe] = 0
   fluximc[0,0,i] = temp
endfor
nds = interpol(ndfac,lam,wvs)
peaks = peak/nds
fluxes = flux/nds

lambdas = wvs

if n_elements(padpix) ne 0 then begin
   fluximc0 = temporary(fluximc)
   fluximc = fltarr(sz+2*padpix,sz+2*padpix,numc)
   for i=0, numc-1 do fluximc[padpix,padpix,i] = fluximc0[*,*,i]
endif

comment='peaks is counts per seconds, with nd=0 or ndfac=1. Flux images normalized to peak=1.'
save,file='flux_ifs.save', fluximc, peaks, fluxes, lambdas, nds, ndfilter, comment
save,file='lambdas_ifs.save',lambdas
end
