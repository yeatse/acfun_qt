import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    title: "关于此程序";

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    Rectangle {
        id: bg;
        anchors.fill: parent;
        color: platformStyle.colorBackgroundInverted;
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
                Rectangle {
                    anchors {
                        left: parent.left; right: parent.right;
                        bottom: parent.top;
                    }
                    height: 500;
                    color: platformStyle.colorBackground;
                }
                Image {
                    anchors { left: parent.left; top: parent.top; }
                    source: "../gfx/meegoTLCorner.png";
                }
                Image {
                    anchors { right: parent.right; top: parent.top; }
                    source: "../gfx/meegoTRCorner.png";
                }
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
                    pixelSize: platformStyle.fontSizeLarge+4;
                    family: platformStyle.fontFamilyRegular;
                }
                color: platformStyle.colorNormalLightInverted;
                text: "AcFun播放器";
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter;
                height: constant.graphicSizeSmall;
                verticalAlignment: Text.AlignVCenter;
                font: constant.labelFont;
                color: platformStyle.colorNormalMidInverted;
                text: "塞班版 v"+utility.appVersion;
            }
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    margins: constant.graphicSizeSmall;
                }
                wrapMode: Text.Wrap;
                font: constant.labelFont;
                color: platformStyle.colorNormalLightInverted;
                text: "\
使用跨平台应用程序和UI框架Nokia Qt编写的AcFun非官方客户端。\n\n\
AcFun弹幕视频网(AcFun.tv)是中国最具影响力的网络弹幕视频平台，是中国弹幕行业的领军品牌，\
也是全球最早上线的弹幕视频网站之一。AcFun网于2007年6月6日正式上线。\n\n\
由于塞班系统的限制，使用前请至系统设置→应用程序设置→视频下设置合适的接入点。\n\n\
如果你喜欢这个应用并愿意支持对它的后续开发，欢迎来捐赠作者。我的支付宝账号：yeatse@163.com。\n"
            }
            ListHeading {
                platformInverted: true;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: "一般设定";
                    platformInverted: true;
                }
            }
            CheckBox {
                enabled: utility.qtVersion >= 0x040800;
                platformInverted: true;
                anchors { left: parent.left; leftMargin: constant.paddingLarge; }
                text: "[测试版]视频弹幕";
                checked: !acsettings.usePlatformPlayer;
                onClicked: acsettings.usePlatformPlayer = !checked;
                Component.onCompleted: {
                    if (!enabled) text += "(需要Qt4.8以上)"
                }
            }
            MenuItem {
                platformInverted: true;
                text: "意见反馈";
                onClicked: {
                    if (acsettings.accessToken !== ""){
                        if (Script.checkAuthData()){
                            var prop = { username: "夜切", talkwith: 108853 };
                            pageStack.push(Qt.resolvedUrl("UserPageCom/ConverPage.qml"), prop);
                        }
                    } else {
                        utility.openURLDefault("http://tieba.baidu.com/p/2180383845");
                    }
                }
            }
            MenuItem {
                platformInverted: true;
                text: "作者微博";
                onClicked: utility.openURLDefault("http://m.weibo.cn/u/1786664917");
            }
        }
    }
}
