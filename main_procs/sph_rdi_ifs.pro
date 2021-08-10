;;Written by Zahed Wahhaj, 2019
;; inputs -
;;   binfac - input cube will be binned by thi factor, for faster
;;            reduction
;;   submedprof - azimuthal filter for better point source reduction 
;;   out_save - name of output save file
;;   tag - tag used to make output save file name
;;   fakes - uses the default input save file 'imcbasic1_fakes.save'

pro sph_rdi_ifs, submedpf=submedpf, profscale=profscale,fakes=fakes,tag=tag, pa_off=pa_off, out_save=out_save, binfac=binfac, remstripe2=remstripe2
  
  if n_elements(pa_off) eq 0 then pa_off = 0

  
  if n_elements(fakes) ne 0 then savefile = 'imcbasic1_fakes.save' $
  else savefile = 'imcbasic1.save'
  zrestore,file=savefile,st=s

  simc0 = s.imc
  npas = s.pas
  
;; bin cube for faster reduction, but less accurate.
;; npas will contain the final "PA"s in both cases
  if n_elements(binfac) ne 0 then $
     if binfac ge 2 then $
        simc0 = ifs_rebin_cube( junk, binfac, save_file=savefile, npas=npas)

  dimc = simc0
  sz = size(simc0)
  lambdas = s.lambdas[0:sz[3]-1]
  

  zrestore,file='imcbasic2.save',st=r
  rimc0 = r.imc
  rpas = r.pas
  
;; bin cube for faster reduction, but less accurate.
;; npas will contain the final "PA"s in both cases
  if n_elements(binfac) ne 0 then $
     if binfac ge 2 then $
        simc0 = ifs_rebin_cube( junk, binfac, save_file='imcbasic2.save', npas=rpas)

  rsz = size(rimc0)
  rlambdas = r.lambdas[0:rsz[3]-1]
  
  wm = getrgn(0,sz=sz[1],10,50)
  wm2 = getrgn(0,sz=sz[1],50,90)
  wt = getrgn(0,sz=sz[1],0,sz[1]/2.0*1.5)
  win = getrgn(0,sz=sz[1],0,9)
  
  ws = where(lambdas eq lambdas[0], numpa)
  

  stripe = readfits("stripe.fits",hh)
  if n_elements(stripe2) eq 0 then qzapboth,stripe,stripe2

  if n_elements(submedpf) ne 0 then submedprof,stripe2
  
  for ii=0L, 38 do begin ;; looping over wavelength
     wr = where(rlambdas eq lambdas[ii])
     rimc = rimc0[*,*,wr]
     
     ws = where(lambdas eq lambdas[ii])

     simc = simc0[*,*,ws]
     pas = npas[ws]
   

;zpca, simc, tr=30, pcs=pcs, psfs=psfs, rimc=rimc,rin=10,rout=90
;dimc = simc-psfs
   
   ssz = size(simc)
   rsz = size(rimc)
   
   diff =simc*0
   drmc = rimc*0
   
   if n_elements(submedpf) ne 0 then begin
      for i=0,ssz[3]-1 do begin
         img = simc[*,*,i]
         submedprof,img
         ;;getfreq,img,6.6,img,/unsharp
         simc[0,0,i] =img
      endfor
      
      for i=0,rsz[3]-1 do begin
         img = rimc[*,*,i]
         submedprof,img
         ;;getfreq,img,6.6,img,/unsharp
         rimc[0,0,i] =img
      endfor
   endif

   ;; for each wave slice, match radial RMS profiles
   ;; of median sci and red PSF
   if n_elements(profscale) ne 0 then begin
      smed = median(simc,dim=3)
      rmed = median(rimc,dim=3)
      srmap = rmsmap(smed,/proper,dia=2,/std)
      rrmap = rmsmap(rmed,/proper,dia=2,/std)
      ;;srmap = rmsmap_slow(smed,dia=2,/not_robust)
      ;;rrmap = rmsmap_slow(rmed,dia=2,/not_robust)
      pmap = srmap/rrmap
      wnan = where(1-finite(pmap))
      if wnan[0] ne -1 then pmap[wnan] = 1.0

      for i=0,rsz[3]-1 do begin
         img = rimc[*,*,i]*pmap
         rimc[0,0,i] =img
      endfor
   endif 

   ;; loop over exposures for one wave slice
   for i=0, ssz[3]-1 do begin 

      img=simc[*,*,i]

      ref = sublcomb(img,rimc,wm,wt)
      dimg2 = img - ref
      ref2 = sublcomb(img,rimc,wm2,wt)
      dimg2[wm2] = img[wm2] - ref2[wm2]

      diff[0,0,i] = dimg2
      dimc[0,0,ws[i]] = diff[*,*,i]

      print, 'slice ', trim(ii)," : ",trim(i), " of ", trim(ssz[3]-1), ' done.' 
      temp = diff[*,*,i]
      temp[win] = 0

      atv, temp
   endfor
   
   imc= diff
endfor


if n_elements(remstripe2) then begin
   med = median(dimc,dim=3)
   junk = zscalediff(med, stripe2, wm=wm, mimg=mstripe)
   for i=0,sz[3]-1 do begin
      dimc[0,0,i] = dimc[*,*,i] - mstripe
   endfor
endif

out_save = 'ifs_reduced0'+tag+'.save' 
imc = dimc
pas = npas

save,file=out_save,imc,pas,lambdas
;;derotate does not overwrite the original save file, so can repeat.
;derotate,imc_save=out_save,stack=stack,pa_off=pa_off, tag=tag
;zdisp, stack,zoom=1.5

end

