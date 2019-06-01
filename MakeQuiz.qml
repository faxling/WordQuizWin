import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0 as Sql

Item {

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
    anchors.rightMargin: 50
    anchors.bottomMargin: 50
    anchors.fill: parent
    Component
    {
      id:idHeaderGlos

      Row {
        TextList {
          color: "steelblue"
          width:50
          text:  "No"
        }
        TextList {
          color: "steelblue"
          width:100
          text:  "word"
        }

        TextList {
          color: "steelblue"
          text: "answer"
        }
      }
    }
    Component.onCompleted:
    {
      var i;

      db =  Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

      db.transaction(
            function(tx) {

              // tx.executeSql('DROP TABLE Glosa');

              tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa( number INT , quizword TEXT, answer TEXT)');

              // tx.executeSql('INSERT INTO Glosa VALUES(?, ?)', [ 'ja', 'да' ]);

              // Show all added greetings
              var rs = tx.executeSql('SELECT * FROM Glosa');

              for(var i = 0; i < rs.rows.length; i++) {
                glosModel.append({"number": rs.rows.item(i).number, "name": rs.rows.item(i).quizword , "answer": rs.rows.item(i).answer})
              }
            }
            )
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
      XmlRole { name: "syn"; query: "text/string()" }
    }

    XmlListModel {
      id: idTrMeanModel
      XmlRole { name: "mean"; query: "text/string()" }
    }

    Row
    {
      TextList
      {
        width:100
        id:idQuizName
        text:"Djur"
      }
      TextList
      {
        id:idLangPair
        text:"sv-ru"
      }
    }


    InputTextQuiz
    {
      text:"tid"
      id:idTextInput
    }

    Row
    {
      spacing:50

      Button {
        height:26

        text: "Find in Dict"
        onClicked: {

          var doc = new XMLHttpRequest();
          doc.open("GET",sReqDictUrl + idTextInput.text);
          console.log("find " + idTextInput.text);

          doc.onreadystatechange = function() {

            if (doc.readyState === XMLHttpRequest.DONE) {
              idTrSynModel.xml = doc.responseText
              idTrTextModel.xml = doc.responseText
              idTrMeanModel.xml = doc.responseText
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
        text:"-"
      }
    }

    Row
    {
      height:150
      width:parent.width - 100
      ListView {
        id:idDicList
        width:parent.width - 100
        height : parent.height
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
                idTrSynModel.query = "/DicResult/def/tr["  +(index + 1) + "]/syn"
                idTrMeanModel.query = "/DicResult/def/tr["  +(index + 1) + "]/mean"
              }

            }

          }
        }
      }
      ListView
      {
        model : idTrSynModel
        width:100
        height : parent.height
        delegate: TextList {
          id:idSynText
          text:syn
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idText.text = idSynText.text;
            }

          }
        }
      }
      ListView
      {
        model : idTrMeanModel
        width:100
        height : parent.height
        delegate: TextList {
          id:idSMeanText
          text:mean
          MouseArea
          {
            anchors.fill: parent
          }
        }
      }
    }

    ListView {

      clip: true
      id:idGlosList
      width:parent.width - 100
      height:200
      spacing: 3

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
          height:26
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
  }
}

