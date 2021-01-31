;;Written by Zahed Wahhaj, 2016

pro irdis_basicreduc,scilist, maskfile=maskfile

  darkb = readfits('dark_irdis.fits',dbhead)
  flat = readfits('flat_irdis.fits',junk)
  badpix = 1-readfits('badpix_irdis.fits',junk)
  noise = randomn(seed,2048,1024)
  
  if n_elements(maskfile) then begin
     restore, file=maskfile
     darkb[wmask]=0
     flat[wmask]=1
     badpix[wmask]=1
  endif

  readcol,scilist,files, f='A'
  numf = n_elements(files)

  fnames = strarr(numf)
  for j=0,numf-1 do begin
     imc = readfits(files[j],head)

     imgfd = imc
     num = sxpar(head,'NAXIS3') ;;(size(imc))[3]
     for i=0,num-1 do begin
        temp = (imc[*,*,i]-darkb)/flat
        if n_elements(maskfile) then begin
           if i eq 0 then noisefac = robust_sigma(temp)
           temp[wmask] = noise[wmask]*noisefac
        endif
        imgfd[0,0,i] = temp
     endfor
   
     ;;additional bad pixels from looking at outliers in the cube
     if (size(imgfd))[0] eq 3 then totc = total(imgfd, 3) $
     else totc = imgfd
     totcs = medsmooth(totc, 10)
     bmap = totc/totcs
     wnan = where(1-finite(bmap))
     if wnan[0] ne -1 then bmap(wnan) = 0
     bmap = bmap le 5
     badpixfin = badpix and bmap
     badpixfin[0:50,*,*] = 1
     badpixfin[940:1080,*,*] = 1
     badpixfin[1960:*,*,*] = 1

     fixpix,imgfd,badpixfin,imgfdb

     wnan = where(1-finite(imgfdb))
     if wnan[0] ne -1 then imgfdb[wnan] = 0
   
     imgfdb[0:50,*,*] = 0
     imgfdb[940:1080,*,*] = 0
     imgfdb[1960:*,*,*] = 0
   
     imgfdbq = imgfdb
     
     fnamenew = 'basic'+zfile(files[j])
     fnames[j] = fnamenew
     writefits, fnamenew, imgfdbq, head
  endfor
  
  forprint,textout='basicredlist.txt',fnames,/nocomm

end
