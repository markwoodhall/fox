(local args (require :args))
(local display (require :display))

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
        (display.render 
          {:version "0.0.0"} 
          (?. arguments.output 1) 
          io.stdout))))

;; give better tracebacks in development
(xpcall main #(match (pcall require :fennel)
                (true {: traceback}) (print $ (traceback))
                _ (print $ (debug.traceback))))
