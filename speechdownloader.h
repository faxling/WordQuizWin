#ifndef SPEECHDOWNLOADER_H
#define SPEECHDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QEventLoop>

class Speechdownloader : public QObject
{
    Q_OBJECT
public:
    explicit Speechdownloader(const QString& sStoragePath);

    Q_INVOKABLE void downloadWord(QString sWord);
    Q_INVOKABLE void playWord(QString sWord);

signals:
    void downloaded();

private slots:
    void FileDownloaded(QNetworkReply* pReply);
private:
    QString m_sWord;
    QString m_sStoragePath;
    QNetworkAccessManager m_oWebCtrl;
    QEventLoop m_oLoop;
    QByteArray m_oDownloadedData;
};

#endif // SPEECHDOWNLOADER_H
