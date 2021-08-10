pro zdisp, im1, xc, yc, zoom=zoom,noticks=noticks,aspect=aspect, min=min, max=max, $
           xco=xco,yco=yco,title=title,ytitle=ytitle,xtitle=xtitle,charsize=charsize,notv=notv,x0=x0,y0=y0,nowin=nowin,orglim=orglim

;; OUTPUTS: 
;; xco = center of zoomed image
;; yco = center of zoomed image
;; Written by Zahed Wahhaj; 2008
;; Feb 1 2010: Keep the org. pixel values when zooming

;; xc,yc = center to zoom in on.
  if n_elements(nowin) eq 0 then window,2,xs=800,ys=800
  ;;if n_elements(nowin) eq 0 then window,2,xs=100,ys=100
  sz = (size(im1))[1]
  
  if n_elements(xc) eq 0 then xc = (sz-1)/2.
  if n_elements(yc) eq 0 then yc = (sz-1)/2.
  if n_elements(zoom) eq 0 then zoom = 4.
  ;;print, xc, yc, zoom

  hs = nint(sz/zoom/2.)
  x0 = nint(xc)-hs
  x1 = nint(xc)+hs
  y0 = nint(yc)-hs
  y1 = nint(yc)+hs

  mx = (max(im1[x0:x1,y0:y1]))[0] & mn = (min(im1[x0:x1,y0:y1]))[0]
  if n_elements(orglim) ne 0 then mx = (max(im1))[0] & mn = (min(im1))[0] 

  
  ;;print, 'mx,min:',mx,mn
  ;;plotimage,bytscl(im1),imgx=[-0.5,sz-0.5],imgy=[-0.5,sz-0.5],xr=[x0,x1],yr=[y0,y1],range=[mx,mn],/PRESERVE_ASPECT
  temp = bytscl(im1,min=mn,max=mx)
  plotimage,temp,imgx=[-0.5,sz-0.5],imgy=[-0.5,sz-0.5],xr=[x0,x1],yr=[y0,y1],/PRESERVE_ASPECT


  ;imext, im1, temp,  xc, yc, sz/zoom
  ;xco = ((size(temp))[1]-1)/2.
  ;yco = ((size(temp))[2]-1)/2.
  ;xcn = nint(xc)
  ;ycn = nint(yc)
  ;x0 = xcn-hs > 0
  ;x1 = xcn+hs < sz-1
  ;y0 = ycn-hs > 0
  ;y1 = ycn+hs < sz-1
  ;;;stop
  ;display, im1[x0:x1, y0:y1]
  ;;display2, im1[x0:x1, y0:y1], rangegen(x0, x1, x1-x0+1), rangegen(y0, y1, y1-y0+1), $
  ;;          noticks=noticks, aspect=aspect, title=title,ytitle=ytitle,xtitle=xtitle, $
  ;;          min=min, max=max,charsize=charsize,notv=notv;;
;
 ; ;;imext, im1, temp,  xc, yc, sz/zoom
 ; ;;xco = ((size(temp))[1]-1)/2.
 ; ;;yco = ((size(temp))[2]-1)/2.
 ; ;;display, temp,noticks=noticks,aspect=aspect
end
