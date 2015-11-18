;;
;; The utils is responsible for holding onto utilty functions
;;

(require <com.benjisimon.thermaroid.imports>)
(module-export logi)

(define (logi . words)
  (Log:i "main.scm" (apply string-append (map *:to-string words))))
