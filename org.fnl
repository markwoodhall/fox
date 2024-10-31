(fn title [org]
  (let [t (string.gmatch org "%#%+TITLE:%s%w+")
        t (t)]
    (when t
      (string.gsub t "%#%+TITLE: " ""))))

(fn headings [org]
  (let [t (string.gmatch org "%*%s([%C]+)")]
    (icollect [v t]
      v)))

(fn ->org [org]
  {:title (title org)
   :headings (headings org)})

(comment
  (let [o (require :org)]
    (o.->org "#+TITLE: Fox\n* Fox\nThis is fox.\n\n* Fox 2\nThis is fox 2.")))

{ : ->org }
