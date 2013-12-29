import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    signal clicked;

    property Flickable listView: root.ListView.view;
    property string text: "继续加载";

    implicitWidth: listView.width;
    implicitHeight: visible ? constant.graphicSizeLarge : 0;

    Button {
        anchors {
            left: parent.left; right: parent.right;
            margins: constant.paddingLarge*2;
            verticalCenter: parent.verticalCenter;
        }
        text: root.text;
        onClicked: root.clicked();
    }
}
