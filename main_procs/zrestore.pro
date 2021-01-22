;; Written by Zahed Wahhaj. Oct 19, 2017
;; INPUTS:
;; vars: a string of variable names separated by spaces'
;; struct: a structure variable in which the desired restored variable will be returned.

pro zrestore, filename=savefile_z, struct_z=struct_z, vars_z=vars_z, avail_vars=avail_vars

  help,out=zzz0
  restore,filename=savefile_z
  help, out=zzz1
  zzz = strsetdiff(zzz1,zzz0)
  zzz = zzz[1:(where(strmatch(zzz,'ZZZ*')))[0]-1]

  ;; trying to use varnames that are atypical so as not to overwrite
  ;; restores variables.
  
  num_z = n_elements(zzz)
  names_z = strarr(num_z)
  forprint, zzz,textout=2
  for i_z=0,num_z-1 do names_z[i_z] = trim((strsplit(zzz[i_z],' ',/ex))[0])
  forprint, names_z,textout=2
  avail_vars = names_z
  
  if arg_present(struct_z) eq 0 then begin
     print,'Usage: filename=savefile, struct_z=struct_z, vars_z=vars_z'
     print,'Available variables in restored file:'
     forprint, names_z,textout=2
     return
  endif

  if n_elements(vars_z) ne 0 then begin
     vnames1_z = (strsplit(vars_z,' ',/ex))  ;; vars wanted by user
     num1_z = n_elements(vnames1_z)

     command_z =vnames1_z[0]+':'+vnames1_z[0] 
     for i_z=1, num1_z-1 do begin
        command_z = command_z+', '+ vnames1_z[i_z]+':'+vnames1_z[i_z]
     endfor
     command_z = 'struct_z = {' + command_z + '}'  
     junk_z = execute(command_z)
  endif else begin
     num1_z = n_elements(names_z)

     command_z =names_z[0]+':'+names_z[0] 
     for i_z=1, num1_z-1 do begin
        command_z = command_z+', '+ names_z[i_z]+':'+names_z[i_z]
     endfor
     command_z = 'struct_z = {' + command_z + '}'  
     junk_z = execute(command_z)
  endelse
  
end

     ; in case I want to go through available variable in restored scope, see code below
     ;vnames2 =  strarr(num)                 ;; var names available in scope (see below).
     ;for i=0, num-1 do vnames[i] = (strsplit(out[i],' ',/ex))[0] 


