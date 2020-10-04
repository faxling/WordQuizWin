import QtQuick 2.5
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

    Row
    {


      Item {
        height: idTextInput.height
        width:  idEditQuiz.width / 2

        TextListLarge {
          id: idTextTrans
          Component.onCompleted: MyDownloader.storeTransText(idTextTrans, idErrorText)
        //  height: idTextInput.height
        //  width:  idEditQuiz.width / 2
          text: "-"
          onTextChanged:  QuizLib.assignTextInputField(idTextTrans.text)
          onClick: {
            QuizLib.assignTextInputField(idTextTrans.text)
          }
        }

        ButtonQuizImg {
          id: idBtnClear
          anchors.right: parent.right
          anchors.rightMargin: 10
          height: nBtnHeight / 2
          width: nBtnHeight / 2
          source: "qrc:quit.png"
          onClicked: {
            idTextInput.text = "-"
            idTextInput.text = ""
          }
        }

      }
      Item {
        height: idTextInput.height
        width:  idEditQuiz.width / 2
        ButtonQuizImg {
          id : idShiftBtn
          x: 10
          height: nBtnHeight / 2
          width: nBtnHeight / 2
          source: "qrc:lr_svg.svg"
          onClicked:
          {
            var sT = idTextInput.displayText
            idTextInput.text = idTextInput2.displayText
            idTextInput2.text = sT
          }
        }

        ButtonQuizImg {
          id: idBtnClear2
          anchors.right: parent.right
          anchors.rightMargin: 5
          height: nBtnHeight / 2
          width: nBtnHeight / 2
          source: "qrc:quit.png"
          onClicked: {
            onClicked: {
              idTextInput2.text = "-"
              idTextInput2.text = ""
            }
          }
        }
      }

    }
    TextMetrics {
      id:     t_metrics
      font: idTextTrans.font
      text:    "-"
    }

    Row {
      id: idIextInputToDictRow
      spacing: 20
      x:5
      InputTextQuiz {
        id: idTextInput
        cursorVisible: true
        onCursorVisibleChanged:
        {
          if (cursorVisible)
            bDoLookUppText1 = true
        }
        width: idEditQuiz.width / 2 - 15
        placeholderText:"text to translate"
      }

      InputTextQuiz {
        id: idTextInput2
        onCursorVisibleChanged:
        {
          if (cursorVisible)
            bDoLookUppText1 = false
        }
        width: idEditQuiz.width / 2 - 15
        placeholderText:"translation"
      }
    }

    Row {
      id: idDictBtnRow
      spacing: 9

      ButtonQuiz {
        id: idBtn1
        text: "Find " + sLangLang
        onClicked: {
          QuizLib.reqTranslation(idBtn1, false)
        }
      }

      ButtonQuiz {
        id: idBtn2
        text: "Find " + sLangLangRev
        onClicked: {
          QuizLib.reqTranslation(idBtn2, true)
        }
      }

      ButtonQuiz {
        id: idBtn3
        text: (bDoLookUppText1 ? sFromLang : sToLang) + " Wiktionary"
        onClicked: {
          QuizLib.lookUppInWiki()
        }
      }

      ButtonQuiz {
        text: "Add"
        onClicked: QuizLib.getTextInputAndAdd()
      }

    }
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

    Row {
      id: idDictionaryResultRow
      height: t_metrics.boundingRect.height*3
      width: parent.width - 100

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
      height : idHeader1Text.height
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
          source: "qrc:horn.png"
          onClicked: MyDownloader.playWord(question, sFromLang)
        }

        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          source: "qrc:horn.png"
          onClicked: MyDownloader.playWord(answer, sToLang)
        }
      }
    }

    Row {
      id: idLowerBtnRow
      x: 5
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
      id : idGlosStateLabel
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.left: idEditWordImage.right
      anchors.leftMargin: 20
      color: "white"
      text: "Done:"
    }

    CheckBox {
      id: idGlosState
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.left: idGlosStateLabel.right
      anchors.rightMargin: 20
    }


    ButtonQuiz {
      id: idBtnImg
      width: n5BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 5
      anchors.right: idBtnUpdate.left
      anchors.rightMargin: 20
      text: "Image"
      onClicked: {
        if (typeof MyImagePicker === "undefined")
        {
          idImagePick.visible = true
        }
        else
        {
          MyImagePicker.pickImage(idTextEdit1.text, sFromLang,
                                  idTextEdit2.text, sToLang)
        }

      }
    }

    ButtonQuiz {
      id: idBtnUpdate
      width: n5BtnWidth
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
      width: n5BtnWidth
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
        console.log("MyDownloader.downloadImage")
        MyDownloader.downloadImage(drop.urls, idTextEdit1.text, sFromLang,
                                   idTextEdit2.text, sToLang, true)
      }
    }
  }

  RectRounded
  {
    id:idImagePick
    visible:false
    color: "#303030"
    anchors.horizontalCenter: parent.horizontalCenter
    y:40
    height : nDlgHeight / 2
    radius:7
    width:parent.width/2

    WhiteText {
      id:idWhiteText
      text : "Use Drag and Drop for images"
      x:20
      anchors.top : idImagePick.bottomClose
    }
    onCloseClicked:
    {
      idImagePick.visible = false
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

}
