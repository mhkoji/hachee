(defpackage :senn.fcitx.t.scenario.transit
  (:use :cl)
  (:export :*ops-tests*))
(in-package :senn.fcitx.t.scenario.transit)

(defmacro assert-ops (ops &key test)
  `(let ((ime (make-instance 'senn.im:ime)))
     (loop for (sym expected-view) in ,ops
           for state = (senn.fcitx.transit.states:make-editing)
           do (destructuring-bind (new-state actual-view)
                  (let ((key (senn.fcitx.transit.keys:make-key
                              :sym sym :state 0)))
                    (senn.fcitx.transit:transit ime state key))
                (,test (string= expected-view actual-view))
                (setq state new-state)))))

(defmacro def-ops-test (name ops)
  `(progn
     (defmacro ,name (&key test)
       `(assert-ops ,',ops :test ,test))
     (pushnew ',name *ops-tests*)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *ops-tests* nil)

  #+nil
  (progn
    (defmacro when-space-key-is-first-inputted-then-full-width-space (&key test)
      `(assert-ops '((32 "<expected-view>")) :test ,test))
    (pushnew 'when-space-key-is-first-inputted-then-full-width-space
             *ops-tests*))

  (def-ops-test when-space-key-is-first-inputted-then-full-width-space-is-inserted
      '((32 "IRV_TO_PROCESS EDITING {\"cursor-pos\":0,\"input\":\"\",\"committed-input\":\"\\u3000\"}"))))