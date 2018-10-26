# Sora User Guide

*created Apr 10, 2018* - *updated Oct 26, 2018*

The commands below will follow `http://yourdomain`.


### Login

Sora is a single-user app. No account creation process exists, and Sora supports a no-password login mechanism. 

To receive the login activation link, a user visits `/sora/login` and enters the email address stored in the Sora YAML configuration file.

If the email address entered matches, then Sora sends a message that contains the login activation link.

The login link can be used only one time. The link contains session information related to the login.



### Create a Post

Sora posts can be created and updated through a web browser on a desktop/laptop computer or on a mobile device. 

The author visits `/sora/create`. A large textarea box is displayed. This can be used to preview and create a post, or the JavaScript editor can be used by clicking the "editor" link, located on the same page as the textarea box.



### Update a Post

While viewing the web page to edit, the author interjects into the URL `/sora/update` between the site's domain name and the name of the web page.

This will display the post in a large textarea box. The author can choose to edit the post within the JavaScript editor by clicking the "editor" link.



### Logout

`/sora/logout`



### Markup

Sora supports Markdown and HTML.

Sora supports the following custom formatting command:

* `c. c..` - to be used around a large code block when indenting each line with four spaces is tedious.





### Power Commands

Special Sora commands are listed within HMTL comments in the markup.

* `<!-- slug : slugname -->` - example for the homepage = `slug:index`
* `<!-- dir:directory-location -->` - example = `dir:2006/03/24`
* `<!-- template : customarticle -->`
* `<!-- url_to_link : [yes|no] -->` - the default is "no". if set to "yes", then raw URLs get converted to clickable links.

CSS can be included, which can override the default CSS or to add new display options.

To use custom CSS in a post, do the following:

    <!-- css_start 
    body {background: yellow;}
    css_end --> 

The starting and ending comment lines must occur at the beginning of a line.

Custom JSON can be output that overrides the default JSON that would be created to represent a post.

    <!-- json_start
    {
      "items": [
       {
          "date_published": "2018-04-27T18:43:02Z",
          "id": "http://sora.soupmode.com/feed1442.html",
          "url": "http://sora.soupmode.com/feed1442.html",
          "content_text": "custom json feed test 27apr2018 1442"
       },
      ...
    json_end -->
    


### Files

To access the markup text version of a post, replace `.html` at the end of the URL with `.txt`.

To access the JSON version of a post, replace `.html` or `.txt` at the end of the URL with `.json`.

Sora maintains a list of all links to posts in a file called `links.json`. Sora uses this file to create `feed.json` and `hfeed.html`. 

`hfeed.html` lists the most recent posts in an HTML file that uses [Microformats](http://microformats.org/wiki/microformats2). Some [Indieweb users](https://indiewebcamp.com/) prefer to syndicate their content by marking up their HTML files with Microformats. These HTML pages are called h-feeds. Parsers would read a user's homepage or a sidefile page, such as Sora's hfeed.html, to create a feed to be read by someone else, instead of accessing the author's RSS feed.



### Configuration

In the Sora YAML configuration file, the following directories need to be specified. The first two should be created outside of document root.

*  `markup_storage : /home/sora/markup` - for easy download, backup
*  `session_id_storage : /home/sora/sessionids`
*  `versions_storage : <html doc root>/versions`
*  `searches_storage:  /home/sora/searches`
*  `links_json_file_storage: /home/sora/filelist`



### Search

Create an article page with the following input form fields.

Sora's built-in search:

    <p>
     <form action="/sora/search" method="post">
      <input size="31" type="text" name="keywords" autofocus>
      <input class="submitbutton" type=submit name=sb value="Sora Search">
     </form>
    </p>


If Google has indexed the site, then include the following HTML to get Google search results:

    <p>
     <form method="GET" action="http://www.google.com/search">
      <input type="text" name="q" size="31" maxlength="255" value="">
      <input class="submitbutton" type=submit name=btnG VALUE="Google Search">
      <input type=hidden name=domains value="http://yoursite.com">
      <input type=hidden name=sitesearch value="http://yoursite.com">
     </form>
    </p>




