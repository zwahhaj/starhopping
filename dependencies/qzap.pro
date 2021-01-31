;+
; NAME:
;   qzap.pro
;
; PURPOSE:
;   Remove cosmic rays from a 2-D image.
;
; CALLING SEQUENCE:
;   qzap, name, outname, [ outmaskname, skyfiltsize=skyfiltsize, $
;    boxsize=boxsize, nsigma=nsigma, /nofluxratio, maxiter=maxiter, $
;    fluxcompare=fluxcompare, nrings=nrings, path=path, nzap=nzap ]

;   qzap, name, outname, outmaskname, skyfiltsize=skyfiltsize, $
;    boxsize=boxsize, nsigma=nsigma, fluxratio=fluxratio, maxiter=maxiter, $
;    nofluxcompare=nofluxcompare, nrings=nrings, path=path, nzap=nzap
;
; INPUTS:
;   name        - 2-D image array, or name of input FITS file.
;   outname     - Output image array, or name of output FITS file.
;
; OPTIONAL INPUTS:
;   outmaskname - Output mask array, or name of output FITS file.
;   skyfiltsize - Boxsize for computing local sky value; default to 15.
;   boxsize     - Boxsize for computing local median; default to 5.
;   nsigma      - Rejection threshhold in sigma; default to 4.
;   fluxratio   - Comparison value for identifying cosmics; default to 0.15
;   maxiter     - Number of zapping iterations; default to 2.
;   nofluxcompare - Set to disable the flux comparison algorithm, which
;                is the "black magic" heart of this routine.
;   nrings      - Radius of cosmic ray neighbors to also zap; default to 1.
;   path        - Input/output path name
;
; OPTIONAL OUTPUTS:
;   NZAP        - Number of pixels zapped.
;
; COMMENTS:
;   Based on the tried and true IRAF QZAP routine by Mark Dickinson.
;   Results from IDL qzap.pro and IRAF QZAP are found to be virtually
;   identical.
;
; PROCEDURES CALLED:
;   djs_iterstat
;
; REVISION HISTORY:
;   20-Aug-1999  Written by Cullen Blake & David Schlegel, Princeton
;   14-Mar-2000  -default for fluxratio changed from 1 to .15;
;                -changed third input param from outmask to outmaskname
;                -include 'skysubimage = outimg - skyimage' inside loop
;                                         - Doug Finkbeiner
;
; bug fix: for 'peaksimage' where command, checks for 0 element case
; 09/29/01 MCL
;
; bug fix: now accepts nrings=0, use this as default
; uses MESSAGE instead of PRINT statements
; 10/19/01 MCL
;
; added /silent
; 03/09/03 MCL
;
; recognizes BADVAL when computing statistics
; 02/05/07 MCL
;-
;------------------------------------------------------------------------------
pro qzap, name, outname, outmaskname, skyfiltsize=skyfiltsize, $
 boxsize=boxsize, nsigma=nsigma, fluxratio=fluxratio, maxiter=maxiter, $
 nofluxcompare=nofluxcompare, nrings=nrings, path=path, nzap=nzap, $
 silent = silent

BADVAL = -1e6

   if (NOT keyword_set(skyfiltsize)) then skyfiltsize=15
   if (NOT keyword_set(boxsize)) then boxsize=5
   if (NOT keyword_set(nsigma)) then nsigma=4
   if (NOT keyword_set(fluxratio)) then fluxratio=.15
   if (NOT keyword_set(maxiter)) then maxiter=2
   if (NOT keyword_set(nofluxcompare)) then nofluxcompare=0
   if (n_elements(nrings) eq 0) then nrings=0
   ;if (NOT keyword_set(nrings)) then nrings=1
   if (NOT keyword_set(path)) then path = ''

   if n_params() lt 2 then begin
       print, 'pro qzap, name, outname, outmaskname, skyfiltsize=skyfiltsize,'
       print, '          boxsize=boxsize, [nsigma=', strc(nsigma), ', fluxratio=fluxratio, maxiter=maxiter,'
       print, '          [nofluxcompare], nrings=nrings, path=path, nzap=nzap'
       return
  endif

   if (size(name, /tname) EQ 'STRING') then outimg=readfits(path+name) $
    else outimg=name

   dims = size(outimg, /dimens)
   outmask = bytarr(dims[0], dims[1])

   if not(keyword_set(silent)) then $
     message, 'Computing image sigma...', /info
   djs_iterstat, outimg(where(outimg ne BADVAL)), sigma=sigval, sigrej=5, silent = silent
   ;djs_iterstat, outimg, sigma=sigval, sigrej=5, silent = silent
   if not(keyword_set(silent)) then $
     message, 'sigma = '+string(sigval), /info

   if (skyfiltsize eq 0) then $
    djs_iterstat,outimg,median=skyimage, silent = silent $
    else skyimage = median(outimg, skyfiltsize)

   nzap = 0
   iter = 0
   nbad = 1

   while (iter LT maxiter and nbad GT 0) do begin
      iter = iter + 1

      skysubimage = outimg - skyimage
      fmedimage = median(skysubimage, boxsize)

      crimage = skysubimage - fmedimage

      peaksimage = crimage GT nsigma*sigval

      if (NOT keyword_set(nofluxcompare)) then begin
         i = where(peaksimage NE 0, nw)
         if (nw gt 0) then $
           peaksimage[i] = (fmedimage[i] / crimage[i]) LT fluxratio
      endif

      if (nrings ge 1) then $
        peaksimage = smooth(float(peaksimage), 1+2*nrings, /edge) GT 1.0E-6

      ibad = where(peaksimage NE 0, nbad)
      if (nbad GT 0) then begin
         outimg[ibad] = skyimage[ibad] + fmedimage[ibad]
         outmask[ibad] = 1
      endif

      if not(keyword_set(silent)) then $
        message, 'Iteration '+strc(iter)+ $
        ': Number zapped = '+strc(nbad), /info
      nzap = nzap + nbad

   endwhile

   if (size(outname, /tname) EQ 'STRING') then begin
      writefits, path+outname, outimg
   endif else begin
      outname = outimg
   endelse

   if (size(outmaskname, /tname) EQ 'STRING') then begin
      writefits, path+outmaskname, outmask
   endif else begin
      outmaskname = outmask
   endelse

end
;------------------------------------------------------------------------------
