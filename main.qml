import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0 as Sql


/// Faxling     Raggo100 trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f


// https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&text=groda&lang=sv-ru
// dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739



Window {
  visible: true

  width:500
  height:600
  property variant db
  ListModel {
    id: glosModel
  }
  property string sReqDictUrl : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text="
  property string sReqUrl: "https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang=sv-ru&text="

  Column
  {
    spacing:20
    anchors.topMargin: 50
    anchors.leftMargin: 50
    anchors.rightMargin: 50
    anchors.fill: parent


    XmlListModel {
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          //      idText.text =  xmlModel.get(0).trans
          //       idTopText.text =  xmlModel.get(0).trans
        }
      }

      id: xmlModel
      query: "/DicResult/def/tr"
      XmlRole { name: "trans"; query: "text/string()" }

    }


    XmlListModel {
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          idText.text =  idTrTextModel.get(0).text1
          // console.log("- " + idText.text )
          //       idTopText.text =  xmlModel.get(0).trans
        }
      }
      id: idTrTextModel
      query: "/DicResult/def/tr"
      XmlRole { name: "text1"; query: "text/string()" }
    }

    XmlListModel {
      id: idTrSynModel
      query: "/DicResult/def/tr/syn"
      XmlRole { name: "syn"; query: "text/string()" }
    }

    XmlListModel {
      id: idTrMeanModel
      query: "/DicResult/def/tr/Mean"
      XmlRole { name: "mean"; query: "mean/string()" }
    }


    Rectangle
    {

      color:"green"
      width: parent.width
      height: 23
      TextInput
      {
        anchors.leftMargin: 5
        font.pointSize: 12
        anchors.fill: parent
        id:idTextInput
        text:"tid"
      }
    }

    Row
    {
      spacing:50
      Button {

        text: "Find"
        onClicked: {


          var doc = new XMLHttpRequest();
          doc.open("GET",sReqDictUrl + idTextInput.text);
          console.log("find " + idTextInput.text);

          doc.onreadystatechange = function() {

            if (doc.readyState === XMLHttpRequest.ERROR) {
              console.log("error")
            }

            if (doc.readyState === XMLHttpRequest.DONE) {
              idTrSynModel.xml = doc.responseText

              idTrTextModel.xml = doc.responseText
              console.log("answer")

            }
          }
          doc.send()

        }
      }


      Button {
        text: "Add"
        onClicked: {
          var nC = 0;
          console.log("count "+ glosModel.count)


          for(var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number;
          }

          nC += 1;


          console.log("add "+ nC)

          db.transaction(
                function(tx) {
                  tx.executeSql('INSERT INTO Glosa VALUES(?, ?, ?)', [nC,  idTextInput.text, idText.text ]);
                })



          glosModel.append({"number": nC, "name": idTextInput.text , "answer": idText.text})


        }
      }
      TextList{
        id:idText
        width: 150
        text:"pucko"
      }
    }

    Component
    {
      id:idHeaderGlos

      Row {
        TextList {
          color: "blue"
          width:50
          text:  "No"
        }
        TextList {
          color: "blue"
          width:100
          text:  "word"
        }

        TextList {
          color: "blue"
          text: "answer"
        }
      }
    }



    ListView {
      id:idDicList
      width:parent.width - 100
      height:200
      model:idTrTextModel
      highlightFollowsCurrentItem: true
      highlight: Rectangle {
        opacity:0.5
        color: "#009bff"
      }
      delegate: Row {

        TextList {
          id:idSearchItem
          width:idDicList.width
          text:  text1
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idDicList.currentIndex = index
              idText.text = idSearchItem.text;
            }

          }

        }


      }
    }
    ListView
    {
      model : idTrMeanModel
      height:100
      width:100
      delegate: Text {

        text:mean

      }
    }

    ListView {
      clip: true
      id:idGlosList
      width:parent.width - 100
      height:350
      spacing: 10


      header:idHeaderGlos

      model: glosModel

      delegate: Row {
        TextList {
          width:50
          text:  number
        }

        TextList {
          width:100
          text:  name
        }

        TextList {
          width:100
          id:idAnswer
          text: answer
        }
        Button
        {
          height:30
          width:32
          y:-5
          iconSource: "qrc:rm.png"
          onClicked:
          {
            console.log("rm " + number)
            db.transaction(
                  function(tx) {
                    tx.executeSql('DELETE FROM Glosa WHERE number = ?',[number]);


                  }
                  )
            glosModel.remove(index)
          }

        }
      }
    }
    Component.onCompleted:
    {
      var i;

      db =  Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

      db.transaction(
            function(tx) {
              // Create the database if it doesn't already exist
              // tx.executeSql('DROP TABLE Glosa');

              tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa( number INT , quizword TEXT, answer TEXT)');

              // Add (another) greeting row
              // tx.executeSql('INSERT INTO Glosa VALUES(?, ?)', [ 'ja', 'да' ]);

              // Show all added greetings
              var rs = tx.executeSql('SELECT * FROM Glosa');


              var r = ""
              for(var i = 0; i < rs.rows.length; i++) {
                glosModel.append({"number": rs.rows.item(i).number, "name": rs.rows.item(i).quizword , "answer": rs.rows.item(i).answer})
              }
            }
            )
    }
  }
}
