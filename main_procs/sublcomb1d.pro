
  ;; Written by Zahed Wahhaj
  ;;im1 is a single image
  ;;imc is the ref cube, 3rd index is the image number
  ;;w are the indices over which to minimisze the rms
  ;;will keep the median level of the region the same
  ;; the linear comb coeefs are returnedin coeff

  ;; KEYWORDS
  ;; exclmed : if set, median is not included in the linear
  ;;           combination. Otherwise it is added into the supplied
  ;;           cube.
  ;; Nov 24, 2014. image reject indices which are set to zero after taking the
  ;;               median
  ;; Apr 20, 2015. Supply an alternate image cube to which the coeffs
  ;;               are also applied.
  ;; Jun 19, 2015  subrimc, gives the results for rimc
  ;; Sep 03, 2019  from sublcomb7. Wrote for 1d and simplified
  ;; Sep 06, 2019  Made more efficient by vectorization.
;; Sep 20, 2019  added "ncomp": number of images to use in linear
;; c                            cutoff by coeff magnitude
function sublcomb1d, im1, imc, coeff=coeff, mode=mode,  verbose=verbose, ncomp=ncomp
  
  ;medc = median(imc,dim=2)
  
  e  = imc
  dz = (size(e))[1]  
  ez = (size(e))[2]  ;; total ref frames
  
  a = im1
  med0 = median(a)
  a -= median(a)

  ;; remove median from every row of data
  e -= transpose(cmreplicate(median(e,dim=1),dz))
  
  AM = fltarr(ez,ez)
  for m=0,ez-1 do begin    
     AM[0,m] = total(cmreplicate(e[*,m],ez)*e,1)
  endfor
  
  BM = total(e*cmreplicate(a,ez),1)

  ;; alternative LOCI matrix linearization.
  if n_elements(mode) eq 0 then mode=0 
  case mode of 
     0: begin
        SVDC, AM, W_S, U_S, V_S  
        cr= SVSOL(U_S, W_S, V_S, BM)  
     end
     1: begin
        LUDC, AM, p  
        cr = LUSOL(AM, p, BM)  
     end
     2: begin
        choldc, AM, p
        cr= cholsol(AM, p, BM)
     end
     3: begin
        AMI = pinv2(AM)
        cr = transpose(AMI) # BM
     end
     4: begin
        LA_SVD, AM, W_S, U_S, V_S  
        cr= SVSOL(U_S, W_S, V_S, BM)  
     end

  endcase

  ;; cr = coeffs of linear combo
  ;; We just add all vectors e, weighting by cr
  if n_elements(ncomp) ne 0 then begin
     o = sort(abs(cr))
     ch = o[ez-ncomp:ez-1]
     T = total(transpose(cmreplicate(cr[ch],dz))*e[*,ch],2)
  endif else T = total(transpose(cmreplicate(cr,dz))*e,2)

  sub=T+med0

if n_elements(verbose) then begin
   print, 'Ref old rms', stddev(im1)
   print, 'Ref new rms', stddev((im1-sub))
   print, '----------------'
endif

coeff= cr
return, sub
end

  ;CATCH, Error_status  
  ;;This statement begins the error handler:  
  ;IF Error_status NE 0 THEN BEGIN  
  ;    FORPRINT2, systime()+': LOCI failed. Returning median PSF instead for simple ADI.', Error_status, textout='error.log',/update  
  ;    FORPRINT2, 'Error index: ', Error_status, textout='error.log',/update  
  ;    FORPRINT2, 'Error message: ', !ERROR_STATE.MSG, textout='error.log',/update  
  ;    CATCH, /CANCEL
  ;    return, medc
  ;ENDIF  
