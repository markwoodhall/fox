(local file (require :file))
(local templates (require :template))
(local org (require :org))

(fn org->html [in template opts out]
  (let [template (file.read template)
        org-file (file.read in)]
    (when (and org-file template)
      (let [org-data (org.->org org-file)
            _ (set opts.org org-data)
            html (templates.apply-template opts template)]
        (if out 
          (file.write out html)
          html)))))

{: org->html }
