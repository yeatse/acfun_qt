#include "qnetworkrequesthelper.h"
#include "utility.h"

QNetworkRequestHelper::QNetworkRequestHelper(QObject *parent) :
    QObject(parent),
    nam(0)
{
}

void QNetworkRequestHelper::classBegin()
{
    QDeclarativeEngine* engine = qmlEngine(this);
    if (QDeclarativeNetworkAccessManagerFactory* factory = engine->networkAccessManagerFactory()){
        nam = factory->create(this);
    } else {
        nam = engine->networkAccessManager();
    }
    connect(nam, SIGNAL(finished(QNetworkReply*)), this, SLOT(slotRequestFinished(QNetworkReply*)));
}

void QNetworkRequestHelper::componentComplete()
{
}

void QNetworkRequestHelper::createDeleteRequest(QUrl url)
{
    qDebug() << "delete request===========\n" << url;
    QNetworkRequest req(url);
    req.setRawHeader("X-API-VERSION", "3.0");
    req.setRawHeader("X-APP-VERSION", "2.5.0");
    QByteArray auth = Utility::Instance()->getValue("accessToken").toByteArray();
    auth.prepend("Bearer ");
    req.setRawHeader("Authorization", auth);
    req.setHeader(QNetworkRequest::ContentLengthHeader, 0);

    nam->deleteResource(req);
}

void QNetworkRequestHelper::slotRequestFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError){
        emit requestFailed(reply->url());
    } else {
        emit requestFinished(reply->url(), QString(reply->readAll()));
    }
}
