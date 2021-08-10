;;Written by Zahed Wahhaj, 2019
;;Feb 3, 2021: zwahhaj. Fixed error when container has no science files.

pro sphere_sort_hopsets, data_dir=data_dir, dest_dir=dest_dir
  
  cd,curr=org_dir ;; just get the curr dir. NO CD happens.
  if n_elements(dest_dir) eq 0 then dest_dir =org_dir 
  if n_elements(data_dir) eq 0 then data_dir =org_dir 

  if strmid(data_dir,0,1) ne '/' then data_dir=org_dir+'/'+data_dir ;; is a subdir
  if strmid(dest_dir,0,1) ne '/' then dest_dir=org_dir+'/'+dest_dir ;; is a subdir
  spawn,'mkdir '+dest_dir

  msgfile = org_dir+'/msglog.txt'
  
  
  cd,data_dir
  spawn, 'dfits SPH*.[0-9][0-9][0-9].fits | fitsort OBS.NAME INS4.MODE SEQ.ARM DPR.TYPE INS.COMB.ICOR INS1.FILT.NAME INS.COMB.IFLT INS2.OPTI2.NAME DET.SEQ1.DIT DET.NDIT OBS.CONTAINER.ID ORIGFILE INS2.COMB.IFS', res
  res = res[1:*]
  num = n_elements(res)
  
  dprtype = strarr(num)
  objects = strarr(num)
  arms = strarr(num)
  fnames = strarr(num)
  ftimes = strarr(num)
  dits = fltarr(num)
  filts= strarr(num)
  prisms= strarr(num)
  contid= strarr(num)  ;; containner ID
  night= strarr(num)   ;; night of year
  ifslamp= strarr(num)  

  ;; Looping over all SPHERE FITS files found.
  for i=0, num-1 do begin
     cols = strsplit(res[i],string(9b),/ex)
     if i eq 0 then night0 = strmid(trim(cols[12]),12,3,/rev) 
     dprtype[i] = trim(cols[4])
     objects[i] = trim(cols[1])
     arms[i] = trim(cols[3])
     fnames[i] = trim(cols[0])
     ftimes[i] = repstr(repstr(fnames[i],'SPHER.',''),'.fits','') ;; writetimes from the file names.
     dits[i] = float(cols[9])
     prisms[i] = trim(cols[8])
     filts[i] = trim(cols[7])
     contid[i] = trim(cols[11])
     ifslamp[i] = trim(cols[13])
     daydiff = long(esotimediff(ftimes[i],ftimes[0])) / 86400L ;; time diff in secs between file_0 and file_i
     night[i] = trim(night0+daydiff)
     print, cols[12], night0, daydiff
  endfor

  ;;Finding all the science files, OBJ, FLUX, CENTER, SKY 
  cond_sci = (strmatch(objects,'*Calibration*') eq 0) AND (strlen(arms) ne 0)
  wsci = where(cond_sci)
;objs = objects+'_'+arms
  datasets = 'day'+night+'-cid'+contid+'-'+arms
  obju = 'day'+night(wsci)+'-cid'+contid(wsci)+'-'+arms(wsci)
  
  objs = obju
  o = sort(obju)
  obju = obju(o)
  u = uniq(obju)
  obju = obju(u)
;;remove any dataset that says that target name is just OBJECT.
;;dont remember what these are.
;wg = where(strmatch(obju,'OBJECT*') eq 0)
;obju = obju[wg]
  numo = n_elements(obju)
  
  comment = '# FILE                                  OBJECT          INS4.MODE       SEQ.ARM         DPR.TYPE        INS.COMB.ICOR   INS1.FILT.NAME  INS.COMB.IFLT   INS2.OPTI2.NAME DET.SEQ1.DIT    DET.NDIT'
  
  
  print,'DATASETS found:'
