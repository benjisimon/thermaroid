;;
;; The main is responsible for implementing the top level access to Thermaroid,
;; our app which lets you print snapshots easily using a thermal printer.
;;

(require 'android-defs)
(require <com.benjisimon.thermaroid.imports>)
(require <com.benjisimon.thermaroid.camera>)
(require <com.benjisimon.thermaroid.utils>)

(activity main
          (on-create-view
           (let* ((texture-view (TextureView (this)))
                  (camera :: Camera #!null)
                  (on-focus :: CameraAutoFocusCallback 
                            (object (CameraAutoFocusCallback)
                                    ((on-auto-focus (success :: boolean) (camera :: Camera)) :: void
                                     (logi "Focused? " success)))))
           (logi "Hardware accelerated? " (texture-view:is-hardware-accelerated))
             (texture-view:set-surface-texture-listener 
              (object (TextureViewListener)
                      ((on-surface-texture-available (surface :: SurfaceTexture)
                                                     (width :: int)
                                                     (height :: int))
                       (let ((c :: Camera (Camera:open)))
                         (set! camera c)
                         (camera:setPreviewTexture surface)
                         (camera:startPreview)
                         (camera:auto-focus on-focus)))
                      
                      ((on-surface-texture-size-changed (surface :: SurfaceTexture)
                                                         (width :: int)
                                                        (height :: int))
                       #!void)

                      ((on-surface-texture-destroyed (surface :: SurfaceTexture)) :: boolean
                       (camera:stopPreview)
                       (camera:release)
                       #t)
                      ((on-surface-texture-updated (surface :: SurfaceTexture))
                       #!void)))
             (texture-view:set-on-touch-listener (object (ViewOnTouchListener)
                                                         ((on-touch (view :: View) (evt :: MotionEvent)) :: boolean
                                                          (if (equal? MotionEvent:ACTION_UP  (evt:get-action))
                                                            (camera:auto-focus on-focus)
                                                            (logi "Taking photo"))
                                                          #t)))
             texture-view)))

