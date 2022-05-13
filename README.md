![Demonstration Video](https://github.com/JackWellborn/Find-and-Paste-URL-from-Browser/blob/master/Find%20and%20Paste%20URL%20from%20Browser.gif?raw=true "Demonstration Video")

# Find and Paste URL from Browser
A script to quickly paste a given url from Safari or Chrome (Firefox does not have a scripting dictionary 😢).

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url from a tab (or tabs) in Safari or Chrome based on the input provided. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable, much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Finding URLs
There are five ways to find URLs to paste, each of which can be broken into two categories:

#### I need the URL from _that_ Tab.
I can't tell you how many times I am writing some sort of email or blog post only to find that I need the url from _that_ tab. Y'know _that_ one. Sometimes it's the current tab I was just browsing. Sometimes it's the one next the current tab, usually because the thing I am writing in is the current tab. You've been there. The syntax below gets and pastes _that__ URL.

1. The default input will paste the URL of the current tab in the frontmost window.
2. Numbers will paste the URL of a tab near the current tab in the frontmost window (e.g. "-1" for one tab left or "2" for two tabs right.)

#### I need the URL from some tab that I am pretty sure is still open... somewhere.
I also can't tell you how many times I am writing something only to find that I need to link to some URL that I know was open this morning. Or maybe it was yesterday? Anyways, you get the idea. The following searches tabs from all windows. You can choose which URL to paste when multiple results are found, but a single result will be immediately pasted (as if you knew where it was all along.)

1. An empty input will display a list of all currently open urls with the one from the current tab selected.
2. Numbers preceded by "=" will get URLs from tabs by index (e.g. "=1"  for the first tabs and "=-2" for the second to last tabs.)
3. Text will get URLs from tabs with titles containing that text.
4. Domains will get URLs from tabs with locations containing that domain.

### Templates and Actions
In addition to returning just the URL, this script can also return links formatted using a predefined template or perform an action. To use a template or action, append ` .` (space period) followed by a code below. When using a template, the script will also default to using the URL as the linked text. For example, "duckduckgo.com .h" will return `<a href="https://duckduckgo.com/">https://duckduckgo.com/</a>`). The script then attempts to select the URL in the linked text so it can be easily replaced with something more descriptive. 

The templates currently supported are the following:

1. m - [Markdown][md] (By default, this will create reference-style links in BBEdit and inline links elsewhere.)
2. h - HTML
3. j - Jira

The only action currently supported is the following:

1. r - Reveal the tab containing the url, because sometimes you just want to find a tab.

#### Markdown Links in BBEdit
Thanks to superb AppleScript support, creating Markdown links is even more streamlined when using this script with BBEdit. This is enabled by default, but can be easily disabled via configuration (see "Configuration Options" below.) The added BBEdit support has several benefits:

- Automatic Markdown detection -- Links will automatically be formatted with Markdown in documents that BBEdit identifies as Markdown. No template code required.
- Uses selected text for links -- Links will use the current selection for linked text, when provided. Empty brackets will be used otherwise.
- Sensible insertion point placement -- When text is selected, the insertion point will be placed after the link so you can continue writing. When no text is selected, the insertion point will be placed between the empty brackets created so you can provide the linked text.
- Supports both inline and reference style links -- Links can either be added right after the linked text or elsewhere in the document using a reference. When using reference style links, the script can be configured to add them to the end of the document or to the end of the paragraph currently being edited. 

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

<table border="1">
<tr>
	<th>Name</th>
	<th>Description</th>
	<th colspan="2">Options</th>
</tr>
<tr valign="top">
	<td rowspan="3"><pre>browserConfig</pre></td>
	<td rowspan="3">Which browser to find links from</td>
	<tr valign="top"><td><pre>browserConfigs.safari</pre></td><td>Safari (default)</td></tr>
	<tr valign="top"><td><pre>browserConfigs.chrome</pre></td><td>Google Chrome</td></tr>
</tr>
<tr valign="top">
	<td rowspan="3"><pre>enableBBEditFeatures</pre></td>
	<td rowspan="3">Enable BBEdit specific features</td>
	<tr valign="top"><td><pre>true</pre></td><td>Enabled (default)</td></tr>
	<tr valign="top"><td><pre>false</pre></td><td>Disabled</td></tr>
</tr>
<tr valign="top">
	<td rowspan="4"><pre>BBEditMarkdownLinkLocation</pre></td>
	<td rowspan="4">Where Markdown links should be added</td>
	<tr valign="top"><td><pre>'END_OF_DOCUMENT'</pre></td><td>Creates a reference style link at the end of the document (default)</td></tr>
	<tr valign="top"><td><pre>'END_OF_PARAGRAPH'</pre></td><td>Creates a reference style link at the end of the paragraph</td></tr>
	<tr valign="top"><td><pre>'INLINE'</pre></td><td>Creates an inline link</td></tr>
</tr>
</table>

## Updates
### 2022-02-27
* Seeing as I found myself simply grabbing the URL from the current tab most of the time, that is now the default input.
* Deleting that new default to use blank input now displays a list of all currently open urls with the one from the current tab selected. This may prove faster for quickly pasting urls from tabs relatively close to the current one.
* I cleaned up some issues where canceling would still continue the process and/or lead to "invalid input" feedback.
* Finally, I improved adding reference-style links to the bottom of BBEdit documents. Now the first reference-style link will prepend empty lines so as to visually separate them from content.

### 2021-06-18
* Supported placing reference style Markdown links at the bottom of paragraphs in BBEdit
* Improved supported for inline Markdown links in BBEdit
	
### 2021-03-19
* Added support for reference-style Markdown links when using BBEdit.
* Removed the need for a space for format and action codes when there is no other input. 

## Disclaimer
Be aware that this solution uses automation to control keyboard input, manipulate the clipboard, and access Safari and Google Chrome. The scripts involved operate locally and only uses these privileges to return URLs as stated above, but this authors recommends further scrutiny when any solution has these and similar elevated privileges.

[md]: https://daringfireball.net/projects/markdown/syntax#link
