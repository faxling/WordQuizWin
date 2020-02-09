import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item {
  id:idRectTakeQuiz
  property bool bExtraInfoVisible : false
  property bool bAnswerVisible : false
  property bool bAllok : false
  property bool bTextMode : false
  property bool bTextAnswerOk : false
  property bool bMoving : false
  width:400
  height:400
  Component.onCompleted:
  {

    idWindow.oTakeQuiz = idRectTakeQuiz
    if (glosModelWorking.count === 0)
      bAllok = true

  }
  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {
      property alias answerVisible: idTextAnswer.visible
      radius:10
      width:idView.width
      height:idView.height
      color:"mediumspringgreen"

      ButtonQuizImg
      {
        id:idInfoBtn
        anchors.left:  parent.left
        anchors.leftMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"qrc:info.png"
        visible :extra.length > 0
        onClicked: bExtraInfoVisible = !bExtraInfoVisible
      }

      ButtonQuizImg
      {
        id:idTextBtn
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"qrc:edit.png"
        onClicked: bTextMode = !bTextMode
      }

      ButtonQuizImg
      {
        id:idSoundBtn
        visible : bTextAnswerOk && bTextMode
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        source:"qrc:horn_small.png"
        onClicked: MyDownloader.playWord(answer,bIsReverse ? sFromLang : sToLang )
      }

      Text
      {
        id:idTextExtra
        anchors.left: idInfoBtn.right
        anchors.leftMargin:  20
        anchors.verticalCenter: idInfoBtn.verticalCenter
        visible:bExtraInfoVisible
        font.pointSize: 12
        text: extra
      }

      Image {
        anchors.left:  parent.left
        anchors.leftMargin:  10
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        visible : bTextAnswerOk && bTextMode
        source: "qrc:thumb_small.png"
      }

      TextField
      {
        id:idTextEditYourAnswer
        y:50
        anchors.horizontalCenter: parent.horizontalCenter
        visible:bTextMode
        width:parent.width  - 150
        placeholderText : "your answer"
        onTextChanged:
        {
          bTextAnswerOk =  QuizLib.isAnswerOk(text, answer)
        }
      }

      Column
      {
        height:200
        spacing: 20
        anchors.centerIn: parent
        visible:!bAllok
        Text
        {
          id:idTextQuestion
          anchors.horizontalCenter: parent.horizontalCenter
          font.pointSize: 25
          text : question
          onTextChanged: idTextEditYourAnswer.text = ""
        }


        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible:bHasSpeech
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(question,bIsReverse ? sToLang : sFromLang)
        }

        ButtonQuiz
        {
          id:idBtnAnswer
          anchors.horizontalCenter: parent.horizontalCenter
          text:"Show Answer"
          onClicked:
          {
            bAnswerVisible = true
          }
        }

        Item
        {
          height:50
          width:parent.width
          //   color:"yellow"
          Text
          {
            id:idTextAnswer
            visible:bAnswerVisible
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 25
            text : answer
          }
        }

        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible:bHasSpeech && bAnswerVisible
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(answer,bIsReverse ? sFromLang : sToLang)
        }

      }
      Image {
        visible:bAllok
        anchors.centerIn: parent
        source: "qrc:thumb.png"
      }
      ButtonQuizImg
      {
        enabled: idView.interactive
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.rightMargin: 20
        source:"qrc:r.png"
        onClicked:
        {
          bMoving = true
          idView.decrementCurrentIndex()
        }
      }
      ButtonQuizImg
      {
        enabled: idView.interactive
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin: 10
        source:"qrc:left.png"
        onClicked:
        {
          bMoving = true
          idView.incrementCurrentIndex()
        }
      }
    }
  }

  PathView
  {
    id:idView
    property int nPreviousCurrentIndex
    property int nLastIndex : 1

    interactive: bTextAnswerOk || !bTextMode || bAnswerVisible || bMoving || moving


    Timer {
      id:idTimer
      interval: 500;
      onTriggered: bMoving = false
    }

    onCurrentIndexChanged:
    {
      if (currentIndex === nPreviousCurrentIndex)
      {
        // When klicking on buttons
        console.log("currentIndex === ")
        return;
      }
      idTimer.start()
      nPreviousCurrentIndex = currentIndex
      QuizLib.calcAndAssigNextQuizWord(currentIndex)
      bTextAnswerOk = false
    }
    clip:true
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height
    model : idQuizModel
    delegate:idQuestionComponent
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -(idView.width / 2 + 100); startY: idView.height / 2
      PathLine  { relativeX:  idView.width*3 + 300; relativeY: 0}
    }
  }
}

