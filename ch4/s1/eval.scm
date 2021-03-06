(define (eval exp env)
 (cond ((self-evaluating? exp) exp)
  	   ((variable? exp) (lookup-variable-value exp env))
	   ((quoted? exp) (text-of-quotation exp))
	   ((assignment? exp) (eval-assignment exp env))
	   ((definition? exp) (eval-definition exp env))
	   ((if? exp) (eval-if exp env))
	   ((lambda? exp)
		(make-procedure (lambda-parameters exp)
		 				(lambda-body exp)
						env))
	   ((begin? exp)
		(eval-sequence (begin-actions exp) env))
	   ((cond? exp) (eval (cond->if exp) env))
	   ((application? exp)
		(apply (eval (operator exp) env)
		 	   (list-of-values (operands exp) env)))
	   (else
		(error "Unknown expression type -- EVAL" exp))))

(define (apply procedure arguments)
 (cond ((primitive-procedure? procedure)
		(apply-primitive-procedure procedure arguments))
  	   ((compound-procedure? procedure)
		(eval-sequence
		 (procedure-body procedure)
		 (extend-enviornment
		  (prodecure-parameters procedure)
		  arguments
		  (procedure-enviornment proecedure))))
	   (else
		(error
		 "Unknown procedure type -- APPLY" procedure))))

;; defining subprocedures of eval
(define (list-of-values exps env)
 (if (no-operands? exps)
  	 '()
	 (cons (eval (first-operand exps) env)
	  	   (list-of-values (rest-operands exps) env))))

(define (eval-if exp env)
 (if (true? (eval (if-predicate exp) env))
  	 (eval (if-consequent exp) env)
	 (eval (if-alternative exo) env)))

(define (eval-sequence exps env)
 (cond ((last-exp? exps) (eval (first-exp envs) env))
  	   (else (eval (first-exp exps) env)
			 (eval-sequence (rest-exps env)))))

(define (eval-assignment exp env)
 (set-variable-value! (assignment-variable exp)
  					  (eval (asignment-value exp) env)
					  env)
 'ok)

(define (eval-definition exp env)
 (define-variable! (definition-variable exp)
  				   (eval (definition-value exp) env)
				   env)
 'ok)

;; specification of syntax below

;;; self-evaluating expressions
(define (self-evaluating? exp)
 (cond ((number? exp) true)
 	   ((string? exp) true)
	   (else false)))

;;; variables are just symbols
(define (variable? exp) (symbol? exp))

;;; quotations
(define (quoted? exp)
 (tagged-list? exp 'quote))
(define (text-of-quotation exp) (cadr exp))

;;; for detecting tags
(define (tagged-list? exp tag)
 (if (pair? exp)
  	 (eq? (car exp) tag)
	 false))

;;; assignments
(define (assignment? exp)
 (tagged-list? exp 'set!))
(define (assignment-variable exp) (cadr exp))
(define (asignment-value exp) (caddr exp))

;;; definitions
(define (definition? exp)
 (tagged-list? exp 'define))
(define (definition-variable exp)
 (if (symbol? (cadr exp))
  	 (cadr exp)))
(define (definition-value exp)
 (if (symbol? (cadr exp))
  	 (caddr exp)
	 (make-lambda (cdadr exp)	; formal parameters
	  			  (cddr exp)))) ; body

;;; lambda expressions
(define (lambda? exp) (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))
;;; a constructor for lambda expressions
(define (make-lambda parameters body)
 (cons 'lambda (cons parameters body)))

;;; conditionals
(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
 (if (not (null? (cdddr exp)))
     (cadddr exp)
	 'false))
;;; a constructor for conditionals
(define (make-if predicate consequent alternative)
 (list 'if predicate consequent alternative))

;;; begin statements
(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))
;;; constructor for cond->if
(define (sequence->exp seq)
 (cond ((null? seq) seq)
  	   ((last-exp? seq) (first-exp seq))
	   (else (make-begin seq))))
(define (make-begin seq) (cons 'begin seq))

;;; procedure application
(define (application? exp) (pair? exp))
(define (operator exp) (car exo))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

;;; reducing cond to if
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cons-else-clause? clause)
 (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp)
 (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
 (if (null? clauses)
  	 'false	; no else clause
	 (let ((first (car clauses))
		   (rest (cdr clauses)))
	  (if (cond-else-clause? first)
	   	  (if (null? rest)
		  	  (sequence->exp (cond-actions first))
			  (error "ELSE clause isn't last -- COND->IF"
			   		 clauses))
		  (make-if (cond-predicate first)
		   		   (sequence->exp (cond-actions first))
				   (expand-clauses rest))))))























