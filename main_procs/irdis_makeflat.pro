;;Written by Zahed Wahhaj, 2018

pro irdis_makeflat, filetxt

readcol,filetxt,filenames,f='A'
num = n_elements(filenames)

case num of
   1: begin
      imgflat1 = readfits(filenames[0],fhead1) ;; dit=10
      if (size(imgflat1))[0] eq 3 then imgflat1 = median(imgflat1,dim=3) 
      flat = imgflat1
      wn1 = -1

   end
   else: begin
      imgflat1 = readfits(filenames[0],fhead1) ;; dit=10
      imgflat2 = readfits(filenames[1],fhead2) ;; dit=4
      if (size(imgflat1))[0] eq 3 then imgflat1 = median(imgflat1,dim=3) 
      if (size(imgflat2))[0] eq 3 then imgflat2 = median(imgflat2,dim=3) 

      dit1 = float(esopar(fhead1,'DET SEQ1 DIT'))
      dit2 = float(esopar(fhead2,'DET SEQ1 DIT'))

      ditrat = (dit1/dit2)[0]
      imgrat = imgflat1/imgflat2
      
      wnl = where( abs(1 -  imgrat/ditrat) gt 0.1 ) 
      flat = imgflat1
   end
endcase

badpix = flat*0
if wnl[0] ne -1 then badpix[wnl] = 1

med = badpix*0
med[0:1023,*]=median(flat[0:1023,*])
med[1024:*,*]=median(flat[1024:*,*])
flat /=med

flat(wnl) = 1

flat[0:50,*] = 1
flat[920:1080,*] = 1
flat[1950:*,*] = 1
flat[*,0:50] = 1
flat[*,940:*] = 1

badpix[0:50,*] = 0
badpix[920:1080,*] = 0
badpix[1950:*,*] = 0
badpix[*,0:50] = 0
badpix[*,940:*] = 0

fixpix,flat, (1-badpix), flatg
flat = (flatg > 0.8) < 1.2
wbad = where(flatg lt 0.8 or flatg gt 1.2) 
badpix[wbad] = 1

writefits,'flat_irdis.fits',flat,fhead
writefits,'badpix_irdis.fits',badpix,fhead
end
