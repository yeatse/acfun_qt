import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root;

    property alias paddingItem: paddingItem;

    signal clicked;
    signal pressAndHold;

    implicitWidth: ListView.view ? ListView.view.width : parent.width;
    implicitHeight: constant.graphicSizeLarge;

    Item {
        id: paddingItem;
        anchors {
            left: parent.left; leftMargin: constant.paddingLarge;
            right: parent.right; rightMargin: constant.paddingLarge;
            top: parent.top; topMargin: constant.paddingLarge;
            bottom: parent.bottom; bottomMargin: constant.paddingLarge;
        }
    }

    Loader {
        id: highlightLoader;
        anchors.fill: parent;
        Component {
            id: highlightComp;
            Image {
                visible: mouseArea.pressed;
                source: theme.inverted ? "image://theme/meegotouch-panel-inverted-background-pressed"
                                       : "image://theme/meegotouch-panel-background-pressed";
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: {
            if (root.ListView.view){
                root.ListView.view.currentIndex = index;
            }
            root.clicked();
        }
        onPressAndHold: root.pressAndHold();
        onPressed: if (highlightLoader.status == Loader.Null)
                       highlightLoader.sourceComponent = highlightComp;
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
