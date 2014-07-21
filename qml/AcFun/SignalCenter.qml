import QtQuick 1.1

QtObject {
    id: signalCenter;

    signal userChanged;
    signal initialized;

    property variant videocategories: [];
    property variant queryDialogComp: null;

    function showMessage(msg){
        if (msg||false){
            infoBanner.text = msg;
            infoBanner.open();
        }
    }

    function viewDetail(vid, cid){
        var id;
        if (typeof(vid) === "number"){
            id = vid;
        } else if (typeof(vid) === "string"){
            var tmp = vid.match(/(videoinfo\?id=ac|\b)(\d+)\b/);
            if (tmp) id = tmp[2];
            else return;
        }
        var prop = {"acId": id};
        if (cid==63||cid==73||cid==110||cid==75||cid==74||cid==76){
            // article
            pageStack.push(Qt.resolvedUrl("VideoDetailCom/ArticlePage.qml"), prop);
        } else if (cid==71){
            // flash
            pageStack.push(Qt.resolvedUrl("VideoDetailCom/OldDetailPage.qml"), prop);
        } else {
            pageStack.push(Qt.resolvedUrl("VideoDetailPage.qml"), prop);
        }
    }

    function playVideo(acId, type, sid, cid){
        console.log("play video==============\n", acId, type, sid, cid);
        var prop = { acId: acId, type: type, sid: sid, cid: cid };
        var p = pageStack.push(Qt.resolvedUrl("VideoPage.qml"), prop, true);
        p.load();
    }

    function login(){
        pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
    }

    function createQueryDialog(title, message, acceptText, rejectText, acceptCallback, rejectCallback){
        if (!queryDialogComp){ queryDialogComp = Qt.createComponent("Component/DynamicQueryDialog.qml"); }
        var prop = { titleText: title, message: message.concat("\n"), acceptButtonText: acceptText, rejectButtonText: rejectText };
        var diag = queryDialogComp.createObject(pageStack.currentPage, prop);
        if (acceptCallback) diag.accepted.connect(acceptCallback);
        if (rejectCallback) diag.rejected.connect(rejectCallback);
    }
}
