;;Written by Zahed Wahhaj, 2019
;;Feb 10, 2020: zwahhaj: allow sublcomb to fit to max area but apply to
;;                   smaller areas
;;Feb 22,, 2020: zwahhaj
;;    Added refwidann = width of refannulus
;;    Added refdr = ref ann has inner radius rin+reddr
;;    numref now enforced and takes best matching frames.
;;Oct 13, 2020, zwahhaj
;;    Added submed to force subbing median in sectors for disk reduc.
;;    /chanmatch - makes only same wavelengths are subtracted.
;;    /fast - faster matching refs

pro sph_smart_rdi_loci, imc_save = imc_save, refrdi_save=refrdi_save, numref=numref, out_imc_save=out_imc_save, rin=rin, rout=rout, widann=widann, disp=disp, binfac=binfac, $
                        refwidann=refwidannn ,refdr=refdr,disk=disk, submed=submed, chanmatch=chanmatch, fast=fast


if n_elements(refrdi_save) eq 0 then refrdi_save='refrdi.save'
zrestore,file=refrdi_save,struct=ref,var='imc lambdas'
numr = (size(ref.imc))[3]

if n_elements(imc_save) eq 0 then imc_save='imcbasic.save'
restore,file=imc_save
num = (size(imc))[3]
sz = (size(imc))[1]
cc = (sz-1)/2.0

;; reduce the number of science images by binning
if n_elements(binfac) ne 0 then begin
   inx = indgen(num)
   io = where(inx mod 2)
   ie = where(inx mod 2)-1
   imco= imc[*,*,io]
   imce= imc[*,*,ie]
   nnum = nint(num/binfac/2.)
   imco = rebin(imco, sz, sz, nnum)
   imce = rebin(imce, sz, sz, nnum)
   imc = [ [[imce]], [[imco]] ]
   num = nnum*2
endif

if n_elements(rin) eq 0 then rin = 4  ;; rin to rout is optimized
if n_elements(rout) eq 0 then rout = 0.9*sz/2.0 ;; rout to rout*2 optimized separately
rall = 1.44*sz/2.0 ;; rout to rout*2 optimized separately
if n_elements(numref) eq 0 then numref = 3 < num  ;; this many reference images will be used.
if n_elements(widann) eq 0 then widann=60.0
if n_elements(refwidann) eq 0 then refwidann=30.0
if n_elements(refdr) eq 0 then refdr=4.0

;radA = nint(rangegen(rin, rout, 20)) ;; The annuli to be optimized
radA = nint(rangegen(rin, rout, nint((rout-rin)/widann)+1))

if n_elements(numref) eq 0 then begin                               ;;deciding num of ref images to use.
   num_degfree = nint((radA[1:*]^2.0-radA^2.0)/(3^2)) < nint(numr/2.) ;;HWHM of resel is 2 pixels, but using 4 pix to be conservative
endif else begin
   num_degfree = radA[1:*]*0+numref < nint(numr/2.)
endelse

print,'Radial ranges of annuli("): ', trim(radA)
print,'Radial ranges of annuli("): ', trim(string(radA*0.0125,f='(F6.2)'))
print,"numrefs : ", num_degfree
print,"allowable numrefs : ", (radA[1:*]^2.0-radA^2.0)/(3^2)

img = imc[*,*,0]
rmsa = fltarr(num,numr)+1e30
rmsb = fltarr(num,numr)+1e30
wma = getrgn(img, radA[0], radA[1])
;;wmb = getrgn(img, radA[1], radA[2])
wout = getrgn(img, rout, sz*0.8)
rmsfina = fltarr(num)
rmsmina = fltarr(num)
rmsfinb = fltarr(num)
rmsminb = fltarr(num)

print,'Doing cross match rms calcs...'
rimc = ref.imc
numr2 = (size(rimc))[3]

;;lesser matching area makes faster comparison.
if n_elements(fast) ne 0 then wm0 = getrgn(img, radA[0]+refdr, radA[0]+refdr+32) $
else wm0 = getrgn(img, radA[0]+refdr, radA[1])

temp1=where321(imc,wm0)
temp2=where321(rimc,wm0)
for i=0, num-1 do begin
   if i mod 10 eq 0 then print, 'image: '+trim(i)+string(13b)
   img1 = temp1[*,i] 
   for j=0, numr2-1 do begin
      img2 = temp2[*,j]
      diffa = zscalediff(img1,img2)
      if n_elements(chanmatch) ne 0 then begin
         if ref.lambdas[j] eq lambdas[i] then rmsa[i,j] = stddev(diffa)/stddev(img1)
      endif else rmsa[i,j] = stddev(diffa)/stddev(img1)
   endfor
endfor

print,'Finished cross match rms calcs.'

