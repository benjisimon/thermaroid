;;
;; The camera is responsible for working with the new camera2 API.
;;
;; XXX - at the moment, we don't bother with Camera2, as it's a
;; pain in the butt to work with. 
;;

(require <com.benjisimon.thermaroid.imports>)
(require <com.benjisimon.thermaroid.utils>)
(require 'android-defs)


(module-export camera-ids camera-facing camera-open)

(define (camera-mgr) :: CameraManager
  (invoke (as Activity (current-activity)) 'getSystemService Context:CAMERA_SERVICE))

(define (camera-ids) :: string[]
  (let ((mgr :: CameraManager (camera-mgr)))
    (mgr:getCameraIdList)))

(define (camera-facing (id :: string))
  (let* ((mgr :: CameraManager (camera-mgr))
         (details :: CameraCharacteristics (mgr:get-camera-characteristics id))
         (key CameraCharacteristics:LENS_FACING)
         (direction (details:get key)))
    (vector-ref (vector "Front" "Back" "External") direction)))

(define (camera-open (id :: string)) :: void
  (let* ((mgr :: CameraManager (camera-mgr)))
    (mgr:open-camera id (new-state-callback) #!null)))

(define (new-state-callback)
  (object (CameraDeviceStateCallback)
          ((on-closed (camera :: CameraDevice)) :: void
           (logi "Camera Closed"))
          ((on-disconnected (camera :: CameraDevice)) :: void
           (logi "Camera disconnected"))
          ((on-error (camera :: CameraDevice) (error :: int)) :: void
           (logi "D'oh. Error"))
          ((on-opened (camera :: CameraDevice)) :: void
           (logi "And we're open for business!"))))
