import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script
import "../../js/database.js" as Database

MyPage {
    id: page;

    title: viewHeader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: {
                pageStack.pop(undefined, true);
                pageStack.pop();
            }
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
                getComments();
                loadText();
            }
            function f(err){
                titleBanner.loading = false;
                titleBanner.error = true;
                signalCenter.showMessage(err);
            }
            Script.getVideoDetail(acId+"/Article", s, f);
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
            var url = "http://service.weibo.com/share/share.php";
            url += "?url="+encodeURIComponent("http://www.acfun.tv/v/ac"+acId);
            url += "&type=3";
            url += "&title="+encodeURIComponent(internal.detail.name||"");
            url += "&pic="+encodeURIComponent(internal.detail.previewurl||"");
            Qt.openUrlExternally(url);
        }

        function loadText(){
            var model = episodeModel;
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

        function play(text){
            var srcMatch = text.match(/src="(.*?)"/);
            if (srcMatch){
                var src = srcMatch[1];
                if (src.indexOf("/") === 0)
                    src = "http://www.acfun.tv"+src;
                src = src.replace(/&amp;/g, "&");
                var vid = utility.urlQueryItemValue(src, "id");
                if (vid !== ""){
                    var type = utility.urlQueryItemValue(src, "type");
                    if (type === "video") type = "sina";
                    signalCenter.playVideo(acId, type, vid, vid);
                    return;
                }
            }
            utility.openHtml(text);
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
        height: 135 + constant.paddingMedium*2;

        z: 10;

        // Background
        BorderImage {
            anchors.fill: parent;
            source: privateStyle.imagePath("qtg_fr_list_heading_normal");
            border { left: 28; top: 5; right: 28; bottom: 0 }
            smooth: true;
        }

        // Preview
        Image {
            id: preview;
            anchors {
                left: parent.left; top: parent.top;
                margins: constant.paddingMedium;
            }
            width: 180;
            height: 135;
            sourceSize: Qt.size(180, 135);
            smooth: true;
            source: internal.detail.previewurl||"";
        }
        Image {
            anchors.centerIn: preview;
            source: "../../gfx/photos.svg";
            visible: preview.status != Image.Ready;
        }
        Button {
            width: height;
            anchors.centerIn: preview;
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-play");
        }
        Rectangle {
            color: "black";
            anchors.fill: preview;
            opacity: previewMouseArea.pressed ? 0.3 : 0;
        }
        MouseArea {
            id: previewMouseArea;
            anchors.fill: preview;
            enabled: episodeModel.count > 0;
            onClicked: {
                internal.log();
                internal.play(episodeModel.get(0).text);
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
            style: Text.Raised;
            styleColor: constant.colorMid;
            wrapMode: Text.Wrap;
            elide: Text.ElideRight;
            maximumLineCount: 2;
            text: internal.detail.name||"";
        }

        Row {
            visible: !titleBanner.error;
            anchors {
                left: preview.right; leftMargin: constant.paddingLarge;
                bottom: parent.bottom; bottomMargin: constant.paddingMedium;
            }
            spacing: constant.paddingMedium;
            Column {
                spacing: 1;
                Repeater {
                    model: [
                        "../../gfx/image_upman_small.png",
                        "../../gfx/image_watches_small.png",
                        "../../gfx/image_comments_small.png"
                    ]
                    Image {
                        width: internal.textHelper.height;
                        height: width;
                        sourceSize: Qt.size(width, height);
                        source: modelData;
                    }
                }
            }
            Column {
                spacing: 1;
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
            width: constant.graphicSizeLarge;
            height: constant.graphicSizeLarge;
        }
        Button {
            anchors.centerIn: parent;
            width: height;
            iconSource: privateStyle.toolBarIconPath("toolbar-refresh");
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
            height: privateStyle.tabBarHeightLandscape;
            tab: commentView;
        }
        TabButton {
            text: "视频详请";
            height: privateStyle.tabBarHeightLandscape;
            tab: detailView;
        }
        TabButton {
            text: "视频段落";
            height: privateStyle.tabBarHeightLandscape;
            tab: episodeView;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        clip: true;
        Item {
            id: commentView;
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
                        source: model.userAvatar||"../../gfx/avatar.jpg";
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
            clip: true;
            ListView {
                anchors.fill: parent;
                model: ListModel { id: episodeModel; }
                delegate: AbstractItem {
                    Text {
                        anchors.left: parent.paddingItem.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: model.title||"视频片段"+(index+1);
                    }
                    onClicked: {
                        internal.log();
                        internal.play(model.text);
                    }
                }
            }
        }
    }
}
