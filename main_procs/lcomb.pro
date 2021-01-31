;;Written by Zahed Wahhaj. 2019.
function lcomb, arr, wts

  sz = size(arr)
  temp = arr*0
  
  if sz[0] eq 3 then begin
     temp = fltarr(sz[1],sz[2],sz[3])
     out = fltarr(sz[1],sz[2])
     for i=0,sz[3]-1 do begin
        temp[0,0,i] = arr[*,*,i]*wts[i]
     endfor
     out = total(temp, 3, /NAN)
  endif

  if sz[0] eq 2 then begin
     temp = fltarr(sz[1],sz[2])
     out = fltarr(sz[1])
     for i=0,sz[2]-1 do begin
        temp[0,i] = arr[*,i]*wts[i]
     endfor
     out = total(temp, 2, /NAN)
  endif

  
  return, out

end
