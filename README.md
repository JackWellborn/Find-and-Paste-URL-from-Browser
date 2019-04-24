# Find-and-Paste-URL-from-Safari
A script to quickly return a given url from Safari.

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url of a tab in the frontmost Safari window based on a provided query. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable and much simpler, and just as conveninet when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

There are currently four types of queries supported:

1. Use `?` to query tabs by title (e.g. "?Google".)
2. Use `/` to query tabs by URL (e.g. "/google.com".)
3. Use `+` or `-` to query tabs by absolute position (e.g. `+1` for the leftmost tab and `-1` for the rightmost tab.)
4. Use `<` or `>` to query tabs by relative position to current tab (e.g. `<1` for one tab left of current tab and `>1` one tab right of current tab. Using `0` with either `<` or `>` will return the current tab.)

## Instructions
1. Copy JavaScript file to your desired scripts folder.
2. Map the JavaScript to a keyboard shortcut using [FastScripts](https://red-sweater.com/fastscripts/) or other keyboard mapping solution.
3. Enable [Web Development Tools in Safari](https://developer.apple.com/safari/tools/).
4. In the __Develop__ menu, check __Allow JavaScript from Apple Events__

## Disclaimer
Be aware that this solution uses automation to control keyboard input, manipulate the clipboard, and access Safari. The scripts involved operate locally and only uses these privileges to return Safari URLs as stated above, but this authors recommends further scrutiny when any solution has these and similar elevated privileges. Additionally, the author considers this solution a workaround. Automation can be somewhat brittle. As such, it only works _most_ of the time. That said, this solution get's the job done for the author until a better one comes along. 