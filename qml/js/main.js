.pragma library

Qt.include("acapi.js");

var signalCenter, acsettings, utility;

function initialize(sc, ac, ut){
    signalCenter = sc;
    acsettings = ac;
    utility = ut;
    signalCenter.initialized();
}

function checkAuthData(){
    var expiresBy = acsettings.expiresBy;
    var token = acsettings.accessToken;
    var userId = acsettings.userId;
    var timeDiff = expiresBy - Date.now()/1000;
    if (timeDiff > 60 && token !== "" && userId !== ""){
        return true;
    } else {
        acsettings.accessToken = "";
        signalCenter.login();
        return false;
    }
}

function getAuthUrl(){
    var url = AcApi.authorize;
    url += "?state=xyz";
    url += "&response_type=token";
    url += "&client_id="+AcApi.clientId;
    url += "&redirect_uri="+AcApi.redirectUri;
    return url;
}

function authUrlChanged(url){
    url = url.toString().replace("#","");
    if (url.indexOf(AcApi.redirectUri) === 0){
        acsettings.expiresBy = utility.urlQueryItemValue(url, "expires_in");
        acsettings.accessToken = utility.urlQueryItemValue(url, "access_token");
        acsettings.userId = utility.urlQueryItemValue(url, "user_id");
        signalCenter.userChanged();
        return true;
    } else {
        return false;
    }
}

function loadVideoModel(model, list){
    if (Array.isArray(list)){
        list.forEach(function(value){
                         var prop = {
                             acId: value.acId,
                             channelId: value.channelId,
                             name: value.name,
                             previewurl: value.previewurl,
                             viewernum: value.viewernum,
                             creatorName: value.creator.name
                         }
                         model.append(prop)
                     });
    }
}

function getVideoCategories(){
    var req = new WebRequest("GET", AcApi.videocategories);
    function s(obj){ signalCenter.videocategories = obj; }
    function f(err){ signalCenter.showMessage(err); }
    req.sendRequest(s, f);
}

