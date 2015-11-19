;;
;; The utils is responsible for holding onto utilty functions
;;

(require <com.benjisimon.thermaroid.imports>)

(define (logi . words)
  (Log:i "main.scm" (apply string-append (map *:to-string words))))

(define (show . words)
  (for-each display words)
  (newline))

(define (inc x)
  (+ 1 x))

(define (dec x)
  (- x 1))

(define (float-val x)
  (exact->inexact x))

(define (int-val x)
  (inexact->exact (truncate x)))

(define (file->string f)
  (let ((text (open-output-string))
        (in (open-input-file f)))
    (let loop ((line (read-line in 'concat)))
      (cond ((eof-object? line) (get-output-string text))
            (else
             (write line text)
             (loop (read-line in 'concat)))))))
          
(define (for-each-coord width height thunk)
  (let loop ((x 0) (y 0))
    (cond ((= y height) 'done)
          (else
           (thunk x y)
           (if (= (inc x) width)
             (loop 0 (inc y))
             (loop (inc x) y))))))

(define (any->string x)
  (if (instance? x java.lang.Throwable)
    (let ((buffer (open-output-string)))
      ((as java.lang.Throwable x):print-stack-trace  buffer)
      (get-output-string buffer))
    (x:to-string)))

(define (make-time-tracker)
  (let ((events `((init . ,(java.util.Date)))))
    (lambda (evt)
      (case evt
        ((dump)
         (reverse events))
        (else
         (set! events (cons (cons evt (java.util.Date)) events)))))))
