#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QAbstractListModel>
#include "..\speechdownloader.h"



// "sqlite3.exe .open c:/Users/fraxl/AppData/Local/glosquiz/QML/OfflineStorage/Databases/2db1346274c33ae632adc881bdcd2f8e.sqlite"


int main(int argc, char *argv[])
{
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
 
  engine.rootContext()->setContextProperty("MyDownloader", new Speechdownloader(engine.offlineStoragePath()));

  engine.load(QUrl::fromLocalFile("c:/Users/fraxl/Documents/qt/glosquiz/main.qml"));

  // QObject* p = engine.rootContext()W->findChild<QObject*>("glosModel");

  // QAbstractListModel* oc = dynamic_cast<QAbstractListModel*>(p);


  //     qDebug() << engine.offlineStoragePath();
  return app.exec();
}
