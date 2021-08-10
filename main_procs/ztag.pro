;; written by zahed wahhaj
;; make time based tag
function ztag, tag
  if n_elements(tag) eq 0 then tag=''
  t = strsplit(systime(),' ',/ex)
  t2 = repstr(t[3],':','.')
  return, tag+'.'+t2
end
