#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QWindow>
#include <QFile>
#include "..\harbour-wordquiz\src\speechdownloader.h"
#include "filehelpers.h"


// "sqlite3.exe .open c:/Users/fraxl/AppData/Local/glosquiz/QML/OfflineStorage/Databases/2db1346274c33ae632adc881bdcd2f8e.sqlite"

class LayoutSaver : public QObject
{
public:
  LayoutSaver(QWindow *p, const QString& sPath )
  {
    m_p = p;
    m_sPath = sPath ^ "WordQuiz.dat";
  }

  void aboutToQuit()
  {
    QFile oGeometry(m_sPath);
    oGeometry.open(QIODevice::ReadWrite);
    QDataStream  ss(&oGeometry);
    ss << m_p->geometry();
    oGeometry.close();
  }

  void LoadLast()
  {
    QFile oGeometry(m_sPath);
    if (oGeometry.open(QIODevice::ReadOnly) == false)
    {
      return;
    }

    QDataStream  ss(&oGeometry);
    QRect tGeometry;
    ss >> tGeometry;
    m_p->setGeometry(tGeometry);
  }

  QWindow *m_p;
  QString m_sPath;
};


int main(int argc, char *argv[])
{
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("MyDownloader", new Speechdownloader(engine.offlineStoragePath(), nullptr));

  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

  // app.QGuiApplication::topLevelWindows().first();
  LayoutSaver oLS(QGuiApplication::topLevelWindows().first(),engine.offlineStoragePath() );
  QObject::connect(&app,&QGuiApplication::aboutToQuit,&oLS, &LayoutSaver::aboutToQuit);

  qDebug() <<  "start wordquiz";

  oLS.LoadLast();

  return app.exec();
}

