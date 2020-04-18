# Find-and-Paste-URL-from-Browser
A script to quickly return a given url from Safari or Google Chrome (Firefox does not have a scripting dictionary 😢).

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url from a tab (or tabs) in Safari or Chrome based on the input provided. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable, much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Finding URLs
There are five ways to find URLs to paste, each of which can be broken into two categories:

#### I need the URL from _that_ Tab.
I can't tell you how many times I am writing some sort of email or blog post only to find that I need the url from _that_ tab. Y'know _that_ one. Sometimes I can even see it. Sometimes it's the current tab I was just viewing. Sometimes it's the one next the current tab, usually because the thing I am writing in is the current tab. You've been there. The syntax below gets and pastes _that__ URL.

1. Leave empty to paste the URL of the current tab in the frontmost window.
2. Numbers will paste the URL of a tab near the current tab in the frontmost window (e.g. "-1" for one tab left of current tab or "2" for two tabs right of current tab.)

#### I need the URL from some tab that I am pretty sure is still open... somewhere.
I also can't tell you how many times I am writing something only to find that I need to link to some URL that I know I was looking at this morning. Or maybe it was yesterday? Anyways, you get the idea. The following searches tabs from all windows. You can choose which URL to paste when multiple results are found, but a single result will be immediately pasted (as if you knew where it was all along.)

1. Numbers preceded by "=" will get URLs from tabs by index (e.g. "=1"  for first tabs and "=-2" for the second to last tabs.)
2. Text will get URLs from tabs with titles containing that text.
3. Domains will get URLs from tabs with locations containing that domain.

### Templates and Actions
In addition to returning just the URL, this script can also return links formatted in predefined templates or perform an action. To add a template or action, simply append ` .` followed by a code below. When using a template, the script will also default to using the URL as the linked text. For example, "duckduckgo.com .m" will return:`[duckduckgo.com](duckduckgo.com)`. The script then attempts to select this URL in the linked text so it can be easily replaced with something more descriptive. 

The templates currently supported are the following:

1. m - Markdown
2. h - HTML
3. j - Jira

The only action currently supported is the following:

1. r - Reveal the tab containing the url, because sometimes you just need to find the tab.

## Instructions
1. Copy the JavaScript file into your desired scripts folder.
2. Map the JavaScript to a keyboard shortcut using [FastScripts](https://red-sweater.com/fastscripts/) or other keyboard mapping solution. Alternatively, you can export the script as an Application, and use the built-in Shortcuts feature found in Keyboard settings. All solutions require Accessibility access found under Privacy in Security and Privacy settings. 

### For use with Safari
1. Ensure that `var browserConfig = browserConfigs.safari;` is uncommented and that `var browserConfig = browserConfigs.chrome;` is commented out.
2. Enable [Web Development Tools in Safari](https://developer.apple.com/safari/tools/).
3. In the __Develop__ menu, check __Allow JavaScript from Apple Events__

### For use with Google Chrome
1. Ensure that `var browserConfig = browserConfigs.chrome;` is uncommented and that `var browserConfig = browserConfigs.safari;` is commented out.
2. In the __View__ menu and __Develop__ submenu, check __Allow JavaScript from Apple Events__

## Disclaimer
Be aware that this solution uses automation to control keyboard input, manipulate the clipboard, and access Safari and Google Chrome. The scripts involved operate locally and only uses these privileges to return URLs as stated above, but this authors recommends further scrutiny when any solution has these and similar elevated privileges. 