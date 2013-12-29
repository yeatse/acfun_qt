import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: root;

    property string title: "";
    property bool loading: false;

    orientationLock: PageOrientation.LockPortrait

    Binding {
        target: statusPaneText;
        property: "text";
        value: root.title;
        when: root.visible && root.status == PageStatus.Active;
    }
}
