(defpackage :senn.win.transit
  (:use :cl
        :senn.win.transit.states)
  (:export :transit)
  (:import-from :senn.im
                :ime))
(in-package :senn.win.transit)

(defvar +crlf+
  (format nil "~A~A" #\Return #\Newline))

(defun move-segment-form-index! (seg diff ime)
  (senn.im:append-candidates ime seg)
  (senn.segment:try-move-cursor-pos! seg diff))

(defun char-p (k)
  (<= (char-code #\A)
      (senn.win.transit.keys:key-code k)
      (char-code #\Z)))

(defun buffer-empty-p (buffer)
  (string= (senn.buffer:buffer-string buffer) ""))


(defgeneric transit (ime state key))


(defun ->editing-view (editing)
  (format nil "EDITING ~A~%" (senn.buffer:buffer-string
                              (editing-buffer editing))))

(defun ->converting-view (converting)
  (let ((json-string
         (jsown:to-json
          (jsown:new-js
           ("forms"
            (mapcar #'senn.segment:segment-current-form
                    (converting-segments converting)))
           ("cursor-form-index"
            (converting-current-segment-index converting))
           ("cursor-form"
            (let ((segment (converting-current-segment converting)))
              (jsown:new-js
               ("candidates"
                (if (senn.segment:segment-has-more-candidates-p segment)
                    nil
                    (senn.segment:segment-forms segment)))
               ("candidate-index"
                (senn.segment:segment-current-index segment)))))))))
    (format nil "CONVERTING ~A~%" json-string)))

(defun ->committed-view (input)
  (let ((json-string
         (jsown:to-json
          (jsown:new-js
            ("input" input)))))
    (format nil "COMMITTED ~A~%" json-string)))


(defmethod transit ((ime ime) (s converting) key)
  (cond ((senn.win.transit.keys:enter-p key)
         (let ((editing (make-editing)))
           (list editing (->committed-view (converting-current-input s)))))

        ((or (senn.win.transit.keys:space-p key)
             (senn.win.transit.keys:up-p key))
         (move-segment-form-index! (converting-current-segment s) +1 ime)
         (list s (->converting-view s)))

        ((senn.win.transit.keys:down-p key)
         (move-segment-form-index! (converting-current-segment s) -1 ime)
         (list s (->converting-view s)))

        ((senn.win.transit.keys:left-p key)
         (converting-move-curret-segment s -1)
         (list s (->converting-view s)))

        ((senn.win.transit.keys:right-p key)
         (converting-move-curret-segment s +1)
         (list s (->converting-view s)))

        (t
         (list s (->converting-view s)))))

(defmethod transit ((ime ime) (s editing)
                    (key senn.win.transit.keys:key))
  (cond ((char-p key)
         (let ((char-lower-case
                (code-char (+ #x20 ;; to lower case
                              (senn.win.transit.keys:key-code key)))))
           (setf (editing-buffer s)
                 (senn.buffer:insert-char (editing-buffer s)
                                          char-lower-case)))
         (list s (->editing-view s)))

        ((senn.win.transit.keys:backspace-p key)
         (let ((pron (senn.buffer:buffer-string (editing-buffer s))))
           (cond ((string= pron "") ;; Should not reach here
                  (list s (->editing-view s)))
                 (t
                  (setf (editing-buffer s)
                        (senn.buffer:delete-char (editing-buffer s)))
                  (list s (->editing-view s))))))

        ((senn.win.transit.keys:space-p key)
         (let ((pron (senn.buffer:buffer-string (editing-buffer s))))
           (if (string= pron "")
               (list s (->editing-view s))
               (let ((segments (senn.im:convert ime pron)))
                 (let ((converting (make-converting :segments segments
                                                    :pronunciation pron)))
                   (list converting (->converting-view converting)))))))

        ((senn.win.transit.keys:enter-p key)
         (let ((buffer (editing-buffer s))
               (editing (make-editing)))
           (list editing (->committed-view
                          (if (buffer-empty-p buffer)
                              +crlf+
                              (senn.buffer:buffer-string buffer))))))

        (t
         (list s (->editing-view s)))))
