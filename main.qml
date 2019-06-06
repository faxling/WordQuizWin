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
  property string sLangLang
  property string sLangLangRev
    property string sLangLangEn
  property string sQuizName : "-"

  ListModel {
    id: glosModel
  }

  ListModel {
    id: glosModelWorking
  }

  Component.onCompleted:
  {
    var i;

    console.log("Load")

    db =  Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

    db.transaction(
          function(tx) {

            // tx.executeSql('DROP TABLE Glosa');

            tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa( number INT , quizword TEXT, answer TEXT, state INT)');

            // tx.executeSql('INSERT INTO Glosa VALUES(?, ?)', [ 'ja', 'да' ]);

            // Show all added greetings
            var rs = tx.executeSql('SELECT * FROM Glosa');

            for(var i = 0; i < rs.rows.length; i++) {
              glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": rs.rows.item(i).answer, "state1" : rs.rows.item(i).state })
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
      MakeQuiz
      {
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

