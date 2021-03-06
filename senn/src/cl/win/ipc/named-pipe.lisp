(defpackage :senn.win.ipc.named-pipe
  (:use :cl)
  (:export :start-server)
  (:import-from :alexandria
                :if-let
                :when-let))
(in-package :senn.win.ipc.named-pipe)

(defstruct client id pipe)

(defmacro log/info (client format-str &rest args)
  `(log:info ,(concatenate 'string "[~A]: " format-str)
             (client-id ,client)
             ,@args))

(defmethod senn.win.stateful-im:read-request ((client client))
  (when-let ((octets (hachee.ipc.named-pipe:read-file (client-pipe client))))
    (let ((string (babel:octets-to-string octets :encoding :utf-8)))
      (hachee.ipc.op:as-expr string))))

(defmethod senn.win.stateful-im:send-response ((client client) (resp string))
  (let ((octets (babel:string-to-octets resp :encoding :utf-8)))
    (hachee.ipc.named-pipe:write-file (client-pipe client) octets)))

(defmethod senn.win.stateful-im:read-request :around ((client client))
  (let ((req (call-next-method)))
    (log/info client "Read: ~A" req)
    req))

(defmethod senn.win.stateful-im:send-response :after ((client client) resp)
  (log/info client "Written: ~A" resp))


(defun spawn-client-thread (client ime)
  (log/info client "Connected")
  (bordeaux-threads:make-thread
   (lambda ()
     (handler-case
         (let ((initial-state
                (senn.win.input-processor.states:make-editing)))
           (senn.win.stateful-im:loop-handling-request
            ime initial-state client))
       (error (e)
         (log:info "~A" e)))
     (log/info client "Disconnected"))))

(defun start-server (ime &key (pipe-name "\\\\.\\Pipe\\senn"))
  (let ((threads nil)
        (clients nil))
    (unwind-protect
         (loop
            for client-id from 1
            for pipe = (hachee.ipc.named-pipe:create pipe-name)
            while pipe
            do (progn
                 (log:info "Waiting for client...")
                 (hachee.ipc.named-pipe:connect pipe)
                 (let ((client (make-client :id client-id :pipe pipe)))
                   (push client clients)
                   (push (spawn-client-thread client ime) threads))))
      (mapc #'hachee.ipc.named-pipe:disconnect-and-close
            (mapcar #'client-pipe clients))
      (mapc #'bordeaux-threads:destroy-thread threads))))
