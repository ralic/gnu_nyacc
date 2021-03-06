;;; lang/matlab/body.scm
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


;; @deffn add-file-attr tl => tl
;; Given a tagged-list this routine adds an attribute @code{(file basename)}
;; which is the basename (with @code{.m} removed) of the current input.
;; This is used for the top-level node of the matlab parse tree to indicate
;; from which file the script or function file originated.  For example,
;; @example
;; (function-file (@ (file "myftn")) (fctn-defn (ident "myftn") ...
;; @end example
(define (add-file-attr tl)
  (let ((fn (port-filename (current-input-port))))
    (if fn (tl+attr tl 'file (basename fn ".m")) tl)))

;;; === lexical analyzer

(define (matlab-read-string ch)
  (if (not (eq? ch #\')) #f
      (let iter ((cl '()) (ch (read-char)))
	(cond ((eq? ch #\\)
	       (let ((c1 (read-char)))
		 (if (eq? c1 #\newline)
		     (iter cl (read-char))
		     (iter (cons c1 cl) (read-char)))))
	      ((eq? ch #\')
	       (let ((nextch (read-char)))
		 (if (eq? #\' nextch)
		     (iter (cons ch cl) (read-char))
		     (begin
		       (unread-char nextch)
		       (cons '$string (list->string (reverse cl)))))))
	      (else (iter (cons ch cl) (read-char)))))))

(define matlab-read-comm (make-comm-reader '(("%" . "\n"))))

;; elipsis reader "..." whitespace "\n"
(define (elipsis? ch)
  (if (eqv? ch #\.)
      (let ((c1 (read-char)))
	(if (eqv? c1 #\.)
	    (let ((c2 (read-char)))
	      (if (eqv? c2 #\.)
		  (cons (string->symbol "...") "...")
		  (begin (unread-char c2) (unread-char c1) #f)))
	    (begin (unread-char c1) #f)))
      #f))

(define (skip-to-next-line)
  (let iter ((ch (read-char)))
    (cond
     ((eof-object? ch) ch)
     ((eqv? ch #\newline) (read-char))
     (else (iter (read-char))))))
  
(define gen-matlab-lexer

  (let* ((match-table mtab)
	 (read-string matlab-read-string)
	 (read-comm matlab-read-comm)
	 (read-ident read-c-ident)
	 (space-cs (string->char-set " \t\r\f"))
	 ;;
	 (strtab (filter-mt string? match-table)) ; strings in grammar
	 (kwstab (filter-mt like-c-ident? strtab))  ; keyword strings =>
	 (keytab (map-mt string->symbol kwstab))  ; keywords in grammar
	 (chrseq (remove-mt like-c-ident? strtab))  ; character sequences
	 (symtab (filter-mt symbol? match-table)) ; symbols in grammar
	 (chrtab (filter-mt char? match-table))	  ; characters in grammar
	 ;;
	 (read-chseq (make-chseq-reader chrseq))
	 (assc-$ (lambda (pair) (cons (assq-ref symtab (car pair)) (cdr pair))))
	 )
    (lambda ()
      (let ((qms #f) (bol #t))		; qms: quote means space
	(lambda ()
	  (let iter ((ch (read-char)))
	    (cond
	     ((eof-object? ch) (assc-$ (cons '$end ch)))
 	     ((elipsis? ch) (iter (skip-to-next-line)))
	     ((eqv? ch #\newline)
	      (set! bol #t) (cons (assq-ref chrtab #\newline) "\n"))
	     ((char-set-contains? space-cs ch) (iter (read-char)))
	     ((read-comm ch bol) => assc-$)
	     (bol (set! bol #f) (iter ch))
	     ((read-ident ch) =>	; returns string
	      (lambda (s)
		(set! qms #f)
		(or (and=> (assq-ref keytab (string->symbol s))
			   (lambda (tval) (cons tval s)))
		    (assc-$ (cons '$ident s)))))
	     ((read-c-num ch) => (lambda (p) (set! qms #f) (assc-$ p)))
	     ((eqv? ch #\') (if qms (assc-$ (read-string ch)) (read-chseq ch)))
	     ((read-chseq ch) =>
	      (lambda (p)
		(cond ((memq ch '(#\= #\, #\()) (set! qms #t))
		      (else (set! qms #f)))
		p))
	     ((assq-ref chrtab ch) => (lambda (t) (cons t (string ch))))
	     (else (cons ch (string ch)))))))))) ; else should be error

;;; --- last line ---
