;;
;; The camera is responsible for working with the camera
;;

(define-alias Activity android.app.Activity)
(define-alias CameraManager android.hardware.camera2.CameraManager)
(define-alias Context android.content.Context)
(define-alias CameraCharacteristics android.hardware.camera2.CameraCharacteristics)

(module-export camera-ids camera-facing)

(define (camera-mgr) :: CameraManager
  (invoke (current-activity) 'getSystemService Context:CAMERA_SERVICE))

(define (camera-ids) :: string[]
  (let ((mgr :: CameraManager (camera-mgr)))
    (mgr:getCameraIdList)))

(define (camera-facing (id :: string))
  (let* ((mgr :: CameraManager (camera-mgr))
         (details :: CameraCharacteristics (mgr:get-camera-characteristics id))
         (key CameraCharacteristics:LENS_FACING)
         (direction (details:get key)))
    (vector-ref direction (vector "Front" "Back" "External"))))

  

