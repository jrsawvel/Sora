
/*
@licstart  The following is the entire license notice for the 

    tanager.js - web browser editor or conduit between writer and 
    web server publishing API code.

    Copyright (C) 2017 - John Sawvel - jr@sawv.org

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

@licend  The above is the entire license notice for the JavaScript code in this page.
*/


var keyCounter=0;
var autoSaveInterval=300000   // in milliseconds. default = 5 minutes.
var intervalID=0;
var prevLength=0;
var currLength=0;
var isFocus=0;


var $ = document; // shortcut


function countKeyStrokes () {
    keyCounter++;    
}


$.addEventListener("DOMContentLoaded", function() {

//    jQuery( window ).bind( 'resize', sync_panels ).trigger( 'resize' );

    window.onresize = sync_panels;

    var handler = window.onresize;
    handler();

    onkeydown = function(e){
        if(e.ctrlKey && e.keyCode == 'P'.charCodeAt(0)){
        //  if(e.ctrlKey && e.shiftKey && e.keyCode == 'P'.charCodeAt(0)){
            e.preventDefault();
            previewPost();
        }

        if(e.ctrlKey && e.keyCode == 'S'.charCodeAt(0)){
            e.preventDefault();
            keyCounter++; // force a save even if no editing occurred since user clicked the save link.
            savePost();
        }

        if(e.ctrlKey && e.keyCode == 'U'.charCodeAt(0)){
            e.preventDefault();
            singleScreenMode();
        }

        // bare minimum view. large textarea box only. no border. no nav bar. no other links. no buttons.
        if(e.ctrlKey && e.keyCode == 'J'.charCodeAt(0)){
            e.preventDefault();
            // document.getElementsByTagName('body')[0].style.background = "#fff";
            $.body.style.background = "#fff";
            $.getElementById('navmenu').style.display = "none";
            $.getElementById('tx_input').style.background = "#fff";
            $.getElementById('tx_input').style.border = "none";
            $.getElementById('tx_input').style.color = "#222";
            $.getElementById('col_left').style.padding = "1em 0 0 0";
            singleScreenMode();
        }

        // display a 5-line text area box
        if(e.ctrlKey && e.keyCode == 'H'.charCodeAt(0)){
            e.preventDefault();
            $.body.style.background = "#fff";
            $.getElementById('navmenu').style.display = "none";
            $.getElementById('tx_input').style.background = "#fff";
            $.getElementById('tx_input').style.border = "none";
            $.getElementById('tx_input').style.color = "#222";
            $.getElementById('tx_input').style.height = "150px";
            $.getElementById('tx_input').style.margin = "30% 0 0 0";
            $.getElementById('col_left').style.padding = "1em 0 0 0";

            isFocus=1;
            singleScreenMode();
        }

        if(e.ctrlKey && e.keyCode == 'B'.charCodeAt(0)){
            e.preventDefault();
            $.body.style.background = "#ddd";
            $.getElementById('navmenu').style.display = "inline";
            $.getElementById('tx_input').style.background = "#f8f8f8";
            $.getElementById('tx_input').style.border = "1px solid #bbb";
            $.getElementById('tx_input').style.color = "#222";
            $.getElementById('col_left').style.padding = "0";

            if ( isFocus ) {            
                $.getElementById('tx_input').style.margin = "0 0 0 0";
                $.getElementById('tx_input').style.height = "100%";

                ifFocus=0;
            }
            splitScreenMode();
        }

        if(e.ctrlKey && e.keyCode == 'D'.charCodeAt(0)){
            e.preventDefault();
            $.body.style.background = "#181818";
            $.getElementById('tx_input').style.background = "#181818";
            $.getElementById('tx_input').style.color = "#c0c0c0";
        }
    }

    // autosave every five minutes
    //    setInterval(function(){savePost()},300000); 
    intervalID = setInterval(function(){savePost()},autoSaveInterval); 


// ******************** 
// SINGLE-SCREEN MODE
// ******************** 

    $.getElementById('moveButton').onclick = singleScreenMode;

    function singleScreenMode () {
        fadeOut($.getElementById('text_preview'));
        fadeIn($.getElementById('tx_input')); // it seems this is unnecessary
        $.getElementById('col_left').className = "singlecol"; // change css class from "col" to "singlecol"
        $.getElementById('col_right').className = "col"; // change css class from "prevsinglecol" to "col"
        $.getElementById('col_right').style.cssFloat = "right";
        $.getElementById('col_right').style.position = "relative";
        $.getElementById('tx_input').focus();
    }


// ******************** 
// SPLIT-SCREEN MODE
// ******************** 

    $.getElementById('resetButton').onclick = splitScreenMode;

    function splitScreenMode () { 
        fadeIn($.getElementById('tx_input'));
        fadeIn($.getElementById('text_preview'));

        $.getElementById('col_left').className = "col"; // change css class from "singlecol" to "col"
        $.getElementById('col_right').className = "col"; // change css class from "prevsinglecol" to "col"

        $.getElementById('col_right').style.cssFloat = "right";
        $.getElementById('col_right').style.position = "relative";
        $.getElementById('tx_input').focus();
    }


// **********
// PREVIEW
// ********** 

    $.getElementById('previewButton').onclick = previewPost;

    function previewPost () { 
     
        var col_type = $.getElementById('col_left').className;

        if ( col_type === "singlecol" ) { 
            $.getElementById('col_left').className = "col"; // change css class from "singlecol" to "col"

            fadeOut($.getElementById('tx_input'));

            $.getElementById('col_right').className = "prevsinglecol"; // change css class from "col" to "prevsinglecol"

            $.getElementById('col_right').style.cssFloat = "normal";
            $.getElementById('col_right').style.position = "absolute";
            fadeIn($.getElementById('text_preview'));
        } 

        var markup = $.getElementById('tx_input').value;

        var regex = /^autosave=(\d+)$/m;
        var myArray;
        if ( myArray = regex.exec(markup) ) {
            if ( myArray[1] > 0  &&  (myArray[1] * 1000) != autoSaveInterval ) {
                autoSaveInterval = myArray[1] * 1000; 
                clearInterval(intervalID);
                intervalID = setInterval(function(){savePost()},autoSaveInterval); 
            }
        }

        var previewing = true;

        doPreviewOrSave(markup, previewing);

    } // end preview post function


// **********
// SAVE
// ********** 

    $.getElementById('saveButton').onclick = forceSave;

    function forceSave () {
        keyCounter++;
        savePost();
    }

    function savePost () {
        var markup = $.getElementById('tx_input').value;

        currLength = markup.length;

        if ( keyCounter == 0 && currLength == prevLength ) {
            return;
        }
    
        prevLength = currLength; 
        keyCounter=0;
 
        var col_type = $.getElementById('col_left').className;

        var previewing = false;

        doPreviewOrSave(markup, previewing);


    } // end save function



    function getHiddenHTMLValues() {
   
        var hv = { 
            action:   $.getElementById('tanageraction').value,
            // cgiapp:   $.getElementById('tanagercgiapp').value,
            apiurl:   $.getElementById('tanagerapiurl').value,        
            postrev:  $.getElementById('tanagerpostrev').value,
            postid:   $.getElementById('tanagerpostid').value
        };

        return hv;
    } 

    function getCookie(c_name) {
        var c_value = $.cookie;
        var c_start = c_value.indexOf(" " + c_name + "=");
        if (c_start == -1) {
            c_start = c_value.indexOf(c_name + "=");
        }
        if (c_start == -1) {
            c_value = null;
        }
        else {
            c_start = c_value.indexOf("=", c_start) + 1;
            var c_end = c_value.indexOf(";", c_start);
            if (c_end == -1) {
                c_end = c_value.length;
            }
            c_value = unescape(c_value.substring(c_start,c_end));
        }
        return c_value;
    }

    function sync_panels () {
        var col = $.getElementById('col_left');
        var md  = $.getElementById('tx_input');
        // ???       var tally = jQuery('body > h1').outerHeight();
        var tally = null;
        var elements = col.children;

        [].forEach.call(elements, function(item) {
            tally += outerHeight(item);
        });

        var space = col.offsetHeight - ( tally - outerHeight(md) );

        $.getElementById('tx_input').style.height= space + "px";
        $.getElementById('text_preview').style.height= space + "px";
    }

    function outerHeight(el) {
        var height = el.offsetHeight;
        var style = getComputedStyle(el);
        height += parseInt(style.marginTop) + parseInt(style.marginBottom);
       return height;
    }


    // http://www.chrisbuttery.com/articles/fade-in-fade-out-with-javascript/
    // fade out
    function fadeOut(el){
        el.style.opacity = 1;

        (function fade() {
            if ((el.style.opacity -= .1) < 0) {
                el.style.display = "none";
            } else {
                requestAnimationFrame(fade);
            }
        })();
    }

    // fade in
    function fadeIn(el, display){
        el.style.opacity = 0;
        el.style.display = display || "block";

        (function fade() {
            var val = parseFloat(el.style.opacity);
            if (!((val += .1) > 1)) {
                el.style.opacity = val;
                requestAnimationFrame(fade);
            }
        })();
    }

    function doPreviewOrSave(markup, preview_flag) {

        var hv = getHiddenHTMLValues();

        var action  = hv.action;
//        var cgiapp  = hv.cgiapp;
        var apiurl  = hv.apiurl;
        var postrev = hv.postrev;
        var postid  = hv.postid;

        markup=escape(markup);

        if ( preview_flag ) {
            sbtype = "Preview";
        } else if ( action === "updateblog" ) {
            sbtype = "Update";
        } else {
            sbtype = "Create";
        }

        var myRequest = {         // create a request object that can be serialized via JSON
            author:      getCookie('soraauthor_name'),
            session_id:  getCookie('sorasession_id'),
            rev:         getCookie('sorarev'),
            submit_type: sbtype,
            form_type:   'ajax',
            markup:      markup,
            crossDomain: true,
            original_slug:     postid,
        };

        var json_str = JSON.stringify(myRequest);       
  
        var request = new XMLHttpRequest();

        if ( action === "updateblog" ) {
            request.open('PUT', apiurl + '/posts', true);
        } else {
            request.open('POST', apiurl + '/posts', true);
        }

        request.withCredentials = true;
        request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');

        request.onload = function() {
            if (request.status >= 200 && request.status < 400) {
                var resp = request.responseText;
                var obj = JSON.parse(resp);
                if ( obj['post_type'] == "article" ) {
                    $.getElementById('text_preview').innerHTML = '<h1>' + obj['title'] + '</h1>' + obj['html'];
                } else {
                    $.getElementById('text_preview').innerHTML = obj['html'];
                }
                if ( sbtype === "Create" || sbtype === "Update" ) {
                    $.getElementById('saveposttext').style.color = "#fff"; 
                    $.getElementById('saveposttext').style.background= "#000"; 
                    setTimeout(function() {$.getElementById('saveposttext').style.color = "#f8f8f8"}, 2000);
                    setTimeout(function() {$.getElementById('saveposttext').style.background= "#f8f8f8"}, 2000);
                    $.getElementById('tanageraction').value =   'updateblog';
                    $.getElementById('tanagerpostid').value =   obj['slug'];
                    $.getElementById('tanagerpostrev').value =  obj['rev']; 
                    $.getElementById('ct').innerHTML = 'saved:' + obj['created_time'];
                }
                $.getElementById('wc').innerHTML = 'wc:' + obj['word_count'];
                $.getElementById('rt').innerHTML = 'rt:' + obj['reading_time'];
            } else {
                // reached the target server, but it returned an error
                var resp = request.responseText;
                var obj = JSON.parse(resp);
                $.getElementById('text_preview').innerHTML = '<h1>Error</h1>' + obj['user_message'] + ' ' + obj['system_message'];
            }
        };

        request.onerror = function() {
            // There was a connection error of some sort
            $.getElementById('text_preview').innerHTML = '<h1>Server Connection Error</h1> Unable to connect to ' + apiurl + '/posts';
        };

        request.send(json_str);
    }

}); // end

// may need to reference this for cors or cross domain posting
// http://stackoverflow.com/questions/5584923/a-cors-post-request-works-from-plain-javascript-but-why-not-with-jquery
// or at http://blog.garstasio.com/you-dont-need-jquery/ajax/#cors

