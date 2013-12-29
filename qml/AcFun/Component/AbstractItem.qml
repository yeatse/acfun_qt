import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    property bool platformInverted: false;
    property alias paddingItem: paddingItem;

    signal clicked;
    signal pressAndHold;

    implicitWidth: ListView.view ? ListView.view.width : 0;
    implicitHeight: platformStyle.graphicSizeLarge;

    Item {
        id: paddingItem;
        anchors {
            left: parent.left; leftMargin: platformStyle.paddingLarge;
            right: parent.right; rightMargin: platformStyle.paddingLarge;
            top: parent.top; topMargin: platformStyle.paddingLarge;
            bottom: parent.bottom; bottomMargin: platformStyle.paddingLarge;
        }
    }

    Rectangle {
        id: bottomLine;
        anchors {
            left: root.left; right: root.right; bottom: parent.bottom;
        }
        height: 1;
        color: root.platformInverted ? platformStyle.colorDisabledLightInverted
                                     : platformStyle.colorDisabledMid;
    }

    MouseArea {
        anchors.fill: parent;
        enabled: root.enabled;
        onClicked: {
            root.ListView.view.currentIndex = index;
            root.clicked();
        }
        onPressed: {
            privateStyle.play(Symbian.BasicItem);
            root.opacity = 0.7;
        }
        onReleased: {
            privateStyle.play(Symbian.BasicItem);
            root.opacity = 1
        }
        onCanceled: {
            root.opacity = 1;
        }
        onPressAndHold: root.pressAndHold();
    }

    NumberAnimation {
        id: onAddAnimation
        target: root
        property: "opacity"
        duration: 250
        from: 0.25; to: 1;
    }

    ListView.onAdd: {
        onAddAnimation.start();
    }
}
