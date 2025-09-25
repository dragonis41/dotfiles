// ==UserScript==
// @name         Fix Pyro-Fêtes Password Autofill
// @namespace    http://tampermonkey.net/
// @version      2025-09-23
// @description  Fix password manager autofill for Pyro-Fêtes login
// @author       dragonis41
// @match        https://pyrofetes.pyrogestion.com/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    // Find the login and password fields
    const loginField = document.querySelector('input[name="login"]');
    const passwordField = document.querySelector('input[name="pass"]');

    if (loginField && passwordField) {
        // Remove the onclick handlers that clear the fields
        loginField.removeAttribute('onclick');
        passwordField.removeAttribute('onclick');

        // Clear placeholder values only when user starts typing
        if (loginField.value === 'IDENTIFIANT') {
            loginField.addEventListener('focus', function() {
                if (this.value === 'IDENTIFIANT') {
                    this.value = '';
                }
            });
        }

        if (passwordField.value === 'MOT DE PASSE') {
            passwordField.addEventListener('focus', function() {
                if (this.value === 'MOT DE PASSE') {
                    this.value = '';
                }
            });
        }

        // Add proper autocomplete attributes to help password managers
        loginField.setAttribute('autocomplete', 'username');
        passwordField.setAttribute('autocomplete', 'current-password');

        // Give password managers time to fill the fields
        setTimeout(() => {
            // If password manager filled the fields, don't show placeholders
            if (loginField.value && loginField.value !== 'IDENTIFIANT') {
                loginField.style.color = '#000'; // Ensure text is visible
            }
            if (passwordField.value && passwordField.value !== 'MOT DE PASSE') {
                passwordField.style.color = '#000'; // Ensure text is visible
            }
        }, 500);
    }
})();