import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {






  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem-1 )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {
      property alias answerVisible: idTextAnswer.visible
      radius:6
      width:300
      height:300
      color:"mediumspringgreen"
      Column
      {
        height:200
        width:300
        spacing: 20
        anchors.centerIn: parent
        Text
        {
          anchors.horizontalCenter: parent.horizontalCenter
          id:idTextQuestion
          font.pointSize: 25
          text : question
        }

        ButtonQuiz
        {
          anchors.horizontalCenter: parent.horizontalCenter
          id:idBtnAnswer
          text:"Show Answer"
          onClicked:
          {
            idQuizModel.setProperty(index,"visible1",true)
          }
        }
        Item
        {
          height:50
          width:parent.width
          //   color:"yellow"
          Text
          {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            id:idTextAnswer
            visible: visible1
            font.pointSize: 25
            text : answer
          }
        }
      }
      Image
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.rightMargin: 20
        source:"r.png"
      }
      Image
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin: 20
        source:"left.png"
      }
    }
  }

  Component.onCompleted:
  {

  }


  Text
  {
    y:10
    text: sScoreText
    id: idNumberText
  }

  PathView
  {
    id:idView

    property int nLastIndex : 1
    onCurrentIndexChanged:
    {
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
      var nI = (currentIndex+1) % 3

      var bDir = 0

      if (nLastIndex == 0 && nI === 1)
        bDir = 1
      if (nLastIndex == 0 && nI === 2)
        bDir = -1
      if (nLastIndex == 1 && nI === 0)
        bDir = -1
      if (nLastIndex == 1 && nI === 2)
        bDir = 1
      if (nLastIndex == 2 && nI === 0)
        bDir = 1
      if (nLastIndex == 2 && nI === 1)
        bDir = -1
      var nLastNumber = idQuizModel.get(nLastIndex).number

      nLastIndex = nI

      idQuizModel.get(nI).question =  glosModelWorking.get(nIndexOwNewWord).question
      idQuizModel.get(nI).answer =  glosModelWorking.get(nIndexOwNewWord).answer
      idQuizModel.get(nI).number =  glosModelWorking.get(nIndexOwNewWord).number
      idQuizModel.setProperty(nI,"visible1",false)
      if (bDir ===-1)
      {
        var nC = glosModelWorking.count
        for ( var i = 0; i < nC;++i) {
          if (glosModelWorking.get(i).number === nLastNumber)
          {
            glosModelWorking.remove(i);
            sScoreText  = glosModelWorking.count + "/" + glosModel.count
            nC = glosModel.count
            for (  i = 0; i < nC;++i) {
              if (glosModel.get(i).number === nLastNumber)
              {
                glosModel.get(i).state1 = 1;

                db.transaction(
                      function(tx) {
                        tx.executeSql("UPDATE Glosa"+ndbnumber+" SET state=1 WHERE number=?", nLastNumber);
                      })

                break;
              }
            }
            break;
          }
        }

      }
    }


    y:100
    clip:true
    width:300
    height:300
    model : idQuizModel
    delegate:idQuestionComponent
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -250; startY: 150
      PathLine  { relativeX:  1200; relativeY: 0}
    }
  }

}

