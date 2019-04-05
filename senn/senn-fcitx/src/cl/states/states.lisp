(defpackage :senn.fcitx.states
  (:use :cl)
  (:export :to-view

           :editing
           :make-editing
           :editing-buffer

           :converting
           :make-converting
           :converting-pronunciation
           :converting-segments
           :converting-current-segment
           :converting-current-input
           :converting-current-segment-index
           :converting-move-curret-segment

           :committed
           :make-committed
           :committed-input))
(in-package :senn.fcitx.states)

(defgeneric to-view (s))

(defstruct editing
  (buffer (senn.buffer:make-buffer)))


(defstruct converting
  segments
  pronunciation
  (current-segment-index 0))

(defun converting-move-curret-segment (c diff)
  (let ((new-index (+ (converting-current-segment-index c) diff)))
    (when (<= 0 new-index (1- (length (converting-segments c))))
      (setf (converting-current-segment-index c) new-index)))
  c)

(defun converting-current-segment (c)
  (elt (converting-segments c)
       (converting-current-segment-index c)))

(defun converting-current-input (c)
  (format nil "~{~A~}"
          (mapcar #'senn.segment:segment-current-form
                  (converting-segments c))))


(defstruct committed input)
