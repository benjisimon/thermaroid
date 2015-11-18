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
                  (camera :: Camera #!null))
             (logi "Hardware accelerated? " (texture-view:is-hardware-accelerated))
             (texture-view:set-surface-texture-listener 
              (object (TextureViewListener)
                      ((on-surface-texture-available (surface :: SurfaceTexture)
                                                     (width :: int)
                                                     (height :: int))
                       (let ((c :: Camera (Camera:open)))
                         (set! camera c)
                         (camera:setPreviewTexture surface)
                         (camera:startPreview)))

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
             texture-view)))

