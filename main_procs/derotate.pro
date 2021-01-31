;; Written by Zahed Wahhaj, 2012
;; rejfrac : fraction of frames rejected because of bad rms
;; submedpf - do submedprof before stacking
;; pafac - multiply PAs by this before derotation

pro derotate, imc_save = imc_save, pas=pas, stack=stack, save_out=save_out, ilambda=ilambda, flambda=flambda, fits_stack=fits_stack, rejfrac=rejfrac, weightstack=weightstack, spat_align=spat_align, rin=rin, rout=rout, dimc=dimc, submedpf=submedpf,pafac=pafac


  if n_elements(imc_save) eq 0 then imc_save='imcbasic.save'
  if n_elements(fits_out) eq 0 then fits_out='stack.fits'
  
  restore,file=imc_save

  if n_elements(pafac) ne 0 then pas = pas*pafac
  if n_elements(spat_align) ne 0 then align_cube, imc, lambdas,/spat
  
  num = (size(imc))[3]
  sz = (size(imc))[1]
  cc = (sz-1)/2.0

          
  if n_elements(inx) eq 0 then inx=num-1


  temp = imc[*,*,0]
  if n_elements(rin) eq 0 then rin=6
  if n_elements(rout) eq 0 then rout=26
  w = get_w(temp,rin,rout)
  if n_elements(rejfrac) then begin
     rmsA = fltarr(num)
     for i=0, num-1 do begin
        temp = imc[*,*,i]
        rmsA[i] = stddev(temp[w])
     endfor
     ;ow = sort(rmsA)
     medrms = median(rmsA)
     wg = where(rmsA lt medrms*10.0 or rmsA gt medrms/100.0)
     ;nlast = rejfrac*num
     ;stop
     imc = imc[*,*,wg]
     pas = pas[wg]
     lambdas = lambdas[wg]
     dits = dits[wg]
     num = (size(imc))[3]
  endif
  
  for i=0, num-1 do begin
     temp = imc[*,*,i]
     temp = rot(temp,pas[i],1,cc,cc,/piv,c=-0.5,missing=0)
     temp = zeroedge(temp, 15)
     if n_elements(submedpf) ne 0 then submedprof,temp,ar=180,/deg
     imc[0,0,i] = temp
  endfor
  
  if arg_present(stack) ne 0 then begin
     if n_elements(weightstack) eq 0 then begin
        whereback, imc, wback
        imc[wback] = !VALUES.F_NAN
        if n_elements(ilambda) ne 0 or n_elements(flambda) ne 0 then begin
           wc = where(lambdas gt ilambda and lambdas le flambda)
           if wc[0] ne -1 then stack = median(imc[*,*,wc], dim=3,/even)
        endif else stack = median(imc,dim=3,/even)
        imc[wback] = 0
     endif else begin
        if n_elements(ilambda) ne 0 or n_elements(flambda) ne 0 then begin
           wc = where(lambdas gt ilambda and lambdas le flambda)
           if wc[0] ne -1 then stack = zsmartmed(imc[*,*,wc],rin,rout)
        endif else stack = zsmartmed(imc,rin,rout)
     endelse
     if n_elements(fits_stack) ne 0 then writefits,fits_stack,stack
  endif
  
  ;;saving cube with all wavelength  slices  
  ;lams = lambdas(sort(lambdas))
  ;;ou = uniq(lams)
  numl = n_elements(lambdas0)
  if numl gt 1 then begin
     imcs = fltarr(sz,sz,numl)
     for i=0,numl-1 do begin
        wc = where(abs((lambdas0[i]-lambdas)/lambdas0[i]) lt 5e-3)
        if n_elements(weightstack) eq 0 then begin
           whereback, imc, wback
           imc[wback] = !VALUES.F_NAN
           if wc[0] ne -1 then imcs[0,0,i] = median(imc[*,*,wc],dim=3,/even)
           imc[wback] = 0
        endif else begin
           if wc[0] ne -1 then imcs[0,0,i] = zsmartmed(imc[*,*,wc],rin,rout)
        endelse
     endfor

     ;; mwrfits is not deleting old file!!! So deleting it myself!!!
     spawn,'rm spectral_cube.fits'
     mkhdr,hdr0,4,[sz,sz,numl],/ext
     sxaddhist,["The primary extension contains images for each wavelength" ],hdr0,/comment
     mwrfits,imcs,'spectral_cube.fits',hdr0
     mkhdr,hdr1,4,[numl]
     sxaddhist,[ "This extension contains the wavelengths in microns for the image slice" ],hdr1,/comment
     mwrfits,lambdas0,'spectral_cube.fits',hdr1
  endif
  
  if n_elements(save_out) ne 0 then begin
                                ;out_imc_save = 'imcderot.save'
     comments='PAs have already been used to derotate the images. These are for reference only.'
     save, file=save_out, imc, lambdas, dits, pas, comments
  endif
  dimc = temporary(imc)
  ;stop
end
