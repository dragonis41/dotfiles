// ==UserScript==
// @name         YggTorrent Auto Close Promo
// @namespace    http://tampermonkey.net/
// @version      2025-05-20
// @description  Automatically close yggtorrent.top promotion banner
// @author       dragonis41
// @match        https://www.yggtorrent.top/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to automatically click on the close button
    function clickPromoCloseButton() {
        const closeButtons = document.querySelectorAll('.promo-close');

        if (closeButtons && closeButtons.length > 0) {
            console.log('Tampermonkey : Found promo close button, clicking...');
            closeButtons.forEach(button => button.click());
        } else {
            console.log('Tampermonkey : No promo close button found');
        }
    }

    // Execute the function now
    clickPromoCloseButton();

    // Watch for changes on the page in case the banner appears later
    //const observer = new MutationObserver(function(mutations) {
    //    clickPromoCloseButton();
    //});

    // Watch for changes on the whole document
    //observer.observe(document.body, { childList: true, subtree: true });
})();
