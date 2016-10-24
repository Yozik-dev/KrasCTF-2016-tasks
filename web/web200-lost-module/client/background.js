function getRandomPronounceableWord(length) {
    length = length ? length : 8;
    var cons = [
        'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm',
        'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'z',
        'pt', 'gl', 'gr', 'ch', 'ph', 'ps', 'sh', 'st', 'th', 'wh'
    ];

    var cons_cant_start = [
        'ck', 'cm',
        'dr', 'ds',
        'ft',
        'gh', 'gn',
        'kr', 'ks',
        'ls', 'lt', 'lr',
        'mp', 'mt', 'ms',
        'ng', 'ns',
        'rd', 'rg', 'rs', 'rt',
        'ss',
        'ts', 'tch'
    ];

    var vows = [
        'a', 'e', 'i', 'o', 'u', 'y',
        'ee', 'oa', 'oo'
    ];

    var current = Math.random() > 0.5 ? cons : vows;

    var word = '';

    while( word.length < length ) {

        if( word.length == 2 ) {
            if(JSON.stringify(current) == JSON.stringify(cons)) {
                var cons = current = cons.concat(cons_cant_start);
            } else {
                var cons = cons.concat(cons_cant_start);
            }
        }

        var rnd = current[ Math.floor( Math.random() * current.length ) ];

        if( (word + rnd).length <= length ) {
            word += rnd;
            current = ( JSON.stringify(current) == JSON.stringify(cons) ? vows : cons );
        }
    }

    return word;
}
function strhash(str ) {
    if (str.length % 32 > 0) str += Array(33 - str.length % 32).join("z");
    var hash = '', bytes = [], i = j = k = a = 0, dict = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','1','2','3','4','5','6','7','8','9'];
    for (i = 0; i < str.length; i++ ) {
        ch = str.charCodeAt(i);
        bytes[j++] = (ch < 127) ? ch & 0xFF : 127;
    }
    var chunk_len = Math.ceil(bytes.length / 32);
    for (i=0; i<bytes.length; i++) {
        j += bytes[i];
        k++;
        if ((k == chunk_len) || (i == bytes.length-1)) {
            a = Math.floor( j / k );
            if (a < 32)
                hash += '0';
            else if (a > 126)
                hash += 'z';
            else
                hash += dict[  Math.floor( (a-32) / 2.76) ];
            j = k = 0;
        }
    }
    return hash;
}

var LOGIN = null;
chrome.runtime.onInstalled.addListener(function(details){
    if(details.reason == "install"){
        LOGIN = getRandomPronounceableWord();
        chrome.storage.local.set({login: LOGIN}, function (data) {
            console.log("Login set success");
        });
    }else if(details.reason == "update"){
        console.log("Updated from " + details.previousVersion + "!");
    }
});

var TAB_EXTENSION_ID = null;
chrome.browserAction.onClicked.addListener(function (tab) {
    var url = chrome.extension.getURL('index.html');
    chrome.tabs.query({url: url}, function (tabs) {
        if (tabs.length) {
            chrome.tabs.update(tabs[0].id, {active: true});
        } else {
            chrome.tabs.create({url: url}, function(tab){
                TAB_EXTENSION_ID = tab.id;
                onRewriteHeaders();
            });
        }
        setTimeout(function() {
            chrome.storage.local.get('login', function (data) {
                //sendPageMessage('set-login', data.login)
                sendPageMessage('s-b', data.login)
            });
        }, 1000);
    });
});

var HASH;
var beforeRequestListener = function (details) {
    HASH = '';
    if(details.requestBody && details.requestBody.formData) {
        var formData = details.requestBody.formData;
        var keys = Object.keys(formData);
        keys.sort();
        for (var i in keys) HASH += formData[keys[i]][0] + '%';
    }
    HASH += LOGIN + '%end';
};

var beforeSendHeadersListener = function (details) {
    var headers = details.requestHeaders,
        blockingResponse = {};
    console.log(HASH);
    headers.push({name:'X-Hash', value: strhash(HASH)});
    blockingResponse.requestHeaders = headers;
    return blockingResponse;
};

function sendPageMessage(action, value, callback){
    callback = callback ? callback : function(response){
        if(response.status){
            console.log('Message success', action);
        } else {
            console.log('Message fail', action);
        }
    };
    chrome.tabs.sendMessage(TAB_EXTENSION_ID, {
        to: 'page',
        action: action,
        value: value
    }, callback);
}

function offRewriteHeaders(eventName) {
    removeListeners(eventName);
}
function removeListeners(eventName){
    if (chrome.webRequest.onBeforeRequest.hasListener(beforeRequestListener)){
        chrome.webRequest.onBeforeRequest.removeListener(beforeRequestListener);
    }
    if (chrome.webRequest.onBeforeSendHeaders.hasListener(beforeSendHeadersListener)){
        chrome.webRequest.onBeforeSendHeaders.removeListener(beforeSendHeadersListener);
        console.log('Rewrite OFF on ' + eventName);
    }
}

function onRewriteHeaders() {
    chrome.webRequest.onBeforeRequest.addListener(beforeRequestListener, {
        urls: ["*://*/*"]
    }, ["requestBody"]);
    chrome.webRequest.onBeforeSendHeaders.addListener(beforeSendHeadersListener, {
        urls: ["*://*/*"]
    }, ["requestHeaders", "blocking"]);
    console.log('Rewrite ON');
}

chrome.tabs.onActivated.addListener(function(activeInfo) {
    offRewriteHeaders('Activated');
});
chrome.tabs.onRemoved.addListener(function(tabId) {
    if(tabId == TAB_EXTENSION_ID){
        TAB_EXTENSION_ID = null;
        offRewriteHeaders('Removed');
    }
});


