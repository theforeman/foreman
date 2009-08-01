/*
Copyright (c) 2007 Brian Dillard and Brad Neuberg:
Brian Dillard | Project Lead | bdillard@pathf.com | http://blogs.pathf.com/agileajax/
Brad Neuberg | Original Project Creator | http://codinginparadise.org

SVN r113 from http://code.google.com/p/reallysimplehistory
+ Changes by Ed Wildgoose - MailASail
+ Changed EncodeURIComponent -> EncodeURI
+ Changed DecodeURIComponent -> DecodeURI
+ Changed 'blank.html?' -> '/blank.html?'
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
       dhtmlHistory: An object that provides history, history data, and bookmarking for DHTML and Ajax applications.
       
       dependencies:
               * the historyStorage object included in this file.

*/
window.dhtmlHistory = {
       
       /*Public: User-agent booleans*/
       isIE: false,
       isOpera: false,
       isSafari: false,
       isKonquerer: false,
       isGecko: false,
       isSupported: false,
       
       /*Public: Create the DHTML history infrastructure*/
       create: function(options) {
               
               /*
                       options - object to store initialization parameters
                       options.blankURL - string to override the default location of blank.html. Must end in "?"
                       options.debugMode - boolean that causes hidden form fields to be shown for development purposes.
                       options.toJSON - function to override default JSON stringifier
                       options.fromJSON - function to override default JSON parser
                       options.baseTitle - pattern for title changes; example: "Armchair DJ [@@@]" - @@@ will be replaced
               */

               var that = this;
               
               /*Set up the historyStorage object; pass in options bundle*/
               window.historyStorage.setup(options);
               
               /*Set up our base title if one is passed in*/
               if (options && options.baseTitle) {
                       if (options.baseTitle.indexOf("@@@") < 0 && historyStorage.debugMode) {
                               throw new Error("Programmer error: options.baseTitle must contain the replacement parameter"
                               + " '@@@' to be useful.");
                       }
                       this.baseTitle = options.baseTitle;
               }
               
               /*set user-agent flags*/
               var UA = navigator.userAgent.toLowerCase();
               var platform = navigator.platform.toLowerCase();
               var vendor = navigator.vendor || "";
               if (vendor === "KDE") {
                       this.isKonqueror = true;
                       this.isSupported = false;
               } else if (typeof window.opera !== "undefined") {
                       this.isOpera = true;
                       this.isSupported = true;
               } else if (typeof document.all !== "undefined") {
                       this.isIE = true;
                       this.isSupported = true;
               } else if (vendor.indexOf("Apple Computer, Inc.") > -1) {
                       this.isSafari = true;
                       this.isSupported = (platform.indexOf("mac") > -1);
               } else if (UA.indexOf("gecko") != -1) {
                       this.isGecko = true;
                       this.isSupported = true;
               }

               /*Create Safari/Opera-specific code*/
               if (this.isSafari) {
                       this.createSafari();
               } else if (this.isOpera) {
                       this.createOpera();
               }
               
               /*Get our initial location*/
               var initialHash = this.getCurrentLocation();

               /*Save it as our current location*/
               this.currentLocation = initialHash;

               /*Now that we have a hash, create IE-specific code*/
               if (this.isIE) {
                       /*Optionally override the URL of IE's blank HTML file*/
                       if (options && options.blankURL) {
                               var u = options.blankURL;
                               /*assign the value, adding the trailing ? if it's not passed in*/
                               this.blankURL = (u.indexOf("?") != u.length - 1
                                       ? u + "?"
                                       : u
                               );
                       }
                       this.createIE(initialHash);
               }

               /*Add an unload listener for the page; this is needed for FF 1.5+ because this browser caches all dynamic updates to the
               page, which can break some of our logic related to testing whether this is the first instance a page has loaded or whether
               it is being pulled from the cache*/

               var unloadHandler = function() {
                       that.firstLoad = null;
               };
               
               this.addEventListener(window,'unload',unloadHandler);          

               /*Determine if this is our first page load; for IE, we do this in this.iframeLoaded(), which is fired on pageload. We do it
               there because we have no historyStorage at this point, which only exists after the page is finished loading in IE*/
               if (this.isIE) {
                       /*The iframe will get loaded on page load, and we want to ignore this fact*/
                       this.ignoreLocationChange = true;
               } else {
                       if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
                               /*This is our first page load, so ignore the location change and add our special history entry*/
                               this.ignoreLocationChange = true;
                               this.firstLoad = true;
                               historyStorage.put(this.PAGELOADEDSTRING, true);
                       } else {
                               /*This isn't our first page load, so indicate that we want to pay attention to this location change*/
                               this.ignoreLocationChange = false;
                               this.firstLoad = false;
                               /*For browsers other than IE, fire a history change event; on IE, the event will be thrown automatically when its
                               hidden iframe reloads on page load. Unfortunately, we don't have any listeners yet; indicate that we want to fire
                               an event when a listener is added.*/
                               this.fireOnNewListener = true;
                       }
               }

               /*Other browsers can use a location handler that checks at regular intervals as their primary mechanism; we use it for IE as
               well to handle an important edge case; see checkLocation() for details*/
               var locationHandler = function() {
                       that.checkLocation();
               };
               setInterval(locationHandler, 100);
       },      
       
       /*Public: Initialize our DHTML history. You must call this after the page is finished loading. Optionally, you can pass your listener in
       here so you don't need to make a separate call to addListener*/
       initialize: function(listener) {

               /*save original document title to plug in when we hit a null-key history point*/
               this.originalTitle = document.title;
               
               /*IE needs to be explicitly initialized. IE doesn't autofill form data until the page is finished loading, so we have to wait*/
               if (this.isIE) {
                       /*If this is the first time this page has loaded*/
                       if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
                               /*For IE, we do this in initialize(); for other browsers, we do it in create()*/
                               this.fireOnNewListener = false;
                               this.firstLoad = true;
                               historyStorage.put(this.PAGELOADEDSTRING, true);
                       }
                       /*Else if this is a fake onload event*/
                       else {
                               this.fireOnNewListener = true;
                               this.firstLoad = false;  
                       }
               }
               /*optional convenience to save a separate call to addListener*/
               if (listener) {
                       this.addListener(listener);
               }
       },

       /*Public: Adds a history change listener. Only one listener is supported at this time.*/
       addListener: function(listener) {
               this.listener = listener;
               /*If the page was just loaded and we should not ignore it, fire an event to our new listener now*/
               if (this.fireOnNewListener) {
                       this.fireHistoryEvent(this.currentLocation);
                       this.fireOnNewListener = false;
               }
       },
       
       /*Public: Change the current HTML title*/
       changeTitle: function(historyData) {
               var winTitle = (historyData && historyData.newTitle
                       /*Plug the new title into the pattern*/
                       ? this.baseTitle.replace('@@@', historyData.newTitle)
                       /*Otherwise, if there is no new title, use the original document title. This is useful when some
                       history changes have title changes and some don't; we can automatically return to the original
                       title rather than leaving a misleading title in the title bar. The same goes for our "virgin"
                       (hashless) page state.*/
                       : this.originalTitle
               );
               /*No need to do anything if the title isn't changing*/
               if (document.title == winTitle) {
                       return;
               }


               /*Now change the DOM*/
               document.title = winTitle;
               /*Change it in the iframe, too, for IE*/
               if (this.isIE) {
                       this.iframe.contentWindow.document.title = winTitle;
               }
               
               /*If non-IE, reload the hash so the new title "sticks" in the browser history object*/
               if (!this.isIE && !this.isOpera) {
                       var hash = decodeURI(document.location.hash);
                       if (hash != "") {
                               var encodedHash = encodeURI(this.removeHash(hash));
                               document.location.hash = encodedHash;
                       } else {
                               //document.location.hash = "#";
                       }
               }
       },
       
       /*Public: Add a history point. Parameters available:
       * newLocation (required):
               This will be the #hash value in the URL. Users can bookmark it. It will persist across sessions, so
               your application should be able to restore itself to a specific state based on just this value. It
               should be either a simple keyword for a viewstate or else a pseudo-querystring.
       * historyData (optional):
               This is for complex data that is relevant only to the current browsing session. It will be available
               to your application until the browser is closed. If the user comes back to a bookmarked history point
               during a later session, this data will no longer be available. Don't rely on it for application
               re-initialization from a bookmark.
       * historyData.newTitle (optional):
               This will swap out the html <title> attribute with a new value. If you have set a baseTitle using the
               options bundle, the value will be plugged into the baseTitle by swapping out the @@@ replacement param.
       */
       add: function(newLocation, historyData) {
               
               var that = this;
               
               /*Escape the location and remove any leading hash symbols*/
               var encodedLocation = encodeURI(this.removeHash(newLocation));
               
               if (this.isSafari) {

                       /*Store the history data into history storage - pass in unencoded newLocation since
                       historyStorage does its own encoding*/
                       historyStorage.put(newLocation, historyData);

                       /*Save this as our current location*/
                       this.currentLocation = encodedLocation;
       
                       /*Change the browser location*/
                       window.location.hash = encodedLocation;
               
                       /*Save this to the Safari form field*/
                       this.putSafariState(encodedLocation);

                       this.changeTitle(historyData);

               } else {
                       
                       /*Most browsers require that we wait a certain amount of time before changing the location, such
                       as 200 MS; rather than forcing external callers to use window.setTimeout to account for this,
                       we internally handle it by putting requests in a queue.*/
                       var addImpl = function() {
                               
                               /*Indicate that the current wait time is now less*/
                               if (that.currentWaitTime > 0) {
                                       that.currentWaitTime = that.currentWaitTime - that.waitTime;
                               }

                               /*IE has a strange bug; if the encodedLocation is the same as _any_ preexisting id in the
                               document, then the history action gets recorded twice; throw a programmer exception if
                               there is an element with this ID*/
                               if (document.getElementById(encodedLocation) && that.debugMode) {
                                       var e = "Exception: History locations can not have the same value as _any_ IDs that might be in the document,"
                                       + " due to a bug in IE; please ask the developer to choose a history location that does not match any HTML"
                                       + " IDs in this document. The following ID is already taken and cannot be a location: " + newLocation;
                                       throw new Error(e);
                               }

                               /*Store the history data into history storage - pass in unencoded newLocation since
                               historyStorage does its own encoding*/
                               historyStorage.put(newLocation, historyData);

                               /*Indicate to the browser to ignore this upcomming location change since we're making it programmatically*/
                               that.ignoreLocationChange = true;

                               /*Indicate to IE that this is an atomic location change block*/
                               that.ieAtomicLocationChange = true;

                               /*Save this as our current location*/
                               that.currentLocation = encodedLocation;
                               
                               /*Change the browser location*/
                               window.location.hash = encodedLocation;

                               /*Change the hidden iframe's location if on IE*/
                               if (that.isIE) {
                                       that.iframe.src = that.blankURL + encodedLocation;
                               }

                               /*End of atomic location change block for IE*/
                               that.ieAtomicLocationChange = false;
                               
                               that.changeTitle(historyData);
                               
                       };

                       /*Now queue up this add request*/
                       window.setTimeout(addImpl, this.currentWaitTime);

                       /*Indicate that the next request will have to wait for awhile*/
                       this.currentWaitTime = this.currentWaitTime + this.waitTime;
               }
       },

       /*Public*/
       isFirstLoad: function() {
               return this.firstLoad;
       },

       /*Public*/
       getVersion: function() {
               return this.VERSIONNUMBER;
       },
       
       /*- - - - - - - - - - - -*/
       
       /*Private: Constant for our own internal history event called when the page is loaded*/
       PAGELOADEDSTRING: "DhtmlHistory_pageLoaded",
       
       VERSIONNUMBER: "0.8",
       
       /*
               Private: Pattern for title changes. Example: "Armchair DJ [@@@]" where @@@ will be relaced by values passed to add();
               Default is just the title itself, hence "@@@"
       */
       baseTitle: "@@@",
       
       /*Private: Placeholder variable for the original document title; will be set in ititialize()*/
       originalTitle: null,
       
       /*Private: URL for the blank html file we use for IE; can be overridden via the options bundle. Otherwise it must be served
       in same directory as this library*/
       blankURL: "/blank.html?",
       
       /*Private: Our history change listener.*/
       listener: null,

       /*Private: MS to wait between add requests - will be reset for certain browsers*/
       waitTime: 200,
       
       /*Private: MS before an add request can execute*/
       currentWaitTime: 0,

       /*Private: Our current hash location, without the "#" symbol.*/
       currentLocation: null,

       /*Private: Hidden iframe used to IE to detect history changes*/
       iframe: null,

       /*Private: Flags and DOM references used only by Safari*/
       safariHistoryStartPoint: null,
       safariStack: null,
       safariLength: null,

       /*Private: Flag used to keep checkLocation() from doing anything when it discovers location changes we've made ourselves
       programmatically with the add() method. Basically, add() sets this to true. When checkLocation() discovers it's true,
       it refrains from firing our listener, then resets the flag to false for next cycle. That way, our listener only gets fired on
       history change events triggered by the user via back/forward buttons and manual hash changes. This flag also helps us set up
       IE's special iframe-based method of handling history changes.*/
       ignoreLocationChange: null,

       /*Private: A flag that indicates that we should fire a history change event when we are ready, i.e. after we are initialized and
       we have a history change listener. This is needed due to an edge case in browsers other than IE; if you leave a page entirely
       then return, we must fire this as a history change event. Unfortunately, we have lost all references to listeners from earlier,
       because JavaScript clears out.*/
       fireOnNewListener: null,

       /*Private: A variable that indicates whether this is the first time this page has been loaded. If you go to a web page, leave it
       for another one, and then return, the page's onload listener fires again. We need a way to differentiate between the first page
       load and subsequent ones. This variable works hand in hand with the pageLoaded variable we store into historyStorage.*/
       firstLoad: null,

       /*Private: A variable to handle an important edge case in IE. In IE, if a user manually types an address into their browser's
       location bar, we must intercept this by calling checkLocation() at regular intervals. However, if we are programmatically
       changing the location bar ourselves using the add() method, we need to ignore these changes in checkLocation(). Unfortunately,
       these changes take several lines of code to complete, so for the duration of those lines of code, we set this variable to true.
       That signals to checkLocation() to ignore the change-in-progress. Once we're done with our chunk of location-change code in
       add(), we set this back to false. We'll do the same thing when capturing user-entered address changes in checkLocation itself.*/
       ieAtomicLocationChange: null,
       
       /*Private: Generic utility function for attaching events*/
       addEventListener: function(o,e,l) {
               if (o.addEventListener) {
                       o.addEventListener(e,l,false);
               } else if (o.attachEvent) {
                       o.attachEvent('on'+e,function() {
                               l(window.event);
                       });
               }
       },


       /*Private: Create IE-specific DOM nodes and overrides*/
       createIE: function(initialHash) {
               /*write out a hidden iframe for IE and set the amount of time to wait between add() requests*/
               this.waitTime = 400;/*IE needs longer between history updates*/
               var styles = (historyStorage.debugMode
                       ? 'width: 800px;height:80px;border:1px solid black;'
                       : historyStorage.hideStyles
               );
               var iframeID = "rshHistoryFrame";
               var iframeHTML = '<iframe frameborder="0" id="' + iframeID + '" style="' + styles + '" src="' + this.blankURL + initialHash + '"></iframe>';
               document.write(iframeHTML);
               this.iframe = document.getElementById(iframeID);
       },
       
       /*Private: Create Opera-specific DOM nodes and overrides*/
       createOpera: function() {
               this.waitTime = 400;/*Opera needs longer between history updates*/
               var imgHTML = '<img src="javascript:location.href=\'javascript:dhtmlHistory.checkLocation();\';" style="' + historyStorage.hideStyles + '" />';
               document.write(imgHTML);
       },
       
       /*Private: Create Safari-specific DOM nodes and overrides*/
       createSafari: function() {
               var formID = "rshSafariForm";
               var stackID = "rshSafariStack";
               var lengthID = "rshSafariLength";
               var formStyles = historyStorage.debugMode ? historyStorage.showStyles : historyStorage.hideStyles;
               var stackStyles = (historyStorage.debugMode
                       ? 'width: 800px;height:80px;border:1px solid black;'
                       : historyStorage.hideStyles
               );
               var lengthStyles = (historyStorage.debugMode
                       ? 'width:800px;height:20px;border:1px solid black;margin:0;padding:0;'
                       : historyStorage.hideStyles
               );
               var safariHTML = '<form id="' + formID + '" style="' + formStyles + '">'
                       + '<textarea style="' + stackStyles + '" id="' + stackID + '">[]</textarea>'
                       + '<input type="text" style="' + lengthStyles + '" id="' + lengthID + '" value=""/>'
               + '</form>';
               document.write(safariHTML);
               this.safariStack = document.getElementById(stackID);
               this.safariLength = document.getElementById(lengthID);
               if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
                       this.safariHistoryStartPoint = history.length;
                       this.safariLength.value = this.safariHistoryStartPoint;
               } else {
                       this.safariHistoryStartPoint = this.safariLength.value;
               }
       },
       
       /*TODO: make this public again?*/
       /*Private: Get browser's current hash location; for Safari, read value from a hidden form field*/
       getCurrentLocation: function() {
               var r = (this.isSafari
                       ? this.getSafariState()
                       : this.getCurrentHash()
               );
               return r;
       },
       
       /*TODO: make this public again?*/
       /*Private: Manually parse the current url for a hash; tip of the hat to YUI*/
   getCurrentHash: function() {
               var r = window.location.href;
               var i = r.indexOf("#");
               return (i >= 0
                       ? r.substr(i+1)
                       : ""
               );
   },
       
       /*Private: Safari method to read the history stack from a hidden form field*/
       getSafariStack: function() {
               var r = this.safariStack.value;
               return historyStorage.fromJSON(r);
       },
       /*Private: Safari method to read from the history stack*/
       getSafariState: function() {
               var stack = this.getSafariStack();
               var state = stack[history.length - this.safariHistoryStartPoint - 1];
               return state;
       },                      
       /*Private: Safari method to write the history stack to a hidden form field*/
       putSafariState: function(newLocation) {
           var stack = this.getSafariStack();
           stack[history.length - this.safariHistoryStartPoint] = newLocation;
           this.safariStack.value = historyStorage.toJSON(stack);
       },

       /*Private: Notify the listener of new history changes.*/
       fireHistoryEvent: function(newHash) {
               var decodedHash = decodeURI(newHash)
               /*extract the value from our history storage for this hash*/
               var historyData = historyStorage.get(decodedHash);
               this.changeTitle(historyData);
               /*call our listener*/
               this.listener.call(null, decodedHash, historyData);
       },
       
       /*Private: See if the browser has changed location. This is the primary history mechanism for Firefox. For IE, we use this to
       handle an important edge case: if a user manually types in a new hash value into their IE location bar and press enter, we want to
       to intercept this and notify any history listener.*/
       checkLocation: function() {
               
               /*Ignore any location changes that we made ourselves for browsers other than IE*/
               if (!this.isIE && this.ignoreLocationChange) {
                       this.ignoreLocationChange = false;
                       return;
               }

               /*If we are dealing with IE and we are in the middle of making a location change from an iframe, ignore it*/
               if (!this.isIE && this.ieAtomicLocationChange) {
                       return;
               }
               
               /*Get hash location*/
               var hash = this.getCurrentLocation();
               
               /*Do nothing if there's been no change*/
               if (hash == this.currentLocation) {
                       return;
               }
               
               /*In IE, users manually entering locations into the browser; we do this by comparing the browser's location against the
               iframe's location; if they differ, we are dealing with a manual event and need to place it inside our history, otherwise
               we can return*/
               this.ieAtomicLocationChange = true;

               if (this.isIE && this.getIframeHash() != hash) {
                       this.iframe.src = this.blankURL + hash;
               }
               else if (this.isIE) {
                       /*the iframe is unchanged*/
                       return;
               }

               /*Save this new location*/
               this.currentLocation = hash;

               this.ieAtomicLocationChange = false;

               /*Notify listeners of the change*/
               this.fireHistoryEvent(hash);
       },

       /*Private: Get the current location of IE's hidden iframe.*/
       getIframeHash: function() {
               var doc = this.iframe.contentWindow.document;
               var hash = String(doc.location.search);
               if (hash.length == 1 && hash.charAt(0) == "?") {
                       hash = "";
               }
               else if (hash.length >= 2 && hash.charAt(0) == "?") {
                       hash = hash.substring(1);
               }
               return hash;
       },

       /*Private: Remove any leading hash that might be on a location.*/
       removeHash: function(hashValue) {
               var r;
               if (hashValue === null || hashValue === undefined) {
                       r = null;
               }
               else if (hashValue === "") {
                       r = "";
               }
               else if (hashValue.length == 1 && hashValue.charAt(0) == "#") {
                       r = "";
               }
               else if (hashValue.length > 1 && hashValue.charAt(0) == "#") {
                       r = hashValue.substring(1);
               }
               else {
                       r = hashValue;
               }
               return r;
       },

       /*Private: For IE, tell when the hidden iframe has finished loading.*/
       iframeLoaded: function(newLocation) {
               /*ignore any location changes that we made ourselves*/
               if (this.ignoreLocationChange) {
                       this.ignoreLocationChange = false;
                       return;
               }

               /*Get the new location*/
               var hash = String(newLocation.search);
               if (hash.length == 1 && hash.charAt(0) == "?") {
                       hash = "";
               }
               else if (hash.length >= 2 && hash.charAt(0) == "?") {
                       hash = hash.substring(1);
               }
               /*Keep the browser location bar in sync with the iframe hash*/
               window.location.hash = hash;

               /*Notify listeners of the change*/
               this.fireHistoryEvent(hash);
       }


};

