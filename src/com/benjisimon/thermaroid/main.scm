;;
;; The main is responsible for implementing the top level access to Thermaroid,
;; our app which lets you print snapshots easily using a thermal printer.
;;


(require 'android-defs)
(activity main
          (on-create-view
           (android.widget.TextView (this)
                                    text: "Thermaroid Goes here")))
