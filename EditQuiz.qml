import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0 as Sql
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item {
  id:idEditQuiz
  property int nLastSearch : 0

  Column
  {
    id:idGlosListHeader
    spacing:20
    anchors.topMargin: 20
    anchors.bottomMargin: 50
    anchors.fill: parent
    Component
    {
      id:idHeaderGlos

      Row {

        TextList {
          color: "steelblue"
          width:150
          text:  "word"
        }

        TextList {
          color: "steelblue"
          text: "answer"
        }
      }
    }


    XmlListModel {
      id: idTrTextModel
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          if (idTrTextModel.count <= 0)
          {
            idText.text = "-"
            return
          }
          idText.text =  idTrTextModel.get(0).text1
          idTextInput2.text = idText.text;
          idTrSynModel.query = "/DicResult/def/tr[1]/syn"
          idTrMeanModel.query = "/DicResult/def/tr[1]/mean"
        }
      }

      query: "/DicResult/def/tr"
      XmlRole { name: "count1"; query: "count(syn)" }
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
    XmlListModel {
      id: idTranslateModel
      query: "/Translation"
      XmlRole { name: "trans"; query: "text/string()" }
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          if (idTranslateModel.count <= 0)
          {
            idTextTrans.text = "-"
            return
          }
          idTextTrans.text =  idTranslateModel.get(0).trans


        }
      }
    }

    Row
    {
      spacing:20
      TextList
      {
        id:idText
        width:idEditQuiz.width / 2
        text :"-"
        onClick: idTextInput2.text = text
      }
      TextList
      {
        id:idTextTrans
        text :"-"
        onClick: {
          if (nLastSearch === 2)
            idTextInput.text = idTextTrans.text
          else
            idTextInput2.text = idTextTrans.text
        }
      }
    }

    Row
    {
      spacing:20
      InputTextQuiz
      {
        width:idEditQuiz.width / 2 -10
        text:""
        id:idTextInput
      }
      InputTextQuiz
      {
        width:idEditQuiz.width / 2 -10
        text:""
        id:idTextInput2
      }
    }

    Row
    {
      spacing:10

      ButtonQuiz {
        text: "Find in Dict " + sLangLang
        onClicked: {
          nLastSearch = 0
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrl , idTextInput.text)

          idTranslateModel.source = sReqUrl + idTextInput.text

        }
      }


      ButtonQuiz {
        text: "Find in Dict " + sLangLangRev
        onClicked: {
          nLastSearch = 1
          if (bHasDictFrom)
            QuizLib.downloadDictOnWord(sReqDictUrlRev , idTextInput2.text)
          idTranslateModel.source = sReqUrlBase +  sLangLangRev + "&text=" + idTextInput2.text
        }
      }


      ButtonQuiz {
        text: "Find in Dict " + sLangLangEn
        onClicked: {
          nLastSearch = 2
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrlEn , idTextInput.text)

          idTranslateModel.source = sReqUrlBase +  sLangLangEn + "&text=" + idTextInput.text
        }
      }

      ButtonQuiz {
        text: "Add"
        onClicked: {

          // Find a new Id
          var nC = 0;
          for(var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number;
          }

          nC += 1;
          QuizLib.insertGlosa(nDbNumber, nC, idTextInput.text, idTextInput2.text)

          if (bHasSpeech)
            MyDownloader.downloadWord(idTextInput2.text,sToLang)

        }
      }

    }

    Row
    {
      id:idDictionaryResultRow
      height:150
      width:parent.width - 100

      Text
      {
        visible:false
        id:idErrorText
        color: "red"
        font.pointSize: 16
      }

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
            text:  text1 + " " + ( count1 > 0 ? "..." : "")
            MouseArea
            {
              anchors.fill: parent
              onClicked:
              {
                idDicList.currentIndex = index
                idText.text = idSearchItem.text;
                idTextInput2.text = idSearchItem.text;
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
              idTextInput2.text = idSynText.text;
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
        }
      }
    }


    ListViewHi {
      id:idGlosList
      clip: true
      width:idEditQuiz.width  -20
      height:200
      spacing: 3
      Component.onCompleted:
      {
        idWindow.glosListView = idGlosList
      }

      header:idHeaderGlos

      model: glosModel
      delegate: Row {
        spacing:5

        TextList {
          width:idGlosList.width  / 3
          text:  question
          color: state1 === 0 ? "black" : "green"
          onClick: idTextInput.text = question
        }

        TextList {
          width:idGlosList.width  / 3
          id:idAnswer
          text: answer
          onClick: idTextInput2.text = answer
        }

        ButtonQuizImg
        {
          height:26
          width:32
          //    y:-5
          source: "qrc:edit.png"
          onClicked:
          {
            db.transaction(
                  function(tx) {
                    tx.executeSql('DELETE FROM Glosa'+nDbNumber+' WHERE number = ?',[number]);

                  }
                  )
            var sQuestion = question
            var sAnswer = answer

            glosModel.remove(index)
            MyDownloader.deleteWord(sAnswer,sToLang)
            MyDownloader.deleteWord(sAnswer,sFromLang)
            var nC = glosModel.count
            sScoreText = nC + "/" + nC
          }
        }


        ButtonQuizImg
        {
          height:26
          width:32
          visible:bHasSpeech
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(question,sFromLang)
        }

        ButtonQuizImg
        {
          height:26
          width:32
          visible:bHasSpeech
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(answer,sToLang)
        }
      }
    }
    Row
    {
      spacing:10
      ButtonQuiz
      {
        text : "Reset"
        onClicked:
        {
          db.transaction(
                function(tx) {
                  tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
                })


          glosModelWorking.clear()
          var nC = glosModel.count

          sScoreText = nC + "/" + nC
          for ( var i = 0; i < nC;++i) {
            glosModel.get(i).state1=0;
            glosModelWorking.append(glosModel.get(i))
          }

          var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

          QuizLib.assignQuizModel(nIndexOwNewWord)

        }

      }

      ButtonQuiz
      {
        text : "Reverse"
        onClicked:
        {
          db.transaction(
                function(tx) {
                  tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
                })


          glosModelWorking.clear()
          var nC = glosModel.count

          sScoreText = nC + "/" + nC
          for ( var i = 0; i < nC;++i) {
            glosModel.get(i).state1=0;

            var squestion = glosModel.get(i).answer
            var sanswer = glosModel.get(i).question
            var nnC  = glosModel.get(i).number
            glosModelWorking.append({"number": nnC, "question": squestion , "answer": sanswer, "state1":0})
          }

          var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

          QuizLib.assignQuizModel(nIndexOwNewWord)

        }

      }

      ButtonQuiz
      {
        text : "Download All Audio"
        onClicked:
        {
          MyDownloader.downLoadAllSpeech(glosModel, sLangLang);
        }

      }

    }

  }
}

