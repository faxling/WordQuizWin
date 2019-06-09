import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.LocalStorage 2.0 as Sql

/// Faxling     Raggo100 trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f


// https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&text=groda&lang=sv-ru
// dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739


//https://dictionary.yandex.net/api/v1/dicservice/getLangs?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739
Window {

  id:idWindow
  property string sReqDictUrlBase : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang="
  property string sReqDictUrl : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text="
  property string sReqDictUrlRev : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=ru-sv&text="
  property string sReqDictUrlEn : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=en-ru&text="

  property string sReqUrl: "https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang=sv-ru&text="

  property variant db
  property string sLangLangSelected
  property string sLangLang
  property string sLangLangRev
  property string sLangLangEn
  property string sQuizName : "-"
  property string sScoreText : "-"
  property int ndbnumber : 0;

  onSScoreTextChanged:
  {
    db.transaction(
          function(tx) {


            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, ndbnumber]);

            console.log("onSScoreTextChanged " + sScoreText + " " + ndbnumber)
            var nC = glosModelIndex.count
            for ( var i = 0; i < nC;++i) {
              if (glosModelIndex.get(i).dbnumber === ndbnumber)
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
    if (glosModel.count < 1)
      return;
    var nC = glosModel.count
    glosModelWorking.clear();

    for ( var i = 0; i < nC;++i) {
      if (glosModel.get(i).state1 === 0)
        glosModelWorking.append(glosModel.get(i))
    }

    var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

    sScoreText = nC + "/" + glosModelWorking.count
    idQuizModel.get(1).question =  glosModelWorking.get(nIndexOwNewWord).question;
    idQuizModel.get(1).answer = glosModelWorking.get(nIndexOwNewWord).answer;
    idQuizModel.get(1).number = glosModelWorking.get(nIndexOwNewWord).number;
  }

  ListModel {
    id: glosModel
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
      question: "1"
      answer:"-"
      number:0
      visible1:false
    }
    ListElement {
      question: "2"
      answer:"-"
      number:1
      visible1:false
    }
    ListElement {
      question: "3"
      answer:"-"
      number:2
      visible1:false
    }
  }

  Component.onCompleted:
  {

    db =  Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

    Sql.LocalStorage.openDatabaseSync()

    db.transaction(
          function(tx) {

            // tx.executeSql('DROP TABLE GlosaDbIndex');


            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbIndex( dbnumber INT , quizname TEXT, state1 TEXT, langpair TEXT )');

            var rs = tx.executeSql('SELECT * FROM GlosaDbIndex');

            for(var i = 0; i < rs.rows.length; i++) {
              glosModelIndex.append({"dbnumber": rs.rows.item(i).dbnumber, "quizname": rs.rows.item(i).quizname , "state1": rs.rows.item(i).state1, "langpair" : rs.rows.item(i).langpair })
            }

          }
          )

  }

  width:500
  height:700
  visible: true
  TextList
  {
    text: sQuizName + " " + sLangLang
    anchors.horizontalCenter: parent.horizontalCenter
  }

  TabView {
    anchors.fill : parent
    anchors.leftMargin : 50
    anchors.topMargin : 50
    Tab
    {
      title: "Create"
      CreateNewQuiz
      {
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Edit"
      EditQuiz
      {
        id:idEditQuiz
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Quiz"
      TakeQuiz
      {
        anchors.fill: parent
      }
    }
    style: TabViewStyle {

      tab: Rectangle {
        color: styleData.selected ? "steelblue" :"lightsteelblue"
        border.color:  "steelblue"
        implicitWidth: 100
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

