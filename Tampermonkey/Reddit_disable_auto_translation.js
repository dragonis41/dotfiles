// ==UserScript==
// @name         Reddit disable auto translation
// @namespace    http://tampermonkey.net/
// @version      2025-05-19
// @description  Removes the ?tl=fr argument from Reddit URLs
// @author       Ja_Shi
// @match        *://*.reddit.com/*
// @grant        none
// ==/UserScript==

(function() {
  'use strict';
  let url = new URL(window.location.href);
  if (url.searchParams.has('tl')) {
	url.searchParams.delete('tl');
	window.history.replaceState(null, '', url);
	window.location.reload();
  }
})();
