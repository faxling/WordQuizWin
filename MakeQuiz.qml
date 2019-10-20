import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0


Item {



  property int nLastSearch : 0
  Column
  {
    spacing:20
    anchors.topMargin: 20
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


    TextList
    {
      id:idText
      text :"-"
    }

    InputTextQuiz
    {
      text:"tid"
      id:idTextInput
    }

    Row
    {
      spacing:10

      ButtonQuiz {


        text: "Find in Dict " + sLangLang
        onClicked: {
          nLastSearch = 0
          var doc = new XMLHttpRequest();
          console.log(sReqDictUrl + idTextInput.text);
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


      ButtonQuiz {


        text: "Find in Dict " + sLangLangRev
        onClicked: {
          nLastSearch = 1
          var doc = new XMLHttpRequest();
          doc.open("GET",sReqDictUrlRev + idTextInput.text);
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


      ButtonQuiz {
        text: "Find in Dict " + sLangLangEn
        onClicked: {
          nLastSearch = 2
          var doc = new XMLHttpRequest();
          doc.open("GET",sReqDictUrlEn + idTextInput.text);
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

      ButtonQuiz {
        text: "Add"
        onClicked: {
          var nC = 0;
          console.log("count "+ glosModel.count)

          for(var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number;
          }

          nC += 1;

          if (nLastSearch !== 1)
          {

            db.transaction(
                  function(tx) {
                    tx.executeSql('INSERT INTO Glosa VALUES(?, ?, ?, ?)', [nC,  idTextInput.text, idText.text, 0 ]);
                  })



            glosModel.append({"number": nC, "question": idTextInput.text , "answer": idText.text, "state1":0})
          }
          else
          {
            db.transaction(
                  function(tx) {
                    tx.executeSql('INSERT INTO Glosa VALUES(?, ?, ?, ?)', [nC,   idText.text, idTextInput.text,0 ]);
                  })



            glosModel.append({"number": nC, "question": idText.text  , "answer":   idTextInput.text, "state1":0})

          }

        }
      }

    }

    Row
    {
      height:150
      width:parent.width - 100
      ListViewHi {
        id:idDicList
        width:parent.width - 100
        height : parent.height
        model:idTrTextModel
        highlightFollowsCurrentItem: true

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
          text:  question
          color: state1 === 0 ? "red" : "green"
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
    ButtonQuiz
    {
      text : "Reset"
      onClicked:
      {
        db.transaction(
              function(tx) {
                tx.executeSql('UPDATE Glosa SET state=0');
              })


        glosModelWorking.clear()
        var nC = glosModel.count

        sScoreText = nC + "/" + nC
        for ( var i = 0; i < nC;++i) {
          glosModel.get(i).state1=0;
          glosModelWorking.append(glosModel.get(i))
        }

      }

    }
  }
}

