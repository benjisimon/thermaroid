;;
;; The main is responsible for implementing the top level access to Thermaroid,
;; our app which lets you print snapshots easily using a thermal printer.
;;

(require 'android-defs)
(require <com.benjisimon.thermaroid.imports>)
(require <com.benjisimon.thermaroid.camera>)

(activity main
          (on-create-view
           (let* ((ids :: string[] (camera-ids))
                  (directions :: list (map camera-facing ids))
                  (cam-info (apply string-append
                                   (map
                                    (lambda (id direction)
                                      (string-append id ": " direction " "))
                                    ids directions))))
             (camera-open "0")
             (android.widget.TextView (this)
                                      text: (as string cam-info)))))

