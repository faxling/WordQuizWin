TEMPLATE = app

QT += qml quick multimedia

CONFIG += c++11

SOURCES += main.cpp \
    speechdownloader.cpp \
    filehelpers.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    speechdownloader.h \
    filehelpers.h



DISTFILES += \
    main.qml \
ButtonQuiz.qml \
ButtonQuizImg.qml \
CreateNewQuiz.qml \
EditQuiz.qml \
InputTextQuiz.qml \
ListViewHi.qml \
main.qml \
TakeQuiz.qml \
TextList.qml \
