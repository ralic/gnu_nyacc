;;; javascript specification for Guile
;;;
;;; Copyright (C) 2015 Matthew R. Wette
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


;; copy to language/javascript/spec.scm

(define-module (language javascript spec)
  #:use-module (language javascript jslib)
  #:export (javascript js-xml->tree-il-ext)
  #:use-module (system base language)
  #:use-module (nyacc lang javascript separser)
  #:use-module (sxml match)
  #:use-module (sxml fold)
  #:use-module ((srfi srfi-1) #:select (fold))
  #:use-module (language tree-il)
  #:use-module (ice-9 pretty-print)
  )

(define (x-assn rhs op lhs junk)
  (case (car op)
    ((assign) `(set! ,lhs ,rhs))
    ((add-assign) `(set! ,lhs (apply (@@ (jslib) JS+) ,lhs ,rhs)))
    (else
     (simple-format (current-error-port) "\nUNKNOWN OP: ~S\n\n" op)
     '(unknown))))

;; @heading variable scope
;; Variables in the compiler are kept in a scope-stack with the highest
;; level being the current module.  Why do I convert to xxx?

(define (add-lexical name dict)
  (acons name `(lexical ,(string->symbol name) ,(gensym "JS~")) dict))

;; Add toplevel to dict.
(define (add-toplevel name dict)
  (acons name `(toplevel ,(string->symbol name)) dict))

;; Add lexcial or toplevel based on level.
(define (add-reference name dict)
  (if (> (assq-ref dict '@l) 1)
      (add-lexical name dict)
      (add-toplevel name dict)))

(define (push-level dict)
  (list (cons '@l (1+ (assq-ref dict '@l))) (cons '@P dict)))
(define (pop-level dict)
  (assq-ref dict '@P))

(define (lookup-lex name dict)
  (cond
   ((not dict) #f)
   ((null? dict) #f)
   ((assoc-ref dict name))
   (else (lookup-lex name (assoc-ref dict '@P)))))

(define (lookup name dict)
  (or (lookup-lex name dict)
      (let* ((sym (string->symbol name))
	     (var (module-variable (current-module) sym)))
	(if (not var) (error "not found:" sym))
	`(toplevel ,sym))))

;; body needs a line to build "var arguments" from Array(@args)
;; Right now args is the gensym of the rest argument named @code{@@args}.
(define (make-function name args body)
  (let ((tagsym (gensym "JS~")) (valsym (gensym "JS~")))
    `(define ,(cadr name)
       (lambda ((name . ,(cadr name)))
	 (lambda-case ((() #f @args #f () (,args))
		       (prompt
			(const return)	; tag
			,body		; body
			(lambda-case	; handler
			 (((tag val) #f #f #f () (,tagsym ,valsym))
			  (lexical val ,valsym))))))))))

;; In the case where we pick off ``low hanging fruit'' we need to coordinate
;; the actions of the up and down handlers.   The down handler will provide
;; a kid-seed in order and generate a null list.  The up handler, upon seeing
;; a null list, will just incorporate the kids w/o the normal reverse.

(define (fD tree seed dict) ;; => tree seed dict
  ;; This handles branches as we go down the tree.  We do two things here:
  ;; @enumerate
  ;; @item Pick off low hanging fruit: items we can quickly convert in entirety.
  ;; @item Add symbols to the dictionary.  This keeps track of lexical scope.
  ;; @end enumerate
  ;;(simple-format #t "fD: ~S\n" tree)
  (simple-format (current-error-port) "fD: seed=~S\n" seed)
  (pretty-print tree (current-error-port))
  (sxml-match tree
    ((NullLiteral)
     (values '() `JS-null dict))
	     
    ((Identifier ,name)
     (values '() (lookup name dict) dict))
    
    ((PrimaryExpression (Identifier ,name))
     (let ((ident (lookup name dict)))
       (if (not ident) (error "identifier not found" name)) 
       (values '() ident dict)))

    ((PrimaryExpression (StringLiteral ,str))
     (values '() `(const ,str) dict))

    ((PrimaryExpression (NumericLiteral ,val))
     (values '() `(const ,(string->number val)) dict))

    ((obj-ref ,object ,ident)
     ;; Convert the tree: obj.ref ==> obj["ref"]
     (values
      `(ary-ref ,object (PrimaryExpression (StringLiteral ,(cadr ident))))
      '() dict))

    ((VariableDeclaration (Identifier ,name) ,rest ...)
     (values tree '() (add-reference name dict)))

    ((FunctionDeclaration (Identifier ,name) ,rest ...)
     (values tree '() (push-level (add-reference name dict))))
    
    ((FormalParameterList ,idlist ...)
     ;; For all functions we just use rest arg and then express each
     ;; var reference as (list-ref @args index)
     ;; Another option is to use case-lambda ...
     (let* ((args (add-lexical "@args" dict))
	    (gsym (list-ref (car args) 3)) ; need gensym ref
	    (dikt (fold
		   (lambda (name indx seed)
		     (acons name `(apply (toplevel list-ref)
					 (lexical @args ,gsym)
					 (const ,indx))
			    seed))
		   args
		   (map cadr idlist)
		   (let iter ((r '()) (n (length idlist))) ;; n-1 ... 0
		     (if (zero? n) r (iter (cons (1- n) r) (1- n))))
		   ))
	    )
       (values tree '() dikt)))
    
    ((SourceElements ,elts ...)
     (values tree '() (push-level dict)))

    (,otherwise
     (values tree '() dict))
    ))

(define (fU tree seed dict kseed kdict) ;; => seed dict
  (simple-format (current-error-port) "fU: kseed=~S\n" kseed)
  (pretty-print tree (current-error-port))
  ;; This routine rolls up processes leaves into the current branch.
  (if
   (null? tree) (values (cons kseed seed) dict)
   (case (car tree)

     ((*TOP*)
      (simple-format (current-error-port) "\n  tree-js: kseed=~S\n\n" kseed)
      (values (car kseed) dict))
     
     ((CallExpression)
      (values (cons `(apply ,@(reverse kseed)) seed) dict))

     ((ArgumentList)
      (values (append kseed seed) dict))

     ((ary-ref)
      (values (cons `(apply (@@ (nyacc jslib) lkup) ,(cadr kseed) ,(car kseed))
		    seed)
	      dict))

     ((obj-ref) ;; ???
      (values (cons `(apply (@@ (nyacc jslib) lkup) ,(cadr kseed) ,(car kseed))
		    seed)
	      dict))

     ((add)
      (values (cons '(@@ (nyacc jslib) JS:+) seed) dict))
      
     ((AssignmentExpression)
      (values (cons (apply x-assn kseed) seed) dict))

     ((FormalParameterList)
      ;; We build the function with the rest argument @code{@@args}.
      (values seed kdict))

     ((VariableStatement VariableDeclarationList)
      (values (append (reverse kseed) seed) kdict))

     ((VariableDeclaration)
      (simple-format (current-error-port) "  VarDecl: seed=~S\n\n" seed)
      (values
       (cons
	(if (= 3 (length kseed))
	    `(define ,(cadr (list-ref kseed 1)) ,(list-ref kseed 0))
	    `(define ,(cadr (list-ref kseed 0)) ,(if #f #f)))
	seed)
       kdict))

     ((Initializer)
      (values (cons (car kseed) seed) dict))

     ((ExpressionStatement)
      (values (cons (car kseed) seed) dict))

     ((EmptyStatement)
      (values seed dict))

     ((ReturnStatement) ;; will need a prompt for return, until optimized?
      (values (cons `(abort (const return) (,kseed) (const ())) seed)
	      dict))

     ((FunctionDeclaration)
      (values
       (let ((name (cadr kseed))
	     (args (list-ref (lookup "@args" kdict) 2))
	     (body (car kseed)))
	 (cons (make-function name args body) seed))
       kdict))

     ((SourceElements)
      (values (cons `(begin ,@(reverse kseed)) seed) dict))

     ((Program)
      (values (car kseed) dict))
     
     (else
      (cond
       ((null? seed) (values (reverse kseed) dict))
       ;;((null? kseed) (values (cons (car tree) seed) dict)) ;; ???
       (else (values (cons (reverse kseed) seed) dict)))))))

(define (fH leaf seed dict)
  (values (cons leaf seed) dict))

(define (js-reader port env)
  ;; probly a bit ugly...
  (let ((iport (current-input-port)))
    (dynamic-wind
	(lambda () (set-current-input-port port))
	(lambda () (cons '*TOP* (parse-js-selt #:debug #f)))
	(lambda () (set-current-input-port iport)))))

;; @deffn {Procedure} js-xml->tree-il-ext exp env opts
;; Compile javascript SXML tree to external tree-il representation.
;; This one is public because it's needed for debugging the compiler.
;; @end deffn
(define (js-xml->tree-il-ext exp env opts)
  (let ((vals (foldts*-values fD fU fH exp '() JSdict)))
    ;;(pretty-print exp)
    ;;(pretty-print vals)
    vals))

(define (js-sxml->tree-il exp env opts)
  (simple-format (current-error-port) "env=~S\n" env)
  (let* ((xrep (js-xml->tree-il-ext exp env opts))
	 (code (parse-tree-il (car xrep))))
    (values code env env)))

(define-language javascript
  #:title	"javascript"
  #:reader	js-reader
  #:compilers   `((tree-il . ,js-sxml->tree-il))
  #:printer	write
  )

;; --- last line ---
