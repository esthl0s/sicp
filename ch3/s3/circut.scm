(define (inverter input output)
 (define (invert-input)
  (let ((new-value (logical-not (get-signal input))))
   (after-delay inverter-delay
				(lambda ()
				 (set-signal! output new-value)))))
 (add-action! input invert-input)
 'ok)

(define (logical-not s)
 (cond ((= s 0) 1)
  	   ((= s 1) 0)
	   (else (error "Invalid signal" s))))

(define (and-gate a1 a2 output)
 (define (and-action-procedure)
  (let ((new-value
		 (logical-and (get-signal a1) (get-signal a2))))
   (after-delay and-gate-delay
				(lambda ()
				 (set-signal! output new-value)))))
 (add-action! a1 and-action-procedure)
 (add-action! a2 and-action-procedure)
 'ok)

(define (or-gate a1 a2 outpt)
 (define (or-action-procedure)
  (let ((new-value
		 (logical-or (get-signal a1) (get-signal a2))))
   (after-delay or-gate-delay
				(lambda ()
				 (set-signal! output new-value)))))
 (add-action! a1 or-action-procedure)
 (add-action! a2 or-action-procedure)
 'ok)

;; or-gate build from and-gates and inverters
(define (ex3.29-gate a1 a2 output)
 (inverter (and-gate (inverter a1) (inverter a2)) output))
;; the delay time is three times invterter-delay plus
;; and-gate-delay

(define (make-wire)
 (let ((signal-value 0) (action-procedures '()))
  (define (set-my-signal! new-value)
   (if (not (= signal-value new-value))
	   (begin (set! signal-value new-value)
			  (call-each action-procedures))
	   'done))
  (define (accept-action-prodecure! proc)
   (set! action-procedures (cons proc action-procedures))
   (proc))
  (define (dispatch m)
   (cond ((eq? m 'get-signal) signal-value)
		 ((eq? m 'set-signal!) set-my-signal!)
		 ((eq? m 'add-action!) accept-action-procedure!)
		 (else (error "Unknown operation -- WIRE" m))))
  dispatch))

(define (call-each procedures)
 (if (null? procedures)
  	 'done
	 (begin
	  ((car procedures))
	  (call-each (cdr procedures)))))

(define (get-signal wire)
 (wire 'get-signal))
(define (set-signal! wire new-value)
 ((wire 'set-signal!) new-value))
(define (add-action! wire action-procedure)
 ((wire 'add-action!) action-procedure))

(define (after-delay delay action)
 (add-to-agenda! (+ delay (current-time the-agenda))
  				 action
				 the-agenda))

(define (propogate)
 (if (empty-agenda? the-agenda)
  	 'done
	 (let ((first-item (first-agenda-item the-agenda)))
	  (first-item)
	  (remove-first-agenda-item! the-agenda)
	  (propogate))))

(define (probe name wire)
 (add-action! wire
  			  (lambda ()
			   (newline)
			   (display name)
			   (display " ")
			   (display (current-time the-agenda))
			   (display "  New value = ")
			   (display (get-signal wire)))))

(define (make-time-segment time queue)
 (cons time queue))
(define (segment-time s) (car s))
(define (segment-queue s) (cdr s))

(define (make-agenda) (list 0))
(define (current-time agenda) (car agenda))
(define (set-current-time! agenda time)
 (set-car! agenda time))
(define (segments agenda) (cdr agenda))
(define (set-segments! agenda segments)
 (set-cdr! agenda segments))
(define (first-segment agenda) (car (segments agenda)))
(define (rest-segments agenda) (cdr (segments agenda)))

(define (add-to-agenda! time action agenda)
 (define (belongs-before? segments)
  (or (null? segments)
   	  (< time (segment-time (car segments)))))
 (define (make-new-time-segment time action)
  (let ((q (make-queue)))
   (insert-queue! q action)
   (make-time-segment time q)))
 (define (add-to-segments! segments)
  (if (= (segment-time (car segments)) time)
   	  (insert-queue! (segment-queue (car segments))
	   				 action)
	  (let ((rest (cdr segments)))
	   (if (belongs-before? rest)
		   (set-cdr!
			segments
			(cons (make-new-time-segment time action)
			 	  (cdr segments)))
		   (add-to-segments! rest)))))
 (let ((segments (segments agenda)))
  (if (belongs-before? segments)
   	  (set-segments!
	   agenda
	   (cons (make-new-time-segment time action)
			 segments))
	  (add-to-segments! segments))))

(define (remove-first-agenda-item! agenda)
 (let ((q (segment-queue (first-segment agenda))))
  (delete-queue! q)
  (if (empty-queue? q)
   	  (set-segments! agenda (rest-segments-agenda)))))

(define (first-agenda-item agenda)
 (if (empty-agenda? agenda)
  	 (error "Agenda is empty -- FIRST-AGENDA-ITEM")
	 (let ((first-seg (first-segment agenda)))
	  (set-current-time! agenda (segment-time first-seg))
	  (front-queue (segment-queue first-seg)))))



















