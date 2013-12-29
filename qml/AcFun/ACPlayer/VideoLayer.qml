import QtQuick 1.1
import com.nokia.symbian 1.1;
import QtMobility.systeminfo 1.1
import QtMultimediaKit 1.1

Item {
    id: root;

    property alias source: video.source;
    property alias duration: video.duration;
    property alias timePlayed: video.position;
    property int timeRemaining: duration - timePlayed;
    property alias volume: video.volume;

    property bool isPlaying: false;
    property bool freezing: video.status === Video.Loading;

    signal playbackStarted;
    signal loadStarted;

    function play(){
        video.play();
    }

    function pause(){
        video.pause();
    }

    function stop(){
        video.stop();
    }

    function forward(){
        timePlayed = Math.min(timePlayed + 15000, duration);
    }

    function backwards(){
        timePlayed = Math.max(timePlayed - 15000, 0);
    }

    function __handleStatusChange(status, playing, position, paused){
        var isVisibleState = status === Video.Buffered || status === Video.EndOfMedia;
        var isStalled = status === Video.Stalled;

        // 背景
        if ((isVisibleState||isStalled) && !(paused && position === 0)){
            blackBackground.opacity = 0;
        } else {
            blackBackground.opacity = 1;
        }

        // 加载图标
        if (!isVisibleState && playing){
            busyIndicator.opacity = 1;
        } else {
            busyIndicator.opacity = 0;
        }

        if (status === Video.EndOfMedia){
            video.stop();
            video.position = 0;
        }
    }

    function __setScreenSaver(){
        if (video.playing && !video.paused){
            screenSaver.setScreenSaverDelayed(true);
        } else {
            screenSaver.setScreenSaverDelayed(false);
        }
    }

    ScreenSaver {
        id: screenSaver;
    }

    Rectangle {
        id: videoBackground;
        color: "#000000";
        anchors.fill: parent;
    }

    Video {
        id: video;

        property bool playbackStarted: false;
        property bool loaded: false;

        volume: visual.currentVolume;
        autoLoad: true;
        anchors.fill: parent;
        fillMode: Video.PreserveAspectFit;
        onSourceChanged: play();
        onPlayingChanged: {
            root.isPlaying = playing;
            __setScreenSaver();
            __handleStatusChange(status, isPlaying, position, paused);
        }
        onPausedChanged: {
            root.isPlaying = !paused;
            __setScreenSaver();
            __handleStatusChange(status, isPlaying, position, paused);
        }
        onStatusChanged: {
            if (status === Video.Buffered && !video.playbackStarted){
                video.playbackStarted = true;
                root.playbackStarted();
            }
            if (status === Video.Loading && !video.loaded){
                video.loaded = true;
                root.loadStarted();
            }
            __handleStatusChange(status, isPlaying, position, paused);
        }
    }

    Rectangle {
        id: blackBackground;
        anchors.fill: parent;
        color: "#000000";
    }

    BusyIndicator {
        id: busyIndicator;
        anchors.centerIn: blackBackground;
        height: visual.busyIndicatorHeight;
        width: visual.busyIndicatorWidth;
        running: true;
        opacity: 0;
    }
}
