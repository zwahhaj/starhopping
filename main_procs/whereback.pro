;; Written by Zahed Wahhaj, Dec 13, 2019
;; Gets the indices of the pixels to be tagged
;; By default the value is 1e-30, small abs float value and easy to remember 
;;
;; Example: Reset to tagval when values of arr changed by procedure
;;   tagpix, arr, w, tagval
;;   messproc, arr
;;   arr[w] = tagval
pro whereback, arr, w, tagval, rmsfrac=rmsfrac
  
  if n_elements(rmsfrac) ne 0 then tagval = stdev(arr[where(arr ne 0)])*rmsfrac
  
  if n_elements(tagval) eq 0 then tagval = 1e-30

  w = where(arr gt -2*tagval and arr lt tagval*2)

end
