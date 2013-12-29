import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import com.yeatse.acfun 1.0
import "Component"
import "ACPlayer" as AC
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    initialPage: MainPage { id: mainPage; }

    CustomProgressBar { id: proBar; parent: pageStack; z: 10; }

    InfoBanner { id: infoBanner; topMargin: 36; }

    ACSettings { id: acsettings; }

    Constant { id: constant; }

    SignalCenter { id: signalCenter; }

    NetworkHelper { id: networkHelper; }

    AC.VisualStyle { id: visual; inPortrait: app.inPortrait; }

    Component.onCompleted: Script.initialize(signalCenter, acsettings, utility);
}
