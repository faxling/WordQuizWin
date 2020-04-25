import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0 as Sql
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item {
  id: idEditQuiz
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
      InputTextQuiz {
        width: idEditQuiz.width / 2 - 15
        text: ""
        id: idTextInput
      }
      InputTextQuiz {
        width: idEditQuiz.width / 2 - 15
        text: ""
        id: idTextInput2
      }
    }

    Row {
      id: idDictBtnRow
      spacing: 10

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
        text: "Find " + sLangLangEn
        onClicked: {
          nLastSearch = 2
          var oInText = QuizLib.getTextFromInput(idTextInput)
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrlEn, oInText)

          idTranslateModel.oBtn = idBtn3
          idTranslateModel.source = sReqUrlBase + sLangLangEn + "&text=" + oInText
        }
      }

      ButtonQuiz {
        text: "Add"
        onClicked: {

          // Find a new Id
          var nC = 0
          for (var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number
          }

          nC += 1
          QuizLib.insertGlosa(nDbNumber, nC, idTextInput.displayText,
                              idTextInput2.displayText)

          if (bHasSpeech)
            MyDownloader.downloadWord(idTextInput2.displayText, sToLang)
        }
      }
    }

    Row {
      id: idDictionaryResultRow
      height: 100
      width: parent.width - 100

      TextList {
        id: idErrorText
        visible: false
        color: "red"
        font.pointSize: 16
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
        delegate: TextListLarge {
          id: idSynText
          text: syn
          MouseArea {
            anchors.fill: parent
            onClicked: QuizLib.assignTextInputField(idSynText.text)
          }
        }
      }
      ListView {
        model: idTrMeanModel
        width: parent.width / 3
        height: parent.height
        delegate: TextListLarge {
          id: idMeanText
          text: mean
          onClick: {
            QuizLib.assignTextInputField(idMeanText.text)
          }
        }
      }
    }

    Row {
      id: idTableHeaderRow
      spacing: 5
      //  height : idHeader1Text.height
      TextList {
        id: idHeader1Text
        color: "steelblue"
        font.bold: bQSort
        width: (idGlosList.width / 2) - 50
        text: "Question"
        onClick: {
          bQSort = true
          QuizLib.sortModel()
        }
      }

      TextList {
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
      clip: true
      width: idEditQuiz.width - 20
      height: parent.height - idTableHeaderRow.y - nBtnHeight
      spacing: 3
      Component.onCompleted: {
        idWindow.glosListView = idGlosList
      }

      model: glosModel
      delegate: Row {
        spacing: 5

        TextList {
          id: idQuestion
          width: (idGlosList.width / 2) - 50
          text: question
          color: state1 === 0 ? "black" : "green"
          onClick: idTextInput.text = question
          onPressAndHold: idTextInput.text = question
        }

        TextList {
          id: idAnswer
          width: idQuestion.width
          text: answer
          font.bold: extra.length > 0
          color: state1 === 0 ? "black" : "green"
          onClick: idTextInput2.text = answer
          onPressAndHold: idTextInput2.text = answer
        }

        ButtonQuizImg {
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
}