nrad = n_elements(radA)-1
;; rank the refs by how well they match
;print,'percentage completion:'
for i=0, num-1 do begin
   ;;p = psf(175-5.77,175-5.77,fw=4,sz=351)*1000
   ;p = psf(175-8,175-8,fw=4,sz=351)*1000
   img1 = imc[*,*,i];;+p ;;/Adding a birght FAKE --- TAKE IT OUT LATER.
   print, 'percentage completion: '+string(i*100d/num,f='(F5.1)')+' % '+string(13b)
   oa = sort(rmsa[i,*])
   ;;ob = sort(rmsb[i,*])
   oc = oa[0:numref]
   ;;where(rmsa[i,*] lt
   ;;(min(rmsa[i,*]))[0]*1.5)
   ;; Will match same wavelength only.
   ;;oc = where(rmsa[i,*] lt (min(rmsa[i,*]))[0]*1.1 and abs(i-findgen(numr)) mod 2 eq 0)
   ;if n_elements(oc) lt 3 then
   ;;oc = where(rmsa[i,*] lt median(rmsa[i,*]))
   ;;oc = where(rmsa[i,*] lt 4*median(rmsa[i,*]))
   ;oc = where(rmsa[i,*] lt (min(rmsa[i,*]))[0]*1.5 and abs(i-findgen(numr)) mod 2 eq 0)
   ;;oc = where(rmsa[i,*] lt (min(rmsa[i,*]))[0]*2.0 and abs(i-findgen(numr)) mod 2 eq 0)
   ;;if n_elements(oc) lt 10 then oc = where(rmsa[i,*] lt median(rmsa[i,*]))
   for k=0, nrad-1 do begin
      ac = oc ;;& numac = n_elements(ac)
      ;if n_elements(numac) gt num_degfree[k] then ac = ac[0: num_degfree[k] < (acnum-1)]
      print,'radius, final numrefs: ',radA[k],', ', n_elements(ac)
      dr=i mod 5
      if k eq 0 then wmn = getrgn(img1, radA[0], radA[1]+dr) $
      else wmn = getrgn(img1, radA[k]+dr, radA[k+1]+dr)
      if k eq 0 then wmn0 = getrgn(img1, radA[0], rall) $
      else wmn0 = getrgn(img1, radA[k]+dr, rall)
 
      
      wma = getrgn(img1, radA[k]+refdr, radA[k]+refdr+refwidann)
      
      ;;print, radA[k], radA[k+1]+dr
      diffa=img1
      temp=where321(rimc[*,*,ac],wma)
      junk = sublcomb1d(img1[wma],temp,coeff=cf) ;
      refa = lcomb(rimc[*,*,ac],cf) 
      ;;diffa[wmn] -= refa[wmn]
      diffa[wmn0] = img1[wmn0] - refa[wmn0]
      if n_elements(disk) eq 0 or n_elements(submed) ne 0 then diffa[wmn] -= median(diffa[wmn])
      ;if i eq 0 then print,'rad, med = ', radA[i], median(diffa[wmn])
      if k eq 0 then print,'red rms, rmsfrac: ',stddev(diffa[wmn]), stddev(diffa[wmn])/stddev(img1[wmn])
      if k eq 0 then diff = diffa $
      else diff[wmn0] = diffa[wmn0]
      if k eq 0 then rmsfina[i] = stddev(diffa[wmn])
      if k eq 1 then rmsfinb[i] = stddev(diffa[wmn])
      atv, diff
      ;stop
   endfor
   wmask = getrgn(diff,0,5) & diff(wmask)=0 ;; masking inner most pixels.
   if n_elements(disk) eq 0 then submedprof,diff,inrad=radA[0],outrad=radA[1],ar=20 ;$
   ;;else getfreq, diff, 25.0, diff, /unsharp
   imc[0,0,i] = diff
   ;print,'diff rms reduction (inner region):'+trim(rmsfina[i])
   ;print,'diff rms reduction (outer region):'+trim(rmsfinb[i])
   if n_elements(disp) ne 0 then zdisp, diff,zoom=6
   ;;if get_kbrd(1) eq '0' then stop
   ;;curpeak, diff, x, y, peak & print, 'peak=', peak
endfor

if median(rmsfina) gt median(rmsmina) or median(rmsfinb) gt median(rmsminb) then msglog,'Most images giving better subtraction than median. Use less numref?'
;msglog, 'average best diff rms reduction (inner region):'+trim(median(rmsmina))
;msglog, 'average final diff rms reduction (inner region):'+trim(median(rmsfina))
;msglog, 'average best diff rms reduction (outer region):'+trim(median(rmsminb))
;msglog, 'average final diff rms reduction (outer region):'+trim(median(rmsfinb))

out_imc_save= fname_addtag(imc_save,'rdi')
save, file=out_imc_save, imc, pas, lambdas, lambdas0, dits , rmsa, rmsb, rmsfina 
;save, file='rms_arr.save', rmsa, rmsb, rmsfina, rmsmina, rmsfinb, rmsminb
end

