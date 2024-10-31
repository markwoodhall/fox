(local log (require :log))

(fn exists? [path]
  (let [f (io.open path)]
    (if f
        (do (f:close) true))))

(fn read [path]
  (if (exists? path)
    (match (io.open path)
      f (with-open [f f]
          (let [data (f:read :*all)]
            data))
      _ (log.warn path "not found;"))
    (log.warn path "not found;")))

(fn write [path data]
  (with-open [f (io.open path :w)]
    (io.output f)
    (io.write data)))

{: read
 : write }
