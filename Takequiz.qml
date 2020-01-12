import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../harbour-wordquiz/Qml/QuizFunctions.js" as QuizLib

Item {
  id:idRectTakeQuiz
  property bool bExtraInfoVisible : false
  property bool bAnswerVisible : false
  property bool bAllok : false

  width:400
  height:400
  Component.onCompleted:
  {
    if (glosModelWorking.count === 0)
      bAllok = true

    idWindow.oTakeQuiz = idRectTakeQuiz
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
        onClicked: bExtraInfoVisible = true
      }

      Text
      {
        anchors.left: idInfoBtn.right
        anchors.leftMargin:  20
        anchors.verticalCenter: idInfoBtn.verticalCenter
        id:idTextExtra
        visible:bExtraInfoVisible
        font.pointSize: 12
        text: extra
      }

      Column
      {
        height:200
        spacing: 20
        anchors.centerIn: parent
        visible:!bAllok
        Text
        {
          anchors.horizontalCenter: parent.horizontalCenter
          id:idTextQuestion
          font.pointSize: 25
          text : question
        }


        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible:bHasSpeech
          source:"qrc:horn.png"
          onClicked: MyDownloader.playWord(question,sFromLang)
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
          onClicked: MyDownloader.playWord(answer,sToLang)
        }
      }
      Image {
        visible:bAllok
        anchors.centerIn: parent
        source: "qrc:thumb.png"
      }
      ButtonQuizImg
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.rightMargin: 20
        source:"qrc:r.png"
        onClicked:
        {
          var nI = (idView.currentIndex-1) % 3
          idView.currentIndex = nI
        }
      }
      ButtonQuizImg
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin: 20
        source:"qrc:left.png"
        onClicked:
        {
          var nI = (idView.currentIndex+1) % 3
          idView.currentIndex = nI
        }
      }
    }
  }

  PathView
  {
    id:idView
    property int nLastIndex : 1
    onCurrentIndexChanged:
    {
      QuizLib.calcAndAssigNextQuizWord(currentIndex)
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

