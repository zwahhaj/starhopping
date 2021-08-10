;;Written by Zahed Wahhaj, April 22, 2015.
pro copy_deps,dir
  spawn,'mkdir '+ dir
  help, /source_files, output=procs
  num = n_elements(procs)
  for i=3,num-1 do begin
     if strmatch(procs[i],'*/*') ne 0 then begin
        proc_path = (strsplit(procs[i],' ',/ex))[1]
        spawn,'cp '+proc_path+' '+dir+'/.'
        print,'cp '+proc_path+' '+dir+'/.'
     endif
  endfor
end

