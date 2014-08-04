var QQParser = new Function();
QQParser.prototype = new VideoParser();
QQParser.prototype.constructor = QQParser;
QQParser.prototype.name = "QQ";

QQParser.prototype.start = function(vid){
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState === XMLHttpRequest.DONE){
                            if (xhr.status == 200){
                                var QZOutputJson;
                                try {
                                    eval(xhr.responseText);
                                    var url = QZOutputJson.vd.vi[0].url;
                                    QQParser.prototype.success(url);
                                    return;
                                } catch(e){
                                }
                            }
                            QQParser.prototype.error();
                        }
                    }
            xhr.open("GET", "http://vv.video.qq.com/geturl?vid=%1&otype=json".arg(vid));
            xhr.send();
        }
