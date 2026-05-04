// ==UserScript==
// @name         X.com Blocked account counter
// @namespace    http://tampermonkey.net/
// @version      2026-02-17
// @description  Auto-scrolling to count blocked accounts
// @author       dragonis41
// @match        https://x.com/settings/blocked/all
// @match        https://twitter.com/settings/blocked/all
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    const blockedRegistry = new Set();
    let isScrolling = false;
    let scrollInterval;
    let lastScrollPos = 0;
    let stagnationCount = 0;

    const container = document.createElement('div');
    container.style.cssText = 'position:fixed;top:60px;right:20px;padding:20px;background:#1d9bf0;color:white;border-radius:15px;font-weight:bold;z-index:9999;box-shadow:0 4px 15px rgba(0,0,0,0.5);font-family:sans-serif;text-align:center;min-width:160px;';

    container.innerHTML = `
        <div style="margin-bottom:5px;font-size:12px;text-transform:uppercase;letter-spacing:1px;">Blocked Total</div>
        <div id="block-num" style="font-size:36px;margin-bottom:15px;text-shadow: 2px 2px 4px rgba(0,0,0,0.2);">0</div>
        <button id="scroll-btn" style="cursor:pointer;padding:10px;border:none;border-radius:20px;background:white;color:#1d9bf0;font-weight:bold;width:100%;transition:0.2s;">Start Scrolling</button>
        <div id="status-msg" style="font-size:11px;margin-top:10px;font-style:italic;">Ready to Scan</div>
    `;
    document.body.appendChild(container);

    const updateCount = () => {
        // We look for spans starting with @ specifically in the main timeline area
        const handles = document.querySelectorAll('span');
        handles.forEach(span => {
            const text = span.innerText;
            if (text.startsWith('@')) {
                blockedRegistry.add(text);
            }
        });
        document.getElementById('block-num').innerText = blockedRegistry.size.toLocaleString();
    };

    const toggleScroll = () => {
        const btn = document.getElementById('scroll-btn');
        const status = document.getElementById('status-msg');

        if (!isScrolling) {
            isScrolling = true;
            btn.innerText = 'Stop Scrolling';
            btn.style.background = '#ff4444';
            btn.style.color = 'white';
            status.innerText = 'Scrolling...';
            status.style.color = 'white';
            stagnationCount = 0;

            scrollInterval = setInterval(() => {
                window.scrollBy(0, 100);
                updateCount();

                const currentScroll = window.scrollY + window.innerHeight;
                const totalHeight = document.documentElement.scrollHeight;

                if (currentScroll >= totalHeight - 10) {
                    if (window.scrollY === lastScrollPos) {
                        stagnationCount++;
                    } else {
                        stagnationCount = 0;
                    }
                }

                lastScrollPos = window.scrollY;

                // If we've been stuck at the bottom for 100 cycles, we're done
                if (stagnationCount > 100) {
                    status.innerText = 'Reached the End!';
                    status.style.color = '#79f279';
                    clearInterval(scrollInterval);
                    isScrolling = false;
                    btn.innerText = 'Scan Complete';
                    btn.style.background = '#222';
                }
            }, 50);
        } else {
            isScrolling = false;
            clearInterval(scrollInterval);
            btn.innerText = 'Resume Scrolling';
            btn.style.background = 'white';
            btn.style.color = '#1d9bf0';
            status.innerText = 'Paused';
        }
    };

    document.getElementById('scroll-btn').addEventListener('click', toggleScroll);
    setInterval(updateCount, 100);
})();
