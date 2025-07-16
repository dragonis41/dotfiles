// ==UserScript==
// @name         meteoblue autoclose adBlocker alert
// @namespace    http://tampermonkey.net/
// @version      2025-07-16
// @description  Auto close banner against adblocklers
// @author       dragonis41
// @match        https://www.meteoblue.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=meteoblue.com
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    function closePopup() {
        // Remove the unblock class from body (this is what the close button does)
        document.body.classList.remove('unblock');

        // Optionally remove the popup div as well
        const popup = document.querySelector('.unblock-div');
        if (popup) {
            popup.remove();
        }

        console.log('Tampermonkey : Popup closed by removing unblock class');
        return true;
    }

    // Try immediately
    setTimeout(closePopup, 500);

    // Watch for the unblock class being added
    const observer = new MutationObserver(function(mutations) {
        if (document.body.classList.contains('unblock')) {
            closePopup();
        }
    });

    // Observe body for class changes
    observer.observe(document.body, {
        attributes: true,
        attributeFilter: ['class']
    });
})();
