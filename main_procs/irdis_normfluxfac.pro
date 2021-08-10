;;Written by Zahed Wahhaj - oct 16, 2017
;;Uses SPHERE/IRDIS header info on ND_filter, filter, and ndit to
;;     estimate the predict the flux for no ND, 1um band width, and 1s
;;     expo, given the original flux was 1 ADU. 
;;
;;July 24, 2021, ZWa: Added 'filename'
;;     Changed the 'dit' and 'ndfac' output to 2-elements arrays, same
;;     as 'normfac' and 'lambdas' for left and right side of DET.

pro irdis_normfluxfac, filelist, normfac, dit, ndfac, lambdas, dlambdas,outsave=outsave, filename=filename 
  pname = 'irdis_normfluxfac'
  if n_elements(outsave) eq 0 then outsave='normscifac.save'
  
  if n_elements(filename) eq 0 then readcol,filelist,filename,f='A'

  img =  readfits(filename[0],head)
  sz = (size(img))[2]
  cc = (sz-1)/2.0

  numc =  (float(esopar(head,'NAXIS3')))[0]
  ;if numc gt 1 then img = total(img,3)/numc

  ndfilter = esopar(head,'INS4 FILT2 NAME')
  filter1 =  esopar(head,'INS1 FILT ID')
  filter2 =  esopar(head,'INS1 OPTI2 ID')
  dit =  float((esopar(head,'DET SEQ1 DIT'))[0])
  ndit =  esopar(head,'DET NDIT')
  

  msglog,pname+': Only first file is used. dit = '+trim(dit)+', filters: '+filter1+', '+filter2+', '+ndfilter
  

case 1 of

   strmatch(ndfilter,'*0.0*') and strmatch(filter2,'*FILT_DBF_NDH23*') and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 3.5
   strmatch(ndfilter,'*1.0*') and strmatch(filter2,'*FILT_DBF_NDH23*') and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 24.9
   strmatch(ndfilter,'*2.0*') and strmatch(filter2,'*FILT_DBF_NDH23*') and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 194.4
   strmatch(ndfilter,'*3.5*') and strmatch(filter2,'*FILT_DBF_NDH23*') and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 3307.5

   strmatch(ndfilter,'*1.0*') and strmatch(filter2,'*FILT_DBF_K12*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 6.7
   strmatch(ndfilter,'*2.0*') and strmatch(filter2,'*FILT_DBF_K12*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 45.0
   strmatch(ndfilter,'*3.5*') and strmatch(filter2,'*FILT_DBF_K12*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 690.7

   strmatch(ndfilter,'*1.0*') and strmatch(filter2,'*FILT_CLEAR*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 6.9
   strmatch(ndfilter,'*2.0*') and strmatch(filter2,'*FILT_CLEAR*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 44.6
   strmatch(ndfilter,'*3.5*') and strmatch(filter2,'*FILT_CLEAR*') and strmatch(filter1,'*FILT_BBF_Ks*'):  ndfac= 698.4

   strmatch(ndfilter,'*1.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 7.18
   strmatch(ndfilter,'*2.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 56.1
   strmatch(ndfilter,'*3.5*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_H*'):  ndfac= 955.0

   strmatch(ndfilter,'*1.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_J*'):  ndfac= 15.9
   strmatch(ndfilter,'*2.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_J*'):  ndfac= 296.2
   strmatch(ndfilter,'*3.5*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_J*'):  ndfac= 16323.0

   strmatch(ndfilter,'*1.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Y*'):  ndfac= 10.7
   strmatch(ndfilter,'*2.0*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Y*'):  ndfac= 122.6
   strmatch(ndfilter,'*3.5*') and (strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Y*'):  ndfac= 3349.7
   else: ndfac=1.0
endcase

filter1 =  esopar(head,'INS1 FILT ID')
filter2 =  esopar(head,'INS1 OPTI2 ID')

case 1 of

(strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.625 & lambda2 = 1.625 & dl1 = 0.290 & dl2 = 0.290 & end
   
strmatch(filter2,'*FILT_DBF_H23*') and strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.593 & lambda2 = 1.667 & dl1 = 0.052 & dl2 = 0.054 & end
   
strmatch(filter2,'*FILT_DBF_H34*') and strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.667 & lambda2 = 1.733 & dl1 = 0.054 & dl2 = 0.057 & end
   
(strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Y*'):  begin & lambda1 = 1.043 & lambda2 = 1.043 & dl1 = 0.140 & dl2 = 0.140 & end
   
strmatch(filter2,'*FILT_DBF_Y23*') and strmatch(filter1,'*FILT_BBF_Y*'):  begin & lambda1 = 1.022 & lambda2 = 1.076 & dl1 = 0.049 & dl2 = 0.050 & end
   
(strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_J*'):  begin & lambda1 = 1.245 & lambda2 = 1.245 & dl1 = 0.240 & dl2 = 0.240 & end
   
strmatch(filter2,'*FILT_DBF_J23*') and strmatch(filter1,'*FILT_BBF_J*'):  begin & lambda1 = 1.190 & lambda2 = 1.273 & dl1 = 0.042 & dl2 = 0.046 & end
   
(strmatch(filter2,'*FILT_CLEAR*') or strmatch(filter2,'*POLA_DP*')) and strmatch(filter1,'*FILT_BBF_Ks*'):  begin & lambda1 = 2.182 & lambda2 = 2.182 & dl1 = 0.300 & dl2 = 0.300 & end
   
strmatch(filter2,'*FILT_DBF_K12*') and strmatch(filter1,'*FILT_BBF_Ks*'):  begin & lambda1 = 2.110 & lambda2 = 2.251 & dl1 = 0.102 & dl2 = 0.109 & end   

endcase

if strmatch(filter2,'*POLA*') then begin
   case 1 of 
   strmatch(filter1,'*FILT_BBF_H*'):  begin & lambda1 = 1.625 & lambda2 = 1.625 & dl1 = 0.290 & dl2 = 0.290 & end
   strmatch(filter1,'*FILT_BBF_Y*'):  begin & lambda1 = 1.043 & lambda2 = 1.043 & dl1 = 0.140 & dl2 = 0.140 & end
   strmatch(filter1,'*FILT_BBF_J*'):  begin & lambda1 = 1.245 & lambda2 = 1.245 & dl1 = 0.240 & dl2 = 0.240 & end
   strmatch(filter1,'*FILT_BBF_Ks*'):  begin & lambda1 = 2.182 & lambda2 = 2.182 & dl1 = 0.300 & dl2 = 0.300 & end
   endcase
endif

dlambdas = [dl1, dl2]
lambdas = [lambda1, lambda2]
normfac = [ndfac/dl1/dit, ndfac/dl2/dit] 
dit = [dit, dit]
ndfac= [ndfac,ndfac]

;print, "ndfac/dl1/dit, ndfac/dl2/dit:",ndfac,dl1,dit, ndfac,dl2,dit
;print, normfac

comment='"normfac" is the multiplyer to convert flux to: no ND, 1um band width, and 1s expo.'

save,file=outsave,normfac,dit,comment,lambdas,dlambdas,ndfac

end
