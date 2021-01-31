pro stats,imgs, nobadval = nobadval

; runs stats on mulitple images
; 7/16/94 MCL
;
; checks if user passes only a single image
; 05/12/01 MCL
;
; checks if user passes only a single vector
; 06/20/01 MCL


on_error,2	; return to $MAIN$


if n_params(imgs) eq 0 or n_elements(imgs) eq 0 then begin
	print,'stats,imgs'
	return
endif

sz = size(imgs)
if sz(0) le 2 then n = 1  $
  else n = sz(3)

im = imgs(*,*,0)
stat,im, nobadval = nobadval
for i = 1,n-1 do begin
	im = imgs(*,*,i)
	stat,im,/nolabel, nobadval = nobadval
endfor
end
