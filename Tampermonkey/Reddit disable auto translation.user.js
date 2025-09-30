// ==UserScript==
// @name         Reddit disable auto translation
// @namespace    http://tampermonkey.net/
// @version      2025-09-30
// @description  Disable Reddit's auto translation by removing the ?tl=fr argument and turning off the translation button
// @author       dragonis41
// @match        *://*.reddit.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';

    // Remove tl parameter from URL immediately
    let url = new URL(window.location.href);
    if (url.searchParams.has('tl')) {
        url.searchParams.delete('tl');
        window.history.replaceState(null, '', url);
        window.location.reload();
        return;
    }

    // Flag to prevent multiple executions
    let isProcessing = false;
    let hasProcessed = false;

    // Function to find the translation switch in shadow DOM
    function findTranslationSwitch() {
        const translationButton = document.querySelector('hui-translation-button');
        if (!translationButton || !translationButton.shadowRoot) return null;

        const shadowRoot = translationButton.shadowRoot;

        // Direct path to switch
        let switchElement = shadowRoot.querySelector('#hui-translation-switch');
        if (switchElement) return switchElement;

        // Check in dropdown menu
        const dropdownMenu = shadowRoot.querySelector('faceplate-dropdown-menu');
        if (dropdownMenu && dropdownMenu.shadowRoot) {
            switchElement = dropdownMenu.shadowRoot.querySelector('#hui-translation-switch');
            if (switchElement) return switchElement;
        }

        // Check deeper in menu structure
        const menuItems = shadowRoot.querySelectorAll('faceplate-switch-input');
        for (let item of menuItems) {
            if (item.id === 'hui-translation-switch') return item;
        }

        return null;
    }

    // Quick disable function
    function quickDisableTranslations() {
        // Prevent multiple executions
        if (isProcessing || hasProcessed) return false;

        const translationButton = document.querySelector('hui-translation-button');
        if (!translationButton || !translationButton.shadowRoot) return false;

        const shadowRoot = translationButton.shadowRoot;
        const menuButton = shadowRoot.querySelector('#translation-menu-button');

        if (menuButton) {
            isProcessing = true;

            // Check if translations are already disabled before opening menu
            const existingSwitch = findTranslationSwitch();
            if (existingSwitch) {
                const isChecked = existingSwitch.hasAttribute('checked') ||
                                existingSwitch.getAttribute('aria-checked') === 'true';
                if (!isChecked) {
                    console.log('Tampermonkey : Translations already disabled');
                    hasProcessed = true;
                    isProcessing = false;
                    return true;
                }
            }

            // Open menu
            menuButton.click();

            // Process and close menu
            setTimeout(() => {
                const translationSwitch = findTranslationSwitch();
                if (translationSwitch) {
                    const isChecked = translationSwitch.hasAttribute('checked') ||
                                    translationSwitch.getAttribute('aria-checked') === 'true';

                    if (isChecked) {
                        console.log('Tampermonkey : Disabling translations...');
                        translationSwitch.click();
                    }

                    // Always close menu after processing
                    setTimeout(() => {
                        if (menuButton.getAttribute('aria-expanded') === 'true') {
                            menuButton.click();
                        }
                        hasProcessed = true;
                        isProcessing = false;
                    }, 150);
                } else {
                    // Close menu if switch not found
                    if (menuButton.getAttribute('aria-expanded') === 'true') {
                        menuButton.click();
                    }
                    isProcessing = false;
                }
            }, 150);

            return true;
        }
        return false;
    }

    // Single observer instance
    let mainObserver = null;

    // Start observing for translation button
    function startObserving() {
        if (mainObserver) return; // Prevent multiple observers

        mainObserver = new MutationObserver((mutations) => {
            if (hasProcessed) {
                mainObserver.disconnect();
                return;
            }

            // Look for translation button appearance
            if (document.querySelector('hui-translation-button')) {
                quickDisableTranslations();
                // Don't disconnect immediately - wait for process to complete
                setTimeout(() => {
                    if (hasProcessed && mainObserver) {
                        mainObserver.disconnect();
                        mainObserver = null;
                    }
                }, 1000);
            }
        });

        if (document.body) {
            mainObserver.observe(document.body, {
                childList: true,
                subtree: true
            });
        }
    }

    // Start observing when body is available
    if (document.body) {
        startObserving();
    } else {
        const bodyObserver = new MutationObserver(() => {
            if (document.body) {
                bodyObserver.disconnect();
                startObserving();
            }
        });
        bodyObserver.observe(document.documentElement, {
            childList: true,
            subtree: true
        });
    }

    // Monitor for navigation changes (Reddit SPA)
    let lastUrl = location.href;
    new MutationObserver(() => {
        const url = location.href;
        if (url !== lastUrl) {
            lastUrl = url;
            // Reset flags for new page
            hasProcessed = false;
            isProcessing = false;
            // Restart observation
            startObserving();
            setTimeout(quickDisableTranslations, 500);
        }
    }).observe(document, { subtree: true, childList: true });

})();
