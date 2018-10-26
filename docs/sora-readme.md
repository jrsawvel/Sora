# Sora README

*created Apr 10, 2018* - *updated Oct 24, 2018*

Sora is a web-based static site generator. Posts can be created and updated through the web browser. The app creates static HTML files that readers access.

Sora is built with the Lua programming language. Sora is based upon my Wren web publishing app that was created with Perl.

Test site: <http://sora.soupmode.com>.



### Brief Description


* Built with Lua and the Mustache template system.
* API-based, using REST and JSON.
* No database.
* Single-user mode only.
* Logging in only requires an email address. A password is never used.
* Markup support: Markdown and HTML. 
* Simple and enhanced writing areas.
* JSON feed for posts sorted by created date. The format is based upon the [Reece-Simmons spec](https://jsonfeed.org).
* HTML feed (h-feed) page exists that is marked up with Microformats, according to the IndieWeb h-entry spec.
* [RSS 3.0 feed support](http://sora.soupmode.com/2018/08/21/rss-30-jokey-but-useful-spec.html).
* Responsive web design.
* Client-side JavaScript is used only with the editor.
* Reading time and word count are calculated for each post.
* Each post is saved as .html, .txt, and .json.
* Custom CSS can be included within the markup for a post.
* Custom JSON can be output that overrides the default JSON that would represent a post.



### Longer Description

Sora is a web-based, static site, blog tool that does not use a database. 

Sora requires the user to create most of the functions that would be automatically created in most "normal" web publishing apps.

For example, the homepage is not automatically generated. The index.html files that are located in the root directory and in sub-directories get created and updated like a regular article post.

The same applies to archives and tag-related pages. My other web publishing apps automatically support hashtag searches. Not Sora. The Sora author must create the hashtag links the HTML pages for each tag. And the author must add the link to the post to each tag-related page.

It's a slower way to produce content, which may mean staying more focused and writing when having something important to create, instead of saving and commenting on every link encountered. And I like the freedom of a blank canvas with minimal constraints.

Sora posts can be created and updated through a web browser on a desktop/laptop or on a mobile device. 

Sora has an API, which can be accessed with command prompt utilities or [curl](https://curl.haxx.se/). The Sora API doc describes how to use it. 

**To-Do:** I need to enable the API to support "Preview" when access has no authentication. Preview will return the formatted post, which could be saved on a local hard drive. 

When logging into a Sora site, it uses a no-password login mechanism. The author submits an email address, and the login activation link is emailed to the address listed within the Sora YAML configuration file. The app uses [MailGun](http://www.mailgun.com/) to send these emails.

With Sora, text can be formatted using [Markdown](https://daringfireball.net/projects/markdown/) and HTML commands.

In recent years, I've tried to minimize the formatting that I do for a web article. Keep it simple. And Markdown satisfies my needs, nearly all of the time.

When Sora creates a new post, Sora automatically generates a sidefile page called `hfeed.html` that is an HTML feed or [h-feed](http://microformats.org/wiki/h-feed) page, based upon [Microformats](http://microformats.org/) usage, suggested by the IndieWeb, specifically [h-entry](http://indieweb.org/h-entry).

One or two feed readers, built by IndieWeb advocates, support consuming content syndicated by RSS, Atom, maybe JSON Feed, and h-feed.

If a website organizes content from youngest to oldest, which can be the homepage or a sidefile page that supports h-entry Microformats, then that HTML page can be submitted as the feed page to readers that support h-feed.

Instead of creating RSS, Atom, or JSON feed pages, a website only has to add Microformats to its already existing HTML stream page, which is the hompage for many blog sites. But at the moment, feed reader support for h-feed is limited.

For search, Google and/or DuckDuckGo can be used, but I rely mainly on Sora's simple, built-in search mechanism. At the moment, the search forms are manually setup by creating an HTML page like any other article. The Sora User Guide doc contains the HTML code that can be used for a search page. I should  make this its own template.

When logged into Sora through a web browser, the author enters the commands in the URL after the site's domain name.

* `/sora/create`
* `/sora/update/file.html` 
* or `/sora/update/2016/03/24/file.html`
* `/sora/login`
* `/sora/logout`




---


In nature, a Sora is a water bird that inhabits marshes. It's more often heard than seen. It vocalizes loudly, but it remains secretive, hiding in the vegetaion. Occasionally, I see one wade through shallow water, along the boardwalk at Magee Marsh Wildlife Area.

<http://www.audubon.org/field-guide/bird/sora>

<https://www.allaboutbirds.org/guide/Sora/>


