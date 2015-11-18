;;
;; The utils is responsible for holding onto utilty functions
;;

(require <com.benjisimon.thermaroid.imports>)
(module-export logi)

(define (logi message)
  (Log:i "main.scm" message))
