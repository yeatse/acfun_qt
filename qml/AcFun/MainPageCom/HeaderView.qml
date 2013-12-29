import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    property alias model: headerView.model;
    property bool loading: false;
    property bool error: false;

    signal refresh;

    implicitWidth: parent.width;
    implicitHeight: Math.floor(width/64*25);

    clip: true;

    PathView {
        id: headerView;
        anchors.fill: parent;
        model: ListModel {}
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            startX: -headerView.width*headerView.count/2+headerView.width/2;
            startY: headerView.height/2;
            PathLine {
                x: headerView.width*headerView.count/2+headerView.width/2;
                y: headerView.height/2;
            }
        }
        delegate: Item {
            implicitWidth: PathView.view.width;
            implicitHeight: PathView.view.height;
            Image {
                id: previewImg;
                anchors.fill: parent;
                smooth: true;
                source: model.previewurl;
            }
            Image {
                anchors.centerIn: parent;
                source: previewImg.status === Image.Ready
                        ? "" : "../../gfx/photos.svg";
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: signalCenter.viewDetail(model.jumpurl)
            }
        }
        Timer {
            running: headerView.visible && headerView.count > 0 && !headerView.moving;
            interval: 3000;
            repeat: true;
            onTriggered: headerView.incrementCurrentIndex();
        }
    }

    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium; }
        spacing: constant.paddingSmall;
        Repeater {
            model: headerView.count;
            Rectangle {
                width: constant.paddingMedium;
                height: constant.paddingMedium;
                border { width: 1; color: "white"; }
                radius: width /2;
                color: index === headerView.currentIndex ? "red" : "transparent";
            }
        }
    }

    Button {
        id: refreshButton;
        visible: root.error;
        anchors.centerIn: parent;
        width: height;
        iconSource: privateStyle.toolBarIconPath("toolbar-refresh");
        onClicked: root.refresh();
    }
}
