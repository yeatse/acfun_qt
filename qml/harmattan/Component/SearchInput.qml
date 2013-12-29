import QtQuick 1.1
import com.nokia.meego 1.1

TextField {
    id: root;

    signal typeStopped;
    signal cleared;

    onTextChanged: {
        inputTimer.restart();
    }

    platformStyle: TextFieldStyle {
        paddingLeft: searchIcon.width+constant.paddingMedium;
        paddingRight: clearButton.width;
    }

    Timer {
        id: inputTimer;
        interval: 500;
        onTriggered: root.typeStopped();
    }

    Image {
        id: searchIcon;
        anchors { left: parent.left; leftMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: constant.graphicSizeSmall;
        width: constant.graphicSizeSmall;
        sourceSize: Qt.size(width, height);
        smooth: true;
        source: "image://theme/icon-m-toolbar-search";
    }

    ToolIcon {
        id: clearButton;
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
        opacity: root.activeFocus ? 1 : 0;
        platformIconId: "toolbar-close";
        Behavior on opacity {
            NumberAnimation { duration: 100; }
        }
        onClicked: {
            root.platformCloseSoftwareInputPanel();
            root.text = "";
            root.cleared();
            root.parent.forceActiveFocus();
        }
    }
}
