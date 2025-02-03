(local {: traceback : getinfo : view} (require :fennel))

(local default-options {:out (fn [...] (_G.io.stderr:write ...))
                        :prefix :ic|
                        :include-context true
                        :enabled true
                        : traceback})

(local options (collect [k v (pairs default-options)]
                 (values k v)))

(fn get-debug-info [level]
  (let [info (getinfo level :Sln)]
    (if (= info.namewhat "[C]")
        (getinfo (+ level 1) :Sln)
        info)))

(fn format-location [loc ?filename]
  (if ?filename (.. loc " <" ?filename ">") loc))

(fn format-values [serialized ...]
  (icollect [i expr (ipairs serialized)]
    (let [arg (select i ...)
          val (view arg)]
      (case (type arg)
        :function val
        _ (if (= expr val)
              val
              (.. expr " " val))))))

(fn format-output [level serialized ...]
  (let [{: short_src : currentline : name} (get-debug-info level)
        location (if options.include-context?
                     (-> (.. short_src ":" currentline)
                         (format-location name)
                         (.. ": "))
                     "")
        header (if (= nil options.prefix)
                   location
                   (.. options.prefix " " location))]
    (if (= 0 (select "#" ...))
        (.. header " " (or (and options.traceback (options.traceback 3)) ""))
        (.. header (table.concat (format-values serialized ...) ", ")))))

(fn inspect [serialized ...]
  (when options.enabled
    (options.out (format-output 4 serialized ...) "\n"))
  ...)

{: inspect : default-options : options :version :0.1.0}
