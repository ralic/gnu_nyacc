;;; examples/nyacc/util.scm
;;;
;;; Copyright (C) 2015 Matthew R. Wette
;;;
;;; This software is covered by the GNU GENERAL PUBLIC LICENCE, Version 3,
;;; or any later version published by the Free Software Foundation.  See the
;;; file COPYING included with the nyacc distribution.")

;; runtime utilities for the parsers -- needs work

(define-module (lang util)
  #:export (lang-crn
	    make-tl
	    tl-append tl-insert
	    tl+attr tl->list
            fmterr)
  )

(define lang-crn "Copyright (C) 2015 Matthew R. Wette

This software is covered by the GNU GENERAL PUBLIC LICENCE, Version 3,
or any later version published by the Free Software Foundation.  See the
file COPYING included with the this distribution.")


(define (fmterr fmt . args)
  (apply simple-format (current-error-port) fmt args))

;; @item make-tl tag [item item ...]
;; Create a tagged-list structure.
(define (make-tl tag . rest)
  (let iter ((tail tag) (l rest))
    (if (null? l) (cons '() tail)
	(iter (cons (car l) tail) (cdr l)))))

;; @item tl-insert tl item
;; Insert item at front of tagged list (but after tag).
(define (tl-insert tl item)
  (cons (cons item (car tl)) (cdr tl)))
(define (tl-insert! tl item)
  (set-car! tl (cons item (car tl)))
  tl)

;; @item tl-append tl item ...
;; Append item at end of tagged list.
(define (tl-append tl . rest)
  (cons (car tl)
	(let iter ((tail (cdr tl)) (items rest))
	  (if (null? items) tail
	      (iter (cons (car items) tail) (cdr items))))))
(define (tl-append! tl item) ;; NEEDS FIXUP
  (set-cdr! tl (cons item (cdr tl)))
  tl)

;; @item tl+attr tl key val)
;; Add an attribute to a tagged list.  Return the tl.
;; @example
;; (tl+attr tl 'type "int")
;; @end example
(define (tl+attr tl key val)
  (tl-insert tl (cons '@ (list key val))))

;; @item tl->list tl
;; Convert a tagged list structure to a list.  This collects added attributes
;; and puts them right after the (leading) tag, resulting in something like
;; @example
;; (<tag> (@ <attr>) <rest>)
;; @end example
(define (tl->list tl)
  (let ((heda (car tl))
	(head (let iter ((head '()) (attr '()) (tl-head (car tl)))
		(if (null? tl-head)
		    (if (pair? attr)
			(cons (cons '@ attr) (reverse head))
			(reverse head))
		    (if (and (pair? (car tl-head)) (eq? '@ (caar tl-head)))
			(iter head (cons (cdar tl-head) attr) (cdr tl-head))
			(iter (cons (car tl-head) head) attr (cdr tl-head)))))))
    (let iter ((tail '()) (tl-tail (cdr tl)))
      (if (pair? tl-tail)
	  (iter (cons (car tl-tail) tail) (cdr tl-tail))
	  (cons tl-tail (append head tail))))))

;; @item tl-merge tl tl1
;; Merge guts of phony-tl @code{tl1} into @code{tl}.
(define (tl-merge tl tl1)
  (error "not implemented (yet)")
  )

#|
;; tl: tagged-list, with make, append, insert, ->list
(define (make-tl0 . rest)
  (if (null? rest)
      (cons '() #f)
      (cons rest (last-pair rest))))

(define (tl0-app! tl . rest)
  (set-cdr! (cdr tl) rest)		; append items to list
  (set-cdr! tl (last-pair rest))	; set tail
  tl)					; return list
(define tl0-append! tl0-app!)

(define (tl0-ins+1! tl item)
  (let ((pair (cons item (cdar tl))))
    (set-cdr! (car tl) pair)
    (if (eq? (car tl) (cdr tl)) (set-cdr! tl pair))
    tl))				; return list
(define tl0-insert! tl0-ins+1!)

(define (tl0->list tl)
  (car tl))
|#

;;; --- last line
