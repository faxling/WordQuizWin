TEMPLATE = app

QT += qml quick multimedia

CONFIG += c++11

SOURCES += main.cpp \
    ../harbour-wordquiz/src/speechdownloader.cpp \
    ../harbour-wordquiz/src/filehelpers.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
# Default rules for deployment.
include(deployment.pri)


HEADERS += \
    ../harbour-wordquiz/src/speechdownloader.h \
    ../harbour-wordquiz/src/filehelpers.h



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
RectRounded.qml \
../harbour-wordquiz/qml/QuizFunctions.js
