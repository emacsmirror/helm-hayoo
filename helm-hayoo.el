;;; helm-hayoo.el --- Source and configured helm for searching hayoo:

;;; Commentary:
;; This package provides a helm source `helm-source-hayoo' and a
;; configured helm `helm-hayoo' to search hayoo online.

;;; Code:
(defvar helm-hayoo-query-url
  "http://holumbus.fh-wedel.de/hayoo/hayoo.json?query=%s"
  "Url used to query hayoo, must have a `%s' placeholder.")

(defun helm-hayoo-make-query (query)
  "Returns a valid query for hayoo, searching for QUERY."
  (format helm-hayoo-query-url query))

(defun helm-hayoo-search ()
  "Search hayoo for current `helm-pattern'."
  (mapcar
   (lambda (result) (cons (helm-hayoo-format-result result) result))
   (append
    (assoc-default
     'functions
     (with-current-buffer
         (url-retrieve-synchronously
          (helm-hayoo-make-query (car (split-string helm-pattern " "))))
       (json-read-object))) nil)))

(defun helm-hayoo-format-result (result)
  "Format a json response for display in helm."
  (let ((package (assoc-default 'package result))
        (signature (assoc-default 'signature result))
        (name (assoc-default 'name result))
        (module (assoc-default 'module result)))
    (format "(%s) %s %s :: %s" package module name signature)))

(defvar helm-source-hayoo
  "Helm source for searching hayoo."
  '((name . "Hayoo")
    (volatile)
    (requires-pattern . 2)
    (action . (("Insert name" . (lambda (e)
                                  (progn (insert (assoc-default 'name e))
                                         (message (helm-hayoo-format-result e)))))
               ("Kill name" . (lambda (e) (kill-new (assoc-default 'name e))))))
    (candidates . helm-hayoo-search)))

(defun helm-hayoo ()
  "Preconfigured helm to search hajoo."
  (interactive)
  (helm :sources '(helm-source-hayoo)))

(provide 'helm-hayoo)