/*
       historyStorage: An object that uses a hidden form to store history state across page loads. The mechanism for doing so relies on
       the fact that browsers save the text in form data for the life of the browser session, which means the text is still there when
       the user navigates back to the page. This object can be used independently of the dhtmlHistory object for caching of Ajax
       session information.
       
       dependencies:
               * json2007.js (included in a separate file) or alternate JSON methods passed in through an options bundle.
*/
window.historyStorage = {
       
       /*Public: Set up our historyStorage object for use by dhtmlHistory or other objects*/
       setup: function(options) {
               
               /*
                       options - object to store initialization parameters - passed in from dhtmlHistory or directly into historyStorage
                       options.debugMode - boolean that causes hidden form fields to be shown for development purposes.
                       options.toJSON - function to override default JSON stringifier
                       options.fromJSON - function to override default JSON parser
               */
               
               /*process init parameters*/
               if (typeof options !== "undefined") {
                       if (options.debugMode) {
                               this.debugMode = options.debugMode;
                       }
                       if (options.toJSON) {
                               this.toJSON = options.toJSON;
                       }
                       if (options.fromJSON) {
                               this.fromJSON = options.fromJSON;
                       }
               }              
               
               /*write a hidden form and textarea into the page; we'll stow our history stack here*/
               var formID = "rshStorageForm";
               var textareaID = "rshStorageField";
               var formStyles = this.debugMode ? historyStorage.showStyles : historyStorage.hideStyles;
               var textareaStyles = (historyStorage.debugMode
                       ? 'width: 800px;height:80px;border:1px solid black;'
                       : historyStorage.hideStyles
               );
               var textareaHTML = '<form id="' + formID + '" style="' + formStyles + '">'
                       + '<textarea id="' + textareaID + '" style="' + textareaStyles + '"></textarea>'
               + '</form>';
               document.write(textareaHTML);
               this.storageField = document.getElementById(textareaID);
               if (typeof window.opera !== "undefined") {
                       this.storageField.focus();/*Opera needs to focus this element before persisting values in it*/
               }
       },
       
       /*Public*/
       put: function(key, value) {
               
               var encodedKey = encodeURI(key);
               
               this.assertValidKey(encodedKey);
               /*if we already have a value for this, remove the value before adding the new one*/
               if (this.hasKey(key)) {
                       this.remove(key);
               }
               /*store this new key*/
               this.storageHash[encodedKey] = value;
               /*save and serialize the hashtable into the form*/
               this.saveHashTable();
       },

       /*Public*/
       get: function(key) {

               var encodedKey = encodeURI(key);
               
               this.assertValidKey(encodedKey);
               /*make sure the hash table has been loaded from the form*/
               this.loadHashTable();
               var value = this.storageHash[encodedKey];
               if (value === undefined) {
                       value = null;
               }
               return value;
       },

       /*Public*/
       remove: function(key) {
               
               var encodedKey = encodeURI(key);

               this.assertValidKey(encodedKey);
               /*make sure the hash table has been loaded from the form*/
               this.loadHashTable();
               /*delete the value*/
               delete this.storageHash[encodedKey];
               /*serialize and save the hash table into the form*/
               this.saveHashTable();
       },

       /*Public: Clears out all saved data.*/
       reset: function() {
               this.storageField.value = "";
               this.storageHash = {};
       },

       /*Public*/
       hasKey: function(key) {
               
               var encodedKey = encodeURI(key);

               this.assertValidKey(encodedKey);
               /*make sure the hash table has been loaded from the form*/
               this.loadHashTable();
               return (typeof this.storageHash[encodedKey] !== "undefined");
       },

       /*Public*/
       isValidKey: function(key) {
               return (typeof key === "string");
               //TODO - should we ban hash signs and other special characters?
       },
       
       /*- - - - - - - - - - - -*/

       /*Private - CSS strings utilized by both objects to hide or show behind-the-scenes DOM elements*/
       showStyles: 'border:0;margin:0;padding:0;',
       hideStyles: 'left:-1000px;top:-1000px;width:1px;height:1px;border:0;position:absolute;',
       
       /*Private - debug mode flag*/
       debugMode: false,

       /*Private: Our hash of key name/values.*/
       storageHash: {},

       /*Private: If true, we have loaded our hash table out of the storage form.*/
       hashLoaded: false,

       /*Private: DOM reference to our history field*/
       storageField: null,

       /*Private: Assert that a key is valid; throw an exception if it not.*/
       assertValidKey: function(key) {
               var isValid = this.isValidKey(key);
               if (!isValid && this.debugMode) {
                       throw new Error("Please provide a valid key for window.historyStorage. Invalid key = " + key + ".");
               }
       },

       /*Private: Load the hash table up from the form.*/
       loadHashTable: function() {
               if (!this.hashLoaded) {
                       var serializedHashTable = this.storageField.value;
                       if (serializedHashTable !== "" && serializedHashTable !== null) {
                               this.storageHash = this.fromJSON(serializedHashTable);
                               this.hashLoaded = true;
                       }
               }
       },
       /*Private: Save the hash table into the form.*/
       saveHashTable: function() {
               this.loadHashTable();
               var serializedHashTable = this.toJSON(this.storageHash);
               this.storageField.value = serializedHashTable;
       },
       /*Private: Bridges for our JSON implementations - both rely on 2007 JSON.org library - can be overridden by options bundle*/
       toJSON: function(o) {
               return o.toJSONString();
       },
       fromJSON: function(s) {
               return s.parseJSON();
       }
};


