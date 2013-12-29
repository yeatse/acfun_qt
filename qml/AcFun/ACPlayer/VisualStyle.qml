import QtQuick 1.1

QtObject {
    id: visual;

    property bool inPortrait: false;

    property double currentVolume: 0;

    // Comment
    property int maxCommentCount: 20;

    property int controlMargins: 10;
    property int controlAreaHeight: 65;
    property int controlHeight: 50;
    property double controlOpacity: 0.8;
    property int separatorWidth: 1
    property color separatorColor: "#303030"
    property int videoControlsHideTimeout: 5000;

    // Busy indicator
    property int busyIndicatorHeight: inPortrait ? screen.displayWidth / 5
                                                 : screen.displayHeight / 5
    property int busyIndicatorWidth: busyIndicatorHeight

    // Transition animation durations (in milliseconds)
    property int animationDurationShort: 150
    property int animationDurationNormal: 350
    property int animationDurationPrettyLong: 500
    property int animationDurationLong: 600
}
