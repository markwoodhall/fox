(local args (require :args))
(local display (require :display))
(local fox (require :fox))

(fn display-help []
  (io.stderr:write
   (.. "Usage: fox [options] [command]\n\n"
       "    Options\n"
       "    [-v, --version                       Display fox version number]\n"
       "\n"
       "    Help:\n"
       "    Set VERBOSE environment variable for info level logging\n"
       )))

(fn main []
  (let [arguments (args.parse arg)]
    (if arguments.help
        (display-help)
        arguments.version
        "v0.0.0"
        arguments.html
        (display.render
          (fox.org->html 
            (?. arguments.org 1) 
            (or (?. arguments.template 1) "templates/simple.html")
            {:css (?. arguments.css 1)
             :head (?. arguments.head 1)
             :header (?. arguments.header 1)
             :footer (?. arguments.footer 1)})
          (?. arguments.output 1)
          io.stdout))))

;; give better tracebacks in development
(xpcall main #(match (pcall require :fennel)
                (true {: traceback}) (print $ (traceback))
                _ (print $ (debug.traceback))))
