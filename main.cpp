#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QWebSettings>
#include "qmlapplicationviewer.h"
#include "src/utility.h"
#include "src/customwebview.h"
#include "src/acnetworkaccessmanagerfactory.h"
#include "src/qnetworkrequesthelper.h"
#ifdef Q_WS_SIMULATOR
#include <QtNetwork/QNetworkProxy>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // Symbian specific
#ifdef Q_OS_SYMBIAN
    QApplication::setAttribute(Qt::AA_CaptureMultimediaKeys);
#endif

    QScopedPointer<QApplication> app(createApplication(argc, argv));

    // Splash screen
#if defined(Q_WS_SIMULATOR)||defined(Q_OS_SYMBIAN)
    QPixmap p(":/splash/splash_640.png");
    QSplashScreen* splash = new QSplashScreen(p);
    splash->show();
    splash->raise();
#endif

    app->setApplicationName("AcFun");
    app->setOrganizationName("Yeatse");
    app->setApplicationVersion(VER);

    // Install translator for qt
    QString locale = QLocale::system().name();
    QTranslator qtTranslator;
    if (qtTranslator.load("qt_"+locale, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app->installTranslator(&qtTranslator);
    QTranslator translator;
    if (translator.load(app->applicationName()+"_"+locale, ":/i18n/"))
        app->installTranslator(&translator);
    // For fiddler network debugging
#ifdef Q_WS_SIMULATOR
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    // Custom web view and css settings
    qmlRegisterType<QDeclarativeWebSettings>();
    qmlRegisterType<QDeclarativeWebView>("CustomWebKit", 1, 0, "WebView");
    QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile("qml/js/theme.css"));

    qmlRegisterType<QNetworkRequestHelper>("com.yeatse.acfun", 1, 0, "NetworkHelper");

    QmlApplicationViewer viewer;

    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.setProperty("orientationMethod", 1);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

    ACNetworkAccessManagerFactory factory;
    viewer.engine()->setNetworkAccessManagerFactory(&factory);
    viewer.rootContext()->setContextProperty("utility", Utility::Instance());
#ifdef Q_OS_SYMBIAN
    viewer.setMainQmlFile(QLatin1String("qml/AcFun/main.qml"));
#elif defined(Q_OS_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/AcFun/main.qml"));
#endif
    viewer.showExpanded();

#if defined(Q_WS_SIMULATOR) || defined(Q_OS_SYMBIAN)
    splash->deleteLater();
#endif

    return app->exec();
}
