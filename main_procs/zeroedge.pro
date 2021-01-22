;; Written by Zahed Wahhaj,  Mar 20,, 2020
;;
;; set image edges to zero, by a certain border width in pixels
;; background region is defined by zero values pixels
;; width = border width in pixels too set to zero

function zeroedge, img, width

  temp = img
  sz = (size(temp))[1]
  cc = (sz-1)/2.
  if n_elements(width) eq 0 then width=10
  zf= (1-width/cc)

  ;;shrink image
  temp2 = rot(temp,0,zf,cc,cc,/piv,c=-0.5,missing=0)
  
  whereback,temp,wback
  whereback,temp2,wback2  
  wz = setDifference(wback2,wback)

  temp3 = img
  temp3[wz]=0

return, temp3

end
