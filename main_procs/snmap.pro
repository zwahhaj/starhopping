;;Written by Zahed Wahhaj
;;last modified May 16, 2014
;; spotblock takes x, y position of some signal you want to discount
;;     from the map calculation
function snmap, img, spotblock=cb, rgnblock=wb, sigmaclip=sigmaclip,xc=xc,yc=yc,smart=smart

  temp = img

  if n_elements(cb) then wb = getrgn(temp,0,4,xc=cb[0],yc=cb[1])
  if n_elements(wb) ne 0 then if  wb[0] ne -1 then temp(wb) = 0

  if n_elements(xc) eq 0 then xc = (size(img))[1]/2.-0.5
  if n_elements(yc) eq 0 then yc = (size(img))[1]/2.-0.5
  ;;print, xc, yc
  ;map = img/rmsmap(temp,/prop,xc=xc,yc=yc,smart=smart)
  ;map = img/rmsmap(temp,/prop,xc=xc,yc=yc)
  map = img/rmsmap(temp,/prop,xc=xc,yc=yc)
  ;;stop

  return, map
end
