pro iterstat, data, out,  $
              lower=lower, upper=upper,  $
              maxiter=maxiter, nsigrej=nsigrej, nobad = nobad, $
              verbose=verbose, nolabel=nolabel, silent=silent
             

;+
; Script to find image statistics excluding deviant pixels
;
; INPUT
;   data  
; 
; OUTPUTS
;   out(0)   number of pixels
;   out(1)   mean
;   out(2)   median
;   out(3)   standard deviation
;   out(4)   minimum pixel
;   out(5)   maximum pixel
;
; KEYWORD PARAMETERS
;   verbose  print results of every iteration
;   silent   print final results
;   nolabel  no column labels printed
;
; USES
;    stat
;
; HISTORY
; Written by John Ward: 08/04/92
; Minor modifications 4 August 1992 MD
; Various subsequent variations.
; Latest revision:  18 Aug 1993 MD
; Converted to IDL: 22 Jun 1994 M. Liu (UCB) using STAT.PRO
;	slower than IRAF iterstat, but tolerable
; Added /nobad flag (ignores BADVAL=-1e6 pixels)  06/09/99 MCL
;
; Please send comments/questions to <mliu@astro.berkeley.edu>
;-

on_error,2	; return to $MAIN$

BADVAL = -1e6
if keyword_set(maxiter) eq 0 then maxiter=10
if keyword_set(nsigrej) eq 0 then nsigrej=5
if (n_params() eq 0) or (n_elements(data) eq 0) then begin
    print,'pro iterstat,data,out,[maxiter='+strc(maxiter)+ $
      '],[nsigrej='+strc(nsigrej)+'], [nobad],'
    print,'             [lower=],[upper=],[verbose],[silent]'
    print,'     out(0) = number of pixels'
    print,'     out(1) = mean'
    print,'     out(2) = median'
    print,'     out(3) = standard deviation'
    print,'     out(4) = minimum pixel'
    print,'     out(5) = maximum pixel'
    return
endif

; set to default values
if not(keyword_set(nobad)) then begin
    if keyword_set(lower) eq 0 then llim = min(data) else llim=lower
    if keyword_set(upper) eq 0 then ulim = max(data) else ulim=upper
endif else begin
    w = where(data ne BADVAL, nw)
    if (nw eq 0) then w = where(data eq BADVAL)
    if keyword_set(lower) eq 0 then llim = min(data(w)) else llim=lower
    if keyword_set(upper) eq 0 then ulim = max(data(w)) else ulim=upper
endelse

if (keyword_set(silent) eq 0) and (keyword_set(nolabel) eq 0) then	$
	print, format = '(A6,6(A10,"  "))', $
	"Iter#","NPIX","MEAN","MEDIAN","STDDEV","MIN","MAX"

m = 1         ; iteration counter

stat,data,datast,lower=llim,upper=ulim,nobad=nobad,/silent
npx = datast(0)  &  mn = datast(1)  &  sig = datast(3) 

while (m le maxiter) do begin
    if keyword_set(verbose) then 	 $
      print, format = '(A4,"   ",6(E10.3,"  "))', $
      strc(m),datast(0),datast(1),datast(2),datast(3),datast(4),datast(5)
;	  print, format = '(I6,6(F8.0,"  "))', $
;		m,datast(0),datast(1),datast(2),datast(3),datast(4),datast(5)
    llim = mn - (nsigrej*sig)
    ulim = mn + (nsigrej*sig)
    if (keyword_set(lower) eq 1) then if (llim lt lower) then llim = lower
    if (keyword_set(upper) eq 1) then if (ulim gt upper) then ulim = upper
    stat,data,datast,/silent,lower=llim,upper=ulim, nobad = nobad
    nx = datast(0)  &  mn = datast(1)  &  sig = datast(3)
    if (nx eq npx) then $
      m = maxiter
    npx = nx
    m = m+1
endwhile

if (m gt maxiter) then m = maxiter

if (keyword_set(silent) eq 0) and (keyword_set(verbose) eq 0) then	$
	print, format = '(A4,"   ",6(E10.3,"  "))', $
	  strc(m),datast(0),datast(1),datast(2),datast(3),datast(4),datast(5)

n = n_params()
if (n gt 1) then begin
	out = fltarr(6)
	out(0) = datast(0)  &  out(1) = datast(1)  &  out(2) = datast(2)
	out(3) = datast(3)  &  out(4) = datast(4)  &  out(5) = datast(5)
endif

end
