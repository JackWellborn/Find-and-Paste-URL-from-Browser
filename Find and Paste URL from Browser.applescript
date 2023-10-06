function run() {
	const enableMarkdownFeatures = true;
	const MarkdownLinkLocation = 'END_OF_DOCUMENT' // Where the link should be located ('END_OF_DOCUMENT', 'END_OF_PARAGRAPH', or 'INLINE').
	const browserConfigs = {
		chrome: {
			name: "Google Chrome"
		},
		safari: {
			name: "Safari"
		}
	};

	let browserConfig = browserConfigs.safari;
	// let browserConfig = browserConfigs.chrome;

	let system = Application("System Events");
	system.includeStandardAdditions = true;

	//For whatever reason this works wheres currentApplication does not.
	let app = Application(system.processes.where({_and:[{visible:true},{frontmost:true}]})[0].displayedName());
	app.includeStandardAdditions = true;

	let processes = system.processes.whose({ _and:[{name:{_beginsWith: browserConfig.name}}, {visible:true}]});

	if ( !processes || !processes.length ) {
		alertError(`${browserConfig.name} isn't running.`, `There's an old saying that you can't paste a URL from a browser that doesn't exist.`);
	}

	let process = processes[0];
	let browser = Application(process.name());
	browser.includeStandardAdditions = true;
	if ( browser.windows().length === 0 ) {
		alertError(`${browserConfig.name} has no open windows.`, `My grandfather once taught me that you can't paste a URL without tab and you can't have a tab without a window.
	
	True story.`);
	}
	
	let currentTab = browserConfig === browserConfigs.safari ? 
		browser.windows[0].currentTab() :
		browser.windows[0].activeTab;
		
	const getAllTabs = () => {
		let index, tabList=[];
		browser.windows().forEach((window, windex) => {
			window.tabs().forEach((tab, index) => {
				tabList.push({
					window: windex,
					tab: index,
					name: tab.name(),
					url: tab.url()
				});
			});
		});
		return tabList;
	}
	
	var getTitleFromUrl = (url) => {
		let tabsWithMatchingUrls = [];
		browser.windows().forEach((window) => {
			let tabs = window.tabs.whose({ url:url });
			if (tabs.length > 0) {
				tabsWithMatchingUrls = tabsWithMatchingUrls.concat(tabs);
			}
		});
		return tabsWithMatchingUrls[0].name();
	}

	const getUserSelectedURL = () => {
		let currentTabURL = currentTab.url();
		let tabURLs = getAllTabs().map(tab => tab.url).filter(tabUrl => Boolean(tabUrl));
		
		let showTabs = app.chooseFromList(tabURLs, {
			withTitle: 'Select URL',
			withPrompt: 'Select the tab with the desired URL.',
			defaultItems: [currentTabURL]
		});
		if (showTabs) {
			return showTabs[0];
		} else {
			return false;
		}
	}

	function pasteURL(url){
		let savedClipboard = app.theClipboard();
		app.setTheClipboardTo(url);
		system.keystroke('v',{using:["command down"]});
		delay(.5);
		app.setTheClipboardTo(savedClipboard);
	}

 
	const alertError = (header, message, optionalButton, syntax='') => {
		const buttons = ['Cancel'];
		if (optionalButton) {
			buttons.push(optionalButton);
		}
		let alert = app.displayAlert(header, {
			message: message,
			buttons: buttons,
			defaultButton: buttons[buttons.length-1],
			cancelButton: 'Cancel',
			as: buttons.length ? "informational" : "critical"
		});
		if (alert.buttonReturned !== "Cancel") {
			openDialog(syntax);	
		}
	}
	
	function executeJavaScriptInCurrentTab(script) {
		if(browser.name().indexOf("Safari") > -1) {
			return browser.doJavaScript(script, {in:currentTab});
		}
		return browser.execute(currentTab, {javascript:script});
	}
	
	function isGithubComment() {
		let nodeName = executeJavaScriptInCurrentTab("document.activeElement.nodeName.toLocaleLowerCase();");
		let ariaLabel = executeJavaScriptInCurrentTab("document.activeElement.ariaLabel;");
		return (nodeName === 'textarea' && ariaLabel === 'Comment body');
	}
	
	function getCurrentTextAreaValue() {
		return executeJavaScriptInCurrentTab('document.activeElement.value;');
	}
	
	function insertTextIntoTextAreaAt(text=``, selectionStart, selectionEnd) {
		if (!selectionEnd) {
			selectionEnd = selectionStart;
		}
		let script = `(function() {
			let textArea = document.activeElement;
			textArea.selectionStart = ${selectionStart};
			textArea.selectionEnd = ${selectionEnd};`;
		if(browser.name().indexOf("Safari") > -1) {
			script = script + `let textEvent = document.createEvent('TextEvent');
			textEvent.initTextEvent('textInput', true, true, null, \`${text}\`);
			textArea.dispatchEvent(textEvent);`
		} else {
			// Non Standard, but works in Chrome
			script = script + `document.execCommand( 'insertText', false, \`${text}\`);`;
		}
		script = script + `})();`;
		executeJavaScriptInCurrentTab(script);
	}
	
	const writeUrl = (url) => {
		if (url) {
			let bbEditMarkdown = (app.name() === "BBEdit" && app.textWindows.at(0).sourceLanguage() === 'Markdown');
			let githubMarkdown = (app.name() === browser.name() && /https\:\/\/github.com(.+)\/pull\/[0-9]+/.test(currentTab.url()) &&  isGithubComment());
			let marsEditMarkdown = (app.name() === "MarsEdit");

			if (marsEditMarkdown) {
				delay(.5); //Weird race condition with MarsEdit
			}
					
			if (enableMarkdownFeatures && (bbEditMarkdown || marsEditMarkdown || githubMarkdown)) { 
				let window = app.windows()[0];
				let pageTitle = getTitleFromUrl(url);

				let selectedText, markdownLinkText, originalOffset = 0, newOffset = 0;
				let selectionStart, selectionEnd; //GitHub only.
				
				if (bbEditMarkdown) {
					selectedText = markdownLinkText = window.selection.contents().toString();
				} else if (githubMarkdown) {					
					selectionStart = executeJavaScriptInCurrentTab('document.activeElement.selectionStart;');
					selectionEnd = executeJavaScriptInCurrentTab('document.activeElement.selectionEnd;');
					selectedText = markdownLinkText = executeJavaScriptInCurrentTab("document.activeElement.value.substring(document.activeElement.selectionStart, document.activeElement.selectionEnd);");
				} else {
					selectedText = markdownLinkText = window.document().selectedText();
				}
				
				if (bbEditMarkdown) { // MarsEdit doesn't provide text offsets
					originalOffset = newOffset = window.selection.characteroffset();
				} else if (githubMarkdown) {
					originalOffset = newOffset = selectionEnd;
				}
				if (MarkdownLinkLocation === 'INLINE' || selectedText.length === 0) {
					markdownLinkText = selectedText.length ? selectedText.replace(/(.+)/g, '[$1](' + url + ')') : '[' + url + '](' + url + ')';
					if (bbEditMarkdown) {
						window.selection.contents = markdownLinkText;
					} else if (githubMarkdown) {
						insertTextIntoTextAreaAt(markdownLinkText, selectionStart, selectionEnd);
					} else {
						window.document().selectedText = markdownLinkText;
					}
					return;
				} else {
					let bodyText, updatedText;
					if (bbEditMarkdown) {
						bodyText = updatedText = window.text();
					} else if (githubMarkdown) {
						bodyText = updatedText = getCurrentTextAreaValue();
					} else {					
						bodyText = updatedText = window.document().body();
					}
					
					let referenceName = selectedText.length ? selectedText : 'ref';
					let referenceNameRegExp = new RegExp('\n\\['+ referenceName +'[0-9\\-]*\\]\\:','g');
							
					let referenceAnchor = '[]';
					let referenceNameCount = 0;
					let referenceNameOccurences = bodyText.match(referenceNameRegExp);
					if (referenceNameOccurences) {
						referenceName = referenceName + '-' + (referenceNameOccurences.length + 1);
					}
					if (referenceNameOccurences || !selectedText.length) {
						let nameDialog = app.displayDialog(`What reference name would you like to use for "${pageTitle}"?`, {
							defaultAnswer: referenceName,
							buttons: ["Cancel", "Use Reference Name"],
							cancelButton: "Cancel",
							defaultButton: "Use Reference Name"
						});
						referenceName = nameDialog.textReturned;
						referenceAnchor = '[' + referenceName + ']';
					}
							
					markdownLinkText = selectedText.length ? selectedText.replace(/(.+)/g, '[$1]'+ referenceAnchor) : '[]' + referenceAnchor;
					if (bbEditMarkdown) {
						newOffset = selectedText.length ? originalOffset + markdownLinkText.length-1 : originalOffset;
						window.selection.contents = markdownLinkText;
						bodyText = updatedText = window.text();
					} else if (githubMarkdown) {
						newOffset = ((selectionEnd - selectionStart) > 0) ? originalOffset + (markdownLinkText.length-selectedText.length) : originalOffset;
						insertTextIntoTextAreaAt(markdownLinkText, selectionStart, selectionEnd);
						bodyText = updatedText = getCurrentTextAreaValue();
					} else {
						window.document().selectedText = markdownLinkText;
						bodyText = updatedText = window.document().body();
					}
					let refenceAnchorText = '[' + referenceName + ']: ' + url;
					referenceAnchorSelectionStart = bodyText.length;
					
					if (MarkdownLinkLocation === 'END_OF_PARAGRAPH') {
						refenceAnchorText = '\n' + refenceAnchorText;
						let paragraphBreakRegexp = /\n\n+/g;
						let paragraphBreakRegexpResult;
						while ((paragraphBreakRegexpResult = paragraphBreakRegexp.exec(bodyText)) !== null) {
							if (paragraphBreakRegexp.lastIndex >= bodyText.indexOf(markdownLinkText)) {
								updatedText = bodyText.slice(0, paragraphBreakRegexpResult.index) + refenceAnchorText + paragraphBreakRegexpResult[0] + bodyText.slice(paragraphBreakRegexp.lastIndex);
								referenceAnchorSelectionStart = paragraphBreakRegexpResult.index;
								break;
							}
						}
						if (updatedText === bodyText) { // We are in the last paragraph
							updatedText = bodyText.replace(/(\n*)$/, refenceAnchorText + "$1");
						}
					} else {
						let prependedExtraLineBreak = '\n\n';
						if (/\[.+\]\:.+\n\s*$/.test(bodyText)) {
							prependedExtraLineBreak = '';
						} else if (/.+\n\s*$/.test(bodyText)) {
							prependedExtraLineBreak = '\n';
						}
						
						refenceAnchorText = prependedExtraLineBreak + refenceAnchorText + '\n';
						updatedText = bodyText + refenceAnchorText;
					}
		
					if (updatedText !== bodyText) {
						if (bbEditMarkdown) {
							window.text = updatedText;
						} else if (githubMarkdown) {
							insertTextIntoTextAreaAt(refenceAnchorText, referenceAnchorSelectionStart)
						} else {
							window.document().body = updatedText;
						}
					}
				}
				if (bbEditMarkdown) {
					app.select(window.characters.at(newOffset).insertionPoints.at(0));
				} else if (githubMarkdown) {
					executeJavaScriptInCurrentTab(`document.activeElement.selectionStart = document.activeElement.selectionEnd = ${newOffset};`);
				}
				
			} else {
				pasteURL(url);
			}
		}
	}
	
	let url = getUserSelectedURL();
	if (url) {
		writeUrl(url);
	}
}
