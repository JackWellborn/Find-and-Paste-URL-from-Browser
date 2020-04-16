# Find-and-Paste-URL-from-Browser
A script to quickly return a given url from Safari or Google Chrome (Firefox does not have a scripting dictionary 😢).

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url of a tab in the frontmost Safari or Chrome window based on a provided query. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable and much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Finding URLs
There are currently five ways find URLs:
1. Leave empty to get the current tab from the frontmost window.
2. Use a number to get a tab relative to the current tab in the frontmost window (e.g. "-1" for one tab left of current tab and "1" one tab right of current tab.)
3. Use a number to preceded by "=" get a tabs by absolute position in all windows (e.g. "=1" for the leftmost tab and "=-1" for the rightmost tab.)
4. Use text to find tabs by title in all windows.
5. Use domains to find tabs by URL in all windows.

### Templates and Actions
In addition to returning just the URL, this script can also return the URLs formatted in predefined templates or perform an action. To use, simply append ` .` followed by a code below. For example, "duckduckgo.com .m" will return:`[](duckduckgo.com)`. When using templates that a have plain text component, such as Markdown or HTML, the script will also attempt to press the arrow key back to where that plain text can be entered. 

The templates currently supported are the following:

1. m - Markdown
2. h - HTML

The only action currently supported is the following:

1. r - Reveal the tab containing the url.

## Instructions
1. Copy JavaScript file to your desired scripts folder.
2. Map the JavaScript to a keyboard shortcut using [FastScripts](https://red-sweater.com/fastscripts/) or other keyboard mapping solution.

### For use with Safari
1. Ensure that `var browserConfig = browserConfigs.safari;` is uncommented and that `var browserConfig = browserConfigs.chrome;` is commented out.
2. Enable [Web Development Tools in Safari](https://developer.apple.com/safari/tools/).
3. In the __Develop__ menu, check __Allow JavaScript from Apple Events__

### For use with Google Chrome
1. Ensure that `var browserConfig = browserConfigs.chrome;` is uncommented and that `var browserConfig = browserConfigs.safari;` is commented out.
2. In the __View__ menu and __Develop__ submenu, check __Allow JavaScript from Apple Events__

## Disclaimer
Be aware that this solution uses automation to control keyboard input, manipulate the clipboard, and access Safari or Google Chrome. The scripts involved operate locally and only uses these privileges to return URLs as stated above, but this authors recommends further scrutiny when any solution has these and similar elevated privileges. Additionally, the author considers this solution a workaround. Automation can be somewhat brittle. As such, it only works _most_ of the time. That said, this solution get's the job done for the author until a better one comes along. 