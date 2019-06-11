#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>

#include "speechdownloader.h"




int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("MyDownloader", new Speechdownloader(engine.offlineStoragePath()));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    //     qDebug() << engine.offlineStoragePath();
    return app.exec();
}

