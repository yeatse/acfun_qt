import QtQuick 1.1
import com.nokia.meego 1.1
import QtWebKit 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active){
            webView.url = Script.getAuthUrl();
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "登录";
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: webView.width;
        contentHeight: webView.height;
        WebView {
            id: webView;
            preferredWidth: view.width;
            preferredHeight: view.height;
            onUrlChanged: {
                var result = Script.authUrlChanged(url);
                if (result){
                    signalCenter.showMessage("登录成功!");
                    pageStack.pop();
                }
            }
            onLoadStarted: page.loading = true;
            onLoadFinished: page.loading = false;
            onLoadFailed: page.loading = false;
        }
    }
}
