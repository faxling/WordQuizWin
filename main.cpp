#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QWindow>
#include <QFile>
#include <QDir>
#include <QKeyEvent>
#include "..\harbour-wordquiz\src\speechdownloader.h"
#include "..\harbour-wordquiz\src\filehelpers.h"
#include "..\harbour-wordquiz\src\svgdrawing.h"
#include "..\harbour-wordquiz\src\crosswordq.h"
#include <QStandardPaths>


#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniObject>
#include <imagepickerandroid.h>
#endif

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
    qDebug() <<  "end wordquiz";
#ifndef Q_OS_ANDROID
    QFile oGeometry(m_sPath);
    oGeometry.open(QIODevice::ReadWrite);
    QDataStream  ss(&oGeometry);
    ss << m_p->geometry();
    oGeometry.close();
#endif
  }

  void LoadLast()
  {

#ifndef Q_OS_ANDROID
    QFile oGeometry(m_sPath);
    if (oGeometry.open(QIODevice::ReadOnly) == false)
    {
      return;
    }

    QDataStream  ss(&oGeometry);
    QRect tGeometry;
    ss >> tGeometry;
    m_p->setGeometry(tGeometry);
#endif
  }

  QWindow *m_p;
  QString m_sPath;

};


class Engine : public QQmlApplicationEngine
{
public:
  Engine()
  {
    qmlRegisterType<SvgDrawing>("SvgDrawing",1,0,"SvgDrawing");

    m_p = new Speechdownloader(offlineStoragePath(), nullptr);
    rootContext()->setContextProperty("MyDownloader",  m_p);
    rootContext()->setContextProperty("CrossWordQ",  new CrossWordQ);
#ifdef Q_OS_ANDROID
    auto pIP = new ImagePickerAndroid(m_p);
    rootContext()->setContextProperty("MyImagePicker",  pIP);
#endif
    connect(m_p, &Speechdownloader::downloadImage,m_p,  &Speechdownloader::downloadImageSlot);
    connect(this, &Engine::objectCreated, [=](QObject *object, const QUrl &){
      object->installEventFilter(this);
    });
  }

  bool eventFilter(QObject*, QEvent *event) override
  {
    if (event->type() == QEvent::KeyPress) {
      QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);
      if (keyEvent->key() == Qt::Key_Back)
      {
        if (rootObjects().first()->property("oPopDlg") != QVariant() )
        {
          QMetaObject::invokeMethod(rootObjects().first(), "onBackPressedDlg");
          return true;
        }
        else if (m_p->isStackEmpty() == false)
        {
          QMetaObject::invokeMethod(rootObjects().first(), "onBackPressedTab");
          return true;
        } else if (m_p->isStackEmpty() == true)
          qDebug() << "StackEmpty " ;
      }
    }
    return false;
  }
  Speechdownloader* m_p;
};


int main(int argc, char *argv[])
{

  QGuiApplication  app(argc, argv);

  Engine engine;

  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

  // app.QGuiApplication::topLevelWindows().first();
  LayoutSaver oLS(QGuiApplication::topLevelWindows().first(),engine.offlineStoragePath() );
  QObject::connect(&app,&QGuiApplication::aboutToQuit,&oLS, &LayoutSaver::aboutToQuit);

  qDebug() <<  "start wordquiz";

  app.setWindowIcon(QIcon("qrc:horn.png"));

  oLS.LoadLast();
#ifdef Q_OS_ANDROID
  QAndroidJniObject const activity = QtAndroid::androidActivity();
  if (activity.isValid()) {
    // Control music volume
    int const STREAM_MUSIC = 3;
    activity.callMethod<void>("setVolumeControlStream", "(I)V", STREAM_MUSIC);
  }
#endif
  return app.exec();
}

