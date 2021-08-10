;; Written by Zahed Wahhaj, Nov 15, 2019
;;

function ifs_rebin_cube, imc, binfac, numlambda, pas=pas, npas=npas, lambdas = lambdas, save_out=save_out, save_file=save_file

  if n_elements(save_file) ne 0 then restore,file=save_file $
  else save_file='cube.save'
  if n_elements(save_file) ne 0 then numlambda = n_elements(zuniq(lambdas))
  
  ;; nlambda = number of spectral channels
  if n_elements(numlambda) eq 0 then numlambda = 39

  sz = size(imc)
  ndit = sz[3]/39
  nndit = nint(ndit/binfac)
  nimc = fltarr(sz[1], sz[2], nndit*numlambda)
  npas = fltarr(nndit*numlambda)
  nlambdas = fltarr(nndit*numlambda)
  npeaks = fltarr(nndit*numlambda)
  inx = indgen(sz[3])

  for i=0, nndit-1 do begin
     for j=0, numlambda-1 do begin
        w = where(inx mod numlambda eq j)
        if i eq nndit-1 then linx = ndit-1 $
        else linx = i*binfac+binfac-1
        nimc[0,0,i*numlambda+j] = median(imc[*,*,w[i*binfac:linx]],dim=3)
        npas[i*numlambda+j] = median(pas[w[i*binfac:linx]])
        nlambdas[i*numlambda+j] = median(lambdas[w[i*binfac:linx]])
        npeaks[i*numlambda+j] = median(peaks[w[i*binfac:linx]])
        ;;print, i, j, i*nlambda+j, w[i*binfac], w[linx]
     endfor
  endfor

  pas = npas
  lambdas = nlambdas
  peaks = npeaks
  imc = nimc
  
  if n_elements(save_out) eq 0 then save_out = fname_addtag(save_file,'_bin'+trim(binfac))
  save,file=save_out, COMMENT, DITS, IMC, LAMBDAS, LAMBDAS0, PAS, PEAKS

  ;;print, sz[3],ndit,nndit,binfac
  return,nimc
end

