#ifndef QNETWORKREQUESTHELPER_H
#define QNETWORKREQUESTHELPER_H

#include <QObject>
#include <QtDeclarative>
#include <QtNetwork>

class QNetworkRequestHelper : public QObject, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QDeclarativeParserStatus)

public:
    explicit QNetworkRequestHelper(QObject *parent = 0);
    Q_INVOKABLE void createDeleteRequest(QUrl url);
    Q_INVOKABLE void createDeflatedRequest(QUrl url);

signals:
    void requestFailed(QUrl url);
    void requestFinished(QUrl url, QString message);

private slots:
    void slotRequestFinished(QNetworkReply* reply);

private:
    virtual void classBegin();
    virtual void componentComplete();
    QByteArray gUncompress(const QByteArray &data);

    QNetworkAccessManager* nam;
};

#endif // QNETWORKREQUESTHELPER_H
