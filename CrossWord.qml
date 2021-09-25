import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0

Rectangle {
  id:idCrossWord
  clip:true
  gradient:  "NearMoon"
  property int nW : 0
  enum SquareType {
    Char,
    Blank,
    Question,
    Space,
    Done
  }

  function loadCW()
  {
    console.log("loadCW")
    idCrossWordGrid.children = null

    CrossWordQ.createCrossWordFromList(glosModel)

    idCrossWordGrid.columns = CrossWordQ.nW
    let nCount = CrossWordQ.nW * CrossWordQ.nH
    for (let i = 0; i < nCount; ++i)
      idChar.createObject(idCrossWordGrid)

    function addQ(nIndex, nHorizontal, nVertical)
    {
      const o = idCrossWordGrid.children[nIndex]
      o.eSquareType = CrossWord.SquareType.Question
      if (nHorizontal !== -1)
        o.text = glosModel.get(nHorizontal).question

      if (nHorizontal !== -1 && nVertical !== -1)
        o.text += "\n\n"

      if (nVertical !== -1)
        o.text += glosModel.get(nVertical).question

    }
    function addCh(nIndex, vVal)
    {
      const o = idCrossWordGrid.children[nIndex]
      if (vVal === " ")
        o.eSquareType = CrossWord.SquareType.Space
      else
      {
        o.eSquareType = CrossWord.SquareType.Char
        o.textA = vVal
      }
    }
    CrossWordQ.assignQuestionSquares(addQ)
    CrossWordQ.assignCharSquares(addCh)
  }


  Component
  {
    id:idChar
    Rectangle
    {
      id: idCharRect
      Component.onCompleted:
      {
        if (nW ===0 )
          nW = idT.font.pixelSize*1.3
        idCharRect.height = nW
        idCharRect.width = nW
      }

      property int eSquareType : CrossWord.SquareType.Blank
      property alias text: idT.text
      property string textA
      color : {
        switch (eSquareType)
        {
        case CrossWord.SquareType.Blank:
          return "grey"
        case CrossWord.SquareType.Char:
          return "white"
        case CrossWord.SquareType.Space:
          return "#feffcc"
        case CrossWord.SquareType.Question:
          return "#e2f087"
        case CrossWord.SquareType.Done:
          return "#71ff96"
        }
      }

      function isQ()
      {
        return (eSquareType ===  CrossWord.SquareType.Question)
      }

      Text {
        id: idT
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill:   parent
        wrapMode: Text.WrapAnywhere
        font.pointSize: isQ() ? 4 : 20
      }
      TextMetrics
      {
        id: fontMetrics
        font.pointSize:20
      }

      MouseArea
      {
        anchors.fill: parent
        onPressed: {
          if (idCharRect.eSquareType === CrossWord.SquareType.Question)
          {
            if (idInfoBox.visible === true && idInfoBox.parent === idCharRect)
            {
              idInfoBox.visible = false
              return
            }

            idInfoBox.parent = idCharRect
            idInfoBox.show(idT.text)

            var sss = idT.text.split("\n\n")

            console.log("ss " + sss.length)
            if (sss.length > 1)
            {
              if (sss[0].length >  sss[1].length)
                fontMetrics.text = sss[0]
              else
                fontMetrics.text = sss[1]
            }
            else
              fontMetrics.text = idT.text
            fontMetrics.text+= "X"

            idInfoBox.width = fontMetrics.width

          }
          else if (idCharRect.eSquareType === CrossWord.SquareType.Char ||
                   idCharRect.eSquareType === CrossWord.SquareType.Done)
          {
            idInfoBox.hide()
            idInputBox.visible = true
            idInputBox.t.text = idCharRect.text
            idInputBox.parent = idCharRect
            idInputBox.t.forceActiveFocus()
          }

          // idInfoBox.x = idCharRect.x + idCrossWordGrid.x- idInfoBox.width / 2
          //  idInfoBox.y = idCharRect.y + idCrossWordGrid.y- idInfoBox.height
        }
      }
    }
  }

  Grid
  {
    id: idCrossWordGrid
    spacing: 2
    anchors.centerIn: parent
  }

  ToolTip
  {
    id: idInfoBox
    font.pointSize: 20
    visible:false
  }

  Popup
  {
    id: idInputBox
    property alias t :  idTextInput
    TextInput
    {
      id: idTextInput
      font.pointSize: 20
      // color: "transparent"
      anchors.fill: parent
      font.capitalization: Font.AllUppercase

      onAccepted:
      {
        idInputBox.parent.text = text.toUpperCase().charAt(0)
        if (idInputBox.parent.text === idInputBox.parent.textA)
          idInputBox.parent.eSquareType = CrossWord.SquareType.Done

      }
      onEditingFinished:
      {
        idInputBox.parent.text = text.toUpperCase().charAt(0)
        idInputBox.visible = false
        if (idInputBox.parent.text === idInputBox.parent.textA)
          idInputBox.parent.eSquareType = CrossWord.SquareType.Done
      }

    }
  }

  /*
  RectRounded
  {
    id: idInfoBox
    visible:false
    property alias text : idText.text
    onCloseClicked:  idInfoBox.visible = false

    WhiteText {
      id:idText
      x:20
      font.pointSize: 20
      anchors.top : idInfoBox.bottomClose
    }

    width:nDlgHeight
    height:nW*3
    bIgnoreBackHandling : true
    Text {
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      anchors.fill:   parent
      wrapMode: Text.WrapAnywhere
    }
  }
  */
  ButtonQuizImgLarge
  {
    id:idThis_addVal
    anchors.right:  parent.right
    anchors.rightMargin:  20
    anchors.top: parent.top
    anchors.topMargin:  20
    source:"qrc:refresh.png"

    onClicked:
    {
      loadCW()
    }
    WhiteText
    {
      anchors.bottom: parent.bottom
      text: "New"
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
  Component.onCompleted:
  {
    /*
    CrossWordQ.createCrossWordFromList(glosModel)

    idCrossWordGrid.columns = 10

    let nCount = 10 * 10
    console.log("nCount " + nCount)
    for (let i = 0; i < nCount; ++i)
    {

      const o = idChar.createObject(idCrossWordGrid)


      if ((i % 5) === 2)
      {
        o.eSquareType = CrossWord.SquareType.Question
        o.text = "långt och smalt djur hos eva"
      }
      if ((i % 10) === 1)
      {
        o.eSquareType = CrossWord.SquareType.Blank
      }

    }
    */

  }
}
