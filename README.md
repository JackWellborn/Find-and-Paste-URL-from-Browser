# Find and Paste URL from Browser
A script to quickly paste a given url from Safari or Chrome (Firefox does not have a scripting dictionary 😢).
![Demonstration Video](https://raw.githubusercontent.com/JackWellborn/Find-and-Paste-URL-from-Browser/master/Find%20and%20Paste%20URL%20from%20Browser.gif "Demonstration Video")

## Introduction
The script below uses Mac OS's JavaScript for Automation to retrieve the url from a tab (or tabs) in Safari or Chrome based on the input provided. It's based on my [TextExpander-Find-URL](https://github.com/JackWellborn/TextExpander-Find-URL) project, which you can read about more about [here](http://wormsandviruses.com/2018/07/textexpander-snippets-with-variables/). This script based solution has proven more reliable, much simpler, and just as convenient when paired with [Red Sweater's FastScripts](https://red-sweater.com/fastscripts/). 

### Usage

When invoked, the script will present a dialog containing a list of all URLs opened as tabs in a given browser. The URL from the current tab is selected automatically. Use the mouse or arrow keys to select the desired URL from the list. Press the return key or click the "Okay" button to paste the selected URL. Press the esc key or click "Cancel" to do nothing.

#### Markdown Links in BBEdit and MarsEdit
Thanks to superb AppleScript support, creating Markdown links are streamlined when using this script with either BBEdit or MarsEdit. This is enabled by default, but can be easily disabled via configuration (see "Configuration Options" below.) The added Markdown support has several benefits:

- Uses selected text for links -- Links will use the current selection for linked text, when provided. Empty brackets will be used otherwise.
- Supports both inline and reference style links -- Links can either be added right after the linked text or elsewhere in the document using a reference. When using reference style links, the script can be configured to add them to the end of the document or to the end of the paragraph currently being edited. 
- Sensible insertion point placement in BBEdit -- When text is selected, the insertion point will be placed after the link so you can continue writing. When no text is selected, the insertion point will be placed between the empty brackets created so you can provide the linked text. This is only available in BBEdit as MarsEdit does not yet surface the insertion point offset information in AppleScript.

#### FastScripts Example
https://github.com/JackWellborn/Find-and-Paste-URL-from-Browser/assets/21010090/5dfaf0f7-7471-477f-8dc2-07f5af7b377c

#### Keyboard Maestro Example
https://github.com/JackWellborn/Find-and-Paste-URL-from-Browser/assets/21010090/92a6cbd4-e454-4cca-8c04-1b4dbb904c4d

## Instructions

### For use with Safari
1. Enable [Web Development Tools in Safari](https://developer.apple.com/safari/tools/).
2. In the __Develop__ menu, check __Allow JavaScript from Apple Events__

### For use with Google Chrome
1. In the __View__ menu and __Develop__ submenu, check __Allow JavaScript from Apple Events__

### FastScripts
1. Copy the JavaScript file into your desired scripts folder.
2. Map the JavaScript to a keyboard shortcut using [FastScripts](https://red-sweater.com/fastscripts/) or other keyboard mapping solution. Alternatively, you can export the script as an Application, which can be mapped without any additional software using the built-in Shortcuts feature found in Keyboard settings. All solutions require Accessibility access found under Privacy in Security in the Privacy settings. 
3. Select the browser of your choice.
	1. For Safari, `var browserConfig = browserConfigs.safari;` is uncommented and that `var browserConfig = browserConfigs.chrome;` is commented out.
	2. Ensure that `var browserConfig = browserConfigs.chrome;` is uncommented and that `var browserConfig = browserConfigs.safari;` is commented out.

### Keyboard Maestro Macro
1. Import the macro under File -> Import -> Import Safely.
2. Assign the macro a keyboard shortcut or other trigger.
3. Provide the exact name of the browser of your choice in the "BrowserName" `Set Variable` action, typically either `Safari` or `Google Chrome`.

## Configuration Options
You can configure `Find and Paste URL from Browser.scpt` by editing these options Script Editor. You can also configure the Keyboard Maestro macro by editing the same options in the final `Execute JavaScript for Automation` action. The following options are available.

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
	<td rowspan="3"><pre>enableMarkdownFeatures</pre></td>
	<td rowspan="3">Enable Markdown specific features in BBEdit and MarsEdit</td>
	<tr valign="top"><td><pre>true</pre></td><td>Enabled (default)</td></tr>
	<tr valign="top"><td><pre>false</pre></td><td>Disabled</td></tr>
</tr>
<tr valign="top">
	<td rowspan="4"><pre>MarkdownLinkLocation</pre></td>
	<td rowspan="4">Where Markdown links should be added</td>
	<tr valign="top"><td><pre>'END_OF_DOCUMENT'</pre></td><td>Creates a reference style link at the end of the document (default)</td></tr>
	<tr valign="top"><td><pre>'END_OF_PARAGRAPH'</pre></td><td>Creates a reference style link at the end of the paragraph</td></tr>
	<tr valign="top"><td><pre>'INLINE'</pre></td><td>Creates an inline link</td></tr>
</tr>
</table>

## Updates
### 2023-08-16
This is a major update that removes prior functionality in favor a simplified flow. 
* The biggest change is this removes the text prompt to query URLs. Navigating a list turned out to be so much more intuitive that I personally stopped using the query functionality. 
* The second biggest change is that there is no longer a second prompt asking for format. Most text fields/editors, be it in app or in browser, don't support Markdown. The few that do, like Github, can't easily support fancy reference style link generation and creating inline links in Markdown is incredibly straight forward.
* Added Markdown support for MarsEdit 5.
* Included a Keyboard Maestro macro.

### 2022-02-27
* Added implicit link support when using Markdown in BBEdit wherein the selected text will be used as the reference id. If the selected text is already being used as a reference id, it appends an incremented number and prompts the writer to change if they want to. If there is no selected text, it uses `ref(-n)` as default and also prompts the writer to change if they want to. 

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
