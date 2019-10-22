#include "speechdownloader.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include "filehelpers.h"
#include <QSound>
#include <QAbstractListModel>
#include <QDataStream>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>


static const QString GLOS_SERVER1("http://212.112.183.157");
static const QString GLOS_SERVER2("http://127.0.0.1");
Speechdownloader::Speechdownloader(const QString& sStoragePath) : QObject(nullptr)
{
  QObject::connect(&m_oQuizExpNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizExported);
  QObject::connect(&m_oWordNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::wordDownloaded);
  QObject::connect(&m_oQuizNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizDownloaded);
  QObject::connect(&m_oListQuizNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::listDownloaded);
  QObject::connect(&m_oDeleteQuizNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizDeleted);
  m_sStoragePath = sStoragePath;
}


QString Speechdownloader::AudioPath(const QString& s)
{
  return m_sStoragePath ^ s + ".wav";
}



void Speechdownloader::wordDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();

  if (m_oDownloadedData.size() < 1000)
    return;
  QString sFileName = AudioPath(m_sWord);
  QFile oWav(sFileName);
  oWav.open(QIODevice::ReadWrite);
  oWav.write(m_oDownloadedData);
  oWav.close();
  emit downloadedSignal();

  if (m_bPlayAfterDownload == true)
  {
    QSound::play(sFileName);
  }
}


void Speechdownloader::quizDeleted(QNetworkReply* pReply)
{
  int nRet = pReply->error();
  QString oc = QString(pReply->readAll());
  if (nRet == QNetworkReply::NoError)
    emit deletedSignal(oc.toInt());
  else
    emit deletedSignal(-1);
}

void Speechdownloader::quizExported(QNetworkReply* pReply)
{
  int nRet = pReply->error();

  if (nRet == QNetworkReply::NoError)
    emit exportedSignal(pReply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt());
  else
    emit exportedSignal(0);

}

void Speechdownloader::listDownloaded(QNetworkReply* pReply)
{
  QByteArray oc = pReply->readAll();
  QJsonDocument oJ = QJsonDocument::fromJson(oc);

  QJsonArray ocJson = oJ.array();
  QStringList ocL;
  m_ocIndexMap.clear();
  for ( auto oI : ocJson)
  {
    auto oJJ = oI.toObject();
    ocL.append(oJJ["qname"].toString());
    ocL.append(oJJ["desc1"].toString());
    ocL.append(oJJ["slang"].toString());
    ocL.append(oJJ["qcount"].toString());
    m_ocIndexMap.append(oJJ["id"].toInt());
  }

  emit quizListDownloadedSignal(ocL.size(), ocL);

}


QString sVoicetechRu(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=oksana&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));
QString sVoicetechEn(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=en_EN&format=wav&speaker=jane&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));

QString sVoicetechFr(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&r=2&hl=fr-fr&src="));
QString sVoicetechSe(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=sv-se&src="));
QString sVoicetechIt(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=it-it&src="));
QString sVoicetechDe(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=de-de&src="));
QString sVoicetechPl(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=pl-pl&src="));
QString sVoicetechEs(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=es-es&src="));




void Speechdownloader::playWord(QString sWord, QString sLang)
{
  QString sFileName = AudioPath(sWord);

  QFileInfo oWavFile(sFileName);
  if (oWavFile.size() > 10000)
  {
    QSound::play(sFileName);
  }
  else
  {
    downloadWord(sWord,sLang);
    m_bPlayAfterDownload = true;
  }
}

void Speechdownloader::downloadWord(QString sWord, QString sLang)
{
  m_sWord = sWord;
  static QMap<QString, QString> ocUrlMap{ { "ru", sVoicetechRu }, { "en", sVoicetechEn }, { "sv", sVoicetechSe }, { "fr", sVoicetechFr }, { "pl", sVoicetechPl }, { "de", sVoicetechDe }, { "es", sVoicetechEs } };
  // QString sUrl = ocUrlMapd[sLang] ;
  QNetworkRequest request(ocUrlMap[sLang] + sWord);
  m_oWordNetMgr.get(request);
}

void  Speechdownloader::listQuiz()
{
  QNetworkRequest request(QUrl(GLOS_SERVER2 ^ "quizlist.php"));
  m_oListQuizNetMgr.get(request);
}

void Speechdownloader::quizDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();

  if (m_oDownloadedData.size() < 1000)
    return;
  QDataStream  ss(&m_oDownloadedData, QIODevice::ReadOnly);
  int nC;
  ss >> nC;
  QString sLang;
  ss >> sLang;
  QVariantList oDataDownloaded;

  for (int i = 0; i < nC; i++)
  {
    for (int j = 0; j < 2; ++j)
    {
      QVariant v;
      ss >> v;
      oDataDownloaded.append(v);
    }
  }
  ss >> nC;

  for (int i = 0; i < nC; i++)
  {
    QString s;
    ss >> s;
    QByteArray oc;
    ss >> oc;
    QFile oWav(AudioPath(s));
    oWav.open(QIODevice::ReadWrite);
    oWav.write(oc);
    oWav.close();
  }

  emit quizDownloadedSignal(oDataDownloaded.size(), oDataDownloaded, sLang);

}

void Speechdownloader::deleteQuiz(QString sName, QString sPwd, QString nDbId)
{
  QString sUrl = GLOS_SERVER2 ^ "deletequiz.php?qname="+sName+"&qpwd="+sPwd+"&dbid="+ nDbId;
  QNetworkRequest request(sUrl);
  m_oDeleteQuizNetMgr.get(request);
}

void Speechdownloader::importQuiz(QString sName)
{
  // pp = qvariant_cast<QAbstractListModel*>(p);
  QString sUrl = GLOS_SERVER2 ^ sName + ".txt";
  //QNetworkRequest request(sUrl + "lang=" + sLang + "&desc=" + "&name=nytt");
  QNetworkRequest request(sUrl);
  m_oQuizNetMgr.get(request);
}


/*
answer
extra
number
question
state1
*/


void Speechdownloader::exportCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd,QString sDesc )
{
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  QByteArray ocArray;
  QDataStream  ss(&ocArray, QIODevice::WriteOnly);
  QStringList ocAudio;
  int nC = pp->rowCount();
  ss << nC;
  ss << sLang;
  for (int i = 0; i < nC; i++)
  {
    for (int j = 0; j <= 3; ++j)
    {
      if (j == 1 || j == 2) // SKIP  state1 and number
        continue;
      ss << pp->data(pp->index(i), j);
    }
    QString sFileName = pp->data(pp->index(i), 0).toString();
    if (QFile::exists(AudioPath(sFileName)))
      ocAudio.append(sFileName);
    sFileName = pp->data(pp->index(i), 2).toString();
    if (QFile::exists(AudioPath(sFileName)))
      ocAudio.append(sFileName);
  }

  ss << ocAudio.size();
  for (auto& oI : ocAudio)
  {
    QFile oF(AudioPath(oI));
    ss << oI;
    oF.open(QIODevice::ReadOnly);
    ss << oF.readAll();
    oF.close();
  }
  QString sFmt = GLOS_SERVER2 ^ "store.php?qname=%ls&slang=%ls&qcount=%d&desc1=%ls&pwd=%ls";
  QString sUrl = QString::asprintf(sFmt.toLatin1(), sName.utf16(), sLang.utf16(), nC,sDesc.utf16(), sPwd.utf16() );

  QNetworkRequest request(sUrl);
  request.setRawHeader("Content-Type", "application/octet-stream");
  request.setRawHeader("Content-Length", QByteArray::number(ocArray.size()));
  m_oQuizExpNetMgr.post(request, ocArray);

}
