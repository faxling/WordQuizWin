import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0



Item
{
  enum SquareType {
    Char,
    Grey,
    Question,
    Space,
    Done
  }
  property int nW : 0
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
    contentHeight: idCrossWordGrid.height + idWindow.height / 3
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
        property int eSquareType : CrossWord.SquareType.Grey
        property alias text: idT.text
        property string textA
        color : {
          switch (eSquareType)
          {
          case CrossWord.SquareType.Grey:
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
      width: idTextInput.width + idTextInput.font.pixelSize
      TextInput
      {
        id: idTextInput

        function isChar(oo)
        {
          if (oo.eSquareType === CrossWord.SquareType.Char || oo.eSquareType === CrossWord.SquareType.Done)
            return true
          return false
        }

        function isBlank(oo)
        {
          if (oo.text === " " || oo.text === "")
            return true
          return false
        }

        function chChar(text)
        {
          const nInTextLen = text.length

          // 0 Horizontal 1 = Verical
          let eDirection =  0;
          text = text.replace(" ","").toUpperCase()

          let nNI = idInputBox.parent.nIndex
          for (let i = 0; i < nInTextLen; ++i)
          {
            // If First init direction
            if (i === 0)
            {
              if ((nNI % CrossWordQ.nW) === (CrossWordQ.nW-1))
              {
                eDirection = 1
              }
              else if (!isChar(idCrossWordGrid.children[nNI+ 1]) && isBlank(idCrossWordGrid.children[nNI+ 1]) )
              {
                eDirection = 1
              }
            }

            let oCursorSq = idCrossWordGrid.children[nNI];
            let chIn = text.charAt(i)

            if (MyDownloader.ignoreAccent(chIn) === MyDownloader.ignoreAccent(oCursorSq.textA))
            {
              oCursorSq.text = oCursorSq.textA
              oCursorSq.eSquareType = CrossWord.SquareType.Done
            }
            else
            {
              oCursorSq.text  = chIn
              oCursorSq.eSquareType = CrossWord.SquareType.Char
            }

            if (eDirection === 0)
            {
              nNI++
              if ((nNI % CrossWordQ.nW) === 0)
                break
            } else
            {
              nNI+=CrossWordQ.nW
              if ( nNI >= (CrossWordQ.nW * (CrossWordQ.nH-1)))
                break
            }

            oCursorSq = idCrossWordGrid.children[nNI];

            if (oCursorSq.eSquareType === CrossWord.SquareType.Space)
            {
              if (eDirection === 0)
                nNI++
              else
                nNI = nNI + CrossWordQ.nW

              oCursorSq = idCrossWordGrid.children[nNI];
            }

            if (!isChar(oCursorSq))
              break

          }

          idInputBox.visible = false
          const nCount = idCrossWordGrid.children.length
          for (let j = 0; j < nCount; ++j)
          {
            console.log(idCrossWordGrid.children[j].eSquareType)
          }

        }
        font.pointSize: 20
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
