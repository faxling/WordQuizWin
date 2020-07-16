import QtQuick 2.14
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item
{

  Rectangle
  {
    anchors.fill: parent
    gradient:  "GagarinView"
  }

  Column
  {
    id:idCreateNewMainColumn
    spacing:10
    anchors.topMargin: 20
    anchors.bottomMargin: 50
    anchors.fill: parent

    TextList
    {
      x:idDescText.x
      id:idDateDesc1
      text: idWindow.sQuizDate
    }

    Row
    {
      id:idDescText
      x:5
      spacing:20
      height: idTextInputQuizName.height
      TextListLarge
      {
        id:idTextSelected
        width: n4BtnWidth
        clip: true
        onClick: idTextInputQuizName.text = text + " "
      }
      TextListLarge
      {
        id:idDescTextOnPage
        text:idWindow.sQuizDesc
      }
    }

    InputTextQuiz
    {
      id:idTextInputQuizName
      cursorVisible : true
      placeholderText: "quiz name"
    }

    Row
    {
      id:rowCreateButtons
      spacing:9
      ButtonQuiz
      {
        text:"New Quiz"
        bIsPressedIn : idLangListRow.visible
        onClicked:
        {
          idLangListRow.visible = !idLangListRow.visible
        }
      }
      ButtonQuiz
      {
        text:"Rename"
        onClicked:
        {
          QuizLib.renameQuiz(idTextInputQuizName.displayText)
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
          idImport.showPane()
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
      visible: false
      anchors.horizontalCenter: parent.horizontalCenter
      //  width:parent.width
      height : nDlgHeight / 2

      spacing:20
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
          width:n4BtnWidth -10
          height : nBtnHeight / 2
          onClick: idLangList1.currentIndex = index
        }
      }

      Column
      {
        TextListLarge
        {
          width:n4BtnWidth
          horizontalAlignment: Text.AlignHCenter
          text:sLangLangSelected
        }
        ButtonQuiz
        {
          width: n4BtnWidth
          text: "Create"
          onClicked:  QuizLib.newQuiz()
        }
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
          horizontalAlignment: Text.AlignRight
          text:lang
          height : nBtnHeight / 2
          width: idLangList2.width - 10
          onClick:idLangList2.currentIndex = index
        }

      }
    }

    TextListLarge
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
      width:nMainWidth - 20
      x:10
      height:parent.height - idAvailableQuizText.y -20
      model:glosModelIndex
      spacing:3

      Component.onCompleted: {
        QuizLib.connectMyDownloader()
      }

      onCurrentIndexChanged:
      {
        if (nGlosaDbLastIndex >= 0)
          QuizLib.loadFromQuizList()
        else
          nGlosaDbLastIndex = 0;
      }

      delegate:Item
      {
        width : n25BtnWidth + n4BtnWidth*2 - 5
        height : idCol2.height
        id:idQuizListRow
        Row {
          TextListLarge
          {
            id:idCol2
            width:n25BtnWidth
            text:quizname
          }

          TextListLarge
          {
            id:idCol3
            width:n4BtnWidth
            text:langpair
            // onClick: idQuizList.currentIndex = index
          }

          TextListLarge
          {
            id:idCol4
            width:n4BtnWidth
            text:state1
            //   onClick: idQuizList.currentIndex = index
          }

          ButtonQuizImg
          {
            id:idCol5
            height:idCol4.height
            width:idCol4.height
            source: "qrc:rm.png"
            onClicked:
            {
              idDeleteConfirmationDlg.sQuizToDelete = quizname
              idDeleteConfirmationDlg.nIndex = index
              idDeleteConfirmationDlg.nNumber = number
              idDeleteConfirmationDlg.visible = true
            }
          }
        }
        MouseArea
        {
          anchors.fill:idQuizListRow
          onClicked: {
            idQuizList.currentIndex = index
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
    property string sQuizToDelete
    onCloseClicked:  idDeleteConfirmationDlg.visible = false

    WhiteText {
      id:idDeleteText
      anchors.top : idDeleteConfirmationDlg.bottomClose
      anchors.topMargin : 30
      x:30
      text:"Do You realy want to delete '" +idDeleteConfirmationDlg.sQuizToDelete + "' ?"
    }

    ButtonQuiz
    {
      text: "Yes"
      width:idDeleteText.contentWidth
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
        //if (idDeleteConfirmationDlg.nIndex === idQuizList.currentIndex)
        //{
        //if (idDeleteConfirmationDlg.nIndex>0)
        //  idQuizList.currentIndex = idQuizList.currentIndex -1
        // }

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
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
        MyDownloader.exportCurrentQuiz( glosModel, sQuizName,sLangLang, idTextInputQuizPwd.displayText, idTextInputQuizDesc.displayText )
      }
    }
  }
  clip: true

  DownLoad
  {
    id:idImport
    //   anchors.fill: parent
    width:parent.width
    height: parent.height
    onStateChanged:{
      idWindow.bDownloadNotVisible = (state === "")
    }
  }

  RectRounded
  {
    id:idErrorDialog
    visible:false
    anchors.horizontalCenter: parent.horizontalCenter
    y:20
    height : nDlgHeight
    radius:7
    width:idImport.width
    property alias text : idWhiteText.text

    WhiteText {
      id:idWhiteText
      x:20
      anchors.top : idErrorDialog.bottomClose

    }
    onCloseClicked:
    {
      idErrorDialog.visible = false
    }
  }

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
}

