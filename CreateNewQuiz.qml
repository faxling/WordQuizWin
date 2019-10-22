import QtQuick 2.0
import QtQuick.Controls 1.4


Item
{
  ListModel {
    id:idServerQModel
    ListElement {
      qname: "testfile"
      code:"sv"
      state1:""
      desc1:""
    }
  }

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
      lang: "Polish"
      code:"pl"
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

    Row
    {
      TextList
      {
        width: 100
        id:idTextSelected
        MouseArea
        {
          anchors.fill: parent
          onClicked: idTextInputQuizName.text = parent.text
        }
      }
      TextList
      {
        id:idDescriptionText
      }
    }
    InputTextQuiz
    {
      id:idTextInputQuizName
      text:"new q"
    }
    Row
    {
      id:rowEButtons
      spacing:10
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

                  glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.text , "state1": "0/0", "langpair" : sLangLangSelected,"desc1":"" })
                }
                )

        }
      }
      ButtonQuiz
      {
        text:"Rename"
        onClicked:
        {
          sQuizName = idTextInputQuizName.text
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
      ButtonQuiz
      {
        id:btnUppload
        text:"Uppload"
        onClicked:
        {
          idExport.visible = true
          idExportError.visible = false
        }
      }
      ButtonQuiz
      {
        text:"Download"
        onClicked:
        {
          idImportMsg.text =""
          idImport.visible = true
          MyDownloader.listQuiz()
        }
      }
      /*
      TextList
      {
        id:idLangPair
        text:sLangLangSelected
      }
      */

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
          onClick: idLangList1.currentIndex = index
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
          onClick:idLangList2.currentIndex = index
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
      text:glosModelIndex.count + " Available Quiz's:"
    }


    ListViewHi
    {
      id:idQuizList
      width:parent.width
      height:200
      model:glosModelIndex
      spacing:3
      /*
      ocL.append(oJJ["qname"].toString());
      ocL.append(oJJ["desc1"].toString());
      ocL.append(oJJ["slang"].toString());
      ocL.append(oJJ["qcount"].toString());
      */
      function loadFromServerList(nCount, oDD) {
        idServerQModel.clear()

        if (nCount===0)
        {
          idDescText.text = ""
          idImport.sSelectedQ = "";
          return;
        }

        idDescText.text = oDD[1];
        idImport.sSelectedQ = oDD[0];

        for(var i = 0; i < nCount; i+=4) {
          idServerQModel.append({"qname":oDD[i], "desc1":oDD[i+1],  "code":oDD[i+2],  "state1":oDD[i+3]});
        }
      }
      function quizDeleted(nResponce)
      {
        idDeleteQuiz.bProgVisible = false
        idDescText.text = ""

        if (nResponce>=0)
        {
          idServerQModel.remove(nResponce);
          if (nResponce>0)
          {
            idServerListView.currentIndex = nResponce - 1
            idDescText.text = idServerQModel.get(nResponce - 1).desc1;
            idImport.sSelectedQ = idServerQModel.get(nResponce - 1).qname;
            idImportMsg.text = ""
          }
        }
        else
          idImportMsg.text = "Not deleted"
      }


      function quizExported(nResponce)
      {
        idExportBtn.bProgVisible = false
        if (nResponce === 0)
        {
          idExportError.text = "Network error";
          idExportError.visible = true;
        }
        else
        {
          if (nResponce === 206)
          {
            idExportError.text = "Quiz with name '"+sQuizName+"' Exists"
            idExportError.visible = true;
          }
          else if (nResponce === 200)
          {
            idExport.visible = false;
          }
          else
          {
            idExportError.text = nResponce
            idExportError.visible = true;
          }

        }
      }

      function loadFromList(nCount, oDD, sLangLoaded) {
        db.transaction(
              function(tx) {
                var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
                var nNr = 1
                if (rs.rows.length > 0)
                {
                  nNr = rs.rows.item(0).newnr + 1
                }

                nDbNumber = nNr;

                tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nNr + '( number INT , quizword TEXT, answer TEXT, state INT )');

                var sState1 = nCount/2 + "/" +nCount/2
                tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nDbNumber,idDescText.text]);
                tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',[nDbNumber, idTextInputQuizName.text,sState1,sLangLoaded  ]);

                glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.text , "state1": sState1 , "langpair" : sLangLoaded,"desc1":idDescText.text })
                // answer, question , state

                for(var i = 0; i < nCount; i+=2) {
                  tx.executeSql('INSERT INTO Glosa' +nNr+' VALUES(?, ?, ?, ?)', [i/2,  oDD[i+1], oDD[i], 0 ]);

                }
                idLoadQuiz.bProgVisible = false
                idImport.visible = false
              }
              );

      }

      Component.onCompleted: {
        MyDownloader.exportedSignal.connect(quizExported)
        MyDownloader.quizDownloadedSignal.connect(loadFromList)
        MyDownloader.quizListDownloadedSignal.connect(loadFromServerList)
        MyDownloader.deletedSignal.connect(quizDeleted)
      }

      onCurrentIndexChanged:
      {

        db.transaction(
              function(tx) {
                tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',[currentIndex]);
              }
              )

        if (glosModelIndex.count === 0)
          return;
        sQuizName = glosModelIndex.get(currentIndex).quizname;
        sLangLang = glosModelIndex.get(currentIndex).langpair;
        nDbNumber  = glosModelIndex.get(currentIndex).dbnumber;
        sScoreText = glosModelIndex.get(currentIndex).state1;
        idDescriptionText.text  = glosModelIndex.get(currentIndex).desc1;
        var res = sLangLang.split("-");
        sLangLangRev = res[1] + "-" + res[0];
        sToLang = res[1]
        sFromLang = res[0]
        sLangLangEn = "en"+ "-" + res[1];
        sReqDictUrl = sReqDictUrlBase +  sLangLang + "&text=";
        sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text=";
        sReqDictUrlEn= sReqDictUrlBase + sLangLangEn + "&text=";

        sReqUrl = sReqUrlBase +  sLangLang + "&text=";

        db.transaction(
              function(tx) {
                // tx.executeSql('DROP TABLE Glosa');

                glosModel.clear();
                tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber + '( number INT , quizword TEXT, answer TEXT, state INT)');

                var rs = tx.executeSql('SELECT * FROM Glosa' + nDbNumber );

                for(var i = 0; i < rs.rows.length; i++) {
                  var sA;
                  var sE = "";

                  var ocA = rs.rows.item(i).answer.split("###")
                  sA = ocA[0]
                  if (ocA.length > 1)
                    sE = ocA[1]

                  glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE, "state1" : rs.rows.item(i).state })
                }
                loadQuiz();

              }
              )
        idTextSelected.text = sQuizName

      }

      delegate: Row {
        id:idQuizListRow

        TextList
        {
          id:idCol1
          width:50
          text:index+1
        }
        TextList
        {
          id:idCol2
          width:100
          text:quizname
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol3
          width:100
          text:langpair
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {

          id:idCol4
          width:100
          text:state1

          onClick: idQuizList.currentIndex = index
        }

        ButtonQuizImg
        {
          height:26
          width:32
          source: "qrc:rm.png"
          onClicked:
          {
            db.transaction(
                  function(tx) {
                    tx.executeSql('DELETE FROM GlosaDbIndex WHERE dbnumber = ?',[dbnumber]);
                    tx.executeSql('DROP TABLE Glosa'+dbnumber);
                    tx.executeSql('DELETE FROM GlosaDbDesc WHERE dbnumber = ?',[dbnumber]);
                  }
                  )

            glosModelIndex.remove(index)
            if (index ===idQuizList.currentIndex)
            {
              if (index>0)
                idQuizList.currentIndex = idQuizList.currentIndex -1
            }

          }
        }
      }
    }

    Component.onCompleted: {
      idQuizList.currentIndex = nGlosaDbLastIndex
    }

  }
  Rectangle{
    id:idExport
    y:20
    visible: false;
    color: "steelblue"
    width:parent.width
    height:170


    TextList {
      x:20
      id:idExportTitle
      text:"Add a description off the quiz '" +sQuizName + "'"
    }

    InputTextQuiz
    {
      id:idTextInputQuizDesc
      anchors.top :idExportTitle.bottom
    }

    TextList {
      id:idExportPwd
      x:20
      anchors.top :idTextInputQuizDesc.bottom
      text:"and a pwd used for deletion/update"
    }

    InputTextQuiz
    {
      id:idTextInputQuizPwd
      anchors.top :idExportPwd.bottom
      text:"*"
    }

    TextList {
      id:idExportError
      x:20
      anchors.top :idTextInputQuizPwd.bottom
      color:"red"
      text:"error"
    }

    ButtonQuiz
    {
      id:idExportBtn
      text: "Export"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idCancelExport.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        MyDownloader.exportCurrentQuiz( glosModel, sQuizName,sLangLang, idTextInputQuizPwd.text, idTextInputQuizDesc.text )
      }
    }

    ButtonQuiz
    {
      id:idCancelExport
      text: "Cancel"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.bottomMargin: 20
      anchors.rightMargin: 20
      onClicked:
      {
        idExport.visible = false
      }
    }
  }

  Rectangle{
    id:idImport
    y:20
    visible: false;
    color: "steelblue"
    width:parent.width
    height:200
    TextList {
      id:idImportMsg
      x:30
      y:25
      color:"red"
      text:""
    }

    TextList {
      id: idImportTitle
      x:20
      text:"Available Quiz"
    }

    Text
    {
      anchors.top :idImportTitle.bottom
      x:20
      id:idDescText
      text:"---"
    }
    TextList {
      anchors.right: parent.right
      anchors.rightMargin:30
      text:"Questions"
    }
    property string sSelectedQ : ""
    ListViewHi
    {
      id:idServerListView
      y:50
      x:10
      clip:true
      width:idImport.width - 20
      height:parent.height - 90
      model: idServerQModel
      delegate: Item {
        height :25
        property int nW : idServerListView.width / 6
        width:idServerListView.width
        Row
        {
          TextList {
            width: nW *3
            id:idTextQname
            text:qname
            onClick:
            {
              idImportMsg.text = ""
              idDescText.text = desc1
              idImport.sSelectedQ = qname;
              idServerListView.currentIndex = index
            }
          }

          Text
          {
            width:nW
            text:code
            font.pointSize: idTextQname.font.pointSize
            height:parent.height
          }

          Text
          {
            width:nW
            text:state1
            font.pointSize: idTextQname.font.pointSize
            height:parent.height
          }
        }
      }
    }
    Rectangle
    {
      id:idPwdDialog
      visible:false
      height:70
      color:"black"
      radius:7
      anchors.bottom: idDeleteQuiz.top
      anchors.bottomMargin: 20
      width:idServerListView.width
      Row
      {
        x:20
        anchors.verticalCenter:parent.verticalCenter
        spacing:20
        Text
        {
          anchors.verticalCenter:parent.verticalCenter
          color: "white"
          text: "Password to remove '" + idImport.sSelectedQ +"'"
        }

        InputTextQuiz
        {
          width:parent.width / 2
          id:idPwdTextInput
        }
      }
    }

    ButtonQuiz
    {
      id:idDeleteQuiz
      text: "Remove"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idLoadQuiz.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        if (idPwdTextInput.displayText.length > 0)
        {
          idPwdDialog.visible = false;
          MyDownloader.deleteQuiz(idImport.sSelectedQ, idPwdTextInput.displayText,idServerListView.currentIndex)
          idPwdTextInput.text = ""
        }
        else
          idPwdDialog.visible = true

      }
    }

    ButtonQuiz
    {
      id:idLoadQuiz
      text: "Load"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idCancelLoad.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        MyDownloader.importQuiz(idImport.sSelectedQ)
      }
    }

    ButtonQuiz
    {
      id:idCancelLoad
      text: "Cancel"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.bottomMargin: 10
      anchors.rightMargin: 20
      onClicked:
      {
        idPwdDialog.visible = false;
        idDeleteQuiz.bProgVisible = false
        idImport.visible = false
      }
    }
  }
}

