import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    title: "关于此程序";

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        contentWidth: view.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            width: parent.width;
            Item {
                anchors { left: parent.left; right: parent.right; }
                height: constant.graphicSizeSmall;
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter;
                sourceSize.height: constant.graphicSizeMedium;
                source: "../gfx/image_logo.png";
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter;
                height: constant.graphicSizeSmall;
                verticalAlignment: Text.AlignVCenter;
                font {
                    pixelSize: constant.titleFont.pixelSize+4;
                    family: constant.titleFont.family;
                }
                color: constant.colorLight;
                text: "AcFun播放器";
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter;
                height: constant.graphicSizeSmall;
                verticalAlignment: Text.AlignVCenter;
                font: constant.labelFont;
                color: constant.colorMid;
                text: "For N9 v"+utility.appVersion;
            }
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    margins: constant.graphicSizeSmall;
                }
                wrapMode: Text.Wrap;
                font: constant.labelFont;
                color: constant.colorLight;
                text: "\
使用跨平台应用程序和UI框架Nokia Qt编写的AcFun非官方客户端。\n\n\
AcFun弹幕视频网(AcFun.tv)是中国最具影响力的网络弹幕视频平台，是中国弹幕行业的领军品牌，\
也是全球最早上线的弹幕视频网站之一。AcFun网于2007年6月6日正式上线。\n\n\
如果你喜欢这个应用并愿意支持对它的后续开发，欢迎来捐赠作者。我的支付宝账号：yeatse@163.com。\n"
            }
            SectionHeader {
                title: "一般设定"
            }
            CheckBox {
                anchors { left: parent.left; leftMargin: constant.paddingLarge; }
                text: "[测试版]视频弹幕";
                checked: !acsettings.usePlatformPlayer;
                onClicked: acsettings.usePlatformPlayer = !checked;
            }
            AbstractItem {
                Text {
                    anchors.left: parent.paddingItem.left;
                    anchors.verticalCenter: parent.verticalCenter;
                    font: constant.titleFont;
                    color: constant.colorLight;
                    text: "意见反馈";
                }
                onClicked: {
                    if (acsettings.accessToken !== ""){
                        if (Script.checkAuthData()){
                            var prop = { username: "夜切", talkwith: 108853 };
                            pageStack.push(Qt.resolvedUrl("UserPageCom/ConverPage.qml"), prop);
                        }
                    } else {
                        Qt.openUrlExternally("http://tieba.baidu.com/p/2180383845");
                    }
                }
            }
            AbstractItem {
                Text {
                    anchors.left: parent.paddingItem.left;
                    anchors.verticalCenter: parent.verticalCenter;
                    font: constant.titleFont;
                    color: constant.colorLight;
                    text: "作者微博";
                }
                onClicked: {
                    Qt.openUrlExternally("http://m.weibo.cn/u/1786664917");
                }
            }
        }
    }
}
