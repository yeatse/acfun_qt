import QtQuick 1.1
import "../../js/main.js" as Script
import "Comments.js" as Utils

Item {
    id: root;

    property string commentId;
    property int timePlayed;

    property int commentCount: 0;
    property int secondsPlayed: timePlayed / 1000;

    function get(){
        var opt = {
            pool: Utils.commentPool,
            cid: commentId
        }
        function s(){
            console.log("comment loaded");
            root.secondsPlayedChanged.connect(createText);
        }
        function f(err){
            console.log(err);
        }
        Script.getSyncComments(opt, s, f);
    }

    function createText(){
        if (secondsPlayed === 0) Utils.commentIndex = 0;
        var secs = secondsPlayed;
        var poolIdx = Utils.commentPool[Utils.commentIndex];
        while(poolIdx !== undefined && poolIdx.time < secs
              && root.commentCount < visual.maxCommentCount){
            if (secs - poolIdx.time < 3){
                var prop = {
                    "color": Utils.intToColor(poolIdx.color),
                    "font.pixelSize": poolIdx.fontSize,
                    "text": poolIdx.text
                }
                singleComment.createObject(root, prop);
            }
            poolIdx = Utils.commentPool[++Utils.commentIndex];
        }
    }

    Component.onCompleted: get();

    Component {
        id: singleComment;
        Text {
            id: commentText;

            property int idx: 0;

            x: root.width;
            y: idx*18;
            textFormat: Text.PlainText;

            NumberAnimation {
                id: normalAnimation;
                target: commentText;
                property: "x";
                from: root.width;
                to: -commentText.width;
                duration: 5000;
                onCompleted: commentText.destroy();
            }

            Component.onCompleted: {
                root.commentCount ++;
                commentText.idx = Utils.addToScreen();
                normalAnimation.start();
            }
            Component.onDestruction: {
                root.commentCount --;
                Utils.clearFromScreen(commentText.idx);
            }
        }
    }
}
