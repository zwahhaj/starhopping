;;written by Zahed Wahhaj - Oct 15, 2017
pro msglog,msg,start=start,file=file,orgfile=orgfile


  if n_elements(file) eq 0 then file = 'msglog.txt'
  if n_elements(start) ne 0 then spawn,'rm '+file

  if arg_present(orgfile) then begin
     ;; In case DIR is changed is middle of code, get the orgfile at start program
     cd,curr=orgdir
     orgfile = orgdir+'/'+file
  endif

  print,'log file: '+file
  ;;help,out=out,lev=-1 ;; level = -1 doesn't work!!! should point to upper scope.
  stc = scope_traceback(/str)
  last = (n_elements(stc.routine)-2) > 0
  routine = trim((stc.routine)[last])
  line = trim((stc.line)[last])
  ppath = trim((stc.filename)[last])

  nl = string(10b);;+string(13b)
  s = ', '
  msg = systime()+s+routine+', line '+line+': '+msg+nl+ppath
  forprint2,textout=file,/update,msg,/silent
  print,msg
end
