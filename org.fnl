(fn title [org]
  (let [t (string.gmatch org "%#%+TITLE:%s%w+")
        t (t)]
    (when t
      (string.gsub t "%#%+TITLE: " ""))))

(fn ->org [org]
  {:title (title org)})

{: title
 : ->org }
