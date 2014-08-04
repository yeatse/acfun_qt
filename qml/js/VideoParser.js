var VideoParser = new Function();

VideoParser.prototype.name = "";

VideoParser.prototype.start = function(vid){
            console.log(vid);
        };

VideoParser.prototype.success = function(url){
            console.log(url);
        };

VideoParser.prototype.error = function(message){
            console.log(message);
        };
