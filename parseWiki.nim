import re, strutils, json, httpclient, strutils, os

# The front matter is required for jekyll to recognise the file.
let front_matter = """
---
layout: page
title: $1
permalink: /wiki/$2
categories: [wiki]
---
"""

let forum_url = "https://forums.freeside.co.uk"

#Make page folder
if not existsDir("_pages"):
  createDir("_pages")


# Make image folder
if not existsDir("uploads/default/original/1X/"):
  createDir("uploads/default/original/1X/")


# Get topics list
var client = newHttpClient()
let
  content = client.getContent(forum_url & "/c/wiki.json").parseJson
  topics = content["topic_list"]["topics"]

# Loop over topics saving them to file
for topic in topics.items:
  let
    id = topic["id"].getInt()
    raw_post = client.getContent(forum_url &  "/raw/" & intToStr(id))
    slug = topic["slug"].getStr()
    title = topic["title"].getStr()
    page = front_matter.format(title, slug) & raw_post

  writeFile("_pages/" & slug & ".md", page)
  echo "Saving page: \"" & title & "\""

  # Download images used in posts
  for image in findAll(raw_post, re"<img[^>]+src='([^'>]+)'"):
    let src = image[11..^2]
    echo "Downloading image: " & src
    client.downloadFile("https://forums.freeside.co.uk/" & src, src)
