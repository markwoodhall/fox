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

(local unordered-list "^%s+[%+%-]")
(local ordered-list "^%s+[%d]%.%s")

(local link "%[%[%C+%]%[%C+%]%]")
(local link-part "%[%[(%C+)%]%[(%C+)%]%]")

(local starts-bold "%*(%C)")
(local ends-bold "(%C)%*")

(local starts-italic "%/(%C)")
(local ends-italic "(%C)%/")

(local starts-inline "%~(%C)")
(local ends-inline "(%C)%~")

(var in-block false)
(var in-src false)
(var in-export false)

(fn node [type v r]

  (case type
    :begin-quote (set in-block true)
    :begin-src (set in-src true)
    :begin-export (set in-export true)
    :end-quote (set in-block false)
    :end-src (set in-src false)
    :end-export (set in-export false))

  (let [s (string.gsub v r "")]
    [type s]))

(fn decorate-text [text t]
  (do 
    (when (string.match text starts-bold)
      (table.insert t [:begin-bold]))
    (when (string.match text starts-italic)
      (table.insert t [:begin-italic]))
    (when (string.match text starts-inline)
      (table.insert t [:begin-inline]))
    (table.insert t [:words [(string.gsub text "[%*%/%~]" "")]])
    (when (string.match text ends-bold)
      (table.insert t [:end-bold]))
    (when (string.match text ends-italic)
      (table.insert t [:end-italic]))
    (when (string.match text ends-inline)
      (table.insert t [:end-inline]))
    t))

(fn parse-text [text]
  (accumulate [acc [] v (string.gmatch text "%S+%S?%s?")]
    (if (string.match v link) 
      (do 
        (table.insert 
            acc 
            [:links (icollect [l l2 (string.gmatch v link-part)] 
                      [l l2])])
        acc)
      (decorate-text v acc))))

(fn parse [org]
  (icollect [v (string.gmatch org "%C+%C")]
    (if 
      (string.match v meta-title) (node :meta-title v meta-title)

      (string.match v heading-1) (node :heading-1 v heading-1)
      (string.match v heading-2) (node :heading-2 v heading-2)
      (string.match v heading-3) (node :heading-3 v heading-3)
      (string.match v heading-4) (node :heading-4 v heading-4)
      (string.match v html) (node :html v html)
      (string.match v unordered-list) (node :ul v unordered-list)
      (string.match v ordered-list) (node :ol v ordered-list)

      (string.match v begin-quote) (node :begin-quote "" begin-quote)
      (string.match v end-quote) (node :end-quote "" end-quote)

      (string.match v begin-export) (node :begin-export "" begin-export)
      (string.match v end-export) (node :end-export "" end-export)

      (string.match v begin-src) (node :begin-src "" begin-src)
      (string.match v end-src) (node :end-src "" end-src)

      (if 
        in-block 
        [:block-text v] 
        in-export
        [:export v]
        in-src
        [:code v]
        [:text (parse-text v)]))))

(comment
  (let [f (require :file)
        o (require :org)]
    (o.parse (f.read "readme.org"))))

{: parse }
