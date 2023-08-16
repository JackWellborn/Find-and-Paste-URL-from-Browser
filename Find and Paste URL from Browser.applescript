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
	
	const writeUrl = (url) => {
		if (url) {
			let bbEditMarkdown = (app.name() === "BBEdit" && app.textWindows.at(0).sourceLanguage() === 'Markdown');
			let marsEditMarkdown = (app.name() === "MarsEdit");
			
			if (marsEditMarkdown) {
				delay(.5); //Weird race condition with MarsEdit
			}
					
			if (enableMarkdownFeatures && (bbEditMarkdown || marsEditMarkdown)) { 
				let window = app.windows()[0];
				let pageTitle = getTitleFromUrl(url);

				let selectedText, markdownLinkText, originalOffset = 0, newOffset = 0;
				selectedText = markdownLinkText = bbEditMarkdown ? window.selection.contents().toString() : window.document().selectedText();
				
				if (bbEditMarkdown) { // MarsEdit doesn't provide text offsets
					originalOffset = newOffset = window.selection.characteroffset();
				}
				if (MarkdownLinkLocation === 'INLINE' || selectedText.length === 0) {
					markdownLinkText = selectedText.length ? selectedText.replace(/(.+)/g, '[$1](' + url + ')') : '[' + url + '](' + url + ')';
					if (bbEditMarkdown) {
						newOffset = selectedText.length ? originalOffset + markdownLinkText.length-1 : originalOffset;
						window.selection.contents = markdownLinkText;
					} else {
						window.document().selectedText = markdownLinkText;
					}
					return;
				} else {
					let bodyText, updatedText;
					bodyText = updatedText = bbEditMarkdown ? window.text() : window.document().body();
					
					let referenceName = selectedText.length ? selectedText : 'ref';
					let referenceNameRegExp = new RegExp('\n\['+ referenceName +'[0-9\-]*\]\:','g');
							
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
					} else {
						window.document().selectedText = markdownLinkText;
					}
					bodyText = updatedText = bbEditMarkdown ? window.text() : window.document().body();
					let prependedExtraLineBreak = '\n\n';
					if (/\n\s*$/.test(bodyText)) {
						prependedExtraLineBreak = '';
					}
					bodyText = updatedText = bodyText + prependedExtraLineBreak;
					if (MarkdownLinkLocation === 'END_OF_PARAGRAPH') {
						let paragraphBreakRegexp = /\n\n+/g;
						let paragraphBreakRegexpResult;
						while ((paragraphBreakRegexpResult = paragraphBreakRegexp.exec(bodyText)) !== null) {
							if (paragraphBreakRegexp.lastIndex >= bodyText.indexOf(markdownLinkText)) {
								updatedText = bodyText.slice(0, paragraphBreakRegexpResult.index) + '\n[' + referenceName + ']: ' + url + paragraphBreakRegexpResult[0] + bodyText.slice(paragraphBreakRegexp.lastIndex);
								break;
							}
						}
					} else {
						updatedText = bodyText + '[' + referenceName + ']: ' + url + '\n';
					}
					if (updatedText !== bodyText) {
						if (bbEditMarkdown) {
							window.text = updatedText;
						} else {
							window.document().body = updatedText;
						}
					}
				}
				if (bbEditMarkdown) {
					app.select(window.characters.at(newOffset).insertionPoints.at(0));
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
