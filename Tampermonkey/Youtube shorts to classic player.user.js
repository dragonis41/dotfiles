// ==UserScript==
// @name         Youtube shorts to classic player
// @namespace    http://tampermonkey.net/
// @version      2025-06-09
// @description  Redirect short videos to classic player
// @author       dragonis41
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @exclude      https://studio.youtube.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @grant        none
// ==/UserScript==

function redirect() {
    const isShorts = location.pathname.startsWith('/shorts/')
    if (isShorts) {
        const newUrl = location.href.replace('/shorts/', '/watch?v=')
        location.replace(newUrl)
    }
}

document.addEventListener('yt-navigate-start', redirect)
redirect()
