import QtQuick 2.0
import QtQuick.Controls 1.4


Item
{

  ListModel {
    id:idLangModel
    ListElement {
      lang: "Swedish"
      code:"sv"
    }
    ListElement {
      lang: "Russian"
      code:"ru"
    }
    ListElement {
      lang: "French"
      code:"fr"
    }
    ListElement {
      lang: "Italian"
      code:"it"
    }
    ListElement {
      lang: "English"
      code:"en"
    }
    ListElement {
      lang: "Hungarian"
      code:"hu"
    }
    ListElement {
      lang: "Norvegian"
      code:"no"
    }
    ListElement {
      lang: "Spanish"
      code:"es"
    }
  }
  Column
  {
    spacing:20
    anchors.topMargin: 20
    anchors.rightMargin: 50
    anchors.bottomMargin: 50
    anchors.fill: parent

    TextList
    {
      id:idTextSelected
    }
    InputTextQuiz
    {
      id:idTextInputQuizName
      text:"new q"
    }
    Row
    {
      spacing:20
      ButtonQuiz
      {
        text:"New Quiz"
        onClicked:
        {

          db.transaction(
                function(tx) {

                  var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
                  var nNr = 1
                  if (rs.rows.length > 0)
                  {
                    nNr = rs.rows.item(0).newnr + 1
                  }
                  tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',[nNr, idTextInputQuizName.text,"0/0",sLangLangSelected  ]);

                  glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.text , "state1": "0/0", "langpair" : sLangLangSelected })
                }
                )

        }
      }
      ButtonQuiz
      {
        text:"Rename"
        onClicked:
        {
          glosModelIndex.setProperty(idQuizList.currentIndex,"quizname", idTextInputQuizName.text)
          db.transaction(
                function(tx) {
                  var nId = glosModelIndex.get(idQuizList.currentIndex).dbnumber;
                  tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[idTextInputQuizName.text, nId]);
                  idTextSelected.text = idTextInputQuizName.text
                }

                )
        }
      }

      TextList
      {
        id:idLangPair
        text:sLangLangSelected
      }

    }

    Row
    {
      width:parent.width
      height : 100
      id:idLangListRow
      function doCurrentIndexChanged()
      {
        if (idLangList1.currentIndex < 0 || idLangList1.currentIndex < 0)
          return
        sLangLangSelected = idLangModel.get(idLangList1.currentIndex).code + "-" + idLangModel.get(idLangList2.currentIndex).code
      }

      ListViewHi
      {
        id:idLangList1
        onCurrentIndexChanged:
        {
          idLangListRow.doCurrentIndexChanged()
        }


        width:100
        height:parent.height
        model: idLangModel
        delegate: TextList {
          text:lang
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idLangList1.currentIndex = index
            }
          }
        }
      }


      ListViewHi
      {
        id:idLangList2
        width:100
        height:parent.height
        model: idLangModel
        onCurrentIndexChanged:
        {
          idLangListRow.doCurrentIndexChanged()
        }

        delegate: TextList {
          text:lang
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idLangList2.currentIndex = index
            }
          }
        }
      }
    }

    TextList
    {
      text:" "
    }

    TextList
    {
      height:5
      color: "steelblue"
      text:"Available Quiz's:"
    }

    ListViewHi
    {
      id:idQuizList
      width:parent.width
      height:200
      model:glosModelIndex


      onCurrentIndexChanged:
      {
        if (glosModelIndex.count === 0)
          return;
        sQuizName = glosModelIndex.get(currentIndex).quizname;
        sLangLang = glosModelIndex.get(currentIndex).langpair;
        ndbnumber  = glosModelIndex.get(currentIndex).dbnumber;
        sScoreText = glosModelIndex.get(currentIndex).state1;

        var res = sLangLang.split("-");
        sLangLangRev = res[1] + "-" + res[0];
        sLangLangEn = "en"+ "-" + res[1];
        sReqDictUrl = sReqDictUrlBase +  sLangLang + "&text=";
        sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text=";
        sReqDictUrlEn= sReqDictUrlBase + sLangLangEn + "&text=";

        db.transaction(
              function(tx) {

                // tx.executeSql('DROP TABLE Glosa');

                glosModel.clear();


                tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + ndbnumber + '( number INT , quizword TEXT, answer TEXT, state INT)');


                var rs = tx.executeSql('SELECT * FROM Glosa' + ndbnumber );

                for(var i = 0; i < rs.rows.length; i++) {
                  glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": rs.rows.item(i).answer, "state1" : rs.rows.item(i).state })
                }

                loadQuiz();

              }
              )
        idTextSelected.text = sQuizName

      }

      delegate:
          Row
      {
      TextList
      {
        width:50
        text:dbnumber
      }
      TextList
      {
        width:100
        text:quizname
        MouseArea
        {
          anchors.fill: parent
          onClicked:
          {
            idQuizList.currentIndex = index
          }
        }
      }
      TextList
      {
        width:100
        text:langpair
      }
      TextList
      {
        width:100
        text:state1
      }
      Button
      {
        height:26
        width:32
        iconSource: "qrc:rm.png"
        onClicked:
        {
          db.transaction(
                function(tx) {

                  tx.executeSql('DELETE FROM GlosaDbIndex WHERE dbnumber = ?',[dbnumber]);
                  tx.executeSql('DROP TABLE Glosa'+dbnumber);

                }
                )

          glosModelIndex.remove(index)
        }

      }
    }
  }
  Component.onCompleted: {

  }
}
}

