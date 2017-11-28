(in-package :serapeum.tests)

(def-suite definitions :in serapeum)
(in-suite definitions)

;;; Note that the defalias forms come *after* the tests. The real test
;;; here is not the tests themselves, but that we don't get warnings
;;; about x1, x2, &c. being undefined.

(test defalias
  (is (fboundp 'x1))
  (is (eql 'x (x1))))

(defalias x1 (constantly 'x))

(test let-over-defalias
  (is (fboundp 'x2))
  (is (eql 'x (x2))))

(let ((x 'x))
  (defalias x2 (lambda () x)))

(test flet-over-defalias
  (is (fboundp 'x3))
  (is (eql 'x (x3))))

(flet ((x () 'x))
  (defalias x3 #'x))

(test labels-over-defalias
  (is (fboundp 'x4))
  (is (eql 'x (x4))))

(labels ((x () 'x))
  (defalias x4 #'x))

(define-do-macro %do-each ((var seq &optional ret) &body body)
  `(map nil (lambda (,var) ,@body) ,seq))

(define-do-macro %do-hash (((key var) hash-table &optional ret) &body body)
  `(maphash (lambda (,key ,var) ,@body) ,hash-table))

(test define-do-macro
  (local
    (let ((seq #(1 2 3 4 5)))
      (seq= seq
            (collecting
              (%do-each (x seq nil) (collect x)))))

    (let ((hash (dict :x 1 :y 2 :z 3)))
      (is (set-equal '(1 2 3)
                     (collecting
                       (%do-hash ((key var) hash)
                                 (declare (ignore key))
                                 (collect var)))))

      (is (eql 'done
               (%do-hash ((key var) hash 'done)
                         (declare (ignore key var))))))))
