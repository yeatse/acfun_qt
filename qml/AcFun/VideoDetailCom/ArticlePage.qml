import QtQuick 1.1
import com.nokia.symbian 1.1
import CustomWebKit 1.0
import "../Component"
import "../../js/main.js" as Script
import "../../js/database.js" as Database

MyPage {
    id: page;

    title: viewHeader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "../../gfx/favourite.svg";
            onClicked: internal.addToFav();
        }
        ToolButton {
            iconSource: "../../gfx/edit.svg";
            onClicked: internal.createCommentUI();
        }
        ToolButton {
            iconSource: "toolbar-share";
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
            Database.storeHistory(acId, detail.category.id, detail.name,
                                  detail.previewurl, detail.viewernum, detail.creator.name);
        }

        function share(){
            var url = "http://service.weibo.com/share/share.php";
            url += "?url="+encodeURIComponent("http://www.acfun.tv/v/ac"+acId);
            url += "&type=3";
            url += "&title="+encodeURIComponent(internal.detail.name||"");
            url += "&pic="+encodeURIComponent(internal.detail.previewurl||"");
            utility.openURLDefault(url);
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
                title: internal.detail.name||""
            }
            ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: internal.detail.creator?internal.detail.creator.name:"";
                }
            }
            Repeater {
                id: repeater;
                model: ListModel {}
                Column {
                    ListHeading {
                        platformInverted: true
                        visible: model.title !== "";
                        ListItemText {
                            platformInverted: true;
                            anchors.fill: parent.paddingItem;
                            role: "Heading";
                            text: model.title;
                        }
                    }
                    WebView {
                        id: webView;
                        preferredWidth: view.width;
                        preferredHeight: view.height;
                        settings {
                            standardFontFamily: platformStyle.fontFamilyRegular;
                            defaultFontSize: platformStyle.fontSizeMedium;
                            defaultFixedFontSize: platformStyle.fontSizeMedium;
                            minimumFontSize: platformStyle.fontSizeMedium;
                            minimumLogicalFontSize: platformStyle.fontSizeMedium;
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
