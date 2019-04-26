JsOsaDAS1.001.00bplist00�Vscript_var browserConfigs = {
	chrome: {
		name: "Google Chrome"
	},
	safari: {
		name: "Safari"
	}
};

var browserConfig = browserConfigs.safari;

var system = Application("System Events");
system.includeStandardAdditions = true;
var browser = Application(system.processes.whose({ _and:[{name:{_beginsWith: browserConfig.name}}, {visible:true}]})[0].name());
browser.includeStandardAdditions = true;

//For whatever reason this works wheres currentApplication does not.
var app = Application(system.processes.where({frontmost:true})[0].displayedName());
app.includeStandardAdditions = true;

function getTabByAbsoluteIndex(query) {
	var index;
	
	if (query > browser.windows[0].tabs.length) {
		query = query % browser.windows[0].tabs.length;
	}
	if ( query < 0 ) {
		index = browser.windows[0].tabs().length + query;
	} else {
		index = query - 1;
	}
	return [browser.windows[0].tabs[index].url()];
}

function getTabByRelativeIndex(query) {
	var currentTabIndex = browserConfig === browserConfigs.safari ? 
		browser.windows[0].currentTab().index() : 
		browser.windows[0].activeTabIndex();
	var relativeTabIndex = currentTabIndex-1 + query;
	if (relativeTabIndex >= browser.windows[0].tabs().length) {
		relativeTabIndex = relativeTabIndex - browser.windows[0].tabs().length;
	}
	return [browser.windows[0].tabs[relativeTabIndex].url()];
}

function getTabsWithUrlsThatContain(query) {
	var urls = [];
	var tabs = browser.windows[0].tabs.whose({ url:{ _contains: query }});
	tabs().forEach(function(tab) {
		urls.push(tab.url());
	});
	return urls;
}

function getTabsWithTitlesThatContain(query) {
	var titles = [];
	var tabs = browser.windows[0].tabs.whose({ name:{ _contains: query }});
	tabs().forEach(function(tab) {
		titles.push(tab.url());
	});
	return titles;
}

function runQuery(input) {
	var input = input.toString();
	var fullQuery = input;
	var queryCharacter = fullQuery.charAt(0);
	var	queryParameter =  fullQuery.substring(1);
	var queryCharacters = ['<','>','+','-','?','/'];
	var url;
	var urls = [];
	if(queryCharacters.indexOf(queryCharacter) >= 0) {
		switch(queryCharacter) {
			case "+":
				urls = getTabByAbsoluteIndex(parseInt(queryParameter, 10));
				break;
			case "-":
				urls = getTabByAbsoluteIndex(parseInt(queryParameter, 10)*-1);
				break;
			case ">":
				urls = getTabByRelativeIndex(parseInt(queryParameter, 10));
				break;
			case "<":
				urls = getTabByRelativeIndex(parseInt(queryParameter, 10)*-1);
				break;
			case "/":
				urls = getTabsWithUrlsThatContain(queryParameter);
				break;
			case "?":
				urls = getTabsWithTitlesThatContain(queryParameter);
				break;
		}
	} else {
		browser.windows[0].tabs()
			.reverse()
			.slice(0,6)
			.forEach(function(tab){
				urls.push(tab.url());
			});
	}
	
	if(urls.length > 1) {
		var choice = app.chooseFromList(urls, {
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
	var savedClipboard = app.theClipboard();
	
	// Gross hack to create markdown links, because I am lazy.
	if(/^\[.+\]$/.test(savedClipboard) && savedClipboard != "[object Object]"){
		url = savedClipboard + '(' + url + ')'; 
	}
	
	app.setTheClipboardTo(url);
	system.keystroke('v',{using:["command down"]});
	delay(.5);
	app.setTheClipboardTo(savedClipboard);
}
var query = app.displayDialog(`Use "?" to query tabs by title (e.g. "?Google".)
	
Use "/" to query tabs by URL (e.g. "/google.com".)

Use "+" or "-" to query tabs by absolute position (e.g. "+1" for the leftmost tab and "-1" for the rightmost tab.)
	
Use "<" or ">" to query tabs by relative position to current tab (e.g. "<1" for one tab left of current tab and ">1" one tab right of current tab.)
	
Leave empty to get the 6 rightmost tabs.`, {
	withTitle:`Find and Paste URL from ${browserConfig.name}`,
	defaultAnswer:"",
	buttons:["Cancel", "Find URLs"],
	cancelButton: "Cancel",
	defaultButton:"Find URLs"
});
var url = runQuery(query.textReturned); 
pasteURL(url);

                              2jscr  ��ޭ