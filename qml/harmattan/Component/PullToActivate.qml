import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root

    property Flickable myView

    property int visualY

    property bool reloadTriggered

    property int indicatorStart: 25
    property int refreshStart: 120

    property string pullDownMessage: isHeader ? qsTr("Pull Down To Activate") : qsTr("Pull Up To Activate");
    property string releaseRefreshMessage: qsTr("Release To Activate");
    property string disabledMessage: qsTr("Now loading");

    property bool isHeader: true;

    signal refresh;

    width: parent ? parent.width : app.inPortrait ? screen.displayHeight : screen.displayWidth;
    height: 0

    Connections {
        target: myView
        onContentYChanged: {
            if (isHeader){
                if (myView.atYBeginning){
                    var y = root.mapToItem(myView, 0, 0).y
                    if ( y < refreshStart + 20 )
                        visualY = y
                }
            } else {
                if (myView.atYEnd){
                    var y = root.mapToItem(myView, 0, 0).y
                    if ( myView.height - y < refreshStart + 20 )
                        visualY = myView.height - y
                }
            }
        }
    }

    Row {
        anchors {
            bottom: isHeader ? parent.top : undefined; top: isHeader ? undefined : parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: isHeader ? constant.paddingLarge : 0
            topMargin: isHeader ? 0 : constant.paddingLarge
        }
        Image {
            source: theme.inverted
                    ? "../../gfx/pull_down.svg" : "../../gfx/pull_down_inverse.svg"
            opacity: visualY < indicatorStart ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 100 } }
            rotation: {
                var newAngle = visualY
                if (newAngle > refreshStart && !myView.flicking){
                    root.reloadTriggered = true
                    return isHeader ? -180 : 0
                } else {
                    newAngle = newAngle > refreshStart ? 180 : 0
                    return isHeader ? -newAngle : newAngle - 180
                }
            }
            Behavior on rotation { NumberAnimation { duration: 150 } }
            onOpacityChanged: {
                if (opacity == 0 && root.reloadTriggered) {
                    root.reloadTriggered = false
                    if (root.enabled){
                        root.refresh();
                    }
                }
            }
        }
        Label {
            text: root.enabled ? reloadTriggered ? releaseRefreshMessage : pullDownMessage : disabledMessage;
        }
    }
}
