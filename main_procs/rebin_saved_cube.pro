

;; Written by Zahed Wahhaj, Jan 30, 2020
;;   from ifs_rebin_cube.pro
;; imcs: save_cube file name

;zrestore,file='imcbasic2.save',st=s
;imc = ifs_rebin_cube(s.imc, 8, 39, pas=s.pas, npas=pas)
;num = (size(imc))[3]
;lambdas = s.lambdas[0:num-1]
;save,file='imcbasic2_bin8.save', imc, pas, lambdas

pro rebin_saved_cube, imcs, binfac=binfac, nlambda=nlambda, out_imc_save=out_imc_save ;;pas=pas, npas=npas
  ;; nlambda = number of spectral channels

  restore,file=imcs
  pas = anglediff(pas,0) ;; to make all pas positive
  
  if n_elements(nlambda) eq 0 then nlambda = 1

  sz = size(imc)
  ndit = sz[3]/nlambda
  nndit = nint(ndit/binfac)
  nimc = fltarr(sz[1], sz[2], nndit*nlambda)
  npas = fltarr(nndit*nlambda)
  inx = indgen(sz[3])

  for i=0, nndit-1 do begin
     for j=0, nlambda-1 do begin
        w = where(inx mod nlambda eq j)
        if i eq nndit-1 then linx = ndit-1 $
        else linx = i*binfac+binfac-1
        nimc[0,0,i*nlambda+j] = median(imc[*,*,w[i*binfac:linx]],dim=3)
        npas[i*nlambda+j] = median(pas[w[i*binfac:linx]])
        ;;print, i, j, i*nlambda+j, w[i*binfac], w[linx]
     endfor
  endfor

  ;;print, sz[3],ndit,nndit,binfac
  ;;return,nimc
  imc = temporary(nimc)
  num = (size(imc))[3]
  lambdas = lambdas[0:num-1]
  if n_elements(lambdas0) then lambdas0 = lambdas[0:nlambdas-1]
  if n_elements(peaks) then peaks = peaks[0:nlambdas-1]
  pas = npas
  imcso = zfile(imcs,4)+'_bin'+trim(string(binfac))+'.save'
  dits *= binfac
  dits = dits[0:ndit-1]
  push,comment,'DITS have been multiplied by binfac'
  save,file=imcso, imc, pas, lambdas, lambdas0, peaks, normsci, comment, dits
  ;;save,file=outfile, imc, pas, lambdas, dits


  out_imc_save = imcso
end

