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
    var url = "http://api.3g.youku.com/videos/"+sid
            +"/download?point=1&pid=69b81504767483cf&format=1,4,6";
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(){
                if (xhr.readyState === xhr.DONE){
                    if (xhr.status === 200){
                        try {
                            var obj = JSON.parse(xhr.responseText);
                            if (obj.status === "success"){
                                if (obj["results"]["3gphd"].length>0){
                                    launchPlayer(obj["results"]["3gphd"][0].url);
                                } else if (obj["results"]["mp4"].length>0){
                                    var u = [];
                                    obj["results"]["mp4"].forEach(function(value){u.push(value.url)});
                                    addMessage("正在尝试使用系统播放器...");
                                    utility.launchPlayer(u.join("\n"));
                                } else {
                                    addMessage("视频格式暂不支持，抱歉了QAQ");
                                }
                            } else {
                                addMessage("服务器错误");
                            }
                        } catch(e){
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

function loadQQ(){
    addMessage("视频来自QQ，正在打开浏览器...");
    var u = "http://vsrc.store.qq.com/"+sid
            +".mp4?channel=vhot2&sdtfrom=v2&r=931&rfc=v0"
    utility.openURLDefault(u);
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
