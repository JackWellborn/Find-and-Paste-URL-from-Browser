# Find-and-Paste-URL-from-Browser
A script to quickly return a given url from Safari or Google Chrome (Firefox does not have a scripting dictionary 😢).

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url of a tab in the frontmost Safari or Chrome window based on a provided input. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable and much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Finding URLs
There are currently five ways find URLs that can be broken into two categories:

#### I need the URL from _that_ Tab. I know where it is, and I can probably see it.
I can't tell you how many times I was writing some sort of email or blog post only to find that I wanted to link to _that_ URL. Y'know _that_ one. Maybe it's the current tab. Maybe it's the one next the current tab, because I am writing in the current tab. You've been there, right? The syntax below always get and paste that one URL.

1. Leave empty to paste the URL of the current tab in the frontmost window.
2. Numbers (e.g. 1,-1) will paste the URL of a tab near the current tab in the frontmost window (e.g. "-1" for one tab left of current tab and "1" one tab right of current tab.)

#### I need the URL from some tab that I am pretty sure is still open.
I also can't tell you how many times I was writing something only to find that I wanted to link to some URL that I know I was looking at this morning. Maybe it was yesterday? Whatever. You get the idea. The following syntax searches all tabs from all windows based on the input provided. You can choose which URL to paste when multiple tabs match. A single match will immediately pasted, kind of like you knew where it was all along.

1. Numbers preceded by "=" will present URLs from tabs by index in all windows (e.g. "=1"  for first tabs and "=-1" for last tabs.)
2. Text will present URLs from tabs with titles containing that text.
3. Domains will present URLs from tabs with locations including that domain.

### Templates and Actions
In addition to returning just the URL, this script can also return links formatted in predefined templates or perform an action. To add a template or action, simply append ` .` followed by a code below. When using a template, the script will also default using the URL as the linked text and attempt to simulate the keyboard input to navigate to and select URL so other text can be entered. For example, "duckduckgo.com .m" will return:`[duckduckgo.com](duckduckgo.com)`. T

The templates currently supported are the following:

1. m - Markdown
2. h - HTML
3. j - Jira

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