function getHomeThumbnails(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.home_thumbnails);
    function s(obj){
        var model = option.model;
        model.clear();
        obj.forEach(function(value){
                        var prop = {
                            previewurl: value.previewurl,
                            jumpurl: value.jumpurl
                        }
                        model.append(prop);
                    })
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getHomeCategroies(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.home_categories);
    function s(obj){
        var model = option.model;
        model.clear();
        obj.forEach(function(value){
                        var videos = [];
                        value.videos.forEach(function(video){
                                                 var v = {
                                                     acId: video.acId,
                                                     channelId: video.channelId,
                                                     name: video.name,
                                                     desc: video.desc,
                                                     previewurl: video.previewurl,
                                                     viewernum: video.viewernum,
                                                     commentnum: video.commentnum
                                                 }
                                                 videos.push(v);
                                             })
                        var prop = {
                            id: value.id,
                            name: value.name,
                            videos: videos
                        };
                        model.append(prop);
                    })
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getVideoDetail(acId, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.videos+"/"+acId);
    req.sendRequest(onSuccess, onFailed);
}

function getVideoComments(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.videos+"/"+option.acId+"/comments");
    if (option.cursor) req.setParameters({cursor:option.cursor});
    function s(obj){
        var model = option.model;
        if (obj.pageNo === 1||option.renew){
            model.clear();
        }
        obj.list.forEach(function(value){
                             var prop = {
                                 content: value.content,
                                 userName: value.user.name,
                                 userAvatar: value.user.avatar||"",
                                 floorindex: value.floorindex
                             }
                             model.append(prop);
                         })
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getSeries(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.series);
    var opt = { type: option.type };
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
        var list = obj.list;
        if(Array.isArray(list)){
            list.forEach(function(value){
                             var prop = {
                                 acId: value.acId,
                                 name: value.name,
                                 previewurl: value.previewurl,
                                 subhead: value.subhead
                             }
                             model.append(prop);
                         })
        }
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getSeriesEpisodes(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.series+"/"+option.acId);
    function s(obj){
        var model = option.model;
        model.clear();
        obj.episodes.forEach(function(value){
                                 var prop = {
                                     subhead: value.subhead,
                                     contentId: value.contentId,
                                     previewurl: value.previewurl
                                 }
                                 model.append(prop);
                             })
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getPlaybill(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.videos_playbill+"/"+option.channelId);
    function s(obj){
        var model = option.model;
        model.clear();
        var weekdays = {
            sat: "周六",
            thu: "周四",
            wed: "周三",
            mon: "周一",
            tue: "周二",
            sun: "周日",
            fri: "周五"
        }
        for (var day in obj.data){
            var dayname = weekdays[day];
            var list = obj.data[day];
            if (typeof(dayname)==="string"
                    && Array.isArray(list)){
                list.forEach(function(value){
                                 var prop = {
                                     id: value.id,
                                     title: value.title,
                                     subhead: value.subhead,
                                     intro: value.intro.substring(0,20),
                                     cover: value.cover,
                                     day: dayname
                                 }
                                 model.append(prop);
                             })
            }
        }
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getHotkeys(model, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.hotkeys);
    function s(obj){
        model.clear();
        obj.forEach(function(value){ model.append({name: value}); });
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getSearch(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.videos_search);
    var opt = {
        channelId: "1,58,59,60,68,69,70",
        orderId: option.orderId,
        term: option.term
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
        loadVideoModel(model, obj.list);
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getClass(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.videos);
    var opt = { "class": option["class"] };
    if (option.isoriginal) opt.isoriginal = option.isoriginal;
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
        loadVideoModel(model, obj.list);
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getSyncComments(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.video_comment+"/"+option.cid);
    function s(obj){
        var pool = option.pool;
        var decodeDanmaku = function(value){
            var c = value.c;
            var clist = c.split(",");
            var mode = Number(clist[2]);
            if (mode === 1){
                var prop = new Object();
                prop.time = Number(clist[0]);
                prop.mode = mode;
                prop.color = Number(clist[1]);
                prop.fontSize = Number(clist[3]);
                prop.text = value.m;
                pool.push(prop);
            }
        }
        var sortPool = function(a, b){
            return a.time - b.time;
        }
        for (var i in obj){
            obj[i].forEach(decodeDanmaku);
        }
        pool.sort(sortPool);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getUserDetail(uid, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.users+"/"+uid);
    var opt = {access_token: acsettings.accessToken}
    req.setParameters(opt);
    req.sendRequest(onSuccess, onFailed);
}

function addToFav(acId, onSuccess, onFailed){
    var req = new WebRequest("POST", AcApi.users+"/"+acsettings.userId+"/fav/videos/collector");
    var opt = { access_token: acsettings.accessToken, videoId: acId };
    req.setParameters(opt);
    req.sendRequest(onSuccess, onFailed);
}

function getFavVideos(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.users+"/"+acsettings.userId+"/fav/videos");
    var opt = { access_token: acsettings.accessToken }
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
        loadVideoModel(model, obj.list);
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getUserVideos(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.users+"/"+acsettings.userId+"/videos");
    var opt = { access_token: acsettings.accessToken };
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model, list = obj.list;
        if (option.renew) model.clear();
        if (Array.isArray(list)){
            list.forEach(function(value){
                             var prop = {
                                 acId: value.acId,
                                 channelId: value.category,
                                 name: value.name,
                                 desc: value.desc,
                                 previewurl: value.previewurl,
                                 state: value.state
                             }
                             model.append(prop);
                         });
        }
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getPrivateMsgs(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.users+"/"+acsettings.userId+"/privatemsgs");
    var opt = { access_token: acsettings.accessToken };
    if (option.talkwith) opt.talkwith = option.talkwith;
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model, list = obj.mailList;
        if (option.renew) model.clear();
        if (Array.isArray(list)){
            var decode;
            if (option.talkwith){
                decode = function(mail){
                            var mailObj = JSON.parse(mail);
                            if (!mailObj) return;
                            var isMine = acsettings.userId === mailObj.fromuId.toString();
                            var prop = {
                                isMine: isMine,
                                text: mailObj.text,
                                postTime: new Date(Number(mailObj.postTime))
                            }
                            model.append(prop);
                        }
            } else {
                decode = function(mail){
                            var mailObj = JSON.parse(mail);
                            if (!mailObj) return;
                            var mailGroupId = mailObj.mailGroupId
                            var prop = {
                                mailGroupId: mailGroupId,
                                fromuId: mailObj.fromuId,
                                fromusername: mailObj.fromusername,
                                postTime: new Date(Number(mailObj.postTime)),
                                user_img: mailObj.user_img,
                                lastMessage: mailObj.lastMessage,
                                p2p: mailObj.p2p,
                                unread: false
                            }
                            var isUnread = function(mgid){
                                return mailGroupId === mgid;
                            }
                            prop.unread = obj.unReadList.some(isUnread);
                            model.append(prop);
                        }
            }
            list.forEach(decode);
        }
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function sendPrivteMsg(option, onSuccess, onFailed){
    var req = new WebRequest("POST", AcApi.users+"/"+acsettings.userId+"/privatemsgs");
    var opt = {
        access_token: acsettings.accessToken,
        content: option.content,
        touserName: option.touserName
    }
    req.setParameters(opt);
    req.sendRequest(onSuccess, onFailed);
}

function sendComment(option, onSuccess, onFailed){
    var req = new WebRequest("POST", AcApi.videos+"/"+option.acId+"/comments");
    var opt = {
        access_token: acsettings.accessToken,
        content: option.content
    }
    req.setParameters(opt);
    req.sendRequest(onSuccess, onFailed);
}
