function immult, im1, im2

; multiply 2 images (or 1 image and 1 scalar), maintaining BADVAL masking
; 05/22/98 MCL

BADVAL = -1e6

w = where(im1 eq BADVAL or im2 eq BADVAL, nw)
ans = im1*im2
if (nw gt 0) then ans(w) = BADVAL
return, ans

end
