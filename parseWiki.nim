import re, strutils, json, httpclient, strutils, os

var
  client = newHttpClient()
  forum_url = "https://forums.freeside.co.uk"
  content = client.getContent(forum_url & "/c/wiki.json").parseJson
  topics = content["topic_list"]["topics"]
for topic in topics.items:
  var id = topic["id"].getInt()
  var raw_post = client.getContent(forum_url &  "/raw/" & intToStr(id))
  var slug = topic["slug"].getStr()
  var title = topic["title"].getStr()

  var front_matter = """
---
layout: page
title: $1
permalink: /wiki/$2.html
categories: [wiki]
---
"""

  var page = front_matter.format(title, slug) & raw_post
  if not existsDir("_pages"):
        createDir("_pages")
  writeFile("_pages/" & topic["slug"].getStr() & ".md", page)
  if not existsDir("uploads/default/original/1X/"):
        createDir("uploads/default/original/1X/")
  for image in findAll(raw_post, re"<img[^>]+src='([^'>]+)'"):
    var src = image[11..^2]
    echo src
    client.downloadFile("https://forums.freeside.co.uk/" & src, src)
