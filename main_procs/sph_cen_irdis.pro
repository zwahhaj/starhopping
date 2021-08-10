;; Written by Zahed Wahhaj. Oct 27, 2019.
;; modified irdis_objcenter.pro to find IRDIS the star-center in
;;     OBJECT,CENTER files automatically
;; filetext: a textfile containing the FITS names of the OBJECT, CENTER files

pro sph_cen_irdis, filetxt, darkfiletxt=darkfiletxt,fitchans=fitchans,badpix=badpix
;;filetxt, darkfiletxt=darkfiletxt,fitchans=fitchans,badpix=badpix
  
filetxt = 'centerlist.txt'
badpix = 'badpix_irdis.fits'
darkfiletxt = './skylist.txt'


readcol,filetxt,filename,f='A'

num = n_elements(filename)
xcs1 = fltarr(num)
xcs2 = fltarr(num)
ycs1 = fltarr(num)
ycs2 = fltarr(num)

for ii=0,num-1 do begin

   img = readfits(filename[ii],head)
   if (size(img))[0] eq 3 then img = median(img,dim=3,/even)

   if n_elements(darkfiletxt) ne 0 then begin
      readcol,darkfiletxt,darkfilename,f='A'
      dark = readfits(darkfilename[0], head)
      if (size(dark))[0] eq 3 then dark = median(dark,dim=3,/even)
      writefits,'dark_irdis.fits',head
      img = img - dark
   endif

   if n_elements(badpix) ne 0 then begin
      bpmap = 1-readfits(badpix)
      fixpix,img,bpmap,img
   endif

   getfreq, img, 4, img


;; blocking out unlikley region for the waffle spots.===========================
   xc = float(esopar(head,'SEQ CORO XC'))
   yc = float(esopar(head,'SEQ CORO YC'))

   im1 =  snmap(img[0:1023,*]   ,xc=xc,yc=yc)
   im2 =  snmap(img[1024:*,*]   ,xc=xc+3,yc=yc-14)
   
   w0 = getrgn(im1,0,30,xc=xc,yc=yc)
   w1 = getrgn(im1,100,512*1.6,xc=xc,yc=yc)
   im1[w0] = 0 & im1[w1] = 0

   w0 = getrgn(im2,0  ,30       ,xc=xc+3,yc=yc-14)
   w1 = getrgn(im2,100,512*1.6,xc=xc+3,yc=yc-14)
   im2[w0] = 0 & im2[w1] = 0

;;loop thru and find 4 spots==============================
   xcs = fltarr(4)
   ycs = fltarr(4)
   
;;left image
   sz = (size(im1))[1]
   for i=0,3 do begin
      junk = max(im1,w)
      where2xy,w,xc=x1,yc=y1,sz=sz
      bscentrd,im1,x1,y1,x,y
      if abs(x1-x) gt 1 or abs(x1-x) gt 1 then $
         begin & x=x1 & y=y1 & endif
      xcs[i] = x[0]
      ycs[i] = y[0]
      wdel = getrgn(im1,xc=x[0],yc=y[0],0,10)
      im1[wdel]=0
   endfor

   xc1 = avg(xcs)
   yc1 = avg(ycs)

   msglog,'left center: '+trim(xc1)+", "+trim(yc1)

   if abs(xc-xc1) gt 20 or abs(yc-yc1) gt 20 then $
      begin & print, "Centering algo failed. Check Manually." & atv, im1 & stop & endif
  
;;right image
   sz = (size(im2))[1]
   for i=0,3 do begin
      junk = max(im2,w)
      where2xy,w,xc=x1,yc=y1,sz=sz
      bscentrd,im2,x1,y1,x,y
      if abs(x1-x) gt 1 or abs(x1-x) gt 1 then $
         begin & x=x1 & y=y1 & endif
      xcs[i] = x[0]
      ycs[i] = y[0]
      wdel = getrgn(im2,xc=x[0],yc=y[0],0,10)
      im2[wdel]=0
   endfor
   
   xc2 = avg(xcs)
   yc2 = avg(ycs)
   msglog,'right center: '+trim(xc2)+", "+trim(yc2)

   if abs( (xc+3) - xc2 ) gt 20 or abs( (yc-14) - yc2 ) gt 20 then $
      begin & print, "Centering algo failed. Check Manually." & atv, im2 & stop & endif

   xcs1[ii] = xc1
   ycs1[ii] = yc1
   xcs2[ii] = xc2
   ycs2[ii] = yc2
   
endfor

xc1 = xcs1[0]
yc1 = ycs1[0]
xc2 = xcs2[0]
yc2 = ycs2[0]
save,file='centers.save',xc1,yc1,xc2,yc2,xcs1,ycs1,xcs2,ycs2

end

