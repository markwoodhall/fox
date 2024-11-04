(fn apply-variable [variable value html]
  (string.gsub
    html
    variable
    value))

(fn apply-footer [footer html]
  (->> html
       (apply-variable
         "${footer}"
         (or footer "Generated by Fox"))))

(fn apply-css [css html]
  (let [css-href (if css (.. "<link rel=\"stylesheet\" href=\"" css "\">") "")]
    (apply-variable
      "${css}"
      css-href
      html)))

(fn apply-node [nodes type]
  (accumulate [acc "" 
               _ [node-type node] (ipairs nodes)]
    (.. 
      acc
      (if (= type node-type)
        node
        "")
      )))

(fn apply-text [text]
  (accumulate [acc ""
               _ [type data] (ipairs text)]
    (.. acc
        (case type
          :begin-bold "<b>"
          :end-bold "</b>"
          :begin-italic "<i>"
          :end-italic "</i>"
          :begin-inline "<code>"
          :end-inline "</code>"
          :words (?. data 1)
          :links (accumulate [links "" _ [href desc] (ipairs data)]
                   (.. links "<a href=\"" href "\">" desc "</a> "))))))

(fn apply-nodes [nodes]
  (accumulate [acc "" 
               _ [node-type node] (ipairs nodes)]
    (.. 
      acc
      (case node-type
        :heading-1 (.. "<h1>" node "</h1>")
        :heading-2 (.. "<h2>" node "</h2>")
        :heading-3 (.. "<h3>" node "</h3>")
        :heading-4 (.. "<h4>" node "</h4>")
        :ol (.. "<ol><li>" node "</li>")
        :ul (.. "<ul><li>" node "</li>")
        :ol-li (.. "<li>" node "</li>")
        :ul-li (.. "<li>" node "</li>")
        :begin-quote "<blockquote>"
        :end-quote "</blockquote>"
        :begin-export ""
        :end-export ""
        :begin-src "<pre><code>"
        :end-src "</code></pre>"
        :text (.. "<p>" (apply-text node) "</p>")
        :export node
        :html node
        :code (.. (string.gsub node "%s" "&nbsp;") "<br />")
        :block-text (.. node "<br />")
        _ "")
      )))

(fn apply-main [nodes html]
  (apply-variable 
    "${main}"
    (apply-nodes nodes)
    html))

(fn apply-title [nodes html]
  (apply-variable 
    "${title}"
    (apply-node nodes :meta-title)
    html))

(fn apply-header [nodes html]
  (apply-variable 
    "${header}"
    (apply-node nodes :meta-title)
    html))

(fn apply-template [data html]
  (->> 
    html
    (apply-css data.css)
    (apply-title data.org)
    (apply-header data.org)
    (apply-main data.org)
    (apply-footer data.footer)))

{: apply-template }
