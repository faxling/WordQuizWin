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
  property bool bIsReverse
  property bool bHasSpeech : sToLang !== "hu"
  property bool bHasSpeechFrom : sFromLang !=="hu"
  property bool bHasDictTo : sToLang ==="ru" || sToLang ==="en"
  property bool bHasDictFrom : sFromLang ==="ru" || sFromLang ==="en"
  property string sLangLangEn
  property string sQuizName : "-"
  property string sScoreText : "-"
  property int nDbNumber : 0;

  property int nQuizIndex: 1
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2
  property bool bQSort : true
  property string sQSort : bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property variant quizListView
  property int nGlosaDbLastIndex:  -1
  onSScoreTextChanged:
  {

    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);

            var i = QuizLib.findDbNumberInModel(glosModelIndex, nDbNumber)
            glosModelIndex.setProperty(i,"state1", sScoreText)

          }
          )
  }

  ListModel {
    objectName:"glosModel"
    id: glosModel

    function sortModel()
    {


      db.transaction(
            function(tx) {QuizLib.loadFromDb(tx)}
            )

    }

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
    id:idQuizModel

    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:0
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:1
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:2
      visible1:false
      allok:false
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
    width:parent.width
    height: idTitle.height
    TextList {
      id: idTitle
      anchors.horizontalCenter: parent.horizontalCenter
      text: sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") +  sToLang + " " + sScoreText
    }

    ButtonQuizImg
    {
      id: idBtnHelp
      anchors.right: parent.right
      //  anchors.topMargin : -40
      anchors.rightMargin : 40
      anchors.top : parent.top
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
    anchors.bottomMargin:  150
    anchors.topMargin : 50

    Tab
    {
      title: "Create"
      active: true
      id:idTab1
      CreateNewQuiz
      {
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Edit"
      active: true
      EditQuiz
      {
        id:idTab2
        anchors.fill: parent
      }

    }
    Tab
    {
      title: "Quiz"
      TakeQuiz
      {
        id:idTab3
        width : idTabMain.width
        height : idTabMain.width
      }
    }


    style: TabViewStyle {

      tab: Rectangle {
        color: styleData.selected ? "steelblue" :"lightsteelblue"
        border.color:  "steelblue"
        implicitWidth: idTabMain.width / 3
        implicitHeight: 40
        radius: 2
        Text {
          id: text
          anchors.centerIn: parent
          text: styleData.title
          color: styleData.selected ? "white" : "black"
        }
      }
      frame: Rectangle { color: "white" }
    }
  }

}

