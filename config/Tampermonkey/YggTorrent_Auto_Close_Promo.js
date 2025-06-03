// ==UserScript==
// @name         YggTorrent Auto Close Promo
// @namespace    http://tampermonkey.net/
// @version      2025-05-20
// @description  Ferme automatiquement les fenêtres de promo sur yggtorrent.top
// @author       dragonis41
// @match        https://www.yggtorrent.top/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Fonction pour cliquer sur le bouton de fermeture
    function clickPromoCloseButton() {
        const closeButtons = document.querySelectorAll('.promo-close');

        if (closeButtons && closeButtons.length > 0) {
            console.log('YggTorrent Auto Close: Bouton de fermeture trouvé, clic en cours...');
            closeButtons.forEach(button => button.click());
        } else {
            console.log('YggTorrent Auto Close: Bouton de fermeture non trouvé');
        }
    }

    // Exécute immédiatement et périodiquement au cas où la promo apparaît après chargement
    clickPromoCloseButton();

    // Observer les changements dans le DOM pour détecter l'apparition de nouvelles promos
    //const observer = new MutationObserver(function(mutations) {
    //    clickPromoCloseButton();
    //});

    // Observer tout le document pour les modifications
    //observer.observe(document.body, { childList: true, subtree: true });
})();
