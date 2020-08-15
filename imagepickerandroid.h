#ifndef IMAGEPICKERANDROID_H
#define IMAGEPICKERANDROID_H

#include <QObject>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
class Speechdownloader;
class ImagePickerAndroid :  public QObject ,  QAndroidActivityResultReceiver
{
  Q_OBJECT
public:
  ImagePickerAndroid( Speechdownloader* pS);
  Q_INVOKABLE void pickImage(QString sWord, QString sLang, QString sWord2, QString sLang2);
  void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);

private:
  QString m_sWord;
  QString m_sLang;
  QString m_sWord2;
  QString m_sLang2;
  Speechdownloader* m_pS;
};
#endif
#endif // IMAGEPICKERANDROID_H
