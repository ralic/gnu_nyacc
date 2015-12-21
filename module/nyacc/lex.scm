;;; nyacc/lex.scm
;;;
;;; Copyright (C) 2015 - Matthew R.Wette
;;; 
;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public
;;; License as published by the Free Software Foundation; either
;;; version 3 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this library; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

;; A module providing procedures for constructing lexical analyzers.

;; '$fixed '$float '$string '$chlit '$ident

;; todo: change lexer to return @code{cons-source} instead of @code{cons}

(define-module (nyacc lex)
  #:export (make-lexer-generator
	    make-ident-reader
	    make-comm-reader
	    make-string-reader
	    make-chseq-reader
	    make-num-reader
	    eval-reader
	    make-like-ident-p
 	    read-c-ident
 	    read-c-comm
	    read-c-string
	    read-c-chlit
	    read-c-num
	    like-c-ident?
	    filter-mt remove-mt map-mt make-ident-like-p 
	    c:ws c:if c:ir)
  #:use-module ((srfi srfi-1) #:select (fold remove))
  #:use-module (ice-9 pretty-print)
  )

;; @section Constructing Lexical Analyzers
;; The @code{lex} module provides a set of procedures to build lexical
;; analyzers.  The approach is to first build a set of @defn{readers} for 
;; MORE TO COME
;;
;; Readers are procecures that take one character (presumably from the
;; current-input-port) and determine try to make a match.   If a match is
;; made something is returned, with any lookaheads pushed back into the
;; input port.  If no match is made @code{#f} is returned and the input
;; argument is still the character to work on.
;;
;; Here are the procedures used:
;; @table @code

(define digit "0123456789")
(define ucase "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
(define lcase "abcdefghijklmnopqrstuvwxyz")

;; C lexemes are popular so include those.
(define c:ws (list->char-set '(#\space #\tab #\newline #\return)))
(define c:if (let ((cs (char-set #\_)))	; ident, first char
	       (string->char-set! ucase cs)
	       (string->char-set! lcase cs)))
(define c:ir (string->char-set digit c:if)) ; ident, rest chars
(define c:nx (string->char-set "eEdD"))	; number exponent

;; @item eval-reader reader string => result
;; For test and debug, this procedure will evaluate a reader on a string.
;; A reader is a procedure that accepts a single character argument intended
;; to match a specific character sequence.  A reader will read more characters
;; by evaluating @code{read-char} until it matches or fails.  If it fails, it
;; will pushback all characters read via @code{read-char} and return @code{#f}.
;; If it succeeds the input pointer will be at the position following the
;; last matched character.
(define (eval-reader reader string)
  (with-input-from-string string
    (lambda () (reader (read-char)))))

;; @item make-space-skipper chset => proc
;; This routine will generate a reader to skip whitespace.
(define (make-space-skipper chset)
  (lambda (ch)
    (if (char-set-contains? chset ch)
	(let iter ((ch (read-char)))
	  (cond
	   ((char-set-contains? chset ch)
	    (iter (read-char)))
	   (else
	    (unread-char ch)
	    #t)))
	#f)))
	 
;; @item skip-c-space ch => #f|#t
;; If @code{ch} is space, skip all spaces, then return @code{#t}, else
;; return @code{#f}.
(define skip-c-space (make-space-skipper c:ws))


;; @item make-ident-reader cs-first cs-rest => ch -> #f|string
;; For identifiers, given the char-set for first character and the char-set
;; for following characters, return a return a reader for identifiers.
;; The reader takes a character as input and returns @code{#f} or @code{string}.
(define (make-ident-reader cs-first cs-rest)
  (lambda (ch)
    (if (char-set-contains? cs-first ch)
	(let iter ((chl (list ch)) (ch (read-char)))
	  (cond
	   ((eof-object? ch)
	    (if (null? chl) #f
		(list->string (reverse chl))))
	   ((char-set-contains? cs-rest ch)
	    (iter (cons ch chl) (read-char)))
	   (else (unread-char ch)
		 (list->string (reverse chl)))))
	#f)))

;; @item read-c-ident ch => #f|string
;; If ident pointer at following char, else (if #f) ch still last-read.
(define read-c-ident (make-ident-reader c:if c:ir))

;; @item make-ident-like-p ident-reader
;; Generate a predicate, from a reader, that determines if a string qualifies
;; as an identifier.
(define (make-like-ident-p reader)
  (lambda (s) (and (string? s) (eval-reader reader s))))
(define make-ident-like-p make-like-ident-p)
(define like-c-ident? (make-like-ident-p read-c-ident))


;; @item make-string-reader delim
;; Generate a reader that uses @code{delim} as delimiter for strings.
;; TODO: need to handle matlab-type strings.
;; TODO: need to handle multiple delim's (like python)
(define (make-string-reader delim) ;; #:xxx
  (lambda (ch)
    (if (eq? ch delim)
	(let iter ((cl '()) (ch (read-char)))
	  (cond ((eq? ch #\\)
		 (let ((c1 (read-char)))
		   (if (eq? c1 #\newline)
		       (iter cl (read-char))
		       (iter (cons* c1 cl) (read-char)))))
		((eq? ch delim) (cons '$string (list->string (reverse cl))))
		(else (iter (cons ch cl) (read-char)))))
	#f)))

;; @item read-c-string dquote-char => c-string
;; Read a C-code string.  Output to code is @code{write} not @code{display}.
;; Return #f if char is not @code{"}.
(define (read-c-string ch)
  (if (not (eq? ch #\")) #f
      (let iter ((cl '()) (ch (read-char)))
	(cond ((eq? ch #\\)
	       (let ((c1 (read-char)))
		 (iter 
		  (case c1
		    ((#\newline) cl)
		    ((#\n) (cons #\newline cl))
		    ((#\t) (cons #\tab cl))
		    ((#\b) (cons #\backspace cl))
		    ((#\r) (cons #\return cl))
		    ((#\f) (cons #\page cl))
		    ((#\v) (cons #\vtab cl))
		    ((#\\) (cons #\\ cl))
		    ((#\') (cons #\' cl))
		    ((#\") (cons #\" cl))
		    ((#\a) (cons #\alarm cl))
		    ((#\?) (cons #\esc cl))
		    (else (iter (cons c1 cl) (read-char))))
		  (read-char))))
	      ((eq? ch #\") (cons '$string (list->string (reverse cl))))
	      (else (iter (cons ch cl) (read-char)))))))


;; @item make-chlit-reader
;; Generate a reader for character literals. NOT DONE.
;; For C, this reads @code{'c'} or @code{'\n'}.
(define (make-chlit-reader . rest) (error "NOT IMPLEMENTED"))

;; @item read-c-chlit ch
;; @example
;; ... 'c' ... => (read-c-chlit #\') => '($ch-lit . #\c)
;; @end example
(define (read-c-chlit ch)
  (if (not (eqv? ch #\')) #f
      (let ((c1 (read-char)) (c2 (read-char)))
	(if (eqv? c1 #\\)
	    (let ((c3 (read-char)))
	      (case c2
		;;((#\a) (cons '$chlit "\a")) ; alert
		;;((#\b) (cons '$chlit "\b")) ; backspace
		;;((#\f) ; formfeed
		((#\n) (cons '$chlit "\n")) ; newline
		((#\t) (cons '$chlit "\t")) ; horizontal tab
		((#\v) (cons '$chlit  "\v")) ; verticle tab
		((#\\ #\' #\" #\?) (cons '$chlit (string c2)))
		(else (error "bad escape sequence"))))
	    (cons '$chlit (string c1))))))

;; @item make-num-reader
;; integer decimal(#t/#f) fraction exponent looking-at
;; i, f and e are lists of characters
;; returns pair ('$fixed . "123") or ('$float . "1.3e0")
;;           or ERROR? (dot by itself)
;; will add "0" before or after dot but otherwise same
;; may want to replace "eEdD" w/ "e"
;; 0: start; 1: p-i; 2: p-f; 3: p-e-sign; 4: p-e-d; 5: packup
;; Removed support for leading '.' to be a number.
;; TODO: add 0x reader
(define (make-num-reader)
  (let ((fix-dot (lambda (l) (if (char=? #\. (car l)) (cons #\0 l) l))))
    (lambda (ch1)
      (let iter ((chl '()) (ty #f) (st 0) (ch ch1))
	(case st
	  ((0)
	   (cond
	    ((eof-object? ch) (iter chl ty 5 ch))
	    ;;((char=? #\. ch) (iter (list #\. #\0) '$fixed 2 (read-char)))
	    ((char-numeric? ch) (iter chl '$fixed 1 ch))
	    (else #f)))
	  ((1)
	   (cond
	    ((eof-object? ch) (iter chl ty 5 ch))
	    ((char-numeric? ch) (iter (cons ch chl) ty 1 (read-char)))
	    ((char=? #\. ch) (iter (cons #\. chl) '$float 2 (read-char)))
	    ((char-set-contains? c:if ch) (error "syntax1"))
	    (else (iter chl '$fixed 5 ch))))
	  ((2)
	   (cond
	    ((eof-object? ch) (iter chl ty 5 ch))
	    ((char-numeric? ch) (iter (cons ch chl) ty 2 (read-char)))
	    ((char-set-contains? c:nx ch)
	     (iter (cons ch (fix-dot chl)) ty 3 (read-char)))
	    ((char-set-contains? c:if ch) (error "syntax2"))
	    (else (iter (fix-dot chl) ty 5 ch))))
	  ((3)
	   (cond
	    ((eof-object? ch) (iter chl ty 5 ch))
	    ((or (char=? #\+ ch) (char=? #\- ch))
	     (iter (cons ch chl) ty 4 (read-char)))
	    ((char-numeric? ch) (iter chl ty 4 ch))
	    (else (error "syntax3"))))
	  ((4)
	   (cond
	    ((eof-object? ch) (iter chl ty 5 ch))
	    ((char-numeric? ch) (iter (cons ch chl) ty 4 (read-char)))
	    ((char-set-contains? c:if ch) (error "syntax4"))
	    (else (iter chl ty 5 ch))))
	  ((5)
	   (unless (eof-object? ch) (unread-char ch))
	   (cons ty (list->string (reverse chl)))))))))

;; @item read-c-num ch => #f|string
;; Reader for unsigned numbers as used in C (or close to it).
(define read-c-num (make-num-reader))

;;.@item si-map string-list ix => a-list
;; Convert list of strings to alist of char at ix and strings.
;; This is a helper for make-tree.
(define (si-map string-list ix)
  (let iter ((sal '()) (sl string-list))
    (cond
     ((null? sl) sal)
     ((= ix (string-length (car sl)))
      (iter (reverse (acons 'else (car sl) sal)) (cdr sl)))
     ((assq (string-ref (car sl) ix) sal) =>
      (lambda (pair)
        (set-cdr! pair (cons (car sl) (cdr pair)))
        (iter sal (cdr sl))))
     (else ;; Add (#\? . string) to alist.
      (iter (cons (cons (string-ref (car sl) ix) (list (car sl))) sal)
            (cdr sl))))))

;;.@item make-tree strtab -> tree
;; This routine takes an alist of strings and symbols and makes a tree
;; that parses one char at a time and provide @code{'else} entry for
;; signaling sequence found.  That is, if @code{("ab" . 1)} is an entry
;; then a chseq-reader (see below) would stop at @code{"ab"} and
;; return @code{1}.
(define (make-tree strtab)
  (define (si-cnvt string-list ix)
    (map (lambda (pair)
	   (if (pair? (cdr pair))
	       (cons (car pair) (si-cnvt (cdr pair) (1+ ix)))
	       (cons (car pair) (assq-ref strtab (cdr pair)))))
	 (si-map string-list ix)))
  (si-cnvt (map car strtab) 0))

;; @item make-chseq-reader strtab
;; Given alist of pairs (string, token) return a function that eats chars
;; until (token . string) is returned or @code{#f} if no match is found.
(define (make-chseq-reader strtab)
  ;; This code works on the assumption that the else-part is always last
  ;; in the list of transitions.
  (let ((tree (make-tree strtab)))
    (lambda (ch)
      (let iter ((cl (list ch)) (node tree))
	(cond
	 ((assq-ref node (car cl)) => ;; accept or shift next character
	  (lambda (n)
	    (if (eq? (caar n) 'else) ; if only else, accept, else read on
		(cons (cdar n) (list->string (reverse cl)))
		(iter (cons (read-char) cl) n))))
	 ((assq-ref node 'else) => ; else exists, accept
	  (lambda (tok)
	    (unread-char (car cl))
	    (cons tok (list->string (reverse (cdr cl))))))
	 (else ;; reject
	  (let pushback ((cl cl))
	    (unless (null? (cdr cl))
	      (unread-char (car cl))
	      (pushback (cdr cl))))
	  #f))))))

;; @item make-comm-reader comm-table [#:eat-newline #t] => lambda
;; comm-table is list of cons for (start . end) comment
;; e.g. ("--" "\n") ("/*" "*/")
;; test with "/* hello **/"
;; If @code{eat-newline} is specified as true then for read comments 
;; ending with a newline a newline swallowed with the comment.
(define* (make-comm-reader comm-table #:key eat-newline)
  (let ((tree (make-tree comm-table)))
    (lambda (ch)
      (letrec
	  ((match-beg ;; match start of comment, return end-string
	    (lambda (cl node)
	      (cond
	       ((assq-ref node (car cl)) => ;; shift next character
		(lambda (n) (match-beg (cons (read-char) cl) n)))
	       ((assq-ref node 'else) =>
		(lambda (res) (unread-char (car cl)) res)) ; yuck?
	       (else
		(let pushback ((cl cl))
		  (unless (null? (cdr cl))
		    (unread-char (car cl))
		    (pushback (cdr cl))))
		#f))))
	   (find-end ;; find end of comment, return comment
	    ;; cl: comm char list; sl: shift list; il: input list;
	    ;; ps: pattern string; px: pattern index
	    (lambda (cl sl il ps px)
	      (cond
	       ((eq? px (string-length ps))
		(if (and (not eat-newline) (eq? #\newline (car sl)))
		    (unread-char #\newline))
		;;(cons '$comment (list->string (reverse cl))))
		(if (eqv? (car cl) #\cr) ;; remove trailing \r 
		    (cons '$comment (list->string (reverse (cdr cl))))
		    (cons '$comment (list->string (reverse cl)))))
	       ((null? il) (find-end cl sl (cons (read-char) il) ps px))
	       ((eof-object? (car il)) (error "open comment"))
	       ((eq? (car il) (string-ref ps px))
		(find-end cl (cons (car il) sl) (cdr il) ps (1+ px)))
	       (else
		(let ((il1 (fold cons il sl)))
		  (find-end (cons (car il1) cl) '() (cdr il1) ps 0)))))))
	(let ((ep (match-beg (list ch) tree)))
	  (if ep (find-end '() '() (list (read-char)) ep 0) #f))))))

(define read-c-comm (make-comm-reader '(("/*" . "*/") ("//" . "\n"))))

;; @item filter-mt p? al => al
;; Filter match-table based on cars of al.
(define (filter-mt p? al) (filter (lambda (x) (p? (car x))) al))

;; @item remove-mt p? al => al
;; Remove match-table based on cars of al.
(define (remove-mt p? al) (remove (lambda (x) (p? (car x))) al))

;; @item map-mt f al => al
;; Map cars of al.
(define (map-mt f al) (map (lambda (x) (cons (f (car x)) (cdr x))) al))

;; @item make-lexer-generator match-table => lexer-generator
;; @example
;; (define gen-lexer (make-lexer-generator #:ident-reader my-id-rdr))
;; (with-input-from-file "foo" (parse (gen-lexer)))
;; @end example
;;
;; Return a thunk that returns tokens.
;; Change this to have user pass the following routines (optionally?)
;; read-num, read-ident, read-comm
;; reztab = reserved ($ident, $fixed, $float ...
;; chrtab = characters
;; comm-reader : if parser does not deal with comments must return #f
;;               but problem with character ..
;; match-table:
;; @enumerate
;; symbol -> (string . symbol)
;; reserved -> (symbol . symbol)
;; char -> (char . char)
;; @end enumerate
;; todo: add bol status
(define* (make-lexer-generator match-table
			       #:key ident-reader num-reader
			       string-reader chlit-reader
			       comm-reader comm-skipper
			       space-chars)
  (let* ((read-ident (or ident-reader (make-ident-reader c:if c:ir)))
	 (read-num (or num-reader (make-num-reader)))
	 (read-string (or string-reader (make-string-reader #\")))
	 (read-chlit (or chlit-reader (lambda (ch) #f)))
	 (read-comm (or comm-reader (lambda (ch) #f)))
	 (skip-comm (or comm-skipper (lambda (ch) #f)))
	 (spaces (or space-chars " \t\r\n"))
	 (space-cs (cond ((string? spaces) (string->char-set spaces))
			 ((list? spaces) (list->char-set spaces))
			 ((char-set? spaces) spaces)
			 (else (error "expecting string list or char-set"))))
	 ;;
	 (ident-like? (make-ident-like-p read-ident))
	 ;;
	 (strtab (filter-mt string? match-table)) ; strings in grammar
	 (kwstab (filter-mt ident-like? strtab))  ; keyword strings =>
	 (keytab (map-mt string->symbol kwstab))  ; keywords in grammar
	 (chrseq (remove-mt ident-like? strtab))  ; character sequences
	 (symtab (filter-mt symbol? match-table)) ; symbols in grammar
	 (chrtab (filter-mt char? match-table))	  ; characters in grammar
	 ;;
	 (read-chseq (make-chseq-reader chrseq))
	 (assc-$ (lambda (pair) (cons (assq-ref symtab (car pair)) (cdr pair))))
	 )
    (lambda ()
      (let ((bol #f))
	(lambda ()
	  (let iter ((ch (read-char)))
	    (cond
	     ((eof-object? ch) (assc-$ (cons '$end ch)))
	     ;;((eq? ch #\newline) (set! bol #t) (iter (read-char)))
	     ((char-set-contains? space-cs ch) (iter (read-char)))
	     ((and (eqv? ch #\newline) (set! bol #t) #f))
	     ((read-comm ch) =>
	      (lambda (p)
		(let ((was-bol bol))
		  (set! bol #f)
		  (cons (if was-bol '$lone-comm '$code-comm) (cdr p)))))
	     ((skip-comm ch) (iter (read-char)))
	     ((read-ident ch) =>
	      (lambda (s) (or (and=> (assq-ref keytab (string->symbol s))
				     (lambda (tval) (cons tval s)))
			      (assc-$ (cons '$ident s)))))
	     ((read-num ch) => assc-$)	  ; => $fixed or $float
	     ((read-string ch) => assc-$) ; => $string
	     ((read-chlit ch) => assc-$)  ; => $chlit
	     ((read-chseq ch) => identity)
	     ((assq-ref chrtab ch) => (lambda (t) (cons t (string ch))))
	     (else (cons ch ch))))))))) ; should be error

;; @end table

;; --- last line ---
