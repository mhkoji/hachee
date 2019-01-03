(defpackage :senn.fcitx.controller
  (:use :cl
        :senn.op
        :senn.fcitx.states)
  (:export :process-client
           :make-controller)
  (:import-from :alexandria
                :when-let))
(in-package :senn.fcitx.controller)

(defstruct controller id kkc)

(defgeneric transit-by-input (controller state code))

(defgeneric make-response (s consumed))


(defun process-client (controller &key reader writer)
  (labels ((process-loop (state)
             (when-let ((line (funcall reader)))
               (let ((expr (as-expr line)))
                 (ecase (expr-op expr)
                   (:do-input
                    (destructuring-bind (new-state &optional (consumed t))
                        (alexandria:ensure-list
                         (transit-by-input controller
                                           state
                                           (expr-arg expr "code")))
                      (funcall writer (make-response new-state consumed))
                      (process-loop new-state))))))))
    (process-loop (make-editing))))
