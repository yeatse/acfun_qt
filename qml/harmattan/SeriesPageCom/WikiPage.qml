import QtQuick 1.1
import com.nokia.meego 1.1
import CustomWebKit 1.0
import "../Component"

MyPage {
    id: page;

    title: webView.title;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            enabled: webView.reload.enabled;
            onClicked: webView.reload.trigger();
        }
    }

    function load(){
        webView.url = "http://wiki.acfun.tv/index.php/里区索引";
    }

    function handle(link){
        var linkString = link.toString();
        if (/http.*?\.swf\?.*?vid=/.test(linkString)){
            //播放器地址
            var vid = utility.urlQueryItemValue(linkString, "vid");
            if (vid !== ""){
                var cid = utility.urlQueryItemValue(linkString, "cid");
                if (cid === "") cid = vid;
                signalCenter.playVideo("", "sina", vid, cid);
                return;
            }
        }
        if (linkString.indexOf("http://wiki.acfun.tv")===0){
            webView.url = linkString;
            return;
        }
        var acMatch = linkString.match(/http:\/\/.*?acfun\.tv\/v\/ac(\d+)/);
        if (acMatch){
            var acId = acMatch[1];
            signalCenter.viewDetail(acId);
            return;
        }
        Qt.openUrlExternally(linkString);
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        clip: true;
        contentWidth: webView.width;
        contentHeight: webView.height;
        boundsBehavior: Flickable.StopAtBounds;
        WebView {
            id: webView;
            preferredWidth: view.width;
            preferredHeight: view.height;
            settings { autoLoadImages: false; }
            onLoadStarted: {
                page.loading = true;
                view.contentX = 0;
                view.contentY = 0;
                view.returnToBounds();
            }
            onLoadFinished: page.loading = false;
            onLoadFailed: page.loading = false;
            onLinkClicked: handle(link);
        }
    }

    ScrollDecorator { flickableItem: view; }
}
