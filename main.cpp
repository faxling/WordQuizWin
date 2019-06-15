#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>

#include "speechdownloader.h"



// "sqlite3.exe .open c:/Users/fraxl/AppData/Local/glosquiz/QML/OfflineStorage/Databases/2db1346274c33ae632adc881bdcd2f8e.sqlite"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("MyDownloader", new Speechdownloader(engine.offlineStoragePath()));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    //     qDebug() << engine.offlineStoragePath();
    return app.exec();
}

