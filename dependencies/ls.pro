pro ls, dir
;+
; NAME:
;	ls
;
; PURPOSE:
;	I can't believe they didn't build an "ls" into IDL!
;	Generates a directory listing for the current directory
;
; ARGUMENTS:
;	none
;
; AUTHOR:
;	Mike Ressler
;-
if n_elements(dir) eq 0 then begin
    spawn,'echo ls of `/usr/bin/pwd`:'
    spawn,'ls --color=tty -CF'
endif else begin
    print,'ls of '+dir+':'
    spawn,'ls --color=tty -CF '+dir
endelse
end
