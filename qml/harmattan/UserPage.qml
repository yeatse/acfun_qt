import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    onUidChanged: internal.getDetail();

    title: "个人中心";

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    QtObject {
        id: internal;

        property variant userData: ({});

        function getDetail(){
            loading = true;
            function s(obj){ loading = false; userData = obj; }
            function f(err){ loading = false; console.log(err); }
            Script.getUserDetail(uid, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            SectionHeader {
                title: "我的资料";
            }
            AbstractItem {
                id: profileItem;
                Image {
                    id: avatar;
                    anchors {
                        left: profileItem.paddingItem.left;
                        top: profileItem.paddingItem.top;
                        bottom: profileItem.paddingItem.bottom;
                    }
                    width: height;
                    sourceSize: Qt.size(width, height);
                    source: internal.userData.avatar||"../gfx/avatar.jpg";
                }
                Column {
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingSmall;
                        right: profileItem.paddingItem.right;
                        top: profileItem.paddingItem.top;
                    }
                    Text {
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: internal.userData.name||"";
                    }
                    Text {
                        width: parent.width;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        elide: Text.ElideRight;
                        text: internal.userData.bio||"";
                    }
                }
            }
            SectionHeader {
                title: "我在AC";
            }
            Repeater {
                model: ListModel {
                    ListElement { name: "我的收藏"; file: "UserPageCom/FavPage.qml"; }
                    ListElement { name: "播放历史"; file: "UserPageCom/HistoryPage.qml"; }
                    ListElement { name: "我的稿件"; file: "UserPageCom/UserVideoPage.qml"; }
                    ListElement { name: "我的私信"; file: "UserPageCom/PrivateMsgPage.qml"; }
                }
                AbstractItem {
                    Text {
                        anchors.left: parent.paddingItem.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: model.name;
                    }
                    onClicked: {
                        if (Script.checkAuthData()){
                            var prop = { title: model.name };
                            pageStack.push(Qt.resolvedUrl(model.file), prop);
                        }
                    }
                }
            }
            FooterItem {
                listView: view;
                text: "退出登录";
                onClicked: {
                    acsettings.accessToken = "";
                    utility.clearCookies();
                    pageStack.pop();
                }
            }
        }
    }
}
