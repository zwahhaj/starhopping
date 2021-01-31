;; Written by Zahed Wahhaj. Dec 4, 2019
;; returns rho/asec vs 5sigma  contrast 
pro sph_contrast, fitsfile, ps=ps, peak=peak, rho=rho, con5s=con5s
  if n_elements(ps) eq 0 then ps=0.01225
  img = readfits(fitsfile)
  rp = radprof(img, /rms)
  rho = findgen(n_elements(rp))*ps
  con5s = logm(peak/5./rp)
  dmag = con5s
  save,file='contrast.save',rho,dmag
end
