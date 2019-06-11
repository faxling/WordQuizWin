#include "speechdownloader.h"
#include <QDebug>
#include <QFile>
#include "filehelpers.h"
#include <QSound>

Speechdownloader::Speechdownloader(const QString& sStoragePath) : QObject(nullptr)
{
    connect(&m_oWebCtrl, SIGNAL(finished(QNetworkReply*)),
            SLOT(FileDownloaded(QNetworkReply*)));

    m_sStoragePath = sStoragePath;
}

void Speechdownloader::FileDownloaded(QNetworkReply* pReply)
{
    m_oDownloadedData = pReply->readAll();
    QFile oWav(m_sStoragePath ^ m_sWord + ".wav");
    oWav.open(QIODevice::ReadWrite);
    oWav.write(m_oDownloadedData);
    qDebug() << "wav downloaded";
    emit downloaded();
}

QString sVoicetech("http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=ermil&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text=");


void Speechdownloader::playWord(QString sWord)
{
    QString sFileName = m_sStoragePath ^ sWord + ".wav";
    if (QFile::exists(sFileName) == true)
        QSound::play(sFileName);
    else
        downloadWord(sWord);
}

void Speechdownloader::downloadWord(QString sWord)
{
    m_sWord = sWord;
    QNetworkRequest request(sVoicetech+sWord);
    m_oWebCtrl.get(request);
}
