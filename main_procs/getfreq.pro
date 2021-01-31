pro getfreq, in, fwhm, out, unsharp=unsharp, low=low, high=high,subsmooth=subsmooth

whereback, in, wback

in0=double(in)
if n_elements(low) eq 0 then low = fwhm*2.
if n_elements(high) eq 0 then high = fwhm/2.

sharp = in0-filter_image(in0, fwhm_gaussian=high);
dull = filter_image(in0, fwhm_gaussian=low);     

if n_elements(subsmooth) ne 0 then out= filter_image(in0-dull, fwhm_gaussian=high) $     
else out = in0-sharp-dull        ;
if (n_elements(unsharp) ne 0) then out = in0-dull

if wback[0] ne -1 then out(wback) = 0
;out = bpass(in, 2, 6, /noclip);tried just a little better almost same
;out = bpass(in,1,5,/noclip)
end
