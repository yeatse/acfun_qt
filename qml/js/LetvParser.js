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
        };

var Letv2Parser = new Function();
Letv2Parser.prototype = new VideoParser();
Letv2Parser.prototype.constructor = Letv2Parser;
Letv2Parser.prototype.name = "乐视";

Letv2Parser.prototype.start = function(vid){
            function GenerateKeyRor(value, key) {
                var i = 0;
                while (i < key) {
                    value = (0x7fffffff & (value >> 1)) | ((value & 1) << 31);
                    ++i;
                }
                return value;
            }
            function GenerateKey(stime) {
                var key = 773625421;
                var value = GenerateKeyRor(stime, key % 13);
                value = value ^ key;
                value = GenerateKeyRor(value, key % 17);
                return value;
            }
//            http://api.letv.com/mms/out/common/geturl?platid=3&splatid=301&callback=vjs_1407252559281&playid=0&vtype=9,13,21&version=2.0&tss=no&vid=20439176&domain=m.letv.com&tkey=-749427743&_r=0
        }
