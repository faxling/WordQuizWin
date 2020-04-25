import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item
{
  property alias nQuizListCurrentIndex: idQuizList.currentIndex

  ListModel {
    id:idServerQModel
    ListElement {
      qname: "-"
      code:""
      state1:""
      desc1:""
      date1:""
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
    id:idCreateNewMainColumn
    spacing:10
    anchors.topMargin: 20
    anchors.rightMargin: 0
    anchors.bottomMargin: 50
    anchors.fill: parent

    Row
    {
      TextList
      {
        width: n4BtnWidth
        id:idTextSelected
        onClick: idTextInputQuizName.text = text
      }
      TextList
      {
        id:idDescTextOnPage
        text:"---"
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
          QuizLib.newQuiz()
        }
      }
      ButtonQuiz
      {
        text:"Rename"
        onClicked:
        {
          sQuizName = idTextInputQuizName.displayText
          glosModelIndex.setProperty(idQuizList.currentIndex,"quizname",sQuizName)
          db.transaction(
                function(tx) {
                  var nId = glosModelIndex.get(idQuizList.currentIndex).number;
                  console.log("name " + sQuizName)
                  tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[sQuizName, nId]);
                  idTextSelected.text = sQuizName
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
        id: idDownloadBtn
        text:"Download"
        onClicked:
        {
          bProgVisible = true
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
      id:idLangListRow
      anchors.horizontalCenter: parent.horizontalCenter
      //  width:parent.width
      height : nDlgHeight / 2

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

        width:n4BtnWidth
        height:parent.height + 2
        model: idLangModel
        delegate: TextListLarge {
          text:lang
          height : nBtnHeight / 2
          onClick: idLangList1.currentIndex = index
        }
      }

      TextListLarge
      {
        width:n4BtnWidth
        horizontalAlignment: Text.AlignLeft
        text:sLangLangSelected
      }

      ListViewHi
      {
        id:idLangList2
        width:n4BtnWidth
        height:parent.height + 2
        model: idLangModel
        onCurrentIndexChanged:
        {
          idLangListRow.doCurrentIndexChanged()
        }

        delegate: TextListLarge {
          text:lang
          height : nBtnHeight / 2
          onClick:idLangList2.currentIndex = index
        }
      }
    }

    TextList
    {
      id:idAvailableQuizText
      x:idQuizList.x
      height:nFontSize*4
      color: "steelblue"
      text:glosModelIndex.count + " Available Quiz's:"
    }

    ListViewHi
    {
      id:idQuizList
      width:nMainWidth
      anchors.horizontalCenter: parent.horizontalCenter
      height:parent.height - idAvailableQuizText.y
      model:glosModelIndex
      spacing:3

      Component.onCompleted: {
        MyDownloader.exportedSignal.connect(QuizLib.quizExported)
        MyDownloader.quizDownloadedSignal.connect(QuizLib.loadFromList)
        MyDownloader.quizListDownloadedSignal.connect(QuizLib.loadFromServerList)
        MyDownloader.deletedSignal.connect(QuizLib.quizDeleted)
        idWindow.quizListView = idQuizList
      }

      onCurrentIndexChanged:
      {
        if (nGlosaDbLastIndex >= 0)
          QuizLib.loadFromQuizList()
        else
          nGlosaDbLastIndex = 0;
      }

      delegate: Row {
        id:idQuizListRow
        TextListLarge
        {
          id:idCol2
          width:n25BtnWidth
          text:quizname
          onClick: idQuizList.currentIndex = index
        }
        TextListLarge
        {
          id:idCol3
          width:n4BtnWidth
          text:langpair
          onClick: idQuizList.currentIndex = index
        }
        TextListLarge
        {

          id:idCol4
          width:n4BtnWidth
          text:state1
          onClick: idQuizList.currentIndex = index
        }

        ButtonQuizImg
        {
          id:idCol5
          height:idCol4.height
          width:idCol4.height
          source: "qrc:rm.png"
          onClicked:
          {
            idDeleteConfirmationDlg.nIndex = index
            idDeleteConfirmationDlg.nNumber = number
            idDeleteConfirmationDlg.visible = true
          }
        }
      }
    }

    Component.onCompleted: {
      // idQuizList.currentIndex = nGlosaDbLastIndex
    }

  }

  RectRounded
  {
    id:idDeleteConfirmationDlg
    y:20
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    width:idDeleteText.width + 70
    height:nDlgHeight
    property int nIndex
    property int nNumber
    onCloseClicked:  idDeleteConfirmationDlg.visible = false

    WhiteText {
      id:idDeleteText
      anchors.top : idDeleteConfirmationDlg.bottomClose
      anchors.topMargin : 30
      x:30
      text:"Do You realy want to delete '" +sQuizName + "' ?"
    }

    ButtonQuiz
    {
      text: "Yes"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: parent.right
      anchors.rightMargin: 10
      onClicked:
      {
        db.transaction(
              function(tx) {
                tx.executeSql('DELETE FROM GlosaDbIndex WHERE dbnumber = ?',[idDeleteConfirmationDlg.nNumber]);
                tx.executeSql('DROP TABLE Glosa'+idDeleteConfirmationDlg.nNumber);
                tx.executeSql('DELETE FROM GlosaDbDesc WHERE dbnumber = ?',[idDeleteConfirmationDlg.nNumber]);
              }
              )

        glosModelIndex.remove(idDeleteConfirmationDlg.nIndex)
        if (idDeleteConfirmationDlg.nIndex ===idQuizList.currentIndex)
        {
          if (idDeleteConfirmationDlg.nIndex>0)
            idQuizList.currentIndex = idQuizList.currentIndex -1
        }

        idDeleteConfirmationDlg.visible = false
      }
    }
  }
  RectRounded
  {
    id:idExport
    y:20
    visible: false;
    width:parent.width
    height:nDlgHeight

    onCloseClicked:  idExport.visible = false

    WhiteText {
      id:idExportTitle
      x:20
      anchors.top : idExport.bottomClose
      text:"Add a description off the quiz '" +sQuizName + "'"
    }

    InputTextQuiz
    {
      id:idTextInputQuizDesc
      anchors.top :idExportTitle.bottom
    }

    WhiteText {
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
      id:idUpdateDescBtn
      text: "Update\nDescription"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idUpdateBtn.left
      anchors.rightMargin: 10
      onClicked:
      {
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
        idExport.visible = false
      }
    }
    ButtonQuiz
    {
      id:idUpdateBtn
      text: "Update"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idExportBtn.left
      anchors.rightMargin: 10
      onClicked:
      {
        bProgVisible = true
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
        MyDownloader.updateCurrentQuiz(glosModel, sQuizName,sLangLang, idTextInputQuizPwd.displayText, idTextInputQuizDesc.displayText )
      }
    }

    ButtonQuiz
    {
      id:idExportBtn
      text: "Upload"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: parent.right
      anchors.rightMargin: 10
      onClicked:
      {
        bProgVisible = true
        MyDownloader.exportCurrentQuiz( glosModel, sQuizName,sLangLang, idTextInputQuizPwd.displayText, idTextInputQuizDesc.displayText )
      }
    }
  }

  RectRounded
  {
    id:idImport
    y:20
    visible: false;
    width:parent.width
    height:nDlgHeightLarge
    onCloseClicked:  {
      idPwdDialog.visible = false;
      idDeleteQuiz.bProgVisible = false
      idImport.visible = false
      idPwdTextInput.text = ""
    }
    WhiteText
    {
      id:idDescText
      anchors.top :idImportTitle.bottom
      x:20
      text:"---"
    }

    WhiteText
    {
      id:idDescDate
      font.pointSize: 9
      anchors.top :idDescText.bottom
      x:20
      text:"-"
    }

    TextList {
      id:idImportMsg
      x:70
      y:25
      color:"red"
      text:""
    }

    WhiteText {
      id: idImportTitle
      x:20
      text:"Available Quiz's"
    }
    WhiteText {
      id: idNameLabel
      x:20
      y: idQuestionsLabel.y
      text:"Name"
    }

    WhiteText {
      id:idQuestionsLabel
      anchors.top :idDescDate.bottom
      anchors.right: parent.right
      anchors.rightMargin:30
      text:"Questions"
    }

    property string sSelectedQ
    ListViewHi
    {
      id:idServerListView
      anchors.top :idQuestionsLabel.bottom
      x:10
      width:idImport.width - 20
      height:parent.height - nBtnHeight  - idServerListView.y - idImport.y
      model: idServerQModel
      delegate: Item {
        property int nW : idServerListView.width / 6
        width:idServerListView.width
        height : idTextQname.height
        Row
        {
          WhiteText {
            width: nW *4
            id:idTextQname
            text:qname
            onClick:
            {
              idImportMsg.text = ""
              idDescText.text = desc1
              idDescDate.text = date1
              idImport.sSelectedQ = qname;
              idServerListView.currentIndex = index
            }
          }

          WhiteText
          {
            width:nW
            text:code
          }

          WhiteText
          {
            width:nW
            text:state1
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
      anchors.right: parent.right
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
      text: "Download"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idDeleteQuiz.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        sQuizName  = idImport.sSelectedQ
        MyDownloader.importQuiz(idImport.sSelectedQ)
      }
    }
  }
}

