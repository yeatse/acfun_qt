import QtQuick 1.1

QtObject {
    id: acsettings;

    property string accessToken: utility.getValue("accessToken","");
    onAccessTokenChanged: utility.setValue("accessToken", accessToken);

    property double expiresBy: utility.getValue("expiresBy", 0);
    onExpiresByChanged: utility.setValue("expiresBy", expiresBy);

    property string userId: utility.getValue("userId","");
    onUserIdChanged: utility.setValue("userId", userId);

    property bool usePlatformPlayer: utility.qtVersion < 0x040800 ||
                                     utility.getValue("usePlatformPlayer", true);
    onUsePlatformPlayerChanged: utility.setValue("usePlatformPlayer", usePlatformPlayer);

    property bool showFirstHelp: utility.getValue("showFirstHelp", true);
    onShowFirstHelpChanged: utility.setValue("showFirstHelp", showFirstHelp);
}
