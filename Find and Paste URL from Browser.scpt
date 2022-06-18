function run() {
	const enableBBEditFeatures = true;
	const BBEditMarkdownLinkLocation = 'END_OF_DOCUMENT' // Where the link should be located ('END_OF_DOCUMENT', 'END_OF_PARAGRAPH', or 'INLINE').
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
	
	const getTabByAbsoluteIndex = (query) => {
		let index, urls=[];
		browser.windows().forEach((window) => {
			if (query <= window.tabs.length) {
				if ( query < 0 ) {
					index = window.tabs().length + query;
				} else {
					index = query - 1;
				}
				urls.push(window.tabs[index].url());
			}
		});
		return urls;
	}

	const getTabByRelativeIndex = (query) => {
		let currentTabIndex = browserConfig === browserConfigs.safari ? 
			browser.windows[0].currentTab().index() : 
			browser.windows[0].activeTabIndex();
		let relativeTabIndex = currentTabIndex-1 + query;
		if (relativeTabIndex >= browser.windows[0].tabs().length) {
			relativeTabIndex = relativeTabIndex - browser.windows[0].tabs().length;
		}
		return [browser.windows[0].tabs[relativeTabIndex].url()];
	}

	const getTabsWithUrlsThatContain = (query) => {
		let urls = [];
		browser.windows().forEach((window) => {
			let tabs = window.tabs.whose({ url:{ _contains: query }});
			tabs().forEach(function(tab) {
				urls.push(tab.url());
			});
		});
		return urls;
	}

	const getTabsWithTitlesThatContain = (query) => {
		let titles = [];
		browser.windows().forEach((window) => {
			let tabs = window.tabs.whose({ name:{ _contains: query }});
			tabs().forEach(function(tab) {
				titles.push(tab.url());
			});
		});
		return titles;
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
	
	let formatCode = 'none';
	let formatSignifier = ' .';
	let formatTemplates = [
		{ name: 'markdown', code: 'm', template: '[{TEXT}]({URL})' },
		{ name: 'jira', code: 'j', template: '[{TEXT}|{URL}]' },
		{ name: 'html', code: 'h', template: '<a href="{URL}">{TEXT}</a>' },
		{ name: 'reveal', code: 'r', template: '', action: (url) => {
			browser.windows().forEach((win, w) => {
				for(let t=0; t < win.tabs().length; t++){
					if (win.tabs[t].url() === url) {
						matchingTab = win.tabs[t];
						matchingTabIndex = t;
						if ( browserConfig.name === 'Safari' ) {
							let tab = win.tabs.whose({ url: url })[0];
							win.currentTab = tab;
						} else {		
							win.activeTabIndex = matchingTabIndex+1;
						}
						browser.activate();
						process.windows[w].actions['AXRaise'].perform();
						break;
					}
				}
			});
		}}
	];

	const runQuery = (input) => {
		input = input.toString();
	
		formatTemplates.forEach((format) => {
			input = input[0] === '.' ? ' ' + input : input;
			let formatRegExp = new RegExp(formatSignifier + format.code + '$');
			if (formatRegExp.test(input)) {
				let inputArr = input.split(formatSignifier);
				console.log(inputArr);
				formatCode = inputArr.pop();
				console.log(inputArr.length);
				input = inputArr.join(formatSignifier);
			}
		});
	
		let fullQuery = input;
		let queryCharacter = fullQuery.charAt(0);
		let	queryParameter =  fullQuery.substring(1);
		const queryCharacters = ['='];
	
		let url, urls = [];
	
		if (fullQuery === currentTab.url()) {
			urls = [currentTab.url()];
		} else if (fullQuery && !isNaN(fullQuery)) {
			urls = getTabByRelativeIndex(parseInt(fullQuery, 10));
		} else if (queryCharacters.indexOf(queryCharacter) >= 0) {
			switch(queryCharacter) {
				case "=":
					urls = getTabByAbsoluteIndex(parseInt(queryParameter, 10));
					break;
			}
		} else if (/^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$/.test(fullQuery)) {
			urls = getTabsWithUrlsThatContain(fullQuery);
		} else if (fullQuery.length > 0) {
			urls = getTabsWithTitlesThatContain(fullQuery);
		} else {
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
	
		if(urls.length > 1) {
			let choice = app.chooseFromList(urls, {
				withTitle:"Multiple Matching URLs Found",
				withPrompt:"Select the desired matching URL",
				okButtonName:"Paste URL",
				cancelButton:"Cancel"});
			
			if(choice){
				url = choice.toString();
			} 
		} else {
			url = urls[0];
		}
		return url;
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
				let bbEditMarkdown = (enableBBEditFeatures && app.name() === "BBEdit" && (app.textWindows.at(0).sourceLanguage() === 'Markdown' || format === 'Markdown'))
	
				let formats = app.chooseFromList(['Plain Text', 'Markdown', 'HTML'], {
					withTitle: 'Select Formatting',
					withPrompt: 'Select the desired URL format.',
					defaultItems: bbEditMarkdown ? ['Markdown'] : ['Plain Text']
				});
				if (formats) {
					let format = formats[0];
					if (typeof url === "undefined" || !url) {
						alertError(`No URL found.`, `WellÉ they can't all be gems.`, `Try Again`, dialog.textReturned);

					}
					if (bbEditMarkdown) { 
						let window = app.windows()[0];
						let pageTitle = getTitleFromUrl(url);
				
						let selectedText, markdownLinkText, originalOffset, newOffset;
						selectedText = markdownLinkText = window.selection.contents().toString();
						
						
						originalOffset = newOffset = window.selection.characteroffset();
				
						if (BBEditMarkdownLinkLocation === 'INLINE') {
							markdownLinkText = selectedText.length ? selectedText.replace(/(.+)/g, '[$1](' + url + ')') : '[](' + url + ')';
							newOffset = selectedText.length ? originalOffset + markdownLinkText.length-1 : originalOffset;
							window.selection.contents = markdownLinkText;
						} else {
							let referenceName = selectedText.length ? selectedText : 'ref';
							let referenceNameRegExp = new RegExp('\n\['+ referenceName +'[0-9\-]*\]\:','g');
							
							let referenceAnchor = '[]';
							let referenceNameCount = 0;
							let referenceNameOccurences = window.text().match(referenceNameRegExp);
							if (referenceNameOccurences) {
								referenceName = referenceName + '-' + (referenceNameOccurences.length + 1);
							}
							if (referenceNameOccurences || !selectedText.length) {
								let nameDialog = app.displayDialog(`What reference name would you like to use for "${pageTitle}"?`, {
									// withTitle:`What reference name would you like to use for "${pageTitle}"?`,
									defaultAnswer: referenceName,
									buttons: ["Cancel", "Use Reference Name"],
									cancelButton: "Cancel",
									defaultButton: "Use Reference Name"
								});
								referenceName = nameDialog.textReturned;
								referenceAnchor = '[' + referenceName + ']';
							}
							
							markdownLinkText = selectedText.length ? selectedText.replace(/(.+)/g, '[$1]'+ referenceAnchor) : '[]' + referenceAnchor;
							newOffset = selectedText.length ? originalOffset + markdownLinkText.length-1 : originalOffset;
							window.selection.contents = markdownLinkText;
							if (BBEditMarkdownLinkLocation === 'END_OF_PARAGRAPH') {
								let paragraphBreakRegexp = /\n\n+/g;
								let paragraphBreakRegexpResult;
								while ((paragraphBreakRegexpResult = paragraphBreakRegexp.exec(window.text())) !== null) {
									if (paragraphBreakRegexp.lastIndex >= originalOffset) {
										let updatedText = window.text().slice(0, paragraphBreakRegexpResult.index) + '\n[' + referenceName + ']: ' + url + paragraphBreakRegexpResult[0] + window.text().slice(paragraphBreakRegexp.lastIndex);
										window.text = updatedText;
										break;
									}
								}
							} else {
								let prependedExtraLineBreak = '\n\n';
								if (/\n\s*$/.test(window.text())) {
									prependedExtraLineBreak = '';
								}
							
								window.text = window.text() + prependedExtraLineBreak + '[' + referenceName + ']: ' + url + '\n';
							}
						}
						app.select(window.characters.at(newOffset).insertionPoints.at(0));
					} else if (format !== 'Plain Text') {
						let formatting = formatTemplates.find(formatTemplate => formatTemplate.name === format.toLowerCase());
						if (formatting.template.indexOf('{URL}') >= 0) {
							let formattedUrl = formatting.template.replace('{URL}', url);
							let charsToTextInsertion = formattedUrl.split('').reverse().join('').indexOf('}TXET{');
							formattedUrl = formattedUrl.replace('{TEXT}', url);
							pasteURL(formattedUrl);
							for (let i = 0; i < charsToTextInsertion; i++) {
								system.keyCode(123);
							}
							for (let j = 0; j < url.length; j++) {
								system.keyCode(123, {using:'shift down'});
							}
						} else if (formatting.action && typeof formatting.action === 'function') {
							formatting.action(url);
						}
					} else {
						pasteURL(url);
					}
				}
			}

	}

	const openDialog = (syntax=currentTab.url()) => {
		let dialog = app.displayDialog(`Find and Paste URL from ${browserConfig.name}`, {
			// withTitle:`Find and Paste URL from ${browserConfig.name}`,
			defaultAnswer: syntax,
			buttons: ["HelpÉ", "Cancel", "Paste URL"],
			cancelButton: "Cancel",
			defaultButton: "Paste URL"
		});
		if (dialog.buttonReturned === "HelpÉ") {
			const examples = [
				{ label: 'Éthe current tab in frontmost window (empty)', syntax: '' },
				{ label: 'Éthe tab left of that current tab formatted in Markdown', syntax: '-1 .m' },
				{ label: 'Éthe tab two to the right of the current tab formatted in HTML', syntax: '2 .h' },
				{ label: 'Éa first tab formmatted in JIRA', syntax: '=1 .j' },
				{ label: 'Éa second to last tab, but reveal instead of paste', syntax: '=-2 .r' },
				{ label: 'Éa tab with the word "News" in its title', syntax: 'News' },
				{ label: 'Éa tab with an address containing "duckduckgo.com"', syntax: 'duckduckgo.com' },
				{ label: 'Just show me the full documentation', syntax: '' }
			];
			let examplesList = [];
			examples.forEach(example => examplesList.push(example.label));
			let showMe = app.chooseFromList(examplesList, {
				withTitle: 'Help',
				withPrompt: 'Show me the syntax to paste the URL fromÉ',
				defaultItems: ['Éthe current tab in frontmost window'],
			});
			let selectedSyntax = '';
			if (showMe) {
				if ( showMe[0] === 'Just show me the full documentation' ) {
					browser.openLocation('https://github.com/JackWellborn/Find-and-Paste-URL-from-Browser/blob/master/README.md');
				} else {
					selectedSyntax = examples.find(example => example.label === showMe[0]).syntax;
					openDialog(selectedSyntax);
				}
			} else {
				openDialog(selectedSyntax);
			}
		} else if (dialog.buttonReturned === "Paste URL") {
			let url = runQuery(dialog.textReturned);
			writeUrl(url);
		}
	};
	openDialog();
}
