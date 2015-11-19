;;
;; Work with images that are going to get printed
;;
(require <com.benjisimon.thermaroid.imports>)
(require <com.benjisimon.thermaroid.utils>)

(module-export image-write)


(define (scale-bitmap feedback (src :: Bitmap) max-width) :: Bitmap
  (let* ((src-w (src:get-width))
         (src-h (src:get-height))
         (matrix :: Matrix (Matrix)))
    (feedback "Scaling: " src-w "x" src-h " to fit in max-width=" max-width)
    (let ((action (cond ((<= src-w max-width)
                         'skip)
                        ((<= src-h max-width)
                         (matrix:postRotate 90)
                         '(rotate 90))
                        ((> src-w src-h)
                         (matrix:postRotate 90)
                         (matrix:postScale (/ max-width src-h)
                                           (/ max-width src-h))
                         `(rotate 90 scale ,(/ max-width src-h)))
                        (else
                         (matrix:postScale (/ max-width src-w)
                                           (/ max-width src-w))
                         `(scale ,(/ max-width src-w))))))
      (feedback "scale action: " action)
      (Bitmap:createBitmap src 0 0 src-w src-h matrix #t))))

;;
;; Via: http://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
;;
(define (fs-dither-bitmap feedback (src :: Bitmap)) :: Bitmap
  (let* ((src-w (src:get-width))
         (src-h (src:get-height))
         (pixels (int[] length: (* src-w src-h)))
         (idx (lambda (x y) (+ (* y src-w) x))))
    (feedback "Dithering " src-w "x" src-h " image")
    (src:get-pixels pixels 0 src-w 0 0 src-w src-h)
    (define (store! x y pixel)
      (set! (pixels (idx x y)) (gray->rgb pixel)))
    (define (update! x y factor)
      (if (and (< x src-w) (< y src-h) (>= x 0) (>= y 0))
        (let ((gray (rgb->gray (pixels (idx x y)))))
          (set! (pixels (idx  x y)) (gray->rgb (gray+ gray factor))))))
    (for-each-coord src-w src-h
                    (lambda (x y)
                      (let* ((old-pixel (rgb->gray (pixels (idx x y))))
                             (new-pixel (if (> old-pixel 128) 255 0))
                             (quant-error (- old-pixel new-pixel)))
                        (store! x y new-pixel)
                        (update! (inc x) y       (* quant-error (/ 7 16)))
                        (update! (dec x) (inc y) (* quant-error (/ 3 16)))
                        (update! x       (inc y) (* quant-error (/ 5 16)))
                        (update! (inc x) (inc y) (* quant-error (/ 1 16))))))
    (src:set-pixels pixels 0 src-w 0 0 src-w src-h)
    src))
                        

(define (make-image-buffer feedback (stream :: PrintStream))
  (let ((bit-index :: int 0)
        (accumulator :: int 0))
    (lambda (value)
      (cond ((eq? value 'flush)
             (if (> 0 bit-index)
               (begin
                 (stream:write accumulator)
                 (stream:flush)))
             (set! bit-index 0)
             (set! accumulator 0))
            (else
             (let ((bit :: int value))
               (set! accumulator
                     (bitwise-ior (bitwise-arithmetic-shift-left accumulator 1)
                                  bit))
               (set! bit-index (+ 1 bit-index))
               (if (= bit-index 8)
                   (begin
                     (stream:write accumulator)
                     (set! bit-index 0)
                     (set! accumulator 0)))))))))
                      
            

(define (image-write feedback  (full :: Bitmap) dither? (stream :: PrintStream))
  (let* ((scaled (if dither? 
                   (fs-dither-bitmap feedback (scale-bitmap feedback full 384))
                   (scale-bitmap feedback full 384)))
         (stream-buffer (make-image-buffer feedback stream)))
    (let* ((img-w (scaled:get-width))
           (h (scaled:get-height))
           (bytes-per-row (int-val (ceiling (/ img-w 8))))
           (bit-w (* bytes-per-row 8))
           (row-header (bytevector #x1F #x10 bytes-per-row #x00))
           (snapshot :: PrintStream (PrintStream "/sdcard/dp.img"))
           (snapshot-buffer (make-image-buffer feedback snapshot)))                   
      (feedback "Writing " img-w "x" h " image (" bit-w " bits wide)") 
      (let loop ((x 0) (y 0))
        (cond ((= y h) 'done)
              (else
               (if (= x 0)
                 (begin
                   (stream-buffer 'flush)
                   (write-bytevector row-header stream)
                   (snapshot-buffer 'flush)
                   (write-bytevector row-header snapshot)))
               (let* ((bit (if (>= x img-w)
                             0
                             (rgb->bit (scaled:get-pixel x y)))))
                 (stream-buffer bit)
                 (snapshot-buffer bit)
                 (cond ((= (inc x) bit-w)
                        (loop 0 (inc y)))
                       (else
                        (loop (inc x) y)))))))
      (stream-buffer 'flush)
      (snapshot-buffer 'flush))))

;;
;; From: http://www.had2know.com/technology/rgb-to-gray-scale-converter.html
;;
(define (rgb->gray pixel)
  (let* ((red (Color:red pixel))
         (green (Color:green pixel))
         (blue (Color:blue pixel)))
    (if (= red green blue)
      red
      (+ (* 0.299 red) (* 0.587 green) (* 0.114 blue)))))

(define (gray->rgb val)
  (Color:rgb val val val))

(define (rgb->bit pixel)
  (if (> (rgb->gray pixel) 128) 0 1))

(define (gray+ gray-value factor)
  (let ((new-value (+ gray-value factor)))
    (cond ((< new-value 0) 0)
          ((> new-value 255) 255)
          (else
           (round new-value)))))
