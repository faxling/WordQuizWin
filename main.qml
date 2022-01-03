import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0 as Sql
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import "../harbour-wordquiz/Qml/CrossWordFunctions.js" as CWLib

Window {

  id: idWindow
  // init in initUrls
  property string sReqDictUrlBase
  property string sReqDictUrl
  property string sReqDictUrlRev
  property string sReqDictUrlEn
  property string sReqUrlBase

  property string sReqUrl
  property string sReqUrlRev
  property string sReqUrlEn

  property variant oHang
  property variant db
  property string sLangLangSelected
  property string sLangLang
  property string sLangLangRev
  property string sToLang
  property string sFromLang
  property string sQuestionLang: bIsReverse ? sToLang : sFromLang
  property string sAnswerLang: bIsReverse ? sFromLang : sToLang
  property bool bIsReverse
  property bool bHasDictTo: sToLang === "ru" || sToLang === "en"
  property bool bHasDictFrom: sFromLang === "ru" || sFromLang === "en"
  property string sLangLangEn
  property string sQuizName: "-"
  property string sQuizDate: "-"
  property string sQuizDesc: "-"
  property string sScoreText: "-"
  property int nDbNumber: 0
  property int nQuizIndex: 1
  property int nFontSize: idWindow.height > 1200 ? 14 : 11
  property int nDlgHeight: idWindow.height / 5 + 80
  property int nDlgHeightLarge: idWindow.height / 2.5
  property int nBtnHeight: idWindow.height / 15
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n5BtnWidth: idTabMain.width / 6
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2 - 10
  property int nMainWidth: idTabMain.width
  property bool bQSort: true
  property string sQSort: bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property variant quizListView
  property variant oTakeQuiz
  property variant oPopDlg
  property bool bAllok: false
  property bool bDownloadNotVisible: true
  property bool bCWBusy: false

  // property int nGlosaDbLastIndex:  -1
  color: "#E5E7E9"

  property int nGlosaTakeQuizIndex: -1
  property int nLastIndexMain: 0
  FontLoader {
    id: webFont
    source: "qrc:ITCKRIST.TTF"
  }

  // Called from c++ event loop
  function onBackPressedTab() {

    var n = MyDownloader.popIndex()
    if (n < 0)
      return

    switch (n) {
    case 0:
      idTabMain.currentIndex = 0
      idSwipeView.currentIndex = 0
      break
    case 1:
      idTabMain.currentIndex = 1
      idSwipeView.currentIndex = 1
      break
    case 2:
      idTabMain.currentIndex = 2
      idSwipeView.currentIndex = 2
      break
    case 3:
      idTabMain.currentIndex = 2
      idSwipeView.currentIndex = 3
      break
    case 4:
      idTabMain.currentIndex = 2
      idSwipeView.currentIndex = 4
      break
    }
  }

  function onBackPressedDlg() {
    idWindow.oPopDlg.closeThisDlg()
  }

  onSScoreTextChanged: {

    db.transaction(function (tx) {
      tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',
                    [sScoreText, nDbNumber])
      var i = MyDownloader.indexFromGlosNr(glosModelIndex, nDbNumber)
      glosModelIndex.setProperty(i, "state1", sScoreText)
    })
  }

  ListModel {
    id: glosModel
  }

  ListModel {
    id: glosModelWorkingRev
  }

  ListModel {
    id: glosModelWorking
  }

  ListModel {
    id: glosModelIndex
  }

  ListModel {
    id: idLangModel
  }

  ListModel {
    id: idQuizModel

    property string question
    property string extra
    property string answer
    property int number

    onQuestionChanged: {
      MyDownloader.setImgWord(question, sQuestionLang)
    }

    ListElement {
      number: 0
    }
    ListElement {
      number: 1
    }
    ListElement {
      number: 2
    }
  }

  width: 570
  height: 730
  visible: true
  Item {
    id: idMainTitle
    z: 3
    width: parent.width
    height: idBtnHelp.height
    TextList {
      id: idTitle
      font.italic: glosModelIndex.count === 0
      anchors.verticalCenter: idBtnHelp.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: {
        if (glosModelIndex.count === 0)
          return "No Quiz create one or download"

        return sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") + sToLang + " " + sScoreText
      }
    }

    ButtonQuizImg {
      id: idBtnHelp
      anchors.right: parent.right
      anchors.rightMargin: 40
      anchors.top: parent.top
      anchors.topMargin: 5
      source: "qrc:help.png"
      onClicked: Qt.openUrlExternally(
                   "https://faxling.github.io/WordQuizWin/index.html")
    }
  }


  /*
  TextList
  {
    text: sQuizName + " " + sLangLang + " " + sScoreText
    anchors.horizontalCenter: parent.horizontalCenter
  }
  */
  TabBar {
    id: idTabMain
    clip: true
    anchors.fill: parent
    anchors.leftMargin: 50
    anchors.rightMargin: 50
    anchors.bottomMargin: nBtnHeight / 2
    anchors.topMargin: idMainTitle.height + 10
    implicitWidth: 200
    background: Item {}

    ButtonTab {
      id: control1
      text: "Home"
      onPressed: {
        checked = true
        idSwipeView.currentIndex = 0
      }
    }
    ButtonTab {
      id: control2
      text: "Edit"
      onPressed: {
        checked = true
        idSwipeView.currentIndex = 1
      }
    }
    ButtonTab {
      id: control3
      text: idComboBox.currentText
      contentItem: ComboBox {
        id: idComboBox

        delegate: ItemDelegate {
          width: idComboBox.width
          contentItem: Text {
            text: modelData
            // color: "#21be2b"
            font.pointSize: 10
            verticalAlignment: Text.AlignVCenter
          }

          highlighted: idComboBox.highlightedIndex === index
        }
        background: Item {}
        contentItem: Item {
          Text {
            text: control3.text
            font.pointSize: 10
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: control3.checked ? "white" : "black"
          }
          MouseArea {
            anchors.fill: parent
            onPressed:
            {
              control3.checked = true
              idSwipeView.currentIndex = idComboBox.currentIndex + 2
            }
          }
        }

        onPressedChanged: {
          if (pressed) {
            control3.checked = true
            idSwipeView.currentIndex = idComboBox.currentIndex + 2
          }
        }
        onCurrentIndexChanged: idSwipeView.currentIndex = idComboBox.currentIndex + 2
        currentIndex: 0
        model: ["Quiz", "Hang Man", "Cross Word"]
      }

      onPressed: {
        // checked = true
        idSwipeView.currentIndex = idComboBox.currentIndex + 2
      }
    }
  }

  SwipeView {
    id: idSwipeView
    clip: true
    x: idTabMain.x
    y: idTabMain.y + idTabMain.contentHeight
    height: idTabMain.height - idTabMain.contentHeight
    width: idTabMain.width
    interactive: false

    CreateNewQuiz {
      id: idTab1
    }
    EditQuiz {
      id: idTab2
      enabled: glosModelIndex.count > 0 && bDownloadNotVisible
    }
    TakeQuiz {
      id: idTab3
    }
    HangMan {
      id: idTab4
      Component.onCompleted: {
        oHang = idTab4
      }
    }

    CrossWord {
      id: idTab5
    }

    Rectangle {
      id: activityTab3
      color: "black"
    }

    onCurrentIndexChanged: {

      MyDownloader.pushIndex(nLastIndexMain)

      if (currentIndex === 3)
        oHang.newQ()
      else if (currentIndex === 4)
        idTab5.loadCW()
      else if (currentIndex === 1) {

        // Highlight the word currenly displayed on Quiz pane
        glosListView.currentIndex = idWindow.nGlosaTakeQuizIndex
        glosListView.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                         ListView.Center)
      }

      nLastIndexMain = currentIndex
    }
  }
}
