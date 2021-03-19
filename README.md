# Find and Paste URL from Browser
A script to quickly paste a given url from Safari or Google Chrome (Firefox does not have a scripting dictionary 😢).

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url from a tab (or tabs) in Safari or Chrome based on the input provided. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable, much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Finding URLs
There are five ways to find URLs to paste, each of which can be broken into two categories:

#### I need the URL from _that_ Tab.
I can't tell you how many times I am writing some sort of email or blog post only to find that I need the url from _that_ tab. Y'know _that_ one. Sometimes it's the current tab I was just browsing. Sometimes it's the one next the current tab, usually because the thing I am writing in is the current tab. You've been there. The syntax below gets and pastes _that__ URL.

1. No input will paste the URL of the current tab in the frontmost window.
2. Numbers will paste the URL of a tab near the current tab in the frontmost window (e.g. "-1" for one tab left or "2" for two tabs right.)

#### I need the URL from some tab that I am pretty sure is still open... somewhere.
I also can't tell you how many times I am writing something only to find that I need to link to some URL that I know was open this morning. Or maybe it was yesterday? Anyways, you get the idea. The following searches tabs from all windows. You can choose which URL to paste when multiple results are found, but a single result will be immediately pasted (as if you knew where it was all along.)

1. Numbers preceded by "=" will get URLs from tabs by index (e.g. "=1"  for the first tabs and "=-2" for the second to last tabs.)
2. Text will get URLs from tabs with titles containing that text.
3. Domains will get URLs from tabs with locations containing that domain.

### Templates and Actions
In addition to returning just the URL, this script can also return links formatted using a predefined template or perform an action. To use a template or action, append ` .` (space period) followed by a code below. When using a template, the script will also default to using the URL as the linked text. For example, "duckduckgo.com .h" will return `<a href="https://duckduckgo.com/">https://duckduckgo.com/</a>`). The script then attempts to select the URL in the linked text so it can be easily replaced with something more descriptive. 

The templates currently supported are the following:

1. m - [Markdown][md] (By default, this will create reference-style links in BBEdit and inline links elsewhere.)
2. h - HTML
3. j - Jira

#### Reference-Style Markdown Links in BBEdit
Thanks to BBEdit's superb AppleScript support makes it possible to support Markdown's reference-style link format. When using the Markdown template in BBEdit, the script will...

1. Additionally prompt for a reference ID. The default value is the count of existing references + 1. 
2. Write the reference ID and link to the bottom of the document.
3. Write the reference link, including the ID at original insertion point. If text is selected, the selected text will be used as linked text and the insertion point will be placed after the reference link. If no text is selected, the insertion point will be placed between the empty brackets for the linked text.
	
This is enabled by default, but can be easily disabled (see "Configuration Options" below.) 

The only action currently supported is the following:

1. r - Reveal the tab containing the url, because sometimes you just want to find a tab.

## Instructions
1. Copy the JavaScript file into your desired scripts folder.
2. Map the JavaScript to a keyboard shortcut using [FastScripts](https://red-sweater.com/fastscripts/) or other keyboard mapping solution. Alternatively, you can export the script as an Application, which can be mapped without any additional software using the built-in Shortcuts feature found in Keyboard settings. All solutions require Accessibility access found under Privacy in Security in the Privacy settings. 

### For use with Safari
1. Ensure that `var browserConfig = browserConfigs.safari;` is uncommented and that `var browserConfig = browserConfigs.chrome;` is commented out.
2. Enable [Web Development Tools in Safari](https://developer.apple.com/safari/tools/).
3. In the __Develop__ menu, check __Allow JavaScript from Apple Events__

### For use with Google Chrome
1. Ensure that `var browserConfig = browserConfigs.chrome;` is uncommented and that `var browserConfig = browserConfigs.safari;` is commented out.
2. In the __View__ menu and __Develop__ submenu, check __Allow JavaScript from Apple Events__

## Configuration Options
You can configure `Find and Paste URL from Browser.scpt` by opening it Script Editor. The following options are available.

<table>
<tr>
	<th>Name</th>
	<th>Description</th>
	<th>Default Value</th>
	<th>Options</th>
</tr>
<tr>
	<td><pre>browserConfig</pre></td>
	<td>Which browser to use.</td>
	<td><pre>browserConfigs.safari</pre></td>
	<td><pre>browserConfigs.safari</pre><pre>browserConfigs.chrome</pre></td>
</tr>
<tr>
	<td><pre>useReferenceStyleMarkdownLinksInBBEdit</pre></td>
	<td>Enables reference-style links in BBEdit.</td>
	<td><pre>true</pre></td>
	<td><pre>true</pre><pre>false</pre></td>
</tr>
</table>

## Updates
### 2021-03-19
* Added support for reference-style markdown links when using BBEdit.
* Removed the need for a space for format and action codes when there is no other input. 

## Disclaimer
Be aware that this solution uses automation to control keyboard input, manipulate the clipboard, and access Safari and Google Chrome. The scripts involved operate locally and only uses these privileges to return URLs as stated above, but this authors recommends further scrutiny when any solution has these and similar elevated privileges.

[md]: https://daringfireball.net/projects/markdown/syntax#link