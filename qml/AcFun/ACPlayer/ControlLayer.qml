import QtQuick 1.1
import com.nokia.symbian 1.1
import "util.js" as Util

Item {
    id: root;

    property bool autoHide;
    property bool isPlaying;
    property int timePlayed;
    property int timeDuration;
    property bool backFreezed;

    signal backPressed;
    signal pausePressed;
    signal playPressed;
    signal forwardPressed;
    signal backwardsPressed;

    Component.onCompleted: root.forceActiveFocus();

    Keys.onUpPressed: __volumeUp();
    Keys.onDownPressed: __volumeDown();
    Keys.onVolumeUpPressed: __volumeUp();
    Keys.onVolumeDownPressed: __volumeDown();


    function __volumeUp() {
        var maxVol = 1.0;
        var volThreshold = 0.1;
        if (visual.currentVolume < maxVol - volThreshold) {
            visual.currentVolume += volThreshold;
        } else {
            visual.currentVolume = maxVol;
        }
    }

    function __volumeDown() {
        var minVol = 0.0;
        var volThreshold = 0.1;
        if (visual.currentVolume > minVol + volThreshold) {
            visual.currentVolume -= volThreshold;
        } else {
            visual.currentVolume = minVol;
        }
    }

    anchors.fill: parent;

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: {
            bottomBar.state = bottomBar.state === "" ? "Hidden" : "";
        }
    }

    Timer {
        id: controlHideTimer;
        running: root.autoHide && bottomBar.state === "";
        interval: visual.videoControlsHideTimeout;
        onTriggered: bottomBar.state = "Hidden";
    }

    Item {
        id: bottomBar;
        width: parent.width;
        height: visual.controlAreaHeight;
        y: parent.height - visual.controlAreaHeight;

        states: [
            State {
                name: "Hidden";
                PropertyChanges {
                    target: bottomBar;
                    y: root.height;
                    opacity: 0.0;
                }
            }
        ]
        transitions: [
            Transition {
                from: ""; to: "Hidden"; reversible: true;
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "opacity"
                        easing.type: Easing.InOutExpo
                        duration: visual.animationDurationShort
                    }
                    PropertyAnimation {
                        properties: "y"
                        duration: visual.animationDurationNormal
                    }
                }
            }
        ]

        BorderImage {
            id: background;
            anchors.fill: parent;
            opacity: visual.controlOpacity;
            source: privateStyle.imagePath("qtg_fr_toolbar",false);
            border { left: 20; top: 20; right: 20; bottom: 20; }
        }
        ToolButton {
            id: backbutton;
            enabled: !root.backFreezed;
            flat: true;
            iconSource: "toolbar-back";
            width: visual.controlHeight;
            height: visual.controlHeight;
            anchors {
                left: parent.left;
                leftMargin: visual.controlMargins / 2;
                verticalCenter: parent.verticalCenter;
            }
            onClicked: root.backPressed();
        }
        Rectangle {
            id: separatorLine;
            width: visual.separatorWidth;
            color: visual.separatorColor;
            anchors {
                top: parent.top;
                bottom: parent.bottom;
                left: backbutton.right;
                leftMargin: visual.controlMargins / 2;
            }
        }
        Button {
            id: playButton;
            iconSource: root.isPlaying
                        ?privateStyle.imagePath("toolbar-mediacontrol-pause")
                        :privateStyle.imagePath("toolbar-mediacontrol-play");
            width: visual.controlHeight;
            height: visual.controlHeight;
            anchors {
                verticalCenter: parent.verticalCenter;
                left: separatorLine.right;
                leftMargin: visual.controlMargins*2;
            }
            onClicked: {
                if (root.isPlaying){
                    root.pausePressed();
                } else {
                    root.playPressed();
                }
            }
        }
        Text {
            id: timeElapsedLabel;
            text: Util.milliSecondsToString(timePlayed);
            font: constant.labelFont;
            color: constant.colorLight;
            anchors {
                bottom: playButton.verticalCenter;
                left: playButton.right;
                right: parent.right;
                leftMargin: visual.controlMargins;
                rightMargin: visual.controlMargins;
            }
        }
        Text {
            id: timeDurationLabel;
            text: Util.milliSecondsToString(timeDuration);
            font: constant.labelFont;
            color: constant.colorLight;
            anchors {
                bottom: playButton.verticalCenter;
                right: parent.right;
                rightMargin: visual.controlMargins;
            }
        }
        ProgressBar {
            id: progressBar;
            anchors {
                top: playButton.verticalCenter;
                left: playButton.right;
                right: timeDurationLabel.right;
                leftMargin: visual.controlMargins;
            }
            value: root.timePlayed / root.timeDuration;
        }
    }

    Row {
        id: controlButtons;
        anchors.centerIn: parent;
        opacity: timeDuration>0 && !isPlaying ? 1 : 0;
        Behavior on opacity { NumberAnimation {} }
        spacing: visual.controlMargins*2;
        Button {
            platformAutoRepeat: true;
            anchors.verticalCenter: parent.verticalCenter;
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-backwards");
            height: visual.controlHeight;
            width: visual.controlHeight;
            onClicked: root.backwardsPressed();
        }
        Button {
            anchors.verticalCenter: parent.verticalCenter;
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-play");
            height: visual.controlHeight + 10;
            width: visual.controlHeight + 10;
            onClicked: root.playPressed();
        }
        Button {
            platformAutoRepeat: true;
            anchors.verticalCenter: parent.verticalCenter;
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-forward");
            height: visual.controlHeight;
            width: visual.controlHeight;
            onClicked: root.forwardPressed();
        }
    }
}
