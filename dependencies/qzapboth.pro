pro qzapboth, name, outname, outmaskname, _extra=_extra

;+
; simple wrapper for running QZAP twice, to clip positive and negative outliers
; note that 'outmaskname' convention is 1=bad, 0=good, OPPOSITE of my typical convention
; 08/02/06 MCL
;
; smarter handling of negative image using IMMULT() to preserve BADVAL pixels
; 02/05/07 MCL
;-

if n_params() lt 2 then begin
    print, 'pro qzapboth, name, outname, outmaskname, skyfiltsize=skyfiltsize,'
    print, '              boxsize=boxsize, nsigma=nsigma, fluxratio=fluxratio, maxiter=maxiter,'
    print, '              [nofluxcompare], nrings=nrings, path=path, nzap=nzap'
    return
endif

; run on positive image
message, '--- finding positive outliers ---', /info
qzap, name, out1, mask1, _extra=_extra

; run on negative image
message, '--- finding negative outliers ---', /info
qzap, immult(out1, -1.0), out2, mask2, _extra=_extra
outimg = immult(out2, -1.0)

; output the resulting image, either to variable or file
if (size(outname, /tname) EQ 'STRING') then begin
   writefits, outname, outimg
endif else begin
   outname = outimg
endelse

; output the resulting mask
; merging both the positive & negative outliers
outmask = mask1 + mask2
if (size(outmaskname, /tname) EQ 'STRING') then begin
   writefits, outmaskname, outmask
endif else begin
   outmaskname = outmask
endelse

end

