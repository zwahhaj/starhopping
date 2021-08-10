;;Written by Zahed Wahhaj, 2019


pro sph_remove_bad_images, insavefile,inrad=inrad, outrad=outrad
  common scope_comm_restore, imc, pas, lambdas, dits, lambdas0, comment, normsci
  pname = 'sph_remove_bad_images'

  sz = (size(imc))[1]

  if n_elements(inrad) eq 0 then inrad = sz*0.2
  if n_elements(outrad) eq 0 then outrad= sz/2.0*0.9

  restore,file=insavefile

  wg = get_good_images(imc,inrad=inrad,outrad=outrad, wb=wb,rms=rms)
  
  numg = n_elements(wg)
  num = (size(imc))[3]
  
  if numg lt num then begin
     fbase = zfile(insavefile,4)
     fext = zfile(insavefile,3)
     save,file=fbase+'_withbad'+fext,/variables

     ;imb = imc[*,*,wb]
     imc = imc[*,*,wg]
     
     if n_elements(dits) ne 0 then dits = dits[wg]
     if n_elements(pas) ne 0 then pas = pas[wg]
     if n_elements(lambdas) ne 0 then lambdas = lambdas[wg]
     if n_elements(lambdas0) ne 0 then lambdas0 = lambdas0[wg]
     if n_elements(stokes) ne 0 then stokes = stokes[wg]
     if n_elements(polfilts) ne 0 then polfilts = polfilts[wg]
     if n_elements(detside) ne 0 then detside = detside[wg]
     if n_elements(tstamps) ne 0 then tstamps = tstamps[wg]
     
     save,file=insavefile,/variables
  endif

  msglog, pname+': number of images: '+trim(num)
  msglog, pname+': number of good images: '+trim(numg)
end
