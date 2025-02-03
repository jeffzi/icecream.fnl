;; fennel-ls: macro-file
(local {: view} (require :fennel))
(local {: find : gsub} string)
(local icecream (case ...
                  (where s (find s :icecream$)) (gsub s :icecream$
                                                      :icecream.icecream)
                  _ (or ... :icecream)))

(fn ic [...]
  "Macro for debug printing values with context."
  (let [serialized (icollect [_ v (ipairs [...])]
                     (view v))]
    `(let [{:inspect inspect#} (require ,icecream)
           out# (inspect# ,serialized ,...)]
       ;; avoid tail call for debug.getinfo
       out#)))

(fn ic-config [options]
  "Configure ic options with an options table."
  ;; (assert (and options (not (. options 1))) "Missing options table")
  (when options
    (let [{: default-options} (require icecream)]
      (each [k _ (pairs options)]
        (assert-compile (. default-options k) (.. k " is not a valid option.")
                        options))))
  `(let [{:options options#} (require ,icecream)]
     (when ,options
       (each [k# v# (pairs ,options)]
         (tset options# k# v#)))
     options#))

{: ic : ic-config}
