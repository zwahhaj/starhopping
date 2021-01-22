function sublcomb, im0, imc0, wr0, wt, mask=mask, rin=rin, rout=rout, rms = rms, coeff=coeff, exclmed=exclmed, mode=mode, verbose=verbose

  ;; Written by Zahed Wahhaj
  ;;im1 is a single image
  ;;imc is the ref cube, 3rd index is the image number
  ;;wr are the ref indices over which to minimisze the rms
  ;;wt are the targ indices over which the subtraction is applied
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
  ;; Sep 03, 2019  from sublcomb7
  ;; Dec 14, 2019  Cleaned up code completely. Removed lots of extra
  ;;               prams also.
  
  ;; make copy of all vars that will be changed
  im1 = im0
  imc = imc0
  wr = wr0

  sz = (size(im1))[1]  

  medlev = median(im0(wr))
  im1 -= median(im1(wr)) ;; remove median from science image

  medc = median(imc,dim=3)
  if n_elements(exclmed) eq 0 then imc = [[[imc]],[[medc]]]

  if n_elements(rin) ne 0 then wr = getrgn(0,sz=sz,rin,rout)
  
  if n_elements(mask) ne 0 then begin
     wnew = getsigrgn(im1)
     wr = setdiff(wr,wnew)
  endif
  
  dzr = n_elements(wr)   ;images taken as a single row of pixels (those in w rgn)
  nz = (size(imc))[3] ;; total ref frames

  ;for l=0,nz-1 do er(0:*,l) -= median((reform(er(0:*,l)))(wr))  ;; removing median from all refs
  for l=0,nz-1 do imc[0,0,l] = imc[*,*,l] - median((imc[*,*,l])[wr])  ;; removing median from all refs

  er = fltarr(dzr,nz) 

  for l=0,nz-1 do er[0:dzr-1,l]  = reform((imc[*,*,l])[wr])

  a = im1[wr]

 

  AM = fltarr(nz,nz)
  for l=0,nz-1 do begin    
     for m=0,nz-1 do begin    
        AM[l,m] = total(reform(er[*,l])*reform(er[*,m]))
     endfor
  endfor

  BM = fltarr(nz)
  for l=0,nz-1 do BM[l] = total(reform(er[*,l])*a)

  CATCH, Error_status  
  
  ;;This statement begins the error handler:  
  IF Error_status NE 0 THEN BEGIN  
      FORPRINT2, systime()+': LOCI failed. Returning median PSF instead for simple ADI.', Error_status, textout='error.log',/update  
      FORPRINT2, 'Error index: ', Error_status, textout='error.log',/update  
      FORPRINT2, 'Error message: ', !ERROR_STATE.MSG, textout='error.log',/update  
      CATCH, /CANCEL
      return, medc
  ENDIF  

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
  coeff= cr
  
  temp = fltarr(sz,sz)
  sub = temp
  for l=0,nz-1 do temp += cr(l)*imc[*,*,l]
  sub[wt] = temp[wt]+medlev ;; the median from the original image is added also

if n_elements(verbose) then begin
   print, 'Ref old rms', stddev(im1(wr))
   print, 'Ref new rms', stddev((im1-sub)(wr))
   print, 'Targ old rms', stddev(im1(wt))
   print, 'Targ new rms', stddev((im1-sub)(wt))
   print, '----------------'
endif


return, sub
  
end
