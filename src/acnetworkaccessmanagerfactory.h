#ifndef ACNETWORKACCESSMANAGERFACTORY_H
#define ACNETWORKACCESSMANAGERFACTORY_H

#include <QtDeclarative>
#include <QtNetwork>

class ACNetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory
{
public:
    explicit ACNetworkAccessManagerFactory();
    virtual QNetworkAccessManager* create(QObject *parent);

private:
    QMutex mutex;
};

class ACNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT
public:
    explicit ACNetworkAccessManager(QObject *parent = 0);

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);
};

class ACNetworkCookieJar : public QNetworkCookieJar
{
public:
    static ACNetworkCookieJar* GetInstance();
    void clearCookies();

    virtual QList<QNetworkCookie> cookiesForUrl(const QUrl &url) const;
    virtual bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url);

private:
    explicit ACNetworkCookieJar(QObject *parent = 0);
    ~ACNetworkCookieJar();

    void save();
    void load();
    mutable QMutex mutex;
};

#endif // ACNETWORKACCESSMANAGERFACTORY_H