;;print out list of science files and corresponding list of fitinfo files
  for i=0, numo-1 do begin
     cd,dest_dir
     print,obju[i]
     spawn,'mkdir '+obju[i]
     cd,obju[i]
     spawn,'rm scilist.txt'
     spawn,'rm sciinfo.txt'
     spawn,'rm centerlist.txt'
     spawn,'rm centerinfo.txt'
     spawn,'rm centeroptions.txt'
     spawn,'rm fluxlist.txt'
     spawn,'rm fluxinfo.txt'
     spawn,'rm fluxoptions.txt'
     spawn,'rm flatlist.txt'
     spawn,'rm flatinfo.txt'
     spawn,'rm flatoptions.txt'
     spawn,'rm skylist.txt'
     spawn,'rm skylist_other.txt'
     spawn,'rm skyinfo.txt'
     spawn,'rm skyoptions.txt'
     spawn,'rm darklist.txt'
     spawn,'rm darkinfo.txt'
     spawn,'rm darkoptions.txt'
     spawn,'rm ifscal*.txt'
     
     ;;writing out science files ======================================================================================
     wm = where(strmatch( objs, obju[i]) ne 0 AND strmatch(dprtype[wsci],'OBJECT') ne 0 $
                AND strmatch(dprtype[wsci],'OBJECT,') eq 0) 
     if wm[0] eq -1 then begin
        msglog, obju[i]+' has no science files. Skipping to next container.',file=msgfile
        continue
     endif
     ditmed = median(dits[wsci[wm]])
     if n_elements(wm) gt 1 then if stddev(dits[wsci[wm]]) ne 0 then begin
        msglog,'WARNING: not all '+obju[i]+' science files have the same DIT!',file=msgfile
        ;;wm = where( strmatch(objs, obju[i]) ne 0 and dits eq ditmed) ;;only choose the most common science DIT.
        wm = where(strmatch( objs, obju[i]) ne 0 AND strmatch(dprtype[wsci],'OBJECT') ne 0 $
                   AND strmatch(dprtype[wsci],'OBJECT,') eq 0 and dits[wsci] eq ditmed) 
        ;; wmo for the other DITs.
        wmo = where(strmatch( objs, obju[i]) ne 0 AND strmatch(dprtype[wsci],'OBJECT') ne 0 $
                   AND strmatch(dprtype[wsci],'OBJECT,') eq 0 and dits[wsci] ne ditmed) 
     endif
     linfo = 'sciinfo.txt'
     lnames = 'scilist.txt'
     lnameso = 'scilist_other.txt'
     if file_test(linfo) eq 0 then forprint2, textout=linfo,comment,/silent
     forprint2, textout=linfo, res[wsci[wm]], /update,/silent
     forprint2, textout=lnames, fnames[wsci[wm]], /update,/silent
     if wmo[0] ne -1 then forprint2, textout=lnameso, fnames[wsci[wmo]], /update,/silent
     for k=0, n_elements(wm)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wsci[wm[k]]])+' .'
     if wmo[0] ne -1 then for k=0, n_elements(wmo)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wsci[wmo[k]]])+' .'
     
     ;;SETTING KEY properties of SCIENCE files to match ===============================================================
     ;;print, dits[wsci[wm]]
     ;;ws0 = wsci[wm[0]] ;; the 1st science file index for this data set
     ;;ws = wsci[wm] ;; the science file indices for this data set

     ;;The science file indices for this data set ;; REMOVED: and dits eq ditmed
     ws = where(strmatch(datasets,obju[i]) ne 0 and dits eq ditmed)
     ;; the 1st science file index for this data set.
     ;; CANNOT use on "datasets" or "obju" arrays. ONLY on "dits", "arms", etc. 
     ws0 = ws[0] 
     
     timediff = fltarr(num)
     for j=0,num-1 do begin ;; TIMEDIFFs for all files 
        timediff[j] = abs(esotimediff(ftimes[ws0],ftimes[j]))
     endfor
     
     ;;FLATS: Get the possible flats, checking only INS/ARM and filter=================================================
     lfnames = 'flatlist.txt'
     lfinfo = 'flatinfo.txt'
     lfopts = 'flatoptions.txt'
     ;;if strmatch(arms[ws0],'IFS') ne 0 then var = prisms $
     ;;else var = filts
     if strmatch(arms[ws0],'IFS') eq 0 then begin
        var = prisms 
        condg = strmatch(dprtype,'*FLAT*') ne 0 and strmatch(var,var[ws0]) ne 0 and strmatch(arms,arms[ws0]) ne 0
        wg = where(condg)
        if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
        forprint2, textout=lfopts, res[wg], /update,/silent
        
        mintimediff = (min(timediff[wg]))[0] ;; the timediff for the closest in time flat
        if mintimediff gt 2*24d*3600 then msglog,'nearest flat is more than 2 days away from science'
        wb =  where(condg and timediff lt mintimediff+16d*3600,numdits) 
        case numdits of  ;; depending on how may approp flats found
           0: begin
              msglog, 'No approp flat dits found. Please check _flatoptions.txt file. Stopping here.'
              stop
           end
           1: begin
              msglog, 'Only flat dit found. Please check _flatoptions.txt file. Continuing...'
              if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
              forprint2, textout=lfinfo, res[wb[0]], /update,/silent
              forprint2, textout=lfnames, fnames[wb[0]], /update,/silent
            spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[0]])+' .'
         end
         else: begin
            ;; Take the maximum DIT and the one next to minimum if possible
            temp = dits[wb]
            o = sort(dits[wb])
            u = uniq(dits[wb[o]])
            numu = n_elements(u)
            if numu eq 1 then begin
               wb1 = wb[o[u[0]]]
               wb2 = wb1
            endif else if numu eq 2 then begin
               wb1 = wb[o[u[0]]]
               wb2 = wb[o[u[1]]]
            endif else begin
               wb1 = wb[o[u[1]]]
               wb2 = wb[o[u[numu-1]]]
            endelse
            if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
            forprint2, textout=lfinfo, res[wb1], /update,/silent
            forprint2, textout=lfinfo, res[wb2], /update,/silent
            forprint2, textout=lfnames, fnames[wb1], /update,/silent
            forprint2, textout=lfnames, fnames[wb2], /update,/silent
            spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb1])+' .'
            spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb2])+' .'
         end
      endcase
     endif

   
   ;; Make sky list =====================================================================================
   lfnames = 'skylist.txt'
   lfinfo = 'skyinfo.txt'
   lfopts = 'skyoptions.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then var = prisms $
   else var = filts
   condg = strmatch(dprtype,'*SKY*') ne 0 and strmatch(var,var[ws0]) ne 0 and strmatch(arms,arms[ws0]) ne 0 and dits[ws0] eq dits and contid[ws0] eq contid
   wg = where(condg)
   if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
   if wg[0] ne -1 then forprint2, textout=lfopts, res[wg], /update,/silent
   
   if wg[0] ne -1 then  mintimediff = (min(timediff[wg]))[0] $ ;; the timediff for the closest in time flat
   else mintimediff = 0
   if mintimediff gt 2*24d*3600 then msglog,'nearest SKY is more than 2 days away from science'
   wb =  where(condg and timediff lt mintimediff+16d*3600,numsky) 
   case numsky of  ;; depending on how may approp flats found
      0: begin
         msglog, 'No approp SKY found. Please check skyoptions.txt file. Continuing...'
      end
      else: begin
         if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
         forprint2, textout=lfinfo, res[wb], /update,/silent
         forprint2, textout=lfnames, fnames[wb], /update,/silent
         for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
      end
   endcase

   ;; Make dark list ===================================================================
   lfnames = 'darklist.txt'
   lfinfo = 'darkinfo.txt'
   lfopts = 'darkoptions.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then begin
      var = prisms
      condf = strmatch(var,'*OPEN*') ne 0
      condd = (dits[ws0] eq dits) or (dits lt 1.7)
   endif else begin
      var = filts
      condf = strmatch(var,var[ws0]) ne 0
      condd = dits[ws0] eq dits
   endelse
   condg = strmatch(dprtype,'*DARK,BACK*') ne 0 and condf and strmatch(arms,arms[ws0]) ne 0 and condd
   wg = where(condg)
   if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
   if wg[0] ne -1 then forprint2, textout=lfopts, res[wg], /update,/silent

   if wg[0] ne -1 then  mintimediff = (min(timediff[wg]))[0] $ ;; the timediff for the closest in time flat
   else mintimediff = 0
   if mintimediff gt 2*24d*3600 then msglog,'nearest DARK is more than 2 days away from science'
   wb =  where(condg and timediff lt mintimediff+16d*3600,numdark) 
   case numdark of  ;; depending on how may approp flats found
      0: begin
         msglog, 'No approp DARK found. Please check darkoptions.txt file. Continuing...'
      end
      else: begin
         if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
         forprint2, textout=lfinfo, res[wb], /update,/silent
         forprint2, textout=lfnames, fnames[wb], /update,/silent
         for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
      end
   endcase

   ;; Make center list ===================================================================
   lfnames = 'centerlist.txt'
   lfinfo = 'centerinfo.txt'
   lfopts = 'centeroptions.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then var = prisms $
   else begin
      var = filts
   endelse
   condg = strmatch(dprtype,'*CENTER*') ne 0 and strmatch(var,var[ws0]) ne 0 and strmatch(arms,arms[ws0]) ne 0 and dits[ws0] eq dits and contid[ws0] eq contid
   wg = where(condg)
   if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
   if wg[0] ne -1 then forprint2, textout=lfopts, res[wg], /update,/silent

   if wg[0] ne -1 then  mintimediff = (min(timediff[wg]))[0] $ ;; the timediff for the closest in time flat
   else mintimediff = 0
   if mintimediff gt 2*24d*3600 then msglog,'nearest CENTER is more than 2 days away from science'
   wb =  where(condg and timediff lt mintimediff+16d*3600,numcenter) 
   case numcenter of  ;; depending on how may approp flats found
      0: begin
         msglog, 'No approp CENTER found. Please check centeroptions.txt file. Continuing...'
      end
      else: begin
         if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
         forprint2, textout=lfinfo, res[wb], /update,/silent
         forprint2, textout=lfnames, fnames[wb], /update,/silent
         for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
      end
   endcase

   ;; Make FLUX list ===================================================================
   lfnames = 'fluxlist.txt'
   lfinfo = 'fluxinfo.txt'
   lfopts = 'fluxoptions.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then var = prisms $
   else var = filts
   condg = strmatch(dprtype,'*FLUX*') ne 0 and strmatch(arms,arms[ws0]) ne 0 and contid[ws0] eq contid
   wg = where(condg)
   if wg[0] ne -1 then begin
      if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
      forprint2, textout=lfopts, res[wg], /update,/silent
      mintimediff = (min(timediff[wg]))[0] ;; the timediff for the closest in time flat
      if mintimediff gt 2d*3600 then msglog,'nearest FLUX is more than 2 hours away from science'
      wb =  where(condg and timediff lt mintimediff+4d*3600 and strmatch(var,var[ws0]) ne 0,numflux) 
   endif else numflux = 0
   case numflux of  ;; depending on how may approp flats found
      0: begin
         msglog, 'No FLUX images found. Please check fluxoptions.txt file. Continuing.'
      end
      else: begin
         if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
         forprint2, textout=lfinfo, res[wb], /update,/silent
         forprint2, textout=lfnames, fnames[wb], /update,/silent
         for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
      end
   endcase

   ;; Make ifscalibs list ===================================================================
   lfnames = 'ifscal_list.txt'
   lfinfo = 'ifscal_info.txt'
   lfopts = 'ifscal_options.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then begin
      var = repstr(prisms,'PRI_','')
      str_calnameA =['CAL_BB_2_','CAL_NB1_1_','CAL_NB2_1_','CAL_NB3_1_','CAL_NB4_2_']
      for ii=0,n_elements(str_calnameA)-1 do begin
         condg = strmatch(dprtype,'*FLAT*') ne 0 and strmatch(arms,arms[ws0]) ne 0 and strmatch(ifslamp,'*'+str_calnameA[ii]+var[ws0]+'*') ne 0
         wg = where(condg)
         numcals = 0
         if wg[0] ne -1 then begin
            if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
            forprint2, textout=lfopts, res[wg], /update,/silent
            mintimediff = (min(timediff[wg]))[0] ;; the timediff for the closest in time flat
            if mintimediff gt 48d*3600 then msglog,'nearest '+str_calnameA[ii]+'FLAT is more than 2 days away from science'
            wg0 =  where(condg and timediff lt mintimediff+12d*3600)                                ;; counting number available. 
            dit0 = (min(dits[wg0], wch1))[0]                                                        ;; minimum dit in the nearest calibs
            wch1 = wg0[wch1[0]]                                                                    ;; the index of the closest calib with the small dit
            wch2 = where(condg and timediff lt mintimediff+12d*3600 and dits ne dit0) & wch2 = wch2[0] ;; the index of the closest calib with the large dit
            if wch2[0] ne -1 then begin
               wb =  [wch1,wch2]
               numcals=2 ;; counting number available. 
            endif
         endif
         case numcals of  ;; depending on how may approp flats found
            0: begin
               msglog, 'No '+str_calnameA[ii]+'FLAT images found. Please check '+lfopts+' file. Continuing.'
            end
            else: begin
               if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
               forprint2, textout=lfinfo, res[wb], /update,/silent
               forprint2, textout=lfnames, fnames[wb], /update,/silent
               for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
            end
         endcase
      endfor
   endif
