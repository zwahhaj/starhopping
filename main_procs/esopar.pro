;;Written by Zahed Wahhaj - sometime in 2016
;; 2019, sep 26: ZWa: Fixed problem when keyval does not end in '/'
function esopar, head, keyword
  w= where(strmatch(head,'*'+keyword+'*'))
  w = w[0]
  str = head[w]
  ;print, str
  p1 = strpos(head[w],'=')
  p2 = strpos(head[w],'/')
  ;print, p1, p2
  if p2 eq -1 then p2=1000
  len = nint(p2)-nint(p1)-2
  return, strmid(str,p1+1,len)
end
