#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    //   QString s = engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    //     qDebug() << engine.offlineStoragePath();
    return app.exec();
}

