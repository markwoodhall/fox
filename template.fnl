(fn apply-variable [variable value html]
  (string.gsub
    html
    variable
    value))

(fn apply-title [title html]
  (apply-variable
    "${title}"
    title
    html))

(fn apply-css [css html]
  (apply-variable
    "${css}"
    (.. "<link rel=\"stylesheet\" href=\"" css "\">")
    html))

(fn apply-template [data html]
  (->> 
    html
    (apply-css data.css)
    (apply-title data.org.title)))

{: apply-template }
