;;
;; The printer is responsible for working with our bluetooth printer
;;

(require <com.benjisimon.thermaroid.imports>)
(module-export send-to-printer)

(define (find-device feedback)
  (feedback "Searching for printer")
  (let* ((adapter :: BluetoothAdapter (<android.bluetooth.BluetoothAdapter>:get-default-adapter))
         (devices :: Set (adapter:get-bonded-devices)))
    (feedback "Found " (devices:size) " possible devices")
    (let loop ((iter :: Iterator (devices:iterator)))
      (if (iter:has-next)
        (let ((item :: BluetoothDevice (iter:next)))
          (cond ((equal? (item:getName) "DL58")
                 (feedback "Found it: " (item:getName))
                 item)
                (else
                 (feedback "Skipping: " (item:getName))
                 (loop iter))))
        #!null))))


(define (send-to-printer feedback thunk) :: void
  (let ((device :: BluetoothDevice (find-device feedback))
        (uuid :: java.util.UUID   (<java.util.UUID>:fromString "00001101-0000-1000-8000-00805F9B34FB")))
    (cond ((not (eq? device #!null))
           (feedback "Device address: " device)
           (let* ((socket :: BluetoothSocket (device:createRfcommSocketToServiceRecord uuid))
                  (out :: OutputStream (socket:get-output-stream)))
             (feedback "Trying to connect")
             (socket:connect)
             (feedback "Got our output stream, let's (thunk)")
             (thunk (PrintStream out))
             (socket:close)))
          (else
           (feedback "No device found. This isn't good.")))))
         
