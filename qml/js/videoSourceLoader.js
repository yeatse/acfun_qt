Qt.include("YoukuParser.js");

var sid, type, model;

function loadSource(t, s, m){
    sid = s; type = t; model = m;
    switch (type){
    case "sina": loadSina(); break;
    case "youku": loadYouku(); break;
    case "qq": loadQQ(); break;
    case "pps": loadPps(); break;
    default: addMessage("未支持的视频源:"+type); break;
    }
}

function loadSina(){
    addMessage("视频来自新浪，正在解析源地址...");
    if (sid.toString() === ""){
        addMessage("视频解析失败> <");
        return;
    }
    var url = "http://video.sina.com.cn/interface/video_ids/video_ids.php?v="+sid;
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(){
                if (xhr.readyState === xhr.DONE){
                    if (xhr.status === 200){
                        try {
                            var obj = JSON.parse(xhr.responseText);
                            if (obj.ipad_vid !== 0){
                                launchPlayer("http://v.iask.com/v_play_ipad.php?vid="+obj.ipad_vid);
                            } else {
                                addMessage("未支持的视频格式，正在尝试下载视频...");
                                utility.openURLDefault("http://v.iask.com/v_play_ipad.php?vid="+sid);
                            }
                        } catch (e){
                            addMessage("无法解析视频> <");
                        }
                    } else {
                        addMessage("网络连接错误，代码"+xhr.status);
                    }
                }
            }
    xhr.open("GET", url);
    xhr.send();
}

function loadYouku(){
    addMessage("视频来自优酷，正在解析源地址...");
    if (sid.toString() === ""){
        addMessage("视频解析失败> <");
        return;
    }
    fetch(sid);
}

function loadQQ(){
    addMessage("视频来自QQ，正在解析源地址...");
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(){
                if (xhr.readyState == XMLHttpRequest.DONE){
                    if (xhr.status == 200){
                        var QZOutputJson;
                        try {
                            eval(xhr.responseText);
                            var url = QZOutputJson.vd.vi[0].url;
                            launchPlayer(url);
                        } catch (e){
                            addMessage("视频解析失败> <");
                        }
                    } else {
                        addMessage("视频解析失败> <");
                    }
                }
            }
    xhr.open("GET", "http://vv.video.qq.com/geturl?vid=%1&otype=json".arg(sid));
    xhr.send();
}

function loadPps(){
    addMessage("视频来自PPS，正在解析源地址...");
    var url = "http://ipd.pps.tv/web/api/v_play.php?vid="+sid;
    networkHelper.createDeflatedRequest(url);
}

function loadPpsData(data){
    var url = utility.domNodeValue(data, "url");
    if (url.length === 0){
        addMessage("无法解析视频> <");
        return;
    }
    if (url.indexOf("vurl.pps.iqiyi.com") > 0){
        addMessage("未支持的视频格式，正在尝试下载视频...");
        utility.openURLDefault(url);
    } else {
        url = url.replace("vurl.ppstv.com","vurl.pps.tv");
        url = url.substring(0, url.length-4)+".mp4";
        launchPlayer(url);
    }
}

function addMessage(msg){
    model.append({"text": msg});
}

function launchPlayer(url){
    if (acsettings.usePlatformPlayer){
        addMessage("正在打开本地播放器...");
        utility.launchPlayer(url);
        exit();
    } else {
        addMessage("正在打开播放器...");
        createPlayer(url);
    }
}
