function fname_addtag, fname, tag
  base = zfile(fname,4)
  ext = zfile(fname,3)
  return, base+tag+ext
end
