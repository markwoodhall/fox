(var current-command [])
(var commands {})

(var tmp-cmd "")
(var tmp-args [])
(fn save-current-command []
  (let [len (length current-command)]
    (when (> len 0)
      (for [i 0 len]
        (if (= i 1)
          (set tmp-cmd (. current-command i))
          (when (> i 1)
            (table.insert tmp-args (. current-command i)))))
      (tset commands tmp-cmd tmp-args)
      (set tmp-cmd "")
      (set tmp-args []))))

(fn start-new-command [val]
  (save-current-command)
  (set current-command [val]))

(fn append-to-current-command [val]
  (if (> (length current-command) 0)
    (table.insert current-command val)))

(fn parse [arg]
  (for [i 0 (length arg)]
    (let [val (. arg i)]
      (match val
        "--help" (start-new-command "help")
        "-h" (start-new-command "help")
        "-?" (start-new-command "help")
        "help" (start-new-command "help")

        "--version" (start-new-command "version")
        "-v" (start-new-command "version")

        "-o" (start-new-command "output")
        "--out" (start-new-command "output")
        "--output" (start-new-command "output")

        _ (append-to-current-command val))))
  (save-current-command)
  commands)

{: parse }
