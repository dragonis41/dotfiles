// ==UserScript==
// @name         pierro-astro Right-Click and Selection Enabler
// @namespace    http://tampermonkey.net/
// @version      2025-06-02
// @description  Re-enables right-click and text selection on websites with disabled interactions
// @author       dragonis41
// @match        https://www.pierro-astro.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to fully enable interactions
    function enableInteractions() {
        // Remove right-click prevention globally
        document.oncontextmenu = null;
        window.oncontextmenu = null;

        // Re-enable text selection
        function enableSelection(element) {
            if (element) {
                element.style.userSelect = 'text';
                element.style.webkitUserSelect = 'text';
                element.style.mozUserSelect = 'text';
                element.style.msUserSelect = 'text';
            }
        }

        // Enable selection on the entire document
        enableSelection(document.body);

        // Re-enable image interactions
        const images = document.getElementsByTagName('img');
        for (let img of images) {
            // Remove any existing event listeners that prevent right-click
            img.oncontextmenu = null;

            // Optional: Add default browser context menu back
            img.addEventListener('contextmenu', function(e) {
                e.stopPropagation(); // Stop propagation of any parent prevention
            }, false);
        }

        // Remove event listeners that prevent selection
        document.addEventListener('selectstart', function(e) {
            e.stopPropagation();
        }, true);

        // Remove any existing selection prevention scripts
        const scripts = document.getElementsByTagName('script');
        for (let script of scripts) {
            if (script.textContent.includes('disableSelection') ||
                script.textContent.includes('contextmenu')) {
                script.remove();
                }
        }

        console.log('Right-click, text selection, and image interactions re-enabled');
    }

    // Ensure the script runs after the page is fully loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', enableInteractions);
    } else {
        enableInteractions();
    }

    // Additional fallback to catch any late-loading content
    //window.addEventListener('load', enableInteractions);
})();