/*******************************************************************/
/** QueryString Object from http://adamv.com/dev/javascript/querystring */
/* Client-side access to querystring name=value pairs
	Version 1.3
	28 May 2008
	
	License (Simplified BSD):
	http://adamv.com/dev/javascript/qslicense.txt
*/
function Querystring(qs) { // optionally pass a querystring to parse
	this.params = {};
	
	if (qs == null) qs = location.search.substring(1, location.search.length);
	if (qs.length == 0) return;

// Turn <plus> back to <space>
// See: http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4.1
	qs = qs.replace(/\+/g, ' ');
	var args = qs.split('&'); // parse out name/value pairs separated via &
	
// split out each name=value pair
	for (var i = 0; i < args.length; i++) {
		var pair = args[i].split('=');
		var name = decodeURI(pair[0]);
		
		var value = (pair.length==2)
			? decodeURI(pair[1])
			: name;
		
		this.params[name] = value;
	}
}

Querystring.prototype.get = function(key, default_) {
	var value = this.params[key];
	return (value != null) ? value : default_;
}

Querystring.prototype.contains = function(key) {
	var value = this.params[key];
	return (value != null);
}

/*******************************************************************/
/* Added by Ed Wildgoose - MailASail */
/* Initialise the library and add our history callback */
/*******************************************************************/
window.dhtmlHistory.create({
        toJSON: function(o) {
                return Object.toJSON(o);
        }
        , fromJSON: function(s) {
                return s.evalJSON();
        }
        
        // Enable this to assist with debugging
//        , debugMode: true

        // dhtmlHistory has been modified not to need the next line
        // But left in for robustness when updating dhtmlHistory
        , blankURL: '/blank.html?'
});

/** Our callback to receive history
    change events. */
var handleHistoryChange = function(pageId, pageData) {
  if (!pageData) return;
  var info = pageId.split(':');
  var id = info[0];
  pageData += '&_method=get';
  new Ajax.Updater(id+'-content', pageData, {asynchronous:true, evalScripts:true, method: 'get', onLoading:function(request){Element.show(id+'-pagination-loading-indicator');}});
}

window.onload = function() {
        dhtmlHistory.initialize(handleHistoryChange);
};

