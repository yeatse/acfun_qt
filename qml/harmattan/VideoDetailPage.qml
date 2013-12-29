import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script
import "../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
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

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        property Text textHelper: Text {
            font: constant.subTitleFont;
            text: " ";
            visible: false;
        }

        property variant commentUI: null;

        function createCommentUI(){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("VideoDetailCom/CommentUI.qml").createObject(page);
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
            function s(){ loading = false; signalCenter.showMessage("发送成功"); getComments(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendComment(opt, s, f);
        }

        function getDetail(){
            titleBanner.error = false;
            titleBanner.loading = true;
            function s(obj){
                titleBanner.loading = false;
                detail = obj;
                if (isArticle(obj.category.id)){
                    pageStack.push(Qt.resolvedUrl("VideoDetailCom/ArticlePage.qml"),
                                   {acId: acId},
                                   true);
                } else {
                    getComments();
                }
            }
            function f(err){
                titleBanner.loading = false;
                titleBanner.error = true;
                if (err === 403){
                    pageStack.push(Qt.resolvedUrl("VideoDetailCom/OldDetailPage.qml"),
                                   {acId: acId},
                                   true);
                } else {
                    signalCenter.showMessage(err);
                }
            }
            Script.getVideoDetail(acId, s, f);
        }

        function getComments(option){
            loading = true;
            var opt = { acId: acId, model: commentListView.model }
            if (commentListView.count === 0) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
            } else {
                opt.cursor = pageNumber * pageSize;
            }
            function s(obj){
                loading = false;
                pageNumber = obj.pageNo;
                totalNumber = obj.totalCount;
                pageSize = obj.pageSize;
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getVideoComments(opt, s, f);
        }
        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
                function s(){ loading = false; signalCenter.showMessage("收藏视频成功!") }
                function f(err){ loading = false; signalCenter.showMessage(err); }
                Script.addToFav(acId, s, f);
            }
        }
        function log(){
            Database.storeHistory(acId, detail.name, detail.previewurl,
                                  detail.viewernum, detail.creator.name);
        }
        function share(){
            var link = "http://www.acfun.tv/v/ac"+acId;
            var title = internal.detail.name||"";
            utility.share(title, link);
        }
        function isArticle(id){
            var list = signalCenter.videocategories;
            for (var i=0; i<list.length; i++){
                var cur = list[i];
                if (cur.name === "文章"){
                    if (cur.id === id)
                        return true;
                    var check = function(value){
                        return value.id === id;
                    }
                    return cur.subclasse.some(check);
                }
            }
            return false;
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "视频详细";
    }

    Item {
        id: titleBanner;

        property bool loading: false;
        property bool error: false;

        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        height: 180 + constant.paddingMedium*2;

        z: 10;

        // Background

        // Preview
        Image {
            id: preview;
            anchors {
                left: parent.left; top: parent.top;
                margins: constant.paddingMedium;
            }
            width: 240;
            height: 180;
            sourceSize: Qt.size(240, 180);
            smooth: true;
            source: internal.detail.previewurl||"";
        }
        Image {
            anchors.centerIn: preview;
            source: visible ? "image://theme/icon-m-toolbar-gallery" : "";
            visible: preview.status != Image.Ready;
        }
        Button {
            platformStyle: ButtonStyle {
                buttonWidth: buttonHeight;
                inverted: true;
            }
            anchors.centerIn: preview;
            iconSource: "image://theme/icon-m-toolbar-mediacontrol-play-white";
        }
        Rectangle {
            color: "black";
            anchors.fill: preview;
            opacity: previewMouseArea.pressed ? 0.3 : 0;
        }
        MouseArea {
            id: previewMouseArea;
            anchors.fill: preview;
            enabled: internal.detail.hasOwnProperty("episodes")
                     && internal.detail.episodes.length > 0;
            onClicked: {
                internal.log();
                var e = internal.detail.episodes[0];
                signalCenter.playVideo(
                            page.acId,
                            e.type,
                            e.sourceId,
                            e.commentId||e.videoId
                            );
            }
        }

        // Infomation
        Text {
            anchors {
                left: preview.right; leftMargin: constant.paddingLarge;
                right: parent.right; rightMargin: constant.paddingMedium;
                top: preview.top;
            }
            font: constant.labelFont;
            color: constant.colorLight;
            wrapMode: Text.Wrap;
            elide: Text.ElideRight;
            maximumLineCount: 2;
            text: internal.detail.name||"";
        }

        Row {
            visible: !titleBanner.error;
            anchors {
                left: preview.right; leftMargin: constant.paddingLarge;
                bottom: parent.bottom; bottomMargin: constant.paddingSmall;
            }
            spacing: constant.paddingMedium;
            Column {
                Repeater {
                    model: [
                        "../gfx/image_upman_small.png",
                        "../gfx/image_watches_small.png",
                        "../gfx/image_comments_small.png"
                    ]
                    Item {
                        width: internal.textHelper.height;
                        height: width;
                        Image {
                            anchors.centerIn: parent;
                            source: modelData;
                        }
                    }
                }
            }
            Column {
                Repeater {
                    model: [
                        internal.detail.creator ? internal.detail.creator.name : " ",
                        internal.detail.viewernum||"0",
                        internal.detail.commentnum||"0"
                    ]
                    Text {
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: modelData;
                    }
                }
            }
        }
        // Loading indicator
        Rectangle {
            anchors.fill: parent;
            color: "black";
            opacity: titleBanner.loading ? 0.3 : 0;
        }
        BusyIndicator {
            anchors.centerIn: parent;
            running: true;
            visible: titleBanner.loading;
            platformStyle: BusyIndicatorStyle {
                size: "large";
            }
        }
        Button {
            anchors.centerIn: parent;
            platformStyle: ButtonStyle {
                buttonWidth: buttonHeight;
            }
            iconSource: "image://theme/icon-m-toolbar-refresh";
            onClicked: internal.getDetail();
            visible: titleBanner.error;
        }
    }

    ButtonRow {
        id: tabRow;
        anchors {
            left: parent.left; top: titleBanner.bottom; right: parent.right;
        }
        TabButton {
            text: "评论";
            tab: commentView;
        }
        TabButton {
            text: "视频详请";
            tab: detailView;
        }
        TabButton {
            text: "视频段落";
            tab: episodeView;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        currentTab: commentView;
        clip: true;
        Item {
            id: commentView;
            anchors.fill: parent;
            ListView {
                id: commentListView;
                anchors.fill: parent;
                model: ListModel {}
                header: PullToActivate {
                    myView: commentListView;
                    enabled: !loading;
                    onRefresh: internal.getComments();
                }
                delegate: commentDelegate;
                footer: FooterItem {
                    visible: internal.pageSize*internal.pageNumber<internal.totalNumber;
                    enabled: !loading;
                    onClicked: internal.getComments("next");
                }
            }
            Component {
                id: commentDelegate;
                AbstractItem {
                    id: root;
                    implicitHeight: contentCol.height+constant.paddingLarge*2;
                    Image {
                        id: avatar;
                        anchors {
                            left: root.paddingItem.left;
                            top: root.paddingItem.top;
                        }
                        width: constant.graphicSizeMedium;
                        height: constant.graphicSizeMedium;
                        sourceSize: Qt.size(width, height);
                        source: model.userAvatar||"../gfx/avatar.jpg";
                    }
                    Column {
                        id: contentCol;
                        anchors {
                            left: avatar.right; leftMargin: constant.paddingSmall;
                            right: root.paddingItem.right; top: root.paddingItem.top;
                        }
                        Item {
                            width: parent.width;
                            height: childrenRect.height;
                            Text {
                                anchors.left: parent.left;
                                font: constant.labelFont;
                                color: constant.colorMid;
                                text: model.userName;
                            }
                            Text {
                                anchors.right: parent.right;
                                font: constant.labelFont;
                                color: constant.colorMid;
                                text: "#"+model.floorindex;
                            }
                        }
                        Text {
                            width: parent.width;
                            wrapMode: Text.Wrap;
                            font: constant.labelFont;
                            color: constant.colorLight;
                            text: model.content;
                        }
                    }
                }
            }
        }
        Item {
            id: detailView;
            anchors.fill: parent;
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    top: parent.top; margins: constant.paddingMedium;
                }
                wrapMode: Text.Wrap;
                textFormat: Text.RichText;
                font: constant.labelFont;
                color: constant.colorLight;
                text: internal.detail.desc||"";
            }
        }
        Item {
            id: episodeView;
            anchors.fill: parent;
            ListView {
                anchors.fill: parent;
                model: internal.detail.episodes||[];
                delegate: AbstractItem {
                    Text {
                        anchors.left: parent.paddingItem.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: modelData.name||"视频片段"+(index+1);
                    }
                    onClicked: {
                        internal.log();
                        signalCenter.playVideo(
                                    page.acId,
                                    modelData.type,
                                    modelData.sourceId,
                                    modelData.commentId||modelData.videoId
                                    );
                    }
                }
            }
        }
    }
}
