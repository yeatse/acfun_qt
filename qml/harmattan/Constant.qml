import QtQuick 1.1

QtObject {
    id: constant;

// public
    property color colorLight: "#191919";
    property color colorMid: "#666666";
    property color colorDisabled: "#b2b2b4";

    property int paddingSmall: 4;
    property int paddingMedium: 8;
    property int paddingLarge: 12;

    property int graphicSizeTiny: 24;
    property int graphicSizeSmall: 32;
    property int graphicSizeMedium: 48;
    property int graphicSizeLarge: 72;

    property variant labelFont: __label.font;
    property variant titleFont: __titleText.font;
    property variant subTitleFont: __subTitleText.font;

// private
    property Text __titleText: Text {
        font { pixelSize: 26; family: "Nokia Pure Text"; }
    }
    property Text __subTitleText: Text {
        font { pixelSize: 22; family: "Nokia Pure Text"; weight: Font.Light; }
    }
    property Text __label: Text {
        font { pixelSize: 24; family: "Nokia Pure Text"; }
    }
}
