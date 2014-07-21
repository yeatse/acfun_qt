#include "qnetworkrequesthelper.h"
#include "utility.h"
#include "zlib.h"

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
    QByteArray auth = Utility::Instance()->getValue("accessToken").toByteArray();
    auth.prepend("Bearer ");
    req.setRawHeader("Authorization", auth);
    req.setHeader(QNetworkRequest::ContentLengthHeader, 0);

    nam->deleteResource(req);
}

void QNetworkRequestHelper::createDeflatedRequest(QUrl url)
{
    qDebug() << "deflate request============\n" << url;
    QNetworkRequest req(url);
    req.setRawHeader("Accept-Encoding", "gzip, deflate");
    nam->get(req);
}

void QNetworkRequestHelper::slotRequestFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError){
        emit requestFailed(reply->url());
    } else {
        QByteArray data = reply->readAll();
        if (reply->rawHeader("Content-Encoding") == "gzip"){
            data = this->gUncompress(data);
        }
        emit requestFinished(reply->url(), QString(data));
    }
}

QByteArray QNetworkRequestHelper::gUncompress(const QByteArray &data)
{
    if (data.size() <= 4){
        qWarning("gUncompress: Input data is truncated");
        return data;
    }
    QByteArray result;

    int ret;
    z_stream strm;
    static const int CHUNK_SIZE = 1024;
    char out[CHUNK_SIZE];

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = data.size();
    strm.next_in = (Bytef*)(data.data());

    ret = inflateInit2(&strm, 15+32);
    if (ret != Z_OK)
        return data;

    do {
        strm.avail_out = CHUNK_SIZE;
        strm.next_out = (Bytef*)(out);

        ret = inflate(&strm, Z_NO_FLUSH);
        Q_ASSERT(ret != Z_STREAM_ERROR);

        switch (ret){
        case Z_NEED_DICT:
            ret = Z_DATA_ERROR;
        case Z_DATA_ERROR:
        case Z_MEM_ERROR:
            (void)inflateEnd(&strm);
            return data;
        }
        result.append(out, CHUNK_SIZE - strm.avail_out);
    } while (strm.avail_out == 0);

    inflateEnd(&strm);
    return result;
}
