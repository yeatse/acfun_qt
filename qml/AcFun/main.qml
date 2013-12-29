import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMobility.systeminfo 1.1
import com.yeatse.acfun 1.0
import "Component"
import "ACPlayer" as AC
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    focus: true;

    platformSoftwareInputPanelEnabled: utility.qtVersion > 0x040800;

    initialPage: MainPage { id: mainPage; }

    StatusPaneText { id: statusPaneText; }

    InfoBanner { id: infoBanner; iconSource: "../gfx/error.svg" }

    ACSettings { id: acsettings; }

    Constant { id: constant; }

    SignalCenter { id: signalCenter; }

    NetworkHelper { id: networkHelper; }

    AC.VisualStyle {
        id: visual;
        inPortrait: app.inPortrait;
        currentVolume: devInfo.voiceRingtoneVolume / 100;
    }

    DeviceInfo {
        id: devInfo;
        monitorCurrentProfileChanges: true;
        onCurrentProfileChanged: {
            visual.currentVolume = devInfo.voiceRingtoneVolume / 100;
        }
    }

    Component.onCompleted: Script.initialize(signalCenter, acsettings, utility);
}
