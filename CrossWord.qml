import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0



Item
{
  enum SquareType {
    Char,
    Blank,
    Question,
    Space,
    Done
  }
  property int nW : 0
  property int nLastAcceptedCharIndex: -1
  function loadCW()
  {
    console.log("loadCW")
    idCrossWordGrid.children = null

    CrossWordQ.createCrossWordFromList(glosModel)

    idCrossWordGrid.columns = CrossWordQ.nW

    // Last low must contain just *
    let nCount = CrossWordQ.nW * (CrossWordQ.nH -1)

    for (let i = 0; i < nCount; ++i)
    {
      let o = idChar.createObject(idCrossWordGrid)
      o.nIndex = i
    }

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

  Flickable {
    id:idCrossWord
    clip:true
    anchors.fill : parent
    // gradient:  "NearMoon"
    contentHeight: idCrossWordGrid.height
    contentWidth:  idCrossWordGrid.width + 80

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

        property int nIndex
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

              const sss = idT.text.split("\n\n")

              if (sss.length > 1)
              {
                if (sss[0].length > sss[1].length)
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
            else
            {
              Qt.inputMethod.hide()
            }

          }
        }
      }
    }

    Grid
    {
      id: idCrossWordGrid
      x:idTabMain.width > width ? (idTabMain.width - width) / 2 : 0
      spacing: 2
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

        function isChar(oo)
        {
          if (oo.eSquareType === CrossWord.SquareType.Char || oo.eSquareType === CrossWord.SquareType.Done)
            return true
          return false
        }


        function chChar(text)
        {
          idInputBox.parent.text = text.toUpperCase().charAt(0)

          if (MyDownloader.ignoreAccent(idInputBox.parent.text) === MyDownloader.ignoreAccent(idInputBox.parent.textA))
          {

            idInputBox.parent.text = idInputBox.parent.textA
            idInputBox.parent.eSquareType = CrossWord.SquareType.Done
          }

          let bV = false

          let nNI = idInputBox.parent.nIndex

          if (idCrossWordGrid.children[nNI+ 1].eSquareType === CrossWord.SquareType.Blank &&
              idCrossWordGrid.children[nNI+ CrossWordQ.nW].eSquareType === CrossWord.SquareType.Blank)
          {
            idInputBox.visible = false
            return
          }

          let nCurrent = nNI

          if ((nNI - nLastAcceptedCharIndex) === CrossWordQ.nW)
          {
            nNI = nNI + CrossWordQ.nW
            if (isChar(idCrossWordGrid.children[nNI]))
            {
              idInputBox.parent = idCrossWordGrid.children[nNI]
              idTextInput.text = idCrossWordGrid.children[nNI].text
              Qt.inputMethod.show()
              bV = true
            }
            idInputBox.visible = bV
            nLastAcceptedCharIndex = nCurrent
            return
          }

          if (idCrossWordGrid.children[nNI+ 1].eSquareType === CrossWord.SquareType.Space)
          {
            nNI = nNI + 2
          } else if (idCrossWordGrid.children[nNI+ CrossWordQ.nW].eSquareType === CrossWord.SquareType.Space)
          {
            nNI = nNI+ CrossWordQ.nW*2
          }
          else
          {
            nNI = nNI+ 1
          }


          if (isChar(idCrossWordGrid.children[nNI]))
          {
            idInputBox.parent = idCrossWordGrid.children[nNI]
            idTextInput.text = idCrossWordGrid.children[nNI].text
            bV = true
          }

          if (!bV)
          {
            nNI = nNI + CrossWordQ.nW -1
            if (isChar(idCrossWordGrid.children[nNI]))
            {
              idInputBox.parent = idCrossWordGrid.children[nNI]
              idTextInput.text = idCrossWordGrid.children[nNI].text
              bV = true
            }
          }

          nLastAcceptedCharIndex = nCurrent

          if (bV)
          {
            idInputBox.visible = bV
            Qt.inputMethod.show()
          }
        }
        font.pointSize: 20
        anchors.fill: parent
        font.capitalization: Font.AllUppercase

        onAccepted:
        {
          onEditingFinished:chChar(text)
        }

      }
    }

    Component.onCompleted:
    {

    }
  }
  ButtonQuizImgLarge
  {
    id:idThis_addVal
    x : idTabMain.width - width -20
    y : 20

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
}
