import QtQuick 1.1
import com.nokia.meego 1.1
import CustomWebKit 1.0
import "../Component"
import "../../js/main.js" as Script
import "../../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: {
                pageStack.pop(undefined, true);
                pageStack.pop();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-favorite-mark";
            onClicked: internal.addToFav();
        }
        ToolIcon {
            platformIconId: "toolbar-edit";
            onClicked: internal.createCommentUI();
        }
        ToolIcon {
            platformIconId: "toolbar-share";
            onClicked: internal.share();
        }
    }

    property string acId;
    onAcIdChanged: internal.getDetail();

    QtObject {
        id: internal;

        property variant detail: ({});

        property variant commentUI: null;

        function createCommentUI(){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("CommentUI.qml").createObject(page);
                commentUI.accepted.connect(sendComment);
            }
            commentUI.text = "";
            commentUI.open();
        }

        function sendComment(){
            var text = commentUI.text;
            if (text.length < 5){
                signalCenter.showMessage("回复长度过短。回复字数应不少于5个字符。");
                return;
            }
            loading = true;
            var opt = { acId: acId, content: text }
            function s(){ loading = false; signalCenter.showMessage("发送成功"); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendComment(opt, s, f);
        }

        function getDetail(){
            loading = true;
            function s(obj){ loading = false; detail = obj; loadText(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getVideoDetail(acId+"/Article", s, f);
        }

        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
                var s = function(){ loading = false; signalCenter.showMessage("收藏文章成功!") }
                var f = function(err){ loading = false; signalCenter.showMessage(err); }
                Script.addToFav(acId, s, f);
            }
        }

        function log(){
            Database.storeHistory(acId, detail.name, detail.previewurl,
                                  detail.viewernum, detail.creator.name);
        }

        function share(){
            var link = "http://www.acfun.tv/v/ac"+acId;
            var title = detail.name||"";
            utility.share(title, link);
        }

        function loadText(){
            var model = repeater.model;
            model.clear();
            var partRep = /\[NextPage](.*?)\[\/NextPage]/g
            var text = detail.txt;
            if (!partRep.test(text)){
                model.append({title: "", text: text});
            } else {
                for (var info = partRep.exec(text), startIndex = 0;
                     info;
                     startIndex = partRep.lastIndex, info = partRep.exec(text)){
                    var prop = {
                        title: info[1],
                        text: text.substring(startIndex, partRep.lastIndex)
                    };
                    model.append(prop);
                }
            }
        }
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        contentWidth: contentCol.width;
        contentHeight: contentCol.height;
        boundsBehavior: Flickable.StopAtBounds;
        Column {
            id: contentCol;
            ViewHeader {
                id: viewHeader;
                width: view.width;
                title: internal.detail.name||""
            }
            SectionHeader {
                width: view.width;
                title: internal.detail.creator?internal.detail.creator.name:"";
            }
            Repeater {
                id: repeater;
                model: ListModel {}
                Column {
                    SectionHeader {
                        width: webView.width;
                        title: model.title;
                        visible: title !== "";
                    }
                    WebView {
                        id: webView;
                        preferredWidth: view.width;
                        preferredHeight: view.height;
                        settings {
                            standardFontFamily: "Nokia Pure Text"
                            defaultFontSize: 26
                            defaultFixedFontSize: 26
                            minimumFontSize: 26
                            minimumLogicalFontSize: 26
                        }
                        html: model.text;
                        onLinkClicked: Qt.openUrlExternally(link);
                    }
                }
            }
            Text {
                width: view.width;
                wrapMode: Text.Wrap;
                font: constant.labelFont;
                color: constant.colorMid;
                text: internal.detail.desc||"";
            }
        }
    }

    ScrollDecorator { flickableItem: view; }
}
