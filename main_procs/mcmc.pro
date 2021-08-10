;;Written by Zahed Wahhaj
;;July 7, 2016: saving chisq_arr

function step_fn, prams, ranges
  ;;return, prams+randomu(seed, n_elements(prams), /normal)*ranges
  return, prams+randomn(seed, n_elements(prams))*ranges
end
  
pro mcmc, prams, chisq, step_fn=step_fn, ranges=ranges, niter=niter, pram_arr=pram_arr, bprams=bprams, jumpfac=jumpfac, chisq_arr=chisq_arr,accept_arr=accept_arr, nlook=nlook, bchisq=bchisq
  
  ;;OUTPUTS:
  ;;chisq_arr = chisq for accepted prams

  if n_elements(jumpfac) eq 0 then jumpfac = 30   ;; every NJUMP steps, a jump of size = jumpfac * range is taken
  NJUMP = 1000 ;; a jump is pram space is take after this many steps
  if n_elements(nlook) eq 0 then NLOOK = 3000 ;; Show stats after this many steps
  accepts = fltarr(NLOOK) ;; keep track of the acceptance rate
  burn_steps =100
  burn=0
  
bchisq = 1d30
if n_elements(niter) eq 0 then niter = 10000L

if n_elements(step_fn) eq 0 then step_fn = "step_fn"

if n_elements(ranges) eq 0 then begin 
   ranges = prams/20.
   wzero = where(ranges eq 0)
   if (wzero[0] ne -1) then ranges(wzero)  = 1.
endif

pram_arr = fltarr(n_elements(prams), niter)
chisq_arr = fltarr(niter)
accept_arr = fltarr(niter) ;; keep record of the accepts

cprams = prams

  cchisq = call_function(chisq, cprams)
for i =0L, niter-1 do begin
   ;;print, i,'----------------------------------------------'
   nprams = call_function(step_fn, cprams, ranges)
   nchisq = call_function(chisq, nprams)

   if (bchisq gt nchisq) then begin 
      bchisq = nchisq
      bprams = nprams
   endif

   pratio = exp(-(nchisq-cchisq)/2d)
   ;print, nprams-cprams
   ;print, nchisq,cchisq
   ;pause

   if (i ne 0) and (i mod NLOOK eq NLOOK-10) then begin 
      print,systime(),'===== ',trim(i),': Bchisq= ',string(bchisq,f='(E9.3)'),': accept rate= ',string(mean(accepts)*100, f='(F5.1)'),'%, prob_ratio= ',string(pratio,f='(E8.1)')
   endif
;print, 'prams = ', nprams
   

   if burn lt burn_steps then begin
      i = (i-1) > 0 ;; overwriting the current step until burn if over  
      burn++
   endif

;; every NJUMP steps, force a big jump
   if (randomu(seed) gt 1.0-1.0/NJUMP) then begin
   ;;if (i ne 0 and i mod NJUMP eq 0) then begin
      nprams = call_function(step_fn, cprams, ranges*jumpfac)
      cprams = nprams
      cchisq = call_function(chisq, cprams)
      burn = 0
   endif else begin ;; else metro-hastings
      if (randomu(seed,/uniform) lt pratio) then begin
         cprams = nprams 
         cchisq = nchisq
         accepts[i mod NLOOK] = 1.0
      endif else accepts[i mod NLOOK] = 0.0
   endelse
   
   accept_arr[i] = accepts[i mod NLOOK]
   pram_arr[0, i] = cprams
   chisq_arr[i] = cchisq
endfor

end
