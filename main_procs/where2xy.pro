;;Written by Zahed Wahhaj, 2006.

pro where2xy, w, sz=sz, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, xcors=xcors, ycors=ycors

; takes a where array and returns coordinate info about the points in it
xcors = w mod sz
ycors = w/sz
xmin = min(xcors)
ymin = min(ycors)
xmax = max(xcors)
ymax = max(ycors)

end
