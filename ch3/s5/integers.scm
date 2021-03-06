;; integers as a stream
(define (integers-starting-from n)
 (cons-stream n (integers-starting-from (+ n 1))))

(define integers (integers-starting-from 1))

;; stream of integers not divisible by 7:
(define (divisible? x y) (= (remainder x y) 0))
(define no-sevens
 (stream-filter (lambda (x) (not (divisible? x 7)))
  				integers))

;; infinite stream of FIbonacci numbers:
(define (fibgen a b)
 (cons-stream a (fibgen b (+ a b))))
(define fibs (fibgen 0 1))

;; infinite stream of prime numbers:
(define (sieve stream)
 (cons-stream
  (stream-car stream)
  (sieve (stream-filter
		  (lambda (x)
		   (not (divisible? x (stream-car stream))))
		  (stream-cdr stream)))))
(define primes (sieve (integers-starting-from 2)))

























