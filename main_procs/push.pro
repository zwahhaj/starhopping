;; Written by Zahed Wahhaj.
pro push, stack, val, clear,empty=empty
  ;; if using in a set clear to loop variable so that it clears first
  case n_elements(empty) of 
     0: if n_elements(stack) eq 0 or (n_elements(clear) ne 0 and keyword_set(clear) eq 0) then stack = val $
     else stack = [stack, val]
     1: if n_elements(stack) then junk = temporary(stack)
  endcase
end
