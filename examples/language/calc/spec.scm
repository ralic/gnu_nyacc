;;; nyacc/lang/calc/spec.scm
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

;; copy to language/calc/spec.scm

(define-module (language calc spec)
  #:export (calc)
  #:use-module (system base language)
  #:use-module (nyacc lang calc parser)
  #:use-module (nyacc lang calc compiler))

(define (calc-reader port env)
  (let ((iport (current-input-port)))
    (dynamic-wind
	(lambda () (set-current-input-port port))
	(lambda () (calc-parse #:debug #f))
	(lambda () (set-current-input-port iport)))))

(define-language calc
  #:title	"calc"
  #:reader	calc-reader
  #:compilers   `((tree-il . ,compile-tree-il))
  #:printer	write)

;; --- last line ---
