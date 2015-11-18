;;
;; The main is responsible for implementing the top level access to Thermaroid,
;; our app which lets you print snapshots easily using a thermal printer.
;;


(define-alias CameraManager android.hardware.camera2.CameraManager)
(define-alias Context android.content.Context)
(define-alias Activity android.app.Activity)

(require 'android-defs)
(require <com.benjisimon.thermaroid.camera>)

(activity main
          (on-create-view
           (let* ((ids :: string[] (camera-ids))
                  (directions :: list (map camera-facing ids))
                  (cam-info (apply string-append
                                   (lambda (id direction)
                                     (string-append id ": " direction))
                                   ids directions)))
             (android.widget.TextView (this)
                                      text: (as string cam-info)))))

