TEMPLATE = app

QT += qml quick multimedia

CONFIG += c++11


SOURCES += main.cpp \
    ../harbour-wordquiz/src/speechdownloader.cpp \
    ../harbour-wordquiz/src/filehelpers.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
# QML_IMPORT_PATH =
# Default rules for deployment.
include(deployment.pri)


RC_FILE = ./glosquiz/Resource.rc

HEADERS += \
    ../harbour-wordquiz/src/speechdownloader.h \
    ../harbour-wordquiz/src/filehelpers.h



DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
