var IQiyiParser = new Function();
IQiyiParser.prototype = new VideoParser();
IQiyiParser.prototype.constructor = IQiyiParser;
IQiyiParser.prototype.name = "爱奇艺";

IQiyiParser.prototype.start = function(vid){
            var resultUrl = "";

            var url = "http://cache.m.iqiyi.com/jp/tmts/272448000/1ed6cc39cdcfeb2f3d9156a6f1b8943e/";
            var param = {
                "uid": "",
                "cupid": "qc_100001_100102",
                "platForm": "h5",
                "type": "mp4",
                "rate": "1",
                "src": "d846d0c32d664d32b6b54ea48997a589",
                "sc": "921359bdda1f665ecbf14842b2222f5f",
                "__refI": "",
                "__ctmM": Date.now(),
                "t": param.__ctmM,
                "__jsT": "sijsc",
                "callback": "QVCallback"
            }
            url += "?";
            for (var i in param){
                url += i + "=" + param[i];
            }
            var QVCallback = function(obj){
                if (obj && obj.code && obj.code == "A00000"){
                    resultUrl = obj.data.m3u;
                }
            }
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState == XMLHttpRequest.DONE){
                            if (xhr.status == 200){
                                try {
                                    eval(xhr.responseText);
                                    if (typeof(resultUrl) == "string" && resultUrl != ""){
                                        IQiyiParser.prototype.success(resultUrl);
                                        return;
                                    }
                                } catch (e){
                                }
                            }
                            IQiyiParser.prototype.error();
                        }
                    }
            xhr.open("GET", url);
            xhr.send();
        }
