# Wren Features not Included with Sora

*created Apr 10, 2018* - *updated May 21, 2018*

While Sora is based upon Wren, many features that exist in Wren were left out of Sora, at least for now. 

The following Wren features have not been added to Sora.

* An additional no-password login method that uses the Indieweb.org's IndieAuth.
* Markup support for Multimarkdown and Textile.
* Additional custom commands to control formatting and functionality of a post. 
* Headings can be used to create a table of contents for the page. 
* RSS feed for posts sorted by created date.
* Creates a sitemap.xml file, according to Google's definition.
* Option to copy .html and .txt files to an AWS S3 bucket after creates and updates.
* Accepts the IndieWeb.org's version of pingback or replies, called Webmentions, which is a cross-site commenting, liking, and sharing mechanism.
* Sends Webmention replies to other websites.
* Supports the IndieWeb Micropub spec on the server, which permits creating posts by using Micropub-supported clients, created by others.
* Newlines or hard line breaks are preserved and get converted to the HTML BR tag. This default behavior can be overridden per above.
* If desired, raw URLs can be converted to clickable links with a custom command.
* image header command for formatting a page. 
* description command that can be used as sub-title text to display over the image header.
* `reply_to : URL` command exists to create a Webmention reply post to the listed URL. Wren will automatically send the reply to the domain name listed within the URL for the post being replied to. 
* `syn_to : twitter` command. this tells Wren to syndicate the newly created post to Twitter or to whatever service is listed. Wren will make a Webmention post to brid.gy], which will make the post to the user's Twitter account. the Wren user must register at brid.gy. if other Twitter users reply to the tweet, brid.gy will grab that info and post it to the Wren website as a Webmention.
* Microformats used on each post. **[late April 2018 update: Microformats were added to the templates.]**
* Additional Microformats used, according to IndieWeb concepts. 
* HTML 5 semantic tags. **[late April 2018 update: some HTML5 semantic tags were added to the templates.]**



