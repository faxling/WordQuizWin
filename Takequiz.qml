import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib
import QtQuick.Window 2.0

Item {
  id:idRectTakeQuiz
  property bool bExtraInfoVisible : false
  property bool bAnswerVisible : false
  property bool bTextMode : false
  property bool bTextAnswerOk : false
  property bool bImageMode : false
  property bool bMoving : false
  property bool bVoiceMode : false

  Component.onCompleted:
  {
    idWindow.oTakeQuiz = idRectTakeQuiz
  }
  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {

      radius:10
      width:idView.width
      height:idView.height -20
      // sy : 15
      gradient:  "NearMoon"

      ButtonQuizImg
      {
        id:idInfoBtn
        anchors.left:  parent.left
        anchors.leftMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"qrc:info.png"
        visible :idQuizModel.extra.length > 0
        onClicked: bExtraInfoVisible = !bExtraInfoVisible
      }

      ButtonQuizImg
      {
        id:idTextBtn
        visible : !allok
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"qrc:edit.png"
        bIsPushed:bTextMode
        onClicked: bTextMode = !bTextMode
      }
      ButtonQuizImg
      {
        id:idVoiceModeBtn
        visible : !allok
        anchors.left:  parent.left
        anchors.leftMargin:  20
        anchors.top:  idInfoBtn.bottom
        anchors.topMargin:  20
        bIsPushed:bVoiceMode
        source:"qrc:horn_small.png"
        onClicked: bVoiceMode = !bVoiceMode
      }

      ButtonQuizImg
      {
        id:idImgBtn
        visible : !allok
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        bIsPushed: bImageMode
        source:"qrc:img.png"
        onClicked: bImageMode = !bImageMode
      }

      ButtonQuizImg
      {
        id:idSoundBtn
        visible : bTextAnswerOk && bTextMode &&  !allok
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idImgBtn.bottom
        anchors.topMargin:  20
        source:"qrc:horn_small.png"
        onClicked: MyDownloader.playWord(idQuizModel.answer,sAnswerLang )
      }

      Text
      {
        id:idTextExtra
        anchors.left: idInfoBtn.right
        anchors.leftMargin:  20
        anchors.verticalCenter: idInfoBtn.verticalCenter
        visible:bExtraInfoVisible
        font.pointSize: 12
        text: idQuizModel.extra
      }

      Image {
        anchors.left:  parent.left
        anchors.leftMargin:  10
        anchors.top:  idSoundBtn.bottom
        anchors.topMargin:  20
        visible : bTextAnswerOk && bTextMode && !allok
        source: "qrc:thumb_small.png"
      }

      InputTextQuiz
      {
        id:idTextEditYourAnswer
        enabled: bTextMode
        Component.onCompleted:
        {
          MyDownloader.storeTextInputField(idTextEditYourAnswer)
        }
        y:50
        z:2
        anchors.horizontalCenter: parent.horizontalCenter
        visible:bTextMode  &&  !allok
        width:parent.width  - 150
        placeholderText : "your answer"
        onTextChanged:
        {
          bTextAnswerOk =  QuizLib.isAnswerOk(text, idQuizModel.answer)
        }

      }

      DropArea
      {
        anchors.fill: parent
        onDropped:
        {
          MyDownloader.downloadImage(drop.urls, idQuizModel.question, sQuestionLang , idQuizModel.answer,sAnswerLang)
        }
      }

      Column
      {
        id:idQuizColumn
        spacing: 20
        anchors.horizontalCenter:  parent.horizontalCenter
        y : parent.height / 5
        visible:!allok

        Image
        {
          id:idWordImage
          cache:false
          fillMode: Image.PreserveAspectFit
          anchors.horizontalCenter: parent.horizontalCenter
          visible : bImageMode && MyDownloader.hasImg
          source : MyDownloader.urlImg
        }


        Text
        {
          id:idTextQuestion
          opacity: ( bVoiceMode ) ? 0 : 1
          anchors.horizontalCenter: parent.horizontalCenter
          font.pointSize: 30
          text :question
        }


        ButtonQuizImgLarge
        {
          height : nBtnHeight
          width : nBtnHeight
          anchors.horizontalCenter: parent.horizontalCenter
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(question,sQuestionLang)
        }

        ButtonQuiz
        {
          id:idBtnAnswer
          width : n25BtnWidth
          anchors.horizontalCenter: parent.horizontalCenter
          text:"Show Answer"
          nButtonFontSize : 20
          onClicked:
          {
            bAnswerVisible = !bAnswerVisible
          }
        }

        Item
        {
          height: idTextAnswer.height
          width:parent.width
          //   color:"yellow"
          Text
          {
            id:idTextAnswer
            visible:bAnswerVisible
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 30
            text : idQuizModel.answer
          }
        }

        ButtonQuizImgLarge
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible: bAnswerVisible
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(idQuizModel.answer,sAnswerLang)
        }

      }
      Image {
        id:idImageAllok
        visible:allok
        anchors.centerIn: parent
        source: "qrc:thumb.png"
      }

      ButtonQuiz {
        visible:allok
        text:"One more time?"
        width : nTextWidth + nTextWidth / 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:idImageAllok.bottom
        anchors.topMargin: 20
        nButtonFontSize : 20
        onClicked:
        {
          QuizLib.resetQuiz()
        }
      }

      ButtonQuizImgLarge
      {
        visible:  !allok
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
      ButtonQuizImgLarge
      {
        visible:  !allok
        enabled: idView.interactive
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin: 20
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
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height
    //   property int nPreviousCurrentIndex
    property int nLastIndex : 1

    interactive: ((!bAllok) && (bTextAnswerOk || !bTextMode || bAnswerVisible)) ||  (bMoving || moving)

    highlightMoveDuration:800

    Timer {
      id:idTimer
      interval: 1000;
      onTriggered: bMoving = false
    }

    onCurrentIndexChanged:
    {
      idTimer.start()
      QuizLib.calcAndAssigNextQuizWord(currentIndex)
    }

    clip:true

    model : idQuizModel
    delegate:idQuestionComponent
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -(idView.width / 2 + 100); startY: idView.height / 2
      PathLine  { relativeX:  idView.width*3 + 300; relativeY: 0}
    }

    // focus: true
    Keys.onLeftPressed: {
      bMoving = true
      idView.incrementCurrentIndex()
    }

    Keys.onRightPressed: {
      bMoving = true
      idView.decrementCurrentIndex()
    }
    Keys.onSpacePressed: {
      bAnswerVisible = !bAnswerVisible
    }
  }

}

