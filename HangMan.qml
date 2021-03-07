import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0
import SvgDrawing 1.0


Item {
  id:idHangMan
  property string sHangWord : ""
  property bool bIsReverseHang : false
  property int nBtnWidthQuote : idTTrans.visible ? 3 : 1
  property int nUsedCharColLen : 8
  property variant sCurrentRow : []
  function newQ()
  {
    QuizLib.hangNewQ()
  }
  Component
  {
    id:idChar
    Rectangle
    {
      property alias text: idT.text
      color :bIsSpecial ? "white" : "grey"
      property bool bIsSpecial : false
      height: idT.font.pixelSize*1.3
      width:idT.font.pixelSize*1.3
      Text {
        id: idT
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn : parent
        font.pointSize: 25
      }
    }
  }

  Rectangle
  {
    id:idBackgroundRectangle
    anchors.fill: parent
    gradient:  "BlackSea"
    SvgDrawing
    {
      id: idDrawing
      anchors.fill: parent
      anchors.topMargin: 40
    }

    Row
    {
      id: idOrdRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing:20
      y : 10
    }

    Column
    {
      id: idOrdCol
      anchors.top: idOrdRow.bottom
      anchors.topMargin:20
      anchors.right: parent.right
      anchors.rightMargin:20
      spacing:20
    }
    Column
    {
      id: idOrdCol2
      anchors.top: idOrdRow.bottom
      anchors.topMargin:20
      anchors.right: idOrdCol.left
      anchors.rightMargin:20
      spacing:20
    }
    Column
    {
      id: idOrdCol3
      anchors.top: idOrdRow.bottom
      anchors.topMargin:20
      anchors.right: idOrdCol2.left
      anchors.rightMargin:20
      spacing:20
    }
    ButtonQuiz
    {
      id:idHangBtn
      width : n25BtnWidth
      anchors.centerIn: parent
      text:"Start"
      nButtonFontSize : 20
      onClicked:
      {
        idDrawing.renderId(1)
        QuizLib.hangAddWord()
        visible = !visible
      }
    }
    Image
    {
      id:idFlagImg
      visible: idHangBtn.visible
      anchors.top:idHangBtn.bottom
      anchors.topMargin: 20
      anchors.horizontalCenter: parent.horizontalCenter
    }
    MouseArea
    {
      anchors.fill: idFlagImg
      onClicked:
      {
        bIsReverseHang = !bIsReverseHang
        QuizLib.hangUpdateImage()
        if (!idHangBtn.visible)
          QuizLib.hangAddWord()
      }
    }

    Component
    {
      id:idCursorDelegate
      Rectangle
      {
        color:parent.focus ? "grey" : "#BDC3C7"
        anchors.fill: parent
      }
    }

    Rectangle
    {
      id:idCharRect
      anchors.top: idOrdRow.bottom
      anchors.topMargin:20
      x:20
      visible: !idHangBtn.visible
      height : idHangBtn2.height
      width :idHangBtn2.width
      property alias text: idT.text
      color :"#BDC3C7"
      TextInput
      {
        id: idTextInput
        color: "transparent"
        anchors.fill: parent
        cursorDelegate :idCursorDelegate
        onDisplayTextChanged:
        {
          if ( displayText.length < 1)
            return
          var inCh = displayText[displayText.length-1]
          if ( !/\s/.test(inCh))
            idCharRect.text = displayText[displayText.length-1].toUpperCase()

          idTextInput.text = " "
        }
      }
      Text {
        id: idT
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn : parent
        font.pointSize: 25
      }
    }

    ButtonQuiz
    {
      id:idHangBtn2
      y:idCharRect.y
      width : height
      anchors.left:idCharRect.right
      anchors.leftMargin:10
      visible: !idHangBtn.visible
      text:"Enter"
      onClicked: {
        QuizLib.hangEnterChar()
      }
    }


    Text {
      id: idTTrans
      visible:false
      anchors.left:  parent.left
      anchors.leftMargin: 50
      anchors.bottom:   parent.bottom
      anchors.bottomMargin: 20
      font.pointSize: 25
    }

    ButtonQuiz
    {
      id:idHangBtn5
      visible: !idHangBtn.visible
      width : n4BtnWidth / nBtnWidthQuote
      anchors.right:  idHangBtn4.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:idTTrans.visible ? "Tr" : "Translation"
      onClicked: {
        idTTrans.visible = !idTTrans.visible
      }
    }

    ButtonQuiz
    {
      id:idHangBtn4
      width : n4BtnWidth / nBtnWidthQuote
      visible: !idHangBtn.visible
      anchors.right:  idHangBtn3.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:idTTrans.visible ? "New" : "New Game"
      onClicked: {
        idDrawing.renderId(1)
        QuizLib.hangAddWord()
      }
    }

    ButtonQuiz
    {
      id:idHangBtn3
      width : n4BtnWidth / nBtnWidthQuote
      visible: !idHangBtn.visible
      property bool bAV : false
      anchors.right:  idSoundBtn.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:idTTrans.visible ? "An" : "Answer"
      onClicked: {
        bAV = !bAV
        idDrawing.answerShown();
        QuizLib.hangShowAnswer(bAV)
      }
    }


    ButtonQuizImgLarge
    {
      id:idSoundBtn
      visible: !idHangBtn.visible
      height : nBtnHeight
      width : nBtnHeight
      anchors.right:  parent.right
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      source:"qrc:horn.png"
      onClicked:
      {
        let sL = bIsReverseHang ? sToLang : sFromLang
        MyDownloader.playWord(sHangWord,sL)
      }
    }

    Timer {
      id:idResultMsgTimer
      interval: 600;
      repeat:true
      onTriggered: idResultMsg.visible = !idResultMsg.visible
    }

    Text {
      id: idResultMsg
      visible: false
      anchors.centerIn: parent
      color:"Tomato"
      font.family: "Kristen ITC"
      font.pixelSize:  idHangMan.width / 7
    }
  }

  Keys.onReturnPressed:
  {
    QuizLib.hangEnterChar()
  }

  Keys.onEnterPressed:
  {
    QuizLib.hangEnterChar()
  }

  RectRounded
  {
    id:idErrorDialogHangMan
    visible:false
    anchors.horizontalCenter: parent.horizontalCenter
    y:20
    height : nDlgHeight
    width:parent.width
    property alias text : idWhiteText.text

    WhiteText {
      id:idWhiteText
      x:20
      anchors.top : idErrorDialogHangMan.bottomClose
    }
    onCloseClicked:
    {
      idErrorDialogHangMan.visible = false
    }
  }
}

