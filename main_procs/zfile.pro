;; Written by Zahed Wahhaj, Dec 14, 2010
;; Return the base , extenstion or path of a file or list of files
;; For examples/syntax do: IDL> zfile() 
;; files: either a single filename, and array of file names or a text
;;        file with a list of files
;; list: if this is 1, then 'files' is a text file with a list of
;;       filenames
;; fromlist: returns the original filenames read in from the text listfile.
 
function zfile, files, part, list=list,fromlist=fromlist
  
  if n_elements(list) then begin ;; if its a text file of a list of files read it in
     readtable,files, file,del=' '
     fromlist = file
  endif else file=files
  
  if n_elements(files) eq 0 then begin
     print, "Works with a scalar an array or a list of files"
     print, "Example: zfile('dir1/dir2/file.ext',0) -> /dir1/dir2"
     print, "Example: zfile('dir1/dir2/file.ext',1) -> file.ext"
     print, "Example: zfile('dir1/dir2/file.ext',2) -> file"
     print, "Example: zfile('dir1/dir2/file.ext',3) -> .ext"
     print, "Example: zfile('dir1/dir2/file.ext',4) -> /dir1/dir2/file"
     print, "The parts 0,1,2... also work in the cases below:"
     print, "zfile(array) -> file1, file2 ....fileN"
     print, "zfile('list.txt',/list) -> file1, file2 ....fileN"
     return,0
  endif

     if n_elements(part) eq 0 then part=1 ;; default return filename

     num =  n_elements(file) ;; how many filenames passed ? 

     for i=0,num-1 do begin ;; loop over filenames : 1 or N
        targ=file[i]
        case part of
           0: begin ;; get path
              pos=strsplit(targ,'/')
              nn = n_elements(pos) & last = pos[nn-1]
              res = strmid(targ,0,last)
           end
           1: begin ;; get filename
              bits=strsplit(targ,'/',/ex)
              nn = n_elements(bits) & res = bits(nn-1)
           end
           2: begin ;; get filebase
              bits=strsplit(targ,'/',/ex)
              nn = n_elements(bits) & res = bits(nn-1) ;;now res = filename
              bits=strsplit(res,'.',/ex)
              nn = n_elements(bits) & res = bits(nn-2) ;;now res = filebase 
           end
           3: begin ;; get file_ext
              bits=strsplit(targ,'/',/ex)
              nn = n_elements(bits) & res = bits(nn-1) ;;now res = filename
              bits=strsplit(res,'.',/ex)
              nn = n_elements(bits) & res = '.'+bits(nn-1) ;;now res = file_ext 
           end
           4: begin ;; get path+filebase
              pos=strsplit(targ,'.')
              last = n_elements(pos)-1
              pos=pos[last]
              res = strmid(targ, 0, pos-1)
           end
        endcase
        push,results,res,i
     endfor

     if num eq 1 then return,results[0] $ ;; if just a single element return as scalar
     else return, results

  end
