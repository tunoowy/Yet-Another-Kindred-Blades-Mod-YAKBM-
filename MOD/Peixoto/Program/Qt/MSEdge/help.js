function LoadCSS(css_file)
{
    var head  = document.getElementsByTagName('HEAD')[0]; 
    var link  = document.createElement('link');
    link.rel  = 'stylesheet'; 
    link.type = 'text/css'; 
    link.href = css_file;    
    head.appendChild(link);    
};

function SendMessage(message, id)
{
    json = { 'msg': message, 'id': String(id) };
    window.chrome.webview.postMessage(JSON.stringify(json));
};

function SendKeyDown(id, key) 
{    
    json = { 'msg': 'KeyDown', 'id': id, 'key' : key};
    window.chrome.webview.postMessage(JSON.stringify(json));
};

function InsertElementOnBody(tag, id) 
{
    var element = document.createElement(tag);
    element.id = id;
    element.onmouseover = function (e) { SendMessage('Over', element.id); e.stopPropagation(); };
    element.onmouseout  = function (e) { SendMessage('Out', element.id); e.stopPropagation(); };
    element.onclick     = function (e) { SendMessage('Clicked', element.id); e.stopPropagation(); };
    element.onkeypress  = function (e) { SendKeyDown(element.id, e.key); };
    document.body.appendChild(element);
};

function InsertElementOnElement(tag, id, parent_id)
{
    var element = document.createElement(tag);
    element.id  = id;
    element.onmouseover = function (e) { SendMessage('Over', element.id); e.stopPropagation(); };
    element.onmouseout  = function (e) { SendMessage('Out', element.id); e.stopPropagation(); };
    element.onclick     = function (e) { SendMessage('Clicked', element.id); e.stopPropagation(); };
    element.onkeypress  = function (e) { SendKeyDown(element.id, e.key); };
    element.onpaste     = function (e) { SendKeyDown(element.id); e.clipboardData.getData('text/plain'); };
    document.getElementById(parent_id).appendChild(element);
}; 

function SliderValueChanged()
{
    json = { 'msg': 'SliderValueChanged', 'id': document.activeElement.id, 'value' : document.activeElement.value};
    window.chrome.webview.postMessage(JSON.stringify(json));	
};	

function RemoveElement(id)
{
    var element = document.getElementById(id);
    if (element == null)
        return;
    element.parentNode.removeChild(element);    
}; 

function EnumChildren(parent_id)
{
    var children = document.getElementById(parent_id).children;   
	for (var i = 0; i < children.length; i++) 
	{
        const newLocal = 'enumchildren';
        json = { 'msg': newLocal, 'id': parent_id, 'child' : children[i].id};
        window.chrome.webview.postMessage(JSON.stringify(json));      
	}
}; 