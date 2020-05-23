import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0 as Sql
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item {
  id: idEditQuiz
  property bool bDoLookUppText1 : true

  Rectangle
  {
    anchors.fill: parent
    gradient:"MorningSalad"
  }

  property int nLastSearch: 0
  onVisibleChanged: {
    if (visible) {
      idGlosList.currentIndex = idWindow.nGlosaTakeQuizIndex
      idGlosList.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                     ListView.Center)
    }
  }

  Column {
    id: idGlosListMainColumn
    spacing: 10
    anchors.topMargin: 20
    anchors.bottomMargin: 50
    anchors.fill: parent

    TextListLarge {
      id: idTextTrans
      height: idTextInput.height
      width: parent.width
      text: "-"
      onClick: {
        QuizLib.assignTextInputField(idTextTrans.text)
      }
    }

    Row {
      id: idIextInputToDictRow
      spacing: 20
      x:5
      InputTextQuiz {
        cursorVisible: true
        onCursorVisibleChanged:
        {
          if (cursorVisible)
            bDoLookUppText1 = true
        }
        width: idEditQuiz.width / 2 - 15
        placeholderText:"text to translate"
        id: idTextInput
      }
      InputTextQuiz {
        onCursorVisibleChanged:
        {
          if (cursorVisible)
            bDoLookUppText1 = false
        }
        width: idEditQuiz.width / 2 - 15
        placeholderText:"translation"
        id: idTextInput2
      }
    }

    Row {
      id: idDictBtnRow
      spacing: 9

      ButtonQuiz {
        id: idBtn1
        text: "Find " + sLangLang
        onClicked: {
          nLastSearch = 0
          var oInText = QuizLib.getTextFromInput(idTextInput)
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrl, oInText)

          idTranslateModel.oBtn = idBtn1
          idTranslateModel.source = sReqUrl + oInText
        }
      }

      ButtonQuiz {
        id: idBtn2
        text: "Find " + sLangLangRev
        onClicked: {
          nLastSearch = 1
          var oInText = QuizLib.getTextFromInput(idTextInput2)
          if (bHasDictFrom)
            QuizLib.downloadDictOnWord(sReqDictUrlRev, oInText)

          idTranslateModel.oBtn = idBtn2
          idTranslateModel.source = sReqUrlBase + sLangLangRev + "&text=" + oInText
        }
      }

      ButtonQuiz {
        id: idBtn3
        text: (bDoLookUppText1 ? sQuestionLang : sAnswerLang) + " Wiktionary"
        onClicked: {
          var oInText
          var sLang = bDoLookUppText1 ? sQuestionLang : sAnswerLang

          if (bDoLookUppText1)
            oInText   = QuizLib.getTextFromInput(idTextInput)
          else
            oInText   = QuizLib.getTextFromInput(idTextInput2)

          onClicked: Qt.openUrlExternally("http://"+sLang+ ".wiktionary.org/w/index.php?title=" +oInText.toLowerCase()  + "&printable=yes" );
        }
      }

      ButtonQuiz {
        text: "Add"
        onClicked: QuizLib.getTextInputAndAdd()
      }

    }

    Row {
      id: idDictionaryResultRow
      height: 100
      width: parent.width - 100
      TextList {
        id: idErrorText
        visible: false
        font.pointSize: 16
        color: "red"
        onClick: visible = false
      }
      TextList {
        id: idErrorText2
        visible: false
        font.pointSize: 16
        color: "red"
        onClick: visible = false
      }

      ListViewHi {
        id: idDicList
        width: parent.width / 2
        height: parent.height
        model: idTrTextModel
        highlightFollowsCurrentItem: true

        delegate: Row {

          TextListLarge {
            id: idSearchItem
            width: idDicList.width
            text: text1 + " " + (count1 > 0 ? "..." : "")
            MouseArea {
              anchors.fill: parent
              onClicked: {
                idDicList.currentIndex = index
                var sText = idSearchItem.text.replace("...", "")
                QuizLib.assignTextInputField(sText)
                idTrSynModel.query = "/DicResult/def/tr[" + (index + 1) + "]/syn"
                idTrMeanModel.query = "/DicResult/def/tr[" + (index + 1) + "]/mean"
              }
            }
          }
        }
      }
      ListView {
        model: idTrSynModel
        width: parent.width / 3
        height: parent.height
        clip:true
        delegate: TextListLarge {
          id: idSynText
          text: syn
          MouseArea {
            anchors.fill: parent
            onClicked: QuizLib.assignTextInputField(idSynText.text)
          }
        }
        ScrollBar.vertical: ScrollBar {}
      }
      ListView {
        model: idTrMeanModel
        width: parent.width / 3
        height: parent.height
        clip:true
        delegate: TextListLarge {
          id: idMeanText
          text: mean
          onClick: {
            QuizLib.assignTextInputField(idMeanText.text)
          }
        }
      }
    }


    //  height : idHeader1Text.height
    Row
    {
      x:10
      id: idHeaderRow
      height : idHeader1Text.height*2
      TextList {
        id: idHeader1Text
        color: "steelblue"
        font.bold: bQSort
        text: "Question"
        onClick: {
          bQSort = true
          QuizLib.sortModel()
        }
      }

      TextList {
        id: idHeader2Text
        color: "steelblue"
        font.bold: !bQSort
        width: n25BtnWidth
        text: "Answer"
        onClick: {
          bQSort = false
          QuizLib.sortModel()
        }
      }
    }

    ListViewHi {
      id: idGlosList
      x:10

      width: idEditQuiz.width
      height: parent.height - idHeaderRow.y - idHeaderRow.height - 55
      spacing: 3
      Component.onCompleted: {
        idWindow.glosListView = idGlosList
      }

      model: glosModel
      delegate: Row {
        id :idRowRow
        spacing: 5

        TextList {
          id: idQuestion
          width: (idGlosList.width / 2) - (idEditBtn.width * 1.5) - 20
          text: question
          color: state1 === 0 ? "black" : "green"
          onClick:
          {
            idTextInput.text = question + " "
            bDoLookUppText1 = true
          }

        }

        TextList {
          id: idAnswer
          onXChanged: idHeader1Text.width = x
          width: idQuestion.width
          text: answer
          font.bold: extra.length > 0
          color: state1 === 0 ? "black" : "green"
          onClick: {
            idTextInput2.text = answer + " "
            bDoLookUppText1 = false
          }
        }

        ButtonQuizImg {
          id : idEditBtn
          height: idAnswer.height
          width: idAnswer.height
          //    y:-5
          source: "qrc:edit.png"
          onClicked: {
            idEditDlg.visible = true
            idTextEdit1.text = question
            idTextEdit2.text = answer
            idTextEdit3.text = extra
            idEditWordImage.visible = MyDownloader.hasImage(idTextEdit1.text,
                                                            sFromLang)
            idEditWordImage.source = idEditWordImage.visible ? MyDownloader.imageSrc(
                                                                 idTextEdit1.text,
                                                                 sFromLang) : ""
            idGlosState.checked = state1 !== 0
            idGlosList.currentIndex = index
          }
        }

        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          visible: bHasSpeech
          source: "qrc:horn.png"
          onClicked: MyDownloader.playWord(question, sFromLang)
        }

        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          visible: bHasSpeech
          source: "qrc:horn.png"
          onClicked: MyDownloader.playWord(answer, sToLang)
        }
      }
    }

    Row {
      x: 5
      id: idLowerBtnRow
      spacing: 10
      ButtonQuiz {
        width: n2BtnWidth
        text: "Reset"
        onClicked: {
          QuizLib.resetQuiz()
        }
      }

      ButtonQuiz {
        text: "Reverse"
        width: n2BtnWidth
        onClicked: {
          QuizLib.reverseQuiz()
        }
      }


      /*
      ButtonQuiz
      {
        text : "Download\nAudio"
        width:n3BtnWidth
        onClicked:
        {
          MyDownloader.downLoadAllSpeech(glosModel, sLangLang);
        }
      }
      */
    }
  }

  RectRounded {
    id: idEditDlg
    visible: false
    width: parent.width
    height: nDlgHeight
    onCloseClicked: idEditDlg.visible = false

    Column {
      x: 20
      anchors.top: idEditDlg.bottomClose
      anchors.topMargin: 10
      spacing: 20
      Row {
        spacing: 20
        width: idEditDlg.width - 40
        height: idTextEdit3.height

        Label {
          color: "white"
          id: idAddInfo
          text: "Additional Info"
        }

        InputTextQuiz {
          id: idTextEdit3
          width: parent.width - idAddInfo.width - 20
        }
      }

      Row {
        spacing: 20
        width: idEditDlg.width
        height: idTextEdit3.height
        InputTextQuiz {
          id: idTextEdit1
          width: idEditDlg.width / 2 - 30
        }
        InputTextQuiz {
          id: idTextEdit2
          width: idEditDlg.width / 2 - 30
        }
      }
    }

    Image {
      id: idEditWordImage
      cache: false
      fillMode: Image.PreserveAspectFit
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 5
      height: 64
      width: 64
    }
    Label {
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idGlosState.left
      anchors.rightMargin: 20
      color: "white"
      text: "Done:"
    }
    CheckBox {
      id: idGlosState
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idBtnUpdate.left
      anchors.rightMargin: 20
    }

    ButtonQuiz {
      id: idBtnUpdate
      width: n3BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: idBtnDelete.left
      anchors.rightMargin: 20
      text: "Update"
      onClicked: {
        QuizLib.updateQuiz()
        idGlosList.positionViewAtIndex(idGlosList.currentIndex, ListView.Center)
      }
    }
    ButtonQuiz {
      id: idBtnDelete
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: parent.right
      anchors.rightMargin: 20
      width: n3BtnWidth
      text: "Delete"
      onClicked: {
        QuizLib.deleteWordInQuiz()
      }
    }

    function imgDownloaded() {
      idEditWordImage.visible = true
      idEditWordImage.source = ""
      idEditWordImage.source = MyDownloader.imageSrc(idTextEdit1.text,
                                                     sFromLang)
    }

    DropArea {
      Component.onCompleted: {
        MyDownloader.downloadedImgSignal.connect(idEditDlg.imgDownloaded)
      }
      anchors.fill: parent
      onDropped: {
        MyDownloader.downloadImage(drop.urls, idTextEdit1.text, sFromLang,
                                   idTextEdit2.text, sToLang, true)
      }
    }
  }


  XmlListModel {
    id: idTrTextModel
    onStatusChanged: {
      if (status === XmlListModel.Ready) {
        if (idTrTextModel.count <= 0) {
          idTextTrans.text = "-"
          return
        }

        QuizLib.assignTextInputField(idTrTextModel.get(0).text1)

        idTrSynModel.query = "/DicResult/def/tr[1]/syn"
        idTrMeanModel.query = "/DicResult/def/tr[1]/mean"
      }
    }

    query: "/DicResult/def/tr"
    XmlRole {
      name: "count1"
      query: "count(syn)"
    }
    XmlRole {
      name: "text1"
      query: "text/string()"
    }
  }

  XmlListModel {
    id: idTrSynModel
    XmlRole {
      name: "syn"
      query: "text/string()"
    }
  }

  XmlListModel {
    id: idTrMeanModel
    XmlRole {
      name: "mean"
      query: "text/string()"
    }
  }

  XmlListModel {
    id: idTranslateModel
    property var oBtn
    query: "/Translation"
    XmlRole {
      name: "trans"
      query: "text/string()"
    }
    onStatusChanged: {
      if (status === XmlListModel.Ready) {
        if (idTranslateModel.count <= 0) {
          idTextTrans.text = "-"
          return
        }
        idTextTrans.text = idTranslateModel.get(0).trans
      }
    }
  }

}
