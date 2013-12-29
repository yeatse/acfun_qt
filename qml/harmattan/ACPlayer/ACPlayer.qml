import QtQuick 1.1

Item {
    id: root;

    // 视频源地址
    property url source;
    onSourceChanged: if (videoPlayer) videoPlayer.source = source;
    // 弹幕池ID
    property string commentId;
    // 播放器层接口
    property alias videoPlayer: videoPlayerLoader.item;

    signal playStarted;
    signal exit;

    function __slotLoadStarted(){
        //开始加载视频，同时加载评论
        commentLayerLoader.sourceComponent = commentLayerComp;
    }
    function __handleExit(){
        if (videoPlayer) videoPlayer.stop();
        root.exit();
    }

    anchors.fill: parent;

    // 播放器层加载器
    Loader {
        id: videoPlayerLoader;
        anchors.fill: parent;
    }

    // 延时加载播放器层，防止页面切换时出现卡顿
    Timer {
        id: playerLoadTimer;
        running: true;
        interval: visual.animationDurationPrettyLong;
        onTriggered: {
            stop();
            videoPlayerLoader.sourceComponent =
                    Qt.createComponent("VideoLayer.qml");
            if (videoPlayerLoader.status === Loader.Ready){
                videoPlayer.loadStarted.connect(__slotLoadStarted);
                videoPlayer.playbackStarted.connect(playStarted);
                videoPlayer.source = root.source;
            }
        }
    }

    // 评论层加载器
    Loader {
        id: commentLayerLoader;
        anchors.fill: parent;
    }
    // 评论层组件
    Component {
        id: commentLayerComp;
        CommentLayer {
            id: commentLayer;
            timePlayed: videoPlayer.timePlayed;
            commentId: root.commentId;
        }
    }

    // 控制器层
    ControlLayer {
        id: controlLayer;
        autoHide: videoPlayer !== null && videoPlayer.isPlaying;
        timePlayed: videoPlayer ? videoPlayer.timePlayed : 0;
        timeDuration: videoPlayer ? videoPlayer.duration : 0;
        isPlaying: videoPlayer ? videoPlayer.isPlaying : false;
        backFreezed: videoPlayer ? videoPlayer.freezing : false;
        onBackPressed: __handleExit();
        onPausePressed: if(videoPlayer)videoPlayer.pause();
        onPlayPressed: if(videoPlayer)videoPlayer.play();
    }
}
