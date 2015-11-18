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
           (let* ((texture-view (TextureView (this))))
             (logi "Hardware accelerated? " (texture-view:is-hardware-accelerated))
             (texture-view:set-surface-texture-listener 
              (object (TextureViewListener)
                      ((on-surface-texture-available (surface :: SurfaceTexture)
                                                     (width :: int)
                                                     (height :: int))
                       (logi "And our surface is ready! " width "x" height)
                       (logi width))
                      ((on-surface-texture-size-changed (surface :: SurfaceTexture)
                                                        (width :: int)
                                                        (height :: int))
                       (logi "Do'h, new dimensions: " width "x" height))
                      ((on-surface-texture-destroyed (surface :: SurfaceTexture)) :: boolean
                       #t)
                      ((on-surface-texture-updated (surface :: SurfaceTexture))
                       (log "udpated"))))
             (camera-open "0")
             texture-view)))

