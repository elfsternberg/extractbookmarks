#!/usr/local/bin/hy

(def *version* "0.0.2")

(import os re sys html2text
        requests
        [slugify [slugify]]
        [datetime [datetime]]
        [bs4 [BeautifulSoup]]
        [xml.etree.ElementTree :as ET])

(def search-date (re.compile "saved by \S+ on (.*)"))

(defn extract-date [infoblock]
  (let [datetext (.group (.search search-date infoblock) 1)
        dateparse (.strptime datetime datetext "%B %d, %Y")]
    (.strftime dateparse "%Y-%m-%d %a 00:00")))

(defn extract-tags [tags]
  (map (fn [li] (. li text)) (.find-all tags "li")))

(defn get-details [article]
  (let [anchor (. (.find article "h3") a)
        title (. anchor text)
        info (.find article "div" :class "articleInfoPan")
        url (-> info (. p) (. a) (. text))
        created-date (extract-date (. info text))
        desc (.find article "div" :class "thumbTBriefTxt")
        rawtags (list (extract-tags desc))
        comment (.join " " (map (fn [i] (. i text)) (.find-all desc "p")))
        tags (if (> (len rawtags) 0) (+ ":" (.join ":" rawtags) ":") "")] 
    (print (.format "** [[{}][{}] {}" url title tags))
    (print ":PROPERTIES:")
    (print (.format ":created: [{}]" created-date))
    (print ":END")
    (print "")
    (if (> (len comment) 0)
      (do (print comment)
          (print "")))))

(defn process-page [html]
  (let [soup (BeautifulSoup html "lxml")
        articles (.find-all soup "div" :class "articleThumbBlockOuter")]
    (for [article articles] (get-details article))
    (let [nexturl (.find soup "a" {"aria-label" "Next"})]
      (if nexturl
        (+ "https://del.icio.us" (get nexturl "href"))
        None))))

(defn process-request [url]
  (let [req (requests.get url)
        html (. req text)]
    (process-page html)))

(defmain [&rest args]
  (try
   (let [nexturl (get args 1)]
     (while nexturl
       (def nexturl (process-request nexturl))))))

