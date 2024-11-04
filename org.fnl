(local meta-title "^%#%+TITLE:%s")

(local begin-quote "%#%+BEGIN_QUOTE%s?")
(local end-quote "%#%+END_QUOTE%s?")

(local begin-export "%#%+BEGIN_EXPORT")
(local end-export "%#%+END_EXPORT")

(local html "%#%+HTML:%s")

(local begin-src "%#%+BEGIN_SRC")
(local end-src "%#%+END_SRC")

(local heading-1 "^%*%s")
(local heading-2 "^%*%*%s")
(local heading-3 "^%*%*%*%s")
(local heading-4 "^%*%*%*%*%s")

(local begin-ol "^%s*1%.%s")
(local begin-ul "^%s*[%+%-]%s")

(local list-item "%s+[%+%-]%s")
(local ordered-list-item "^%s+[%d]%.%s")

(local starts-bold "%*(%C)")
(local ends-bold "(%C)%*")

(local starts-strike "%+(%S)")
(local ends-strike "(%C)%+")

(local starts-underline "%_(%S)")
(local ends-underline "(%C)%_")

(local starts-italic "%/(%C)")
(local ends-italic "(%C)%/")

(local starts-inline "[%~%=](%C)")
(local ends-inline "(%C)[%~%=]")

(local empty "^[%S%c]")

(var in-block false)
(var in-src false)
(var in-export false)

(var lists [])

(local lines-done [])

(fn last [c]
  (?. c (length c)))

(fn take [c i]
  (table.move c 1 i 1 []))

(fn but-last [c]
  (take c (- (length c) 1)))

(fn indented-by [v]
  (var seen-non-whitespace false)
  (accumulate [i 0 v (string.gmatch v ".")]
    (do 
      (when (not seen-non-whitespace)
        (if (= v " ")
          (set i (+ 1 i))
          (set seen-non-whitespace true))) 
      i)))

(fn decorate-text [text t]
  (do 
    (when (string.match text starts-bold)
      (table.insert t [:begin-bold]))
    (when (string.match text starts-italic)
      (table.insert t [:begin-italic]))
    (when (string.match text starts-inline)
      (table.insert t [:begin-inline]))
    (when (string.match text starts-strike)
      (table.insert t [:begin-strike]))
    (when (string.match text starts-underline)
      (table.insert t [:begin-underline]))
    (let [cleaned (string.gsub text "^[%*%/%~%+%_]" "")
          cleaned (string.gsub cleaned "[%*%/%~%+%_]%s$" " ")]
      (table.insert t [:words [cleaned]]))
    (when (string.match text ends-underline)
      (table.insert t [:end-underline]))
    (when (string.match text ends-strike)
      (table.insert t [:end-strike]))
    (when (string.match text ends-bold)
      (table.insert t [:end-bold]))
    (when (string.match text ends-italic)
      (table.insert t [:end-italic]))
    (when (string.match text ends-inline)
      (table.insert t [:end-inline]))
    t))

(fn parse-text [text]
  (accumulate [acc [] v (string.gmatch text "%S+%S?%s?")]
    (decorate-text v acc)))

(fn node [type v r]
    (case type
      :begin-quote (set in-block true)
      :begin-src (set in-src true)
      :begin-export (set in-export true)
      :begin-ol (table.insert lists :ol)
      :begin-ul (table.insert lists :ul)
      :end-quote (set in-block false)
      :end-src (set in-src false)
      :end-export (set in-export false))

    (let [before (when (and (> (length lists) 0) 
                            (< (indented-by v) (indented-by (last lines-done)))) 
                   (let [t (last lists)]
                     (set lists (but-last lists))
                     t))
          s (string.gsub v r "")]
      [type (if 
              (= type :li)
              (parse-text s)
              (= type :begin-ol)
              (parse-text s)
              (= type :begin-ul)
              (parse-text s)
              s) before]))

(fn parse [org]
  (icollect [_ v (ipairs org)]
    (let [out 
          (if 
            (string.match v meta-title) (node :meta-title v meta-title)

            (string.match v heading-1) (node :heading-1 v heading-1)
            (string.match v heading-2) (node :heading-2 v heading-2)
            (string.match v heading-3) (node :heading-3 v heading-3)
            (string.match v heading-4) (node :heading-4 v heading-4)
            (string.match v html) (node :html v html)

            (string.match v begin-quote) (node :begin-quote "" begin-quote)
            (string.match v end-quote) (node :end-quote "" end-quote)

            (string.match v begin-ol) (node :begin-ol v begin-ol)
            (and 
              (> (indented-by v) (indented-by (last lines-done)))
              (string.match v begin-ul)) (node :begin-ul v begin-ul)

            (string.match v list-item) (node :li v list-item)
            (string.match v ordered-list-item) (node :li v ordered-list-item)

            (string.match v begin-export) (node :begin-export "" begin-export)
            (string.match v end-export) (node :end-export "" end-export)

            (string.match v begin-src) (node :begin-src "" begin-src)
            (string.match v end-src) (node :end-src "" end-src)

            (= v "") (node :empty "" empty)

            (if 
              in-block 
              [:block-text v] 
              in-export
              [:export v]
              in-src
              [:code v]
              [:text (parse-text v)]))]
      (when (not (= v "")) (table.insert lines-done v))
      out)))
      

(comment
  (lset [f (require :file)
        o (require :org)]
    (o.parse (f.read "readme.org"))))

{: parse }
