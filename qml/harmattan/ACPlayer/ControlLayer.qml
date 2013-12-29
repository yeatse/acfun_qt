import QtQuick 1.1
import com.nokia.meego 1.1
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

    Component.onCompleted: root.forceActiveFocus();

    Keys.onUpPressed: __volumeUp();
    Keys.onDownPressed: __volumeDown();

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

    Connections {
        target: Qt.application;
        onActiveChanged: {
            if (!Qt.application.active){
                root.pausePressed();
            }
        }
    }

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
            property Style tbStyle: ToolBarStyle {
                inverted: true;
            }
            anchors.fill: parent;
            opacity: visual.controlOpacity;
            source: tbStyle.background;
            border { left: 10; top: 10; right: 10; bottom: 10; }
        }
        Button {
            id: backbutton;
            platformStyle: ButtonStyle {
                buttonWidth: visual.controlHeight;
                buttonHeight: visual.controlHeight;
                inverted: true;
            }
            enabled: !root.backFreezed;
            iconSource: "image://theme/icon-m-toolbar-back-white"
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
            platformStyle: ButtonStyle {
                buttonWidth: visual.controlHeight;
                buttonHeight: visual.controlHeight;
                inverted: true;
            }
            iconSource: root.isPlaying
                        ? "image://theme/icon-m-toolbar-mediacontrol-pause-white"
                        : "image://theme/icon-m-toolbar-mediacontrol-play-white";
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
            color: "white";
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
            color: "white";
            anchors {
                bottom: playButton.verticalCenter;
                right: parent.right;
                rightMargin: visual.controlMargins;
            }
        }
        ProgressBar {
            id: progressBar;
            platformStyle: ProgressBarStyle {
                inverted: true;
            }
            anchors {
                top: playButton.verticalCenter;
                left: playButton.right;
                right: timeDurationLabel.right;
                leftMargin: visual.controlMargins;
            }
            value: root.timePlayed / root.timeDuration;
        }
    }
}
