#include "acnetworkaccessmanagerfactory.h"
#include "utility.h"

ACNetworkAccessManagerFactory::ACNetworkAccessManagerFactory() :
    QDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager* ACNetworkAccessManagerFactory::create(QObject *parent)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QNetworkAccessManager* manager = new ACNetworkAccessManager(parent);

    QNetworkCookieJar* cookieJar = ACNetworkCookieJar::GetInstance();
    manager->setCookieJar(cookieJar);
    cookieJar->setParent(0);

    return manager;
}

ACNetworkAccessManager::ACNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
}

QNetworkReply *ACNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QNetworkRequest req(request);
    req.setRawHeader("User-Agent", "Acfun_Video/1.0 (iPod touch; iOS 6.1.3; Scale/2.00)");
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    return reply;
}

ACNetworkCookieJar::ACNetworkCookieJar(QObject *parent) :
    QNetworkCookieJar(parent)
{
    load();
}

ACNetworkCookieJar::~ACNetworkCookieJar()
{
    save();
}

ACNetworkCookieJar* ACNetworkCookieJar::GetInstance()
{
    static ACNetworkCookieJar cookieJar;
    return &cookieJar;
}

void ACNetworkCookieJar::clearCookies()
{
    QList<QNetworkCookie> emptyList;
    setAllCookies(emptyList);
}

QList<QNetworkCookie> ACNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::cookiesForUrl(url);
}

bool ACNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

void ACNetworkCookieJar::save()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> list = allCookies();
    QByteArray data;
    foreach (QNetworkCookie cookie, list) {
        if (!cookie.isSessionCookie() && cookie.domain() == ".acfun.tv"){
            data.append(cookie.toRawForm());
            data.append("\n");
        }
    }
    Utility::Instance()->setValue("Cookies", data);
}

void ACNetworkCookieJar::load()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QByteArray data = Utility::Instance()->getValue("Cookies").toByteArray();
    setAllCookies(QNetworkCookie::parseCookies(data));
}
