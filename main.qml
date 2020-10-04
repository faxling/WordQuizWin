import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.LocalStorage 2.0 as Sql
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Window {

  id:idWindow
  // init in initUrls
  property string sReqDictUrlBase
  property string sReqDictUrl
  property string sReqDictUrlRev
  property string sReqDictUrlEn
  property string sReqUrlBase

  property string sReqUrl
  property string sReqUrlRev
  property string sReqUrlEn

  property variant db
  property string sLangLangSelected
  property string sLangLang
  property string sLangLangRev
  property string sToLang
  property string sFromLang
  property string sQuestionLang : bIsReverse ? sToLang : sFromLang
  property string sAnswerLang : bIsReverse ? sFromLang : sToLang
  property bool bIsReverse
  property bool bHasDictTo : sToLang ==="ru" || sToLang ==="en"
  property bool bHasDictFrom : sFromLang ==="ru" || sFromLang ==="en"
  property string sLangLangEn
  property string sQuizName : "-"
  property string sQuizDate : "-"
  property string sQuizDesc : "-"
  property string sScoreText : "-"
  property int nDbNumber : 0;
  property int nQuizIndex: 1
  property int nFontSize:  idWindow.height > 1200 ? 14 : 11
  property int nDlgHeight: idWindow.height / 5 + 45
  property int nDlgHeightLarge: idWindow.height / 2.5
  property int nBtnHeight: idWindow.height / 15
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n5BtnWidth: idTabMain.width / 6
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2 - 10
  property int nMainWidth: idTabMain.width
  property bool bQSort : true
  property string sQSort : bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property variant quizListView
  property variant oTakeQuiz
  property variant oPopDlg
  property bool bAllok : false
  property bool bDownloadNotVisible : true
  property int nGlosaDbLastIndex:  -1

  color: "#E5E7E9"

  property int nGlosaTakeQuizIndex : -1
  property int nLastIndexMain : 0

  function onBackPressedTab() {
    nLastIndexMain = MyDownloader.popIndex()
    idTabMain.currentIndex = nLastIndexMain
  }

  function onBackPressedDlg() {
    idWindow.oPopDlg.closeThisDlg()
  }


  onSScoreTextChanged:
  {

    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);
            var i = MyDownloader.indexFromGlosNr(glosModelIndex, nDbNumber)
            glosModelIndex.setProperty(i,"state1", sScoreText)

          }
          )
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
  // https://www.countryflags.com/
  ListModel {
    id:idLangModel
    ListElement {
      lang: "Swedish"
      imgsource:"qrc:/glosquiz/flags/sweden-flag-button-round-icon-128.png"
      code:"sv"
    }

    ListElement {
      lang: "Russian"
      imgsource:"qrc:/glosquiz/flags/russia-flag-button-round-icon-128.png"
      code:"ru"
    }

    ListElement {
      lang: "French"
      imgsource:"qrc:/glosquiz/flags/france-flag-button-round-icon-128.png"
      code:"fr"
    }

    ListElement {
      lang: "Italian"
      imgsource:"qrc:/glosquiz/flags/italy-flag-button-round-icon-128.png"
      code:"it"
    }

    ListElement {
      lang: "English"
      imgsource:"qrc:/glosquiz/flags/united-kingdom-flag-button-round-icon-128.png"
      code:"en"
    }

    ListElement {
      lang: "German"
      imgsource:"qrc:/glosquiz/flags/germany-flag-button-round-icon-128.png"
      code:"de"
    }

    ListElement {
      lang: "Polish"
      imgsource:"qrc:/glosquiz/flags/poland-flag-button-round-icon-128.png"
      code:"pl"
    }

    ListElement {
      lang: "Norvegian"
      imgsource:"qrc:/glosquiz/flags/norway-flag-button-round-icon-128.png"
      code:"no"
    }

    ListElement {
      lang: "Spanish"
      imgsource:"qrc:/glosquiz/flags/spain-flag-button-round-icon-128.png"
      code:"es"
    }

    ListElement {
      lang: "Hungarian"
      imgsource:"qrc:/glosquiz/flags/hungary-flag-button-round-icon-128.png"
      code:"hu"
    }

  }
  ListModel {
    id:idQuizModel

    property string question
    property string extra
    property string answer
    property int number

    onQuestionChanged:
    {
      MyDownloader.setImgWord(question,sQuestionLang )
    }

    ListElement {
      number:0
    }
    ListElement {
      number:1
    }
    ListElement {
      number:2
    }
  }

  Component.onCompleted:
  {
    QuizLib.getAndInitDb()
  }

  width:570
  height:730
  visible: true
  Item
  {
    id:idMainTitle
    z: 3
    width:parent.width
    height: idBtnHelp.height
    TextList {
      id: idTitle
      font.italic: glosModelIndex.count === 0
      anchors.verticalCenter: idBtnHelp.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      text: {
        if (glosModelIndex.count === 0)
          return "No Quiz create one or download"

        return sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") +  sToLang + " " + sScoreText

      }
    }

    ButtonQuizImg
    {
      id: idBtnHelp
      anchors.right: parent.right
      anchors.rightMargin : 40
      anchors.top : parent.top
      anchors.topMargin : 5
      source:"qrc:help.png"
      onClicked: Qt.openUrlExternally("https://faxling.github.io/WordQuizWin/index.html");
    }
  }
  /*
  TextList
  {
    text: sQuizName + " " + sLangLang + " " + sScoreText
    anchors.horizontalCenter: parent.horizontalCenter
  }
  */

  TabView {
    id:idTabMain
    anchors.fill : parent
    anchors.leftMargin : 50
    anchors.rightMargin : 50
    anchors.bottomMargin:  nBtnHeight / 2
    anchors.topMargin:  idMainTitle.height + 10


    Tab
    {
      id:idTab1
      title: "Home"
      active: true
      CreateNewQuiz
      {
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Edit"
      enabled: glosModelIndex.count > 0 && bDownloadNotVisible
      active: true
      EditQuiz
      {
        id:idTab2
        anchors.fill: parent
      }
    }
    Tab
    {
      enabled: glosModelIndex.count > 0 && bDownloadNotVisible
      title: "Quiz"
      TakeQuiz
      {
        id:idTab3
        anchors.fill: parent
      }
    }

    style: TabViewStyle {

      tab: Rectangle {
        color: styleData.selected ? "#626567" :"#BDC3C7"
        opacity: styleData.enabled ? 1 :0.5
        border.color:  "#797D7F"
        implicitWidth: idTabMain.width / 3
        implicitHeight: nBtnHeight
        radius: 2
        Text {
          id: text
          anchors.centerIn: parent
          text: styleData.title
          color: styleData.selected ? "white" : "black"
        }
      }
      frame: Rectangle { color: "#E5E7E9" }
    }

    onCurrentIndexChanged:
    {
      if (nLastIndexMain === currentIndex)
        return
      MyDownloader.pushIndex(nLastIndexMain)
      nLastIndexMain = currentIndex
    }

  }

}

