(fn info [...]
  (when (os.getenv "VERBOSE")
    (print ...)))

(fn warn [...]
  (when (not (os.getenv "SILENT"))
    (print ...)))

{: info : warn}
