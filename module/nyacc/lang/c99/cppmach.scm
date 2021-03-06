;;; lang/c99/cppmach.scm
;;;
;;; Copyright (C) 2015,2016 Matthew R. Wette
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by 
;;; the Free Software Foundation, either version 3 of the License, or 
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of 
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; C preprocessor expression parser generator

(define-module (nyacc lang c99 cppmach)
  #:export (cpp-spec cpp-mach gen-cpp-files)
  #:use-module (nyacc lalr)
  #:use-module (nyacc parse)
  #:use-module (nyacc lex)
  #:use-module (nyacc lang util)
  #:use-module ((srfi srfi-43) #:select (vector-map))
  #:use-module (rnrs arithmetic bitwise)
  )

(define cpp-spec
  (lalr-spec
   (notice (string-append "Copyright (C) 2016,2017 Matthew R. Wette"
			  lang-crn-lic))
   (expect 0)
   (start conditional-expression)
   (grammar
    (conditional-expression
     (logical-or-expression)
     (logical-or-expression "?" logical-or-expression ":" conditional-expression
			    ($$ `(cond-expr ,$1 ,$3 ,$5))))
    (logical-or-expression
     (logical-and-expression)
     (logical-or-expression "||" logical-and-expression ($$ `(or ,$1 ,$3))))
    (logical-and-expression
     (bitwise-or-expression)
     (logical-and-expression "&&" bitwise-or-expression ($$ `(and ,$1 ,$3))))
    (bitwise-or-expression
     (bitwise-xor-expression)
     (bitwise-or-expression "|" bitwise-xor-expression
			    ($$ `(bitwise-or ,$1 ,$3))))
    (bitwise-xor-expression
     (bitwise-and-expression)
     (bitwise-xor-expression "^" bitwise-and-expression
			     ($$ `(bitwise-xor ,$1 ,$3))))
    (bitwise-and-expression
     (equality-expression)
     (bitwise-and-expression "&" equality-expression
			     ($$ `(bitwise-and ,$1 ,$3))))
    (equality-expression
     (relational-expression)
     (equality-expression "==" relational-expression ($$ `(equal ,$1 ,$3)))
     (equality-expression "!=" relational-expression ($$ `(noteq ,$1 ,$3))))
    (relational-expression
     (shift-expression)
     (relational-expression "<" shift-expression ($$ `(lt ,$1 ,$3)))
     (relational-expression "<=" shift-expression ($$ `(le ,$1 ,$3)))
     (relational-expression ">" shift-expression ($$ `(gt ,$1 ,$3)))
     (relational-expression ">=" shift-expression ($$ `(ge ,$1 ,$3))))
    (shift-expression
     (additive-expression)
     (shift-expression "<<" additive-expression ($$ `(lshift ,$1 ,$3)))
     (shift-expression ">>" additive-expression ($$ `(rshift ,$1 ,$3))))
    (additive-expression
     (multiplicative-expression)
     (additive-expression "+" multiplicative-expression ($$ `(add ,$1 ,$3)))
     (additive-expression "-" multiplicative-expression ($$ `(sub ,$1 ,$3))))
    (multiplicative-expression
     (unary-expression)
     (multiplicative-expression "*" unary-expression ($$ `(mul ,$1 ,$3)))
     (multiplicative-expression "/" unary-expression ($$ `(div ,$1 ,$3)))
     (multiplicative-expression "%" unary-expression ($$ `(mod ,$1 ,$3))))
    (unary-expression
     (postfix-expression)
     ("-" unary-expression ($$ `(neg ,$2)))
     ("+" unary-expression ($$ `(pos ,$2)))
     ("!" unary-expression ($$ `(not ,$2)))
     ("~" unary-expression ($$ `(bitwise-not ,$2)))
     ("++" unary-expression ($$ `(pre-inc ,$2)))
     ("--" unary-expression ($$ `(pre-dec ,$2))))
    (postfix-expression
     (primary-expression)
     (postfix-expression "++" ($$ `(post-inc ,$1)))
     (postfix-expression "--" ($$ `(post-dec ,$1))))
    (primary-expression
     ($ident ($$ `(ident ,$1)))
     ($fixed ($$ `(fixed ,$1)))	; integer-constant
     ($chlit ($$ `(char ,$1)))	; char-constant
     ("defined" "(" $ident ")" ($$ `(defined ,$3)))
     ("defined" $ident ($$ `(defined ,$2)))
     ("(" expression-list ")" ($$ $2)))
    (expression-list
     (conditional-expression)
     (expression-list "," conditional-expression ($$ $3)))
    )))

(define cpp-mach
  (compact-machine
   (hashify-machine
    (make-lalr-machine cpp-spec))))

;;; =====================================

;; @item gen-cpp-files [dir] => #t
;; Update or generate the files @quot{cppact.scm} and @quot{cpptab.scm}.
;; If there are no changes to existing files, no update occurs.
(define (gen-cpp-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (write-lalr-actions cpp-mach (xtra-dir "cppact.scm.new"))
  (write-lalr-tables cpp-mach (xtra-dir "cpptab.scm.new"))
  (let ((a (move-if-changed (xtra-dir "cppact.scm.new")
			    (xtra-dir "cppact.scm")))
	(b (move-if-changed (xtra-dir "cpptab.scm.new")
			    (xtra-dir "cpptab.scm"))))
    (when (or a b) 
      (system (string-append "touch " (lang-dir "cpp.scm"))))))

;; --- last line ---
