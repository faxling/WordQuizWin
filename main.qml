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
  property int nGlosaDbLastIndex;
  onSScoreTextChanged:
  {

    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);

            var nC = glosModelIndex.count
            for ( var i = 0; i < nC;++i) {
              if (glosModelIndex.get(i).dbnumber === nDbNumber)
              {
                glosModelIndex.setProperty(i,"state1", sScoreText)
                break;
              }
            }
          }
          )
  }

  function loadQuiz()
  {
    glosModelWorking.clear();
    if (glosModel.count < 1)
    {
      for (var  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = false;
        idQuizModel.get(i).question = "-";
        idQuizModel.get(i).answer = "-";
        idQuizModel.get(i).number = "-";
        idQuizModel.get(i).visible1 = false
      }
      return;
    }

    var nC = glosModel.count

    bIsReverse = false

    for (  i = 0; i < nC;++i) {
      if (glosModel.get(i).state1 === 0)
        glosModelWorking.append(glosModel.get(i))
    }

    var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

    // sScoreText =  glosModelWorking.count + "/" + nC

    if (glosModelWorking.count === 0)
    {
      for (  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = true;
      }
    }
    else
    {
      for (  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = false;
      }
      idQuizModel.get(nQuizIndex).question = glosModelWorking.get(nIndexOwNewWord).question;
      idQuizModel.get(nQuizIndex).answer = glosModelWorking.get(nIndexOwNewWord).answer;
      idQuizModel.get(nQuizIndex).number = glosModelWorking.get(nIndexOwNewWord).number;
      idQuizModel.get(nQuizIndex).visible1 = false
    }

  }
  ListModel {
    objectName:"glosModel"
    id: glosModel

    function sortModel()
    {

      db.transaction(
            function(tx) {
              glosModel.clear();

              var rs = tx.executeSql("SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort);

              for(var i = 0; i < rs.rows.length; i++) {

                var sA;
                var sE = "";
                var ocA = rs.rows.item(i).answer.split("###")
                sA = ocA[0]
                if (ocA.length > 1)
                  sE = ocA[1]

                glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE,  "state1" : rs.rows.item(i).state })

              }
            }
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
      number:0
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      number:1
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      number:2
      visible1:false
      allok:false
    }
  }


  Component.onCompleted:
  {
    QuizLib.getAndInitDb()
  }

  width:555
  height:700
  visible: true
  TextList
  {
    text: sQuizName + " " + sLangLang + " " + sScoreText
    anchors.horizontalCenter: parent.horizontalCenter
  }

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
      CreateNewQuiz
      {
        id:idTab1
        Component.onCompleted:
        {
          idTab1.nQuizListCurrentIndex = idWindow.nGlosaDbLastIndex
        }

        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Edit"
      EditQuiz
      {
        id:idTab2
        Component.onCompleted:
        {
          idWindow.glosListView = idTab2.glosListView
        }

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

