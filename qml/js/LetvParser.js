var LetvParser = new Function();
LetvParser.prototype = new VideoParser();
LetvParser.prototype.constructor = LetvParser;
LetvParser.prototype.name = "乐视";

LetvParser.prototype.start = function(vid){
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState == xhr.DONE){
                            if (xhr.status == 200){
                                try {
                                    var resp = JSON.parse(xhr.responseText);
                                    if (resp.code == 0){
                                        var vl = resp.data.video_list;
                                        var mainUrl = vl[vl.default_play].main_url;
                                        var result = Qt.atob(mainUrl);
                                        LetvParser.prototype.success(result);
                                        return;
                                    }
                                } catch (e){
                                }
                            }
                            LetvParser.prototype.error();
                        }
                    }
            var url = "http://api.letvcloud.com/gpc.php?cf=html5&sign=signxxxxx&ver=2.0&format=json&vu=%1&uu=419176ad52".arg(vid);
            xhr.open("GET", url);
            xhr.send();
        }
