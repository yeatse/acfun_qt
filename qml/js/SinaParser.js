var SinaParser = new Function();
SinaParser.prototype = new VideoParser();
SinaParser.prototype.constructor = SinaParser;
SinaParser.prototype.name = "新浪";

SinaParser.prototype.start = function(vid){
            var url = "http://video.sina.com.cn/interface/video_ids/video_ids.php?v="+vid;
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState === XMLHttpRequest.DONE){
                            if (xhr.status === 200){
                                try {
                                    var obj = JSON.parse(xhr.responseText);
                                    if (obj.ipad_vid !== 0){
                                        SinaParser.prototype.success("http://v.iask.com/v_play_ipad.php?vid="+obj.ipad_vid);
                                        return;
                                    } else {
                                    }
                                } catch (e){
                                }
                            }
                            SinaParser.prototype.error();
                        }
                    }
            xhr.open("GET", url);
            xhr.send();
        }
