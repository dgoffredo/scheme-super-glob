
; -*- mode: Clojure;-*-
; This is Chicken Scheme, not Clojure, but it looks better in github this way.

(module super-glob
  ; This module exports the function 'super-glob', which is an extension to the
  ; posix unit's 'glob' function that supports something similar to bash brace
  ; expansion.
  (super-glob)

  (import chicken scheme)
  (use srfi-1            ; lists
       srfi-13           ; strings
       clojurian-syntax  ; ->>
       matchable         ; pattern matching
       posix)            ; glob
  
  (define (cartesian-product . lists)
    ; Return a list of lists, where the i'th member of each list in the output
    ; is a member of the i'th list in lists.  Include every such list possible.
    ; For example,
    ; 
    ; (cartesian-product '(a b) '(1 2 3) '("hi"))
    ;
    ; returns
    ;
    ; ((a 1 "hi") (a 2 "hi") (a 3 "hi") (b 1 "hi") (b 2 "hi") (b 3 "hi"))
    ;
    ; This implementation is based on the StackOverflow answer
    ; <https://stackoverflow.com/a/20591545>.
    ;
    (fold-right (lambda (axis results)
                  (append-map (lambda (axis-value)
                                (map (lambda (result)
                                       (cons axis-value result))
                                     results))
                              axis))
                '(())
                lists))
  
  (define (glob* . patterns)
    ; 'glob', but without raising an error if any of the traversed directories
    ; doesn't exist.  Any erroneous pattern is skipped instead.
    (append-map (lambda (pattern)
                  (handle-exceptions _ '() ; an error (called _) yields '()
                    (glob pattern)))
                patterns))
  
  (define (super-glob components)
    ; Return a list of all paths matching the specified 'components' pattern,
    ; where 'components' is a list of path components, where each component is
    ; one of the following:
    ;
    ; - a string, indicating a normal glob pattern, e.g. "foo*bar" or "snacks?"
    ; - (list '? string), indicating zero or more of the string
    ; - (list string ...), indicating exactly one of the listed strings.
    ;
    ; For example,
    ;
    ; (define t "program")
    ; (super-glob `((? "/opt") "/xy" ("data" "logs") (? ,t) ,(conc t ".log*")))
    ;
    ; might return
    ;
    ; ("/opt/xy/logs/program/program.log"
    ;  "/xy/data/program.log.oldschool"
    ;  "/xy/logs/program/program.log.normal"
    ;  "/xy/logs/program/program.log.normal.gz")
    ;
    ; Note that this is equivalent to the brace expansion of
    ;
    ; {/opt,}/xy/{data,logs}{/program,}/program.log*
    ;
    (->> components
         (map (match-lambda
                [('? optional) (list "" optional)]
                [(options ...) options]
                [other         (list other)]))
         (apply cartesian-product)
         (map (lambda (parts) (string-join parts "/")))
         (apply glob*))))
