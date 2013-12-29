import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/videoSourceLoader.js" as VL

Page {
    id: page;

    property string acId;    //ac id;
    property string type;   //source type;
    property string sid;    //source id;
    property string cid;    //comment id;

    orientationLock: PageOrientation.LockLandscape;
    onStatusChanged: {
        if (status === PageStatus.Activating){
            app.showStatusBar = false;
        }
    }

    function load(){
        VL.loadSource(type, sid, messageModel);
    }
    function exit(){
        pageStack.pop(undefined, true);
        app.showStatusBar = true;
    }
    function createPlayer(url){
        playerLoader.sourceComponent = Qt.createComponent("ACPlayer/ACPlayer.qml");
        if (playerLoader.status === Loader.Ready){
            var item = playerLoader.item;
            item.source = url;
            item.commentId = cid;
            item.playStarted.connect(hideMessage);
            item.exit.connect(exit);
        } else {
            console.log("Error: player is not ready");
        }
    }
    function hideMessage(){
        exitBtn.visible = false;
        messageModel.clear();
    }

    Loader {
        id: playerLoader;
        anchors.fill: parent;
    }

    // return button
    Button {
        id: exitBtn;
        enabled: playerLoader.item === null ||
                 playerLoader.item.videoPlayer === null ||
                 !playerLoader.item.videoPlayer.freezing;
        anchors {
            right: parent.right; top: parent.top;
            margins: constant.paddingSmall;
        }
        width: height;
        iconSource: "../gfx/tb_close_stop.svg";
        onClicked: exit();
    }

    // messages
    Column {
        id: contentCol;
        anchors {
            left: parent.left; bottom: parent.bottom;
            margins: constant.paddingSmall;
        }
        spacing: constant.paddingSmall;
        Repeater {
            model: ListModel { id: messageModel; }
            Text {
                font: constant.labelFont;
                color: constant.colorLight;
                text: modelData;
            }
        }
    }
}
