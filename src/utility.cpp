#include "utility.h"
#include "acnetworkaccessmanagerfactory.h"

#ifdef Q_OS_SYMBIAN
#include <apgcli.h>
#include <apgtask.h>
#include <w32std.h>
#endif

#ifdef Q_OS_HARMATTAN
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>
#endif

Utility::Utility(QObject *parent) :
    QObject(parent),
    settings(0)
{
    settings = new QSettings(this);
}

Utility::~Utility()
{
}

Utility* Utility::Instance()
{
    static Utility u;
    return &u;
}

QString Utility::appVersion() const
{
    return qApp->applicationVersion();
}

int Utility::qtVersion() const
{
    QString qtver(qVersion());
    QStringList vlist = qtver.split(".");
    if (vlist.length() >= 3){
        int major = vlist.at(0).toInt();
        int minor = vlist.at(1).toInt();
        int patch = vlist.at(2).toInt();
        return (major << 16) + (minor << 8) + patch;
    } else {
        return 0;
    }
}

QVariant Utility::getValue(const QString &key, const QVariant defaultValue)
{
    if (map.contains(key)){
        return map.value(key);
    } else {
        return settings->value(key, defaultValue);
    }
}

void Utility::setValue(const QString &key, const QVariant &value)
{
    if (map.value(key) != value){
        map.insert(key, value);
        settings->setValue(key, value);
    }
}

void Utility::clearCookies()
{
    ACNetworkCookieJar::GetInstance()->clearCookies();
}

QString Utility::urlQueryItemValue(const QString &url, const QString &key) const
{
    QUrl myUrl(url);
    return myUrl.queryItemValue(key);
}

void Utility::launchPlayer(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    //    const int KMpxVideoPlayerID = 0x200159B2;
    //    Launch(KMpxVideoPlayerID, url);
    QString path = QDir::tempPath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    QString ramPath = path+"/video.ram";
    QFile file(ramPath);
    if (file.exists()) file.remove();
    if (file.open(QIODevice::ReadWrite)){
        QTextStream out(&file);
        out << url;
        file.close();
        QDesktopServices::openUrl(QUrl("file:///"+ramPath));
    }
#elif defined(Q_OS_HARMATTAN)
    VideoSuiteInterface suite;
    QStringList list = url.split("\n");
    suite.play(list);
#else
    QDesktopServices::openUrl(url);
#endif
}

void Utility::openHtml(const QString &html)
{
    QString path = QDir::tempPath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    QString htmlPath = path + "/temp.html";
    QFile file(htmlPath);
    if (file.exists()) file.remove();
    if (file.open(QIODevice::ReadWrite)){
        QTextStream out(&file);
        out << html;
        file.close();
        QDesktopServices::openUrl(QUrl("file:///"+htmlPath));
    }
}

void Utility::share(const QString &title, const QString &link)
{
#ifdef Q_OS_HARMATTAN
    MDataUri duri;
    duri.setMimeType("text/x-url");
    duri.setTextData(link);
    duri.setAttribute("title", title);
    if (!duri.isValid()){
        qDebug() << "Share: Invalid URI";
        return;
    }
    QStringList items;
    items << duri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (!shareIf.isValid()){
        qDebug() << "Share: Invalid interface";
        return;
    }
    shareIf.share(items);
#else
#endif
}

QString Utility::easyDate(const QDateTime &date)
{
    if (formats.length() == 0) initializeLangFormats();

    QDateTime now = QDateTime::currentDateTime();
    int secsDiff = date.secsTo(now);

    QString token;
    if (secsDiff < 0){
        secsDiff = abs(secsDiff);
        token = lang["from"];
    } else {
        token = lang["ago"];
    }

    QString result;
    foreach (QVariantList format, formats) {
        if (secsDiff < format.at(0).toInt()){
            if (format == formats.at(0)){
                result = format.at(1).toString();
            } else {
                int val = ceil(double(normalize(secsDiff, format.at(3).toInt()))/format.at(3).toInt());
                result = tr("%1 %2 %3", "e.g. %1 is number value such as 2, %2 is mins, %3 is ago")
                        .arg(QString::number(val)).arg(val != 1 ? format.at(2).toString() : format.at(1).toString()).arg(token);
            }
            break;
        }
    }
    return result;
}

void Utility::initializeLangFormats()
{
    lang["ago"] = tr("ago");
    lang["from"] = tr("From Now");
    lang["now"] = tr("just now");
    lang["minute"] = tr("min");
    lang["minutes"] = tr("mins");
    lang["hour"] = tr("hr");
    lang["hours"] = tr("hrs");
    lang["day"] = tr("day");
    lang["days"] = tr("days");
    lang["week"] = tr("wk");
    lang["weeks"] = tr("wks");
    lang["month"] = tr("mth");
    lang["months"] = tr("mths");
    lang["year"] = tr("yr");
    lang["years"] = tr("yrs");

    QVariantList l1;
    l1 << 60 << lang["now"];
    QVariantList l2;
    l2 << 3600 << lang["minute"] << lang["minutes"] << 60;
    QVariantList l3;
    l3 << 86400 << lang["hour"] << lang["hours"] << 3600;
    QVariantList l4;
    l4 << 604800 << lang["day"] << lang["days"] << 86400;
    QVariantList l5;
    l5 << 2628000 << lang["week"] << lang["weeks"] << 604800;
    QVariantList l6;
    l6 << 31536000 << lang["month"] << lang["months"] << 2628000;
    QVariantList l7;
    l7 << INT_MAX << lang["year"] << lang["years"] << 31536000;

    formats << l1 << l2 << l3 << l4 << l5 << l6 << l7;
}

int Utility::normalize(int val, int single)
{
    int margin = 0.1;
    if (val >= single && val <= single*(1+margin))
        return single;
    return val;
}

#ifdef Q_OS_SYMBIAN
void Utility::LaunchAppL(const TUid aUid, HBufC* aParam)
{
    RWsSession ws;
    User::LeaveIfError(ws.Connect());
    CleanupClosePushL(ws);
    TApaTaskList taskList(ws);
    TApaTask task = taskList.FindApp(aUid);

    if(task.Exists())
    {
        task.BringToForeground();
        HBufC8* param8 = HBufC8::NewLC(aParam->Length());
        param8->Des().Append(*aParam);
        task.SendMessage(TUid::Null(), *param8); // UID not used, SwEvent capability need to be declared
        CleanupStack::PopAndDestroy(param8);
    }
    else
    {
        RApaLsSession apaLsSession;
        User::LeaveIfError(apaLsSession.Connect());
        CleanupClosePushL(apaLsSession);
        TThreadId thread;
        User::LeaveIfError(apaLsSession.StartDocument(*aParam, aUid, thread));
        CleanupStack::PopAndDestroy(1, &apaLsSession);
    }
    CleanupStack::PopAndDestroy(&ws);
}
void Utility::LaunchL(int id, const QString& param)
{
    //Coversion to Symbian C++ types
    TUid uid = TUid::Uid(id);
    TPtrC ptr(static_cast<const TUint16*>(param.utf16()), param.length());
    HBufC* desc_param = HBufC::NewLC( param.length());
    desc_param->Des().Copy(ptr);

    LaunchAppL(uid, desc_param);

    CleanupStack::PopAndDestroy(desc_param);
}
bool Utility::Launch(const int id, const QString& param)
{
    // TRAPD to prevent possible leave (kind of exception in Symbian C++)
    TRAPD(err, LaunchL(id, param));
    return err == KErrNone;
}
#endif
