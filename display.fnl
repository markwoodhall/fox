(local json (require :lib.dkjson))

(fn print-json [data out]
  (when (. out :write)
    (out:write (json.encode data))))

(fn render [data format out]
  (match format
    "json" (print-json data out)
    "raw" (print data)
    _ (render data "json" out)))

{: render}