;;--------------MORE IFS CALS which need single files
   lfnames = 'ifscal2_list.txt'
   lfinfo = 'ifscal2_info.txt'
   lfopts = 'ifscal2_options.txt'
   if strmatch(arms[ws0],'IFS') ne 0 then begin
      ;;var = repstr(prisms,'PRI_','')
      str_dprtype =['SPECPOS,LAMP','WAVE,LAMP','FLAT,LAMP']
      for ii=0,n_elements(str_dprtype)-1 do begin
         condg = strmatch(dprtype,'*'+str_dprtype[ii]+'*') ne 0 and strmatch(arms,arms[ws0]) ne 0 and strmatch(prisms,prisms[ws0]) ne 0 and strmatch(ifslamp,'*OBS*') ne 0
         wg = where(condg,numcals)
         if wg[0] ne -1 then begin
            if file_test(lfopts) eq 0 then forprint2, textout=lfopts,comment,/silent
            forprint2, textout=lfopts, res[wg], /update,/silent
            mintimediff = (min(timediff[wg],wmintime))[0] ;; the timediff for the closest in time flat
            if mintimediff gt 48d*3600 then msglog,'nearest '+str_dprtype[ii]+' CAL is more than 2 days away from science'
            wb = wg[wmintime[0]]
         endif
         case numcals of  ;; depending on how may approp flats found
            0: begin
               msglog, 'No '+str_dprtype[ii]+' CALs found. Please check '+lfopts+' file. Continuing.'
            end
            else: begin
               if file_test(lfinfo) eq 0 then forprint2, textout=lfinfo,comment,/silent
               forprint2, textout=lfinfo, res[wb], /update,/silent
               forprint2, textout=lfnames, fnames[wb], /update,/silent
               for k=0, n_elements(wb)-1 do spawn,'ln -s '+trim(data_dir)+'/'+trim(fnames[wb[k]])+' .'
            end
         endcase
      endfor
   endif
   
endfor
  
  cd,org_dir
  print,"Number of science files found per concatenation:"
  spawn,"wc -l "+dest_dir+"/*/scilist.txt"
end
