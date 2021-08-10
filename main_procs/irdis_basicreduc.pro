;;Written by Zahed Wahhaj, 2016
;;2021, Jul 21, ZWa: Added tag, out1, out2
;;OUTPUT:
;;  out1 - filename of list star1 files
;;  out2 - filename of list star2 files

pro irdis_basicreduc,scilist, maskfile=maskfile, tag=tag, out1=out1, out2=out2

  if n_elements(tag) eq 0 then tag=''
  
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

  ;;divide the list into two, one for science, one for ref
  
  spawn,'cat basicredlist.txt | xargs dfits | fitsort RA DEC | cut -f 1', fnames
  spawn,'cat basicredlist.txt | xargs dfits | fitsort RA DEC | cut -f 2', ras
  spawn,'cat basicredlist.txt | xargs dfits | fitsort RA DEC | cut -f 3', decs
  
  fnames = fnames[1:*]
  ras = ras[1:*]
  decs = decs[1:*]
  
  dras = abs(float(ras)-float(ras[0])) 
  ddecs = abs(float(decs)-float(decs[0])) 
;;dras = string(abs(float(ras)-float(ras[0])),f="(F7.3)") 
;;ddecs = string(abs(float(decs)-float(decs[0])),f="(F7.3)") 
  
  ds = sqrt(dras^2 + ddecs^2)
  
  w1 = where(ds lt 0.001)
  w2 = where(ds ge 0.001)

  out1 = 'basicredlist1'+tag+'.txt'
  out2 = 'basicredlist2'+tag+'.txt'
  
  forprint, textout=out1, fnames[w1],/nocomment
  forprint, textout=out2, fnames[w2],/nocomment

end
