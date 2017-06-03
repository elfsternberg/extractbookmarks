#!/usr/local/bin/hy

(def *version* "0.0.2")

(import os re sys html2text
        [slugify [slugify]]
        [datetime [datetime]]
        [xml.etree.ElementTree :as ET])

(defn process-date [ndate]
  (let [d (.strptime datetime ndate "%Y%m%dT%H%M%SZ")]
    (.strftime d "%Y-%m-%d %a %H:%M")))

(def body-wrap (re.compile "^.*<en-note>(.*?)</en-note>"))
(def htmparser (.HTML2Text html2text))

(def post-body-clean-re (re.compile "^\* \* \*"))

(defn process-body [body]
  (let [post-body (.sub body-wrap "\\1" (. body text))
        markdown (htmparser.handle (.sub post-body-clean-re "" post-body))]
    (->> markdown
         (.sub post-body-clean-re ""))))

(defn process-note [note]
  (let [url (if (not (= None (note.find ".//source-url")))
              (. (note.find ".//source-url") text)
              None)
        title (. (note.find "title") text)
        created-date (. (note.find "created") text)
        updated-date (if (note.find "updated") (. (note.find "updated") text) "")
        tags (+ ":" (.join ":" (map (fn [a] (. a text)) (note.findall "tag"))) ":")
        body (note.find "content")]
    (, title (.join "\n" (+ ["#+STARTUP: showall "
                             ""
                             (if url 
                               (.format "** [[{}][{}]] {}" url title tags)
                               (.format "** {} {}" title tags))
                             ":PROPERTIES:"
                             (.format ":created: [{}]" (process-date created-date))]
                            (if updated-date
                              [(.format ":updated: [{}]" (process-date updated-date))] [])
                            [":END" "" (process-body body) ""])))))

(defmain [&rest args]
  (try
   (let [filename (get args 1)
         tree (ET.parse filename)
         root (.getroot tree)
         notes (root.iter "note")]
     (with [bmarks (open "Bookmarks.org" "a")]
       (.write bmarks "* Bookmarks\n\n")
       (for [note notes]
         (let [(, title content) (process-note note)
               slug (slugify title)]
           (with [hndl (open  (.format "{}.org" (slugify title)) "w")]
             (.write hndl content))
           (.write bmarks (.format "** [[file:./{}.org][{}]]\n\n" (slugify title) title))))))))
