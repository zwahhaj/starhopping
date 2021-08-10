;; Written by Zahed Wahhaj
;;centers, gets pas, DITS, wavelengths, and crops if wanted, then puts
;;   all in one cube.
;;July 25, 2021. ZWa. INPUT cenybyobid = save file containing
;;    obid, xcs1, ycs1, xcs2, ycs2  

pro irdis_make_asdi_cube, basicredlist, szn=szn, normfac=normfac, cenbyfit=cenbyfit, outfile=outfile, cenobid=cenobid

  irdis_normfluxfac, basicredlist, normsci, dit, ndfac,outsave='normscifac.save'      ;; get correction factor for nd_filt, dit and sci_filt_width 
  normfac=normsci
  
  getcen = 0
  if file_test('centers.save') then restore,file='centers.save' $
  else getcen = 1
  
  readcol, basicredlist, files, f='A'
  numf = n_elements(files)

  img = readfits(files[0],head)

  sz = (size(img))[2]
  cc = (sz-1)/2.0
  pp0 = nint(cc-szn/2.0)
  
if n_elements(szn) eq 0 then begin
   szn=sz
   pp0 = 0
endif
ccn = (szn-1)/2.0

;xc1 = xc1-pp0
;yc1 = yc1-pp0
;xc2 = xc2-pp0
;yc2 = yc2-pp0

for j=0,numf-1 do begin
   imc0 = readfits(files[j],head)
   numc = nint((esopar(head,'NAXIS3'))[0])

   itime = esotime(esopar(head,'DET FRAM UTC'))
   ftime = esotime(esopar(head,'DET SEQ UTC'))
   
   pa1 = float(esopar(head,'TEL PARANG START'))
   pa2 = float(esopar(head,'TEL PARANG END'))

   posx = float((esopar(head,'INS1 DITH POSX'))[0])
   posy = float((esopar(head,'INS1 DITH POSY'))[0])

   dit = float(esopar(head,'DET SEQ1 DIT'))
   
   filter1 =  esopar(head,'INS1 FILT ID')
   filter2 =  esopar(head,'INS1 OPTI2 ID')
   
   if strmatch(filter2,'*POLA_DP_0*') then begin polfilt1=0 & polfilt2=90 & end
   if strmatch(filter2,'*POLA_DP_45*') then begin polfilt1=45 & polfilt2=135 & end
   stoke12 = esopar(head,'OCS DPI H2RT STOKES')
   
   obid = nint(esopar(head,'ESO OBS ID')) 
;B_Y 	1043 	140 	Plot - Numerical values
;B_J 	1245 	240 	Plot - Numerical values
;B_H 	1625 	290 	Plot - Numerical values
;B_Ks 	2182 	300 	Plot - Numerical values

   case 1 of
      (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Y*'): begin & lambda1 = 1.043 & lambda2 = 1.043 & end
      (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_J*'): begin & lambda1 = 1.245 & lambda2 = 1.245 & end
      (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_H*'): begin & lambda1 = 1.625 & lambda2 = 1.625 & end
      (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Ks*'): begin & lambda1 = 2.182 & lambda2 = 2.182 & end
      strmatch(filter2,'*FILT_DBF_H23*') and strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.593 & lambda2 = 1.667 & end
      strmatch(filter2,'*FILT_DBF_H34*') and strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.667 & lambda2 = 1.733 & end
      strmatch(filter2,'*FILT_DBF_Y23*') and strmatch(filter1,'*FILT_BBF_Y*'):  begin & lambda1 = 1.022 & lambda2 = 1.076 & end
      strmatch(filter2,'*FILT_DBF_J23*') and strmatch(filter1,'*FILT_BBF_J*'):  begin & lambda1 = 1.190 & lambda2 = 1.273 & end
      strmatch(filter2,'*FILT_DBF_K12*') and strmatch(filter1,'*FILT_BBF_Ks*'):  begin & lambda1 = 2.110 & lambda2 = 2.251 & end
   endcase

   for i=0, numc-1 do begin
      pa = pa1 + (pa2-pa1)/numc*i
      tstamp = itime + (ftime-itime)/numc*i
      ;img1 = imc[0:1023,*,i]
      ;img2 = imc[1024:2047,*,i]

      if getcen eq 1 then begin ;; no center frames, so just dither first
         xc1 = cc & yc1 = cc  
         xc2 = cc & yc2 = cc  
      endif

      if n_elements(cenobid) ne 0 then begin
         zrestore, file=cenobid, st=co
         wco = where(co.oid eq obid)
         xc1 = co.xcs1[wco[0]]
         yc1 = co.ycs1[wco[0]]
         xc2 = co.xcs2[wco[0]]
         yc2 = co.ycs2[wco[0]]
      endif
      
      dx1 = cc-xc1
      dy1 = cc-yc1
      dx2 = cc-xc2
      dy2 = cc-yc2
      
      img1 = shift_sub(imc0[0:sz-1,0:sz-1,i],-posx+dx1,-posy+dy1)  ;;undither and center
      img2 = shift_sub(imc0[sz:sz+sz-1,0:sz-1,i],-posx+dx2,-posy+dy2)
      
      img1 = img1[pp0:pp0+szn-1,pp0:pp0+szn-1]
      img2 = img2[pp0:pp0+szn-1,pp0:pp0+szn-1]

      if getcen eq 1 then begin  ;; there was no center frames, so getting from images
         peakfind, img1, xc1, yc1
         peakfind, img2, xc2, yc2
         dx1 = ccn-xc1
         dy1 = ccn-yc1
         dx2 = ccn-xc2
         dy2 = ccn-yc2
         ;;stop
         img1 = shift_sub(img1,dx1,dy1)
         img2 = shift_sub(img2,dx2,dy2)
      endif

      if i eq 0 and j eq 0 then begin

         imc = [ [[img1]], [[img2]] ]
         detside = [0, 1] ;; left = 0, right = 1
         pas = [ pa, pa ]
         dits = [ dit, dit ]
         stokes = [ stoke12, stoke12 ]
         polfilts = [polfilt1, polfilt2]
         lambdas = [ lambda1, lambda2 ]
         tstamps = [tstamp, tstamp]
      endif else begin
         
         imc = [ [[imc]], [[img1]], [[img2]] ]
         detside = [detside, 0, 1]
         pas  = [ pas, pa, pa ]
         dits = [ dits, dit, dit ]
         stokes = [ stokes, stoke12, stoke12 ]
         polfilts = [polfilts, polfilt1, polfilt2]
         lambdas = [ lambdas, lambda1, lambda2 ]
         tstamps = [tstamps, tstamp, tstamp]
      endelse

   endfor
   junk = temporary(imc0)
endfor

pas = -pas

if n_elements(cenbyfit) ne 0 then centerbyfit, imc

comment='normsci is the predicted flux for no ND, 1um band width, and 1s expo, given the original flux was 1 ADU.'
if n_elements(outfile) eq 0 then outfile = 'imcbasic.save'
save,file=outfile, imc, detside, pas, lambdas, dits, normsci, stokes, polfilts, comment, tstamps
;save, file='centers.save', xc1, yc1, xc2, yc2

end

