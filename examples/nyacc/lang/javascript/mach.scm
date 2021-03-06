;;; lang/javascript/mach.scm
;;;
;;; Copyright (C) 2015,2017 Matthew R. Wette
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

(define-module (nyacc lang javascript mach)
  #:export (js-spec
	    js-mach
	    dev-parse-js
	    gen-js-files gen-se-files)
  #:use-module (nyacc lang util)
  #:use-module (nyacc lalr)
  #:use-module (nyacc parse)
  #:use-module (nyacc lex)
  #:use-module (nyacc util)
  #:use-module ((srfi srfi-43) #:select (vector-map))
  )

;; NOTE
;; The 'NoIn' variants are needed to avoid confusing the in operator 
;; in a relational expression with the in operator in a for statement.

;; NSI = "no semi-colon insertion"

;; need to deal with reserved keywords:
;; abstract boolean byte char class const debugger double enum export extends
;; final float goto implements import int interface long native package private
;; protected public short static super synchronized throws transient volatile

;; Not in the grammar yet: FunctionExpression

(define js-spec
  (lalr-spec
   (notice (string-append "Copyright 2016 Matthew R. Wette" lang-crn-lic))
   (prec< "then" "else")
   (start Program)
   (grammar

    (Literal
     (NullLiteral ($$ `(NullLiteral)))
     (BooleanLiteral ($$ `(BooleanLiteral ,$1)))
     (NumericLiteral ($$ `(NumericLiteral ,$1)))
     (StringLiteral ($$ `(StringLiteral ,$1)))
     )

    (NullLiteral ("null"))
    (BooleanLiteral ("true") ("false"))
    (NumericLiteral ($fixed) ($float))
    (StringLiteral ($string))
    ;;(DoubleStringCharacters ($string))
    ;;(SingleStringCharacters ($string))

    (Identifier ($ident ($$ `(Identifier ,$1))))

    ;; A.3
    (PrimaryExpression
     ("this" ($$ `(PrimaryExpression (this))))
     (Identifier ($$ `(PrimaryExpression ,$1)))
     (Literal ($$ `(PrimaryExpression ,$1)))
     (ArrayLiteral ($$ `(PrimaryExpression ,$1)))
     ;; until we get $with-prune working:
     #;(ObjectLiteral ($$ `(PrimaryExpression ,$1)))
     ("(" Expression ")" ($$ $2))
     )

    (ArrayLiteral
     ("[" Elision "]" ($$ `(ArrayLiteral (Elision ,(number->string $2)))))
     ("[" "]" ($$ `(ArrayLiteral)))
     ("[" ElementList "," Elision "]"
      ($$ `(ArrayLiteral (Elision ,(number->string $2)))))
     ("[" ElementList "," "]" ($$ `(ArrayLiteral ,$2)))
     )

    (ElementList
     (Elision AssignmentExpression
	      ($$ (make-tl 'ElementList `(Elision ,(number->string $2)))))
     (AssignmentExpression ($$ (make-tl 'ElementList $1)))
     (ElementList "," Elision AssignmentExpression
		  ($$ (tl-append $1 `(Elision ,(number->string $3)) $4)))
     (ElementList "," AssignmentExpression ($$ (tl-append $1 $3)))
     )

    (Elision
     ("," ($$ 1))
     (Elision "," ($$ (1+ $1)))
     )

    (ObjectLiteral
     ("{" "}" ($$ `(ObjectLiteral)))
     ("{" PropertyNameAndValueList "}" ($$ `(ObjectLiteral ,(tl->list $2))))
     )

    (PropertyNameAndValueList
     (PropertyName ":" AssignmentExpression
		   ($$ (make-tl `PropertyNameAndValueList $1 $3)))
     (PropertyNameAndValueList "," PropertyName ":" AssignmentExpression
		   ($$ (tl-append $1 $3 $5)))
     )

    (PropertyName
     (Identifier)
     (StringLiteral)
     (NumericLiteral)
     )

    (MemberExpression
     (PrimaryExpression)
     ;; Until we get $with-prune working:
     #;(FunctionExpression)
     (MemberExpression "[" Expression "]" ($$ `(ary-ref ,$3 ,$1)))
     (MemberExpression "." Identifier ($$ `(obj-ref ,$3 ,$1)))
     ("new" MemberExpression Arguments ($$ `(new ,$2 ,$3)))
     )

    (NewExpression
     (MemberExpression)
     ("new" NewExpression ($$ `(new ,$2)))
     )

    (CallExpression
     (MemberExpression Arguments ($$ `(CallExpression ,$1 ,$2)))
     (CallExpression Arguments ($$ `(CallExpression ,$1 ,$2)))
     (CallExpression "[" Expression "]" ($$ `(ary-ref ,$3 ,$1)))
     (CallExpression "." Identifier ($$ `(obj-ref ,$3 ,$1))) ;; see member expr
     )

    (Arguments
     ("(" ")" ($$ '(Arguments)))
     ("(" ArgumentList ")" ($$ `(Arguments ,(tl->list $2))))
     )

    (ArgumentList
     (AssignmentExpression ($$ (make-tl 'ArgumentList $1)))
     (ArgumentList "," AssignmentExpression ($$ (tl-append $1 $3)))
     )

    (LeftHandSideExpression
     (NewExpression)
     (CallExpression)
     )

    (PostfixExpression
     (LeftHandSideExpression)
     (LeftHandSideExpression ($$ (NSI)) "++" ($$ `(post-inc $1)))
     (LeftHandSideExpression ($$ (NSI)) "--" ($$ `(post-dec $1)))
     )

    (UnaryExpression
     (PostfixExpression)
     ("delete" UnaryExpression ($$ `(delete ,$2)))
     ("void" UnaryExpression ($$ `(void ,$2)))
     ("typeof" UnaryExpression ($$ `(typeof ,$2)))
     ("++" UnaryExpression ($$ `(pre-inc ,$2)))
     ("--" UnaryExpression ($$ `(pre-dec ,$2)))
     ("+" UnaryExpression ($$ `(pos ,$2)))
     ("-" UnaryExpression ($$ `(neg ,$2)))
     ("~" UnaryExpression ($$ `(??? ,$2)))
     ("!" UnaryExpression ($$ `(not ,$2)))
     )

    (MultiplicativeExpression
     (UnaryExpression)
     (MultiplicativeExpression "*" UnaryExpression
			       ($$ `(mul ,$1 ,$3)))
     (MultiplicativeExpression "/" UnaryExpression
			       ($$ `(div ,$1 ,$3)))
     (MultiplicativeExpression "%" UnaryExpression
			       ($$ `(mod ,$1 ,$3)))
     )

    (AdditiveExpression
     (MultiplicativeExpression)
     (AdditiveExpression "+" MultiplicativeExpression
			 ($$ `(add ,$1 ,$3)))
     (AdditiveExpression "-" MultiplicativeExpression
			 ($$ `(sub ,$1 ,$3)))
     )

    (ShiftExpression
     (AdditiveExpression)
     (ShiftExpression "<<" AdditiveExpression
		      ($$ `(lshift ,$1 ,$3)))
     (ShiftExpression ">>" AdditiveExpression
		      ($$ `(rshift ,$1 ,$3)))
     (ShiftExpression ">>>" AdditiveExpression
		      ($$ `(rrshift ,$1 ,$3)))
     )

    (RelationalExpression
     (ShiftExpression)
     (RelationalExpression "<" ShiftExpression
			   ($$ `(lt ,$1 ,$3)))
     (RelationalExpression ">" ShiftExpression
			   ($$ `(gt ,$1 ,$3)))
     (RelationalExpression "<=" ShiftExpression
			   ($$ `(le ,$1 ,$3)))
     (RelationalExpression ">=" ShiftExpression
			   ($$ `(ge ,$1 ,$3)))
     (RelationalExpression "instanceof" ShiftExpression
			   ($$ `(instanceof ,$1 ,$3)))
     ;; until we get $with-prune working:
     #;(RelationalInExpression)
     )
    #;(RelationalInExpression
     (RelationalExpression "in" ShiftExpression
			   ($$ `(in ,$1 ,$3)))
     )
    
    (EqualityExpression
     (RelationalExpression)
     (EqualityExpression "==" RelationalExpression
			 ($$ `(eq ,$1 ,$3)))
     (EqualityExpression "!=" RelationalExpression
			 ($$ `(neq ,$1 ,$3)))
     (EqualityExpression "===" RelationalExpression
			 ($$ `(eq-eq ,$1 ,$3)))
     (EqualityExpression "!==" RelationalExpression
			 ($$ `(neq-eq ,$1 ,$3)))
     )

    (BitwiseANDExpression
     (EqualityExpression)
     (BitwiseANDExpression "&" EqualityExpression
			   ($$ `(bit-and ,$1 ,$3)))
     )

    (BitwiseXORExpression
     (BitwiseANDExpression)
     (BitwiseXORExpression "^" BitwiseANDExpression
			   ($$ `(bit-xor ,$1 ,$3)))
     )

    (BitwiseORExpression
     (BitwiseXORExpression)
     (BitwiseORExpression "|" BitwiseXORExpression
			  ($$ `(bit-or ,$1 ,$3)))
     )

    (LogicalANDExpression
     (BitwiseORExpression)
     (LogicalANDExpression "&&" BitwiseORExpression
			   ($$ `(and ,$1 ,$3)))
     )

    (LogicalORExpression
     (LogicalANDExpression)
     (LogicalORExpression "||" LogicalANDExpression
			  ($$ `(or ,$1 ,$3)))
     )

    (ConditionalExpression
     (LogicalORExpression)
     (LogicalORExpression "?" AssignmentExpression ":" AssignmentExpression
			  ($$ `(ConditionalExpression ,$1 ,$3 ,$5)))
     )
    
    (AssignmentExpression
     (ConditionalExpression)
     (LeftHandSideExpression AssignmentOperator AssignmentExpression
			     ($$ `(AssignmentExpression ,$1 ,$2 ,$3)))
     )

    (AssignmentOperator
     ;; todo
     ("=" ($$ `(assign ,$1)))
     ("*=" ($$ `(mul-assign ,$1)))
     ("/=" ($$ `(div-assign ,$1)))
     ("%=" ($$ `(mod-assign ,$1)))
     ("+=" ($$ `(add-assign ,$1)))
     ("-=" ($$ `(sub-assign ,$1)))
     ("<<=" ($$ `(lshift-assign ,$1)))
     (">>=" ($$ `(rshift-assign ,$1)))
     (">>>=" ($$ `(rrshift-assign ,$1)))
     ("&=" ($$ `(and-assign ,$1)))
     ("^=" ($$ `(xor-assign ,$1)))
     ("|=" ($$ `(or-assign ,$1))))

    (Expression
     (AssignmentExpression)
     (Expression
      "," AssignmentExpression
      ($$ (if (and (pair? (car $1)) (eqv? 'expr-list (caar $1)))
	      (tl-append $1 $3)
	      (make-tl 'expr-list $1 $3))))
     )
    (ExpressionNoIn
     #;($with Expression ($prune RelationalInExpression))
     (Expression)
     )
	    
    ;; A.4
    (Statement
     (Block)
     (VariableStatement)
     (EmptyStatement)
     (ExpressionStatement)
     (IfStatement)
     (IterationStatement)
     (ContinueStatement)
     (BreakStatement)
     (ReturnStatement)
     (WithStatement)
     (LabelledStatement)
     (SwitchStatement)
     (ThrowStatement)
     (TryStatement)
     )

    (Block
     ("{" StatementList "}" ($$ `(Block ,$2)))
     ("{" "}" ($$ '(Block)))
     )

    (StatementList
     (Statement ($$ (make-tl 'StatementList $1)))
     (StatementList Statement ($$ (tl-append $1 $2)))
     )

    (VariableStatement
     ("var" VariableDeclarationList ";"
      ($$ `(VariableStatement ,(tl->list $2))))
     )

    (VariableDeclarationList
     (VariableDeclaration ($$ (make-tl 'VariableDeclarationList $1)))
     (VariableDeclarationList "," VariableDeclaration ($$ (tl-append $1 $3)))
     )
    (VariableDeclarationListNoIn
     #;($with VariableDeclarationList ($prune RelationalInExpression))
     ;; ==[Until we get $with-prune working]==>
     (VariableDeclarationList)
     )

    (VariableDeclaration
     (Identifier Initializer ($$ `(VariableDeclaration ,$1 ,$2)))
     (Identifier ($$ `(VariableDeclaration ,$1)))
     )
    (VariableDeclarationNoIn
     #;($with VariableDeclaration ($prune RelationalInExpression))
     ;; ==[Until we get $with-prune working]==>
     (VariableDeclaration)
     )

    (Initializer
     ("=" AssignmentExpression ($$ `(Initializer ,$2)))
     )

    (EmptyStatement
     (";" ($$ '(EmptyStatement)))
     )

    (ExpressionStatement
     ;; spec says: Reject if lookahead "{" "," "function".
     #;(($with Expression
	     ($prune FunctionExpression)
	     ($prune ObjectLiteral))
     ";")
     ;; ==[until we get $with-prune working]==>
     (Expression ";" ($$ `(ExpressionStatement ,$1)))
     )

    (IfStatement
     ("if" "(" Expression ")" Statement "else" Statement
      ($$ `(IfStatement ,$3 ,$5 ,$7)))
     ("if" "(" Expression ")" Statement ($prec "then")
      ($$ `(IfStatement ,$3 ,$5)))
     )

    (IterationStatement
     ("do" Statement "while" "(" Expression ")" ";"
      ($$ `(do ,$2 ,$5)))
     ("while" "(" Expression ")" Statement
      ($$ `(while ,$3 ,$5)))
     ("for" "(" OptExprStmtNoIn OptExprStmt OptExprClose Statement
      ;;($$ `(for ,$3 ,$
      )
     ("for" "(" "var" VariableDeclarationListNoIn ";" OptExprStmt
      OptExprClose Statement)
     ("for" "(" LeftHandSideExpression "in" Expression ")" Statement)
     ("for" "(" "var" VariableDeclarationNoIn "in" Expression ")" Statement)
     )
    (OptExprStmtNoIn
     (":" ($$ `(Expression)))
     (ExpressionNoIn ";")
     )
			
    (OptExprStmt
     (";" ($$ '(ExprStmt)))
     (Expression ";")
     )
    (OptExprClose
     (";" ($$ '(Expression)))
     (Expression ")")
     )

    (ContinueStatement
     ("continue" ($$ (NSI)) Identifier ";"
      ($$ `(ContinueStatement ,$3)))
     ("continue" ";" ($$ '(ContinueStatement)))
     )

    (BreakStatement
     ("break" ($$ (NSI)) Identifier ";"
      ($$ `(BreakStatement ,$3)))
     ("break" ";" ($$ '(ContinueStatement)))
     )

    (ReturnStatement
     ("return" ($$ (NSI)) Expression ";"
      ($$ `(ReturnStatement ,$3)))
     ("return" ";" ($$ '(ReturnStatement)))
     )

    (WithStatement
     ("with" "(" Expression ")" Statement
      ($$ `(WithStatement ,$3 ,$5))))

    (SwitchStatement
     ("switch" "(" Expression ")" CaseBlock
      ($$ `(SwitchStatement ,$3 ,$5))))

    (CaseBlock
     ("{" CaseClauses "}" ($$ `(CaseBlock ,$2)))
     ("{" "}" ($$ '(CaseBlock)))
     ("{" CaseClauses DefaultClause CaseClauses "}"
      ($$ `(CaseBlock ,(tl->list $2) ,$3 ,(tl->list $4))))
     ("{" CaseClauses DefaultClause "}"
      ($$ `(CaseBlock ,(tl->list $2) ,$3)))
     ("{" DefaultClause CaseClauses "}"
      ($$ `(CaseBlock ,$2 ,(tl->list $3))))
     ("{" DefaultClause "}"
      ($$ `(CaseBlock ,$2)))
     )

    (CaseClauses
     (CaseClause ($$ (make-tl 'CaseClauses $1)))
     (CaseClauses CaseClause ($$ (tl-append $1 $2)))
     )

    (CaseClause
     ("case" Expression ":" StatementList
      ($$ `(CaseClause ,$2 ,$4)))
     ("case" Expression ":"
      ($$ `(CaseClause ,$2)))
     )

    (DefaultClause
      ("default" ":" StatementList
       ($$ `(DefaultClause ,(tl->list $2))))
      ("default" ":"
       ($$ `(DefaultClause)))
      )

    (LabelledStatement
     (Identifier ":" Statement
		 ($$ `(LabelledStatement ,$1 ,$3)))
     )

    (ThrowStatement
     ("throw" ($$ (NSI)) Expression ";"
      ($$ `(ThrowStatement ,$3)))
     )

    (TryStatement
     ("try" Block Catch
      ($$ `(TryStatement ,$2 ,$3)))
     ("try" Block Finally
      ($$ `(TryStatement ,$2 ,$3)))
     ("try" Block Catch Finally
      ($$ `(TryStatement ,$2 ,$3 ,$4)))
     )

    (Catch
     ("catch" "(" Identifier ")" Block
      ($$ `(Catch ,3 ,$5)))
     )

    (Finally
     ("finally" Block
      ($$ `(Finally ,2)))
     )

    ;; A.5
    (FunctionDeclaration
     ("function" Identifier "(" FormalParameterList ")" "{" FunctionBody "}"
      ($$ `(FunctionDeclaration ,$2 ,(tl->list $4) ,$7)))
     ("function" Identifier "(" ")" "{" FunctionBody "}"
      ($$ `(FunctionDeclaration ,$2 (FormalParameterList) ,$6)))
     )

    (FunctionExpression
     ("function" Identifier "(" FormalParameterList ")" "{" FunctionBody "}"
      ($$ `(FunctionExpression ,$2 ,(tl->list $4) ,$7)))
     ("function" "(" FormalParameterList ")" "{" FunctionBody "}"
      ($$ `(FunctionExpression ,(tl->list $4) ,$6)))
     ("function" Identifier "(" ")" "{" FunctionBody "}"
      ($$ `(FunctionExpression ,$2 ,$6)))
     ("function" "(" ")" "{" FunctionBody "}"
      ($$ `(FunctionExpression ,$5)))
     )

    (FormalParameterList
     (Identifier ($$ (make-tl 'FormalParameterList $1)))
     (FormalParameterList "," Identifier ($$ (tl-append $1 $3)))
     )

    (FunctionBody
     (SourceElements ($$ (tl->list $1)))
     )

    (Program
     (SourceElements ($$ (list 'Program (tl->list $1))))
     )

    (SourceElements
     (SourceElement ($$ (make-tl 'SourceElements $1)))
     (SourceElements SourceElement ($$ (tl-append $1 $2)))
     )

    (SourceElement
     (Statement)
     (FunctionDeclaration)
     )
    
    )))

(define js-mach
  (hashify-machine
   (compact-machine
    (make-lalr-machine js-spec))))

(define len-v (assq-ref js-mach 'len-v))
(define pat-v (assq-ref js-mach 'pat-v))
(define rto-v (assq-ref js-mach 'rto-v))
(define mtab (assq-ref js-mach 'mtab))
(define sya-v (vector-map (lambda (ix actn) (wrap-action actn))
			  (assq-ref js-mach 'act-v)))
(define act-v (vector-map (lambda (ix f) (eval f (current-module))) sya-v))

(include-from-path "nyacc/lang/javascript/body.scm")

(define raw-parser (make-lalr-parser js-mach))

(define* (dev-parse-js #:key debug)
  (catch
   'parse-error
   (lambda ()
     (with-fluid*
	 *insert-semi* #t
	 (lambda () (raw-parser (gen-js-lexer) #:debug #f))))
   (lambda (key fmt . rest)
     (apply simple-format (current-error-port) fmt rest)
     #f)))

;; ======= gen files

(define (gen-js-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (write-lalr-actions js-mach (xtra-dir "jsact.scm.new"))
  (write-lalr-tables js-mach (xtra-dir "jstab.scm.new"))
  (let ((a (move-if-changed (xtra-dir "jsact.scm.new")
			    (xtra-dir "jsact.scm")))
	(b (move-if-changed (xtra-dir "jstab.scm.new")
			    (xtra-dir "jstab.scm"))))
    (when (or a b) 
      (system (string-append "touch " (lang-dir "parser.scm"))))
    (or a b)))

(define (gen-se-files . rest)
  (define (lang-dir path)
    (if (pair? rest) (string-append (car rest) "/" path) path))
  (define (xtra-dir path)
    (lang-dir (string-append "mach.d/" path)))

  (let* ((se-spec (restart-spec js-spec 'SourceElement))
	 #;(se-mach (compact-machine
		   (hashify-machine
	             (make-lalr-machine se-spec))))
	 (se-mach (hashify-machine
		   (make-lalr-machine se-spec)))
    )
    (write-lalr-actions se-mach (xtra-dir "seact.scm.new"))
    (write-lalr-tables se-mach (xtra-dir "setab.scm.new")))
  
  (let ((a (move-if-changed (xtra-dir "seact.scm.new")
			    (xtra-dir "seact.scm")))
	(b (move-if-changed (xtra-dir "setab.scm.new")
			    (xtra-dir "setab.scm"))))
    #;(when (or a b)
    (system (string-append "touch " (lang-dir "separser.scm"))))
    (or a b)))


;;; --- last line ---
