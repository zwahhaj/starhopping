;;Written by Zahed Wahhaj, Oct 25, 2017
;;returns the difference between two sets of strings:
;; that is removes all string from the 2nd set from the first set.

function strsetdiff,str1, str2

  num1= n_elements(str1)
  num2= n_elements(str2)
  
  for i=0, num1-1 do begin
     flag = 1
     for j=0, num2-1 do begin
        if strmatch(str1[i], str2[j]) ne 0 then begin
           flag = 0
           break
        endif
     endfor
     if flag then begin
        if n_elements(w) ne 0 then w = [w,i] $
        else w = i
     endif
  endfor
  
  return, str1[w]
  
end
