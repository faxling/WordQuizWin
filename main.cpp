#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

 //   QString s = engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

