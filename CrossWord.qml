import QtQuick 2.14
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import "../harbour-wordquiz/Qml/CrossWordFunctions.js" as CWLib

Item {
  id: idCrossWordItem
  enum SquareType {
    Char,
    Grey,
    Question,
    QuestionH,
    QuestionV,
    Space,
    Done
  }
  // width in pixel of a char square
  property int nW: 0
  property int nLastCrossDbId: -1

  function loadCW() {
    CWLib.loadCW()
  }

  Component {
    id: idDline

    Item {
      anchors.fill: parent
      property string textH
      property string textV
      Image {
        opacity: 0.35
        anchors.fill: parent
        source: "qrc:dline.svg"
      }

      Text {
        id: idTV
        text: textV
        x: parent.width * 0.10
        y: parent.height * 0.70
        font.pointSize: 3
      }
      Text {
        id: idTH
        text: textH
        x: parent.width * 0.30
        y: parent.height * 0.10
        font.pointSize: 3
      }
    }
  }

  Flickable {
    id: idCrossWord
    clip: true
    anchors.fill: parent
    // gradient:  "NearMoon"
    contentHeight: idCrossWordGrid.height + idWindow.height / 3
    contentWidth: idCrossWordGrid.width + 80

    Component {
      id: idCWCharComponent
      Rectangle {
        id: idCharRect
        Component.onCompleted: {
          if (nW === 0)
            nW = idT.font.pixelSize * 1.3
          idCharRect.height = nW
          idCharRect.width = nW
        }

        property int nIndex
        property int eSquareType: CrossWord.SquareType.Grey
        property alias text: idT.text

        property string textA
        color: {
          switch (eSquareType) {
          case CrossWord.SquareType.Grey:
            return "grey"
          case CrossWord.SquareType.Char:
            return "white"
          case CrossWord.SquareType.Space:
            return "#feffcc"
          case CrossWord.SquareType.QuestionV:
          case CrossWord.SquareType.QuestionH:
          case CrossWord.SquareType.Question:
            return "#e2f087"
          case CrossWord.SquareType.Done:
            return "#71ff96"
          }
        }

        Text {
          id: idT
          visible: eSquareType !== CrossWord.SquareType.Question
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          anchors.fill: parent
          wrapMode: Text.WrapAnywhere
          font.pointSize: CWLib.isQ(eSquareType) ? 4 : 20
        }

        TextMetrics {
          id: fontMetrics
          font.pointSize: 20
        }

        MouseArea {
          anchors.fill: parent
          onPressed: CWLib.popupOnPress(idCharRect, idT, fontMetrics)
        }
      }
    }

    Grid {
      id: idCrossWordGrid
      x: idTabMain.width > width ? (idTabMain.width - width) / 2 : 0
      spacing: 2
    }

    ToolTip {
      id: idInfoBox
      font.pointSize: 20
      visible: false
    }

    Popup {
      id: idInputBox
      property alias t: idTextInput
      width: idTextInput.width + idTextInput.font.pixelSize
      TextInput {
        id: idTextInput
        font.pointSize: 20
        font.capitalization: Font.AllUppercase
        onAccepted: CWLib.handleCharInput(text)
      }
    }
  }

  ButtonQuizImgLarge {
    id: idRefresh
    x: idTabMain.width - width - 20
    y: 20
    source: "qrc:refresh.png"

    onClicked: {
      CWLib.sluggCW()
    }

    WhiteText {
      anchors.bottom: parent.bottom
      text: "New"
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }

    BusyIndicator {
      running: bCWBusy
      id: idBusyIndicator
      anchors.fill: parent
    }
  }

  Text {
    id: idErrMsg
    text: "Select Quiz with more than 6 questions"
    visible: false
    anchors.centerIn: parent
    color: "red"
    font.pixelSize: idCrossWordItem.width / 40
  }

  Text {
    id: idCrossResultMsg
    text: "Nice job!"
    visible: false
    anchors.centerIn: parent
    color: "tomato"
    font.family: webFont.name
    font.pixelSize: idCrossWordItem.width / 5
  }
}
