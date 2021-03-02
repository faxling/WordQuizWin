import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0
import SvgDrawing 1.0


Item {
  id:idHangMan
  property string sHangWord : ""
  property int nQID: 0
  property bool bIsReverseHang : false


  function updateImage()
  {
    const n = idLangModel.count
    let sL = bIsReverseHang ? sToLang : sFromLang
    for (let i = 0 ; i < n ; ++i)
    {
      if (idLangModel.get(i).code === sL)
      {
        idFlagImg.source = idLangModel.get(i).imgsource
        break;
      }
    }
  }

  function newQ()
  {
    if (idWindow.nDbNumber === nQID)
      return
    idGameOver.visible = false
    idGameOverTimer.stop()
    bIsReverseHang = false
    nQID = idWindow.nDbNumber
    idOrdRow.children = []
    idOrdCol.children = []
    idDrawing.renderId(1)
    updateImage()
    idCharRect.text = ""
    idHangBtn.visible = true
  }
  function addWord()
  {
    idGameOver.visible = false
    idGameOverTimer.stop()
    idOrdRow.children = []
    idOrdCol.children = []
    idOrdCol2.children = []
    let n = 0
    let i = 0
    let nIndexOfNewWord = 0
    for ( i = 0 ; i < 10; ++i)
    {
      nIndexOfNewWord = Math.floor(MyDownloader.rand() * glosModel.count)

      if (bIsReverseHang)
      {
        sHangWord = glosModel.get(nIndexOfNewWord).answer
        idTTrans.text = glosModel.get(nIndexOfNewWord).question
      }
      else
      {
        sHangWord = glosModel.get(nIndexOfNewWord).question
        idTTrans.text = glosModel.get(nIndexOfNewWord).answer
      }

      sHangWord = sHangWord.toUpperCase()
      n = sHangWord.length
      if (n < 10)
        break
    }

    if (n === 10)
    {
      idErrorDialogHangMan.text = "Create or Select a Word List that contains short words!"
      idErrorDialogHangMan.visible = true
      return;
    }

    for (i = 0; i < n; ++i)
    {
      const ch = sHangWord[i]
      if (MyDownloader.isSpecial(ch))
        idChar.createObject(idOrdRow, {text : ch , bIsSpecial:true })
      else
        idChar.createObject(idOrdRow)
    }
    idWindow.nGlosaTakeQuizIndex = nIndexOfNewWord;

  }

  function checkChar(sChar)
  {
    let n = idOrdCol2.children.length
    let i
    for ( i = 0; i < n; ++i)
    {
      if (MyDownloader.ignoreAccent(idOrdCol2.children[i].text) === MyDownloader.ignoreAccent(sChar))
        return true
    }
    n = idOrdCol.children.length
    for (i = 0; i < n; ++i)
    {
      if (MyDownloader.ignoreAccent(idOrdCol.children[i].text) === MyDownloader.ignoreAccent(sChar))
        return true
    }
    return false
  }

  function enterChar()
  {
    Qt.inputMethod.hide()
    let n = sHangWord.length
    let nValidCount = 0
    let nOKCount = 0
    let nC = 0
    var i = 0
    for (i = 0; i < n; ++i)
    {
      if (idOrdRow.children[i].bIsSpecial)
        continue

      ++nValidCount

      if (MyDownloader.ignoreAccent(sHangWord[i]) === MyDownloader.ignoreAccent(idCharRect.text[0]))
      {
        nC+=1
        idOrdRow.children[i].text = sHangWord[i]
      }

      if (idOrdRow.children[i].text !== "")
        nOKCount += 1
    }

    if (nOKCount === nValidCount)
    {
      idDrawing.renderId(0)
      return
    }

    if (nC === 0)
    {
      let n = idOrdCol.children.length

      if (n < 10)
      {
        if (checkChar(idCharRect.text))
          return
        idChar.createObject(idOrdCol, {text: idCharRect.text})
      }
      else
      {
        if (checkChar(idCharRect.text))
          return
        idChar.createObject(idOrdCol2, {text: idCharRect.text})
      }

      let bRet = idDrawing.renderId(2)

      console.log("bRet " + bRet)
      if (!bRet)
      {
        idGameOver.visible = true
        idGameOverTimer.start()
      }
    }
  }

  function showAnswer(bAV)
  {
    let n = idOrdRow.children.count
    if (bAV === false)
    {
      for (let i = 0; i < n; ++i)
        idOrdRow.children[i].text = sHangWord[i]
    }
    else
    {
      for (let i = 0; i < n; ++i)
        idOrdRow.children[i].text =  ""
    }
  }

  Component
  {
    id:idChar
    Rectangle
    {
      property alias text: idT.text
      color :bIsSpecial ? "white" : "grey"
      property bool bIsSpecial : false
      height: 40
      width:40
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
    anchors.fill: parent

    // sy : 15
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
      anchors.right: parent.right
      anchors.rightMargin:20
      spacing:20
    }
    Column
    {
      id: idOrdCol2
      anchors.top: idOrdRow.bottom
      anchors.right: idOrdCol.left
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
        addWord()
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
        updateImage()
        if (!idHangBtn.visible)
          addWord()
      }
    }

    Component.onCompleted:
    {

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
      color :"grey"
      Text {
        id: idT
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn : parent
        font.pointSize: 25
      }


      TextInput
      {
        id: idTextInput
        anchors.fill: parent
        onDisplayTextChanged:
        {
          if ( displayText.length < 1)
            return
          idCharRect.text = displayText[0].toUpperCase()
          idTextInput.text = ""
        }

      }

    }

    ButtonQuiz
    {
      id:idHangBtn2
      y:idCharRect.y
      anchors.left:idCharRect.right
      anchors.leftMargin:10
      visible: !idHangBtn.visible
      text:"Enter"
      width: 50
      onClicked: {
        enterChar()
      }
    }
    ButtonQuiz
    {
      id:idHangBtn5
      visible: !idHangBtn.visible
      anchors.right:  idHangBtn4.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:"Trans"
      width: 50
      onClicked: {
        idTTrans.visible = !idTTrans.visible
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
      id:idHangBtn4
      visible: !idHangBtn.visible
      anchors.right:  idHangBtn3.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:"Again"
      width: 50
      onClicked: {
        idDrawing.renderId(1)
        addWord()
        idCharRect.text = ""
      }
    }

    ButtonQuiz
    {
      id:idHangBtn3
      visible: !idHangBtn.visible
      property bool bAV : false
      anchors.right:  idSoundBtn.left
      anchors.rightMargin:  20
      anchors.bottom: parent.bottom
      anchors.bottomMargin:  20
      text:"Answer"
      width: 50
      onClicked: {
        showAnswer(bAV)
        bAV = !bAV
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
      id:idGameOverTimer
      interval: 1000;
      repeat:true
      onTriggered: idGameOver.visible = !idGameOver.visible
    }

    Text {
      id: idGameOver
      visible: false
      anchors.centerIn: parent
      color:"red"
      text: "Game Over!"
      font.family: "Kristen ITC"
      font.pixelSize:  idHangMan.width / 7
    }

  }

  Keys.onReturnPressed:
  {
    enterChar()
  }

  Keys.onEnterPressed:
  {
    enterChar()
  }

  RectRounded
  {
    id:idErrorDialogHangMan
    visible:false
    anchors.horizontalCenter: parent.horizontalCenter
    y:20
    height : nDlgHeight
    radius:7
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

