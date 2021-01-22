;;Written by Zahed Wahhaj, 2018.
pro peakcalc, normscisave, fluxsave, peaks=peaks

  if n_elements(normscisave) eq 0 then normscisave='normfac.save'
  if n_elements(fluxsave) eq 0 then fluxsave='fluxfilt.save'

  zrestore,file=fluxsave,str=flux
 
  if file_test(normscisave) ne 0 then begin
     zrestore,file=normscisave,str=sci
     peaks = flux.peaks*flux.normflux/sci.normfac
     print, 'DITs already factored into normfac and normflux.'
     print, 'left:  flux.peaks*flux.normflux/sci.normfac:',flux.peaks[0],flux.normflux[0],sci.normfac[0]
     print, 'right: flux.peaks*flux.normflux/sci.normfac:',flux.peaks[1],flux.normflux[1],sci.normfac[1]
  endif else begin
     peaks = flux.peaks
     print, 'Peak estimated only from flux.save. Science rescaling file normfac.save not present.'
  endelse
  
  print, peaks
end
