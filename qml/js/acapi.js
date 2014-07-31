.pragma library

var AcApi = {
    clientId:           "hf2QkYjrqcT3ndr9",
    authorize:          "https://ssl.acfun.tv/oauth2/authorize.aspx",
    redirectUri:        "https://ssl.acfun.tv/authSuccess.aspx",

    videocategories:    "http://api.acfun.tv:1069/videocategories",
    home_thumbnails:    "http://api.acfun.tv:1069/home/thumbnails",
    home_categories:    "http://api.acfun.tv:1069/home/categories",
    videos:             "http://api.acfun.tv:1069/videos",
    series:             "http://api.acfun.tv:1069/series",
    videos_playbill:    "http://api.acfun.tv:1069/videos/playbill",
    hotkeys:            "http://api.acfun.tv:1069/hotkeys",
    videos_search:      "http://api.acfun.tv:1069/videos/search",
    danmaku:            "http://danmaku1.acfun.tv",
    users:              "http://api.acfun.tv:1069/users",

    video_comment:      "http://static.comment.acfun.tv"
}

var WebRequest = function (method, url){
    this.method = method;
    this.url = url;
    this.parameters = new Object();
    this.encodedParams = function(){
             var res = [];
             for (var i in this.parameters){
                 res.push(i+"="+encodeURIComponent(this.parameters[i]));
             }
             return res.join("&");
         }
}

WebRequest.prototype.setParameters = function(param){
            for (var i in param) this.parameters[i] = param[i];
        }

WebRequest.prototype.sendRequest = function(onSuccess, onFailed){
            console.log("request==========\n", this.url);
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState === xhr.DONE){
                            if (xhr.status === 200 || xhr.status === 201){
                                var res;
                                try {
                                    res = JSON.parse(xhr.responseText);
                                } catch(e){
                                    res = xhr.responseText;
                                }
                                try {
                                    onSuccess(res);
                                } catch(e){
                                    onFailed(JSON.stringify(e));
                                }
                            } else {
                                onFailed(xhr.status);
                            }
                        }
                    }
            var p = this.encodedParams(), m = this.method;
            if (m === "GET" && p.length > 0){
                xhr.open("GET", this.url+"?"+p);
            } else {
                xhr.open(m, this.url);
            }

            if (m === "POST"){
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                xhr.setRequestHeader("Content-Length", p.length);
                xhr.send(p);
            } else if (m === "GET"){
                xhr.send();
            }
        }
