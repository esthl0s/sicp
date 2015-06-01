(define (make-point x y)
    (cons x y))

(define (x-point point)
    (car point))

(define (y-point point)
    (cdr point))

(define (make-segment a b)
    (cons a b))

(define (start-segment segment)
    (car segment))

(define (end-segment segment)
    (cdr segment))

(define (midpoint-segment segment)
    (make-point (avg-x-coord segment)
                (avg-y-coord segment)))

(define (avg-x-coord segment)
    (average (x-point (start-segment segment))
             (x-point (end-segment segment))))

(define (avg-y-coord segment)
    (average (y-point (start-segment segment))
             (y-point (end-segment segment))))

(define (average a b)
    (/ (+ a b) 2))

(define (print-point p)
    (newline)
    (display "(")
    (display (x-point p))
    (display ",")
    (display (y-point p))
    (display ")")
    0)
