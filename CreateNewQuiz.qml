import QtQuick 2.0
import QtQuick.Controls 1.4


Item
{
  ListModel {
    id:idQuizModel
    ListElement {
      quizname: "Viktiga ord"
      langpair:"sv-ru"
    }

    ListElement {
      quizname: "Viktiga ord"
      langpair:"sv-fr"
    }
  }

  ListModel {
    id:idLangModel
    ListElement {
      lang: "Swedish"
      code:"sv"
    }
    ListElement {
      lang: "Russian"
      code:"ru"
    }
    ListElement {
      lang: "French"
      code:"fr"
    }
    ListElement {
      lang: "Italian"
      code:"it"
    }
    ListElement {
      lang: "English"
      code:"en"
    }
    ListElement {
      lang: "Hungarian"
      code:"hu"
    }
    ListElement {
      lang: "Norvegian"
      code:"no"
    }
    ListElement {
      lang: "Spanish"
      code:"es"
    }
  }
  Column
  {
    spacing:20
    anchors.topMargin: 50
    anchors.rightMargin: 50
    anchors.bottomMargin: 50
    anchors.fill: parent

    InputTextQuiz
    {

    }
    Row
    {
      spacing:20
      Button
      {
        text:"New Quiz"
      }
      TextList
      {
        id:idLangPair
      }
    }

    Row
    {
      width:parent.width
      height : 100

      ListView
      {
        id:idLangList1
        width:100
        height:parent.height
        model: idLangModel
        delegate: TextList {
          text:lang
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idLangList1.currentIndex = index
              idLangPair.text = code + "-" + idLangModel.get(idLangList2.currentIndex).code
            }
          }
        }
        highlight: Rectangle {
          opacity:0.5
          color: "#009bff"
        }
      }


      ListView
      {
        id:idLangList2
        width:100
        height:parent.height
        model: idLangModel

        highlight: Rectangle {
          opacity:0.5
          color: "#009bff"
        }

        delegate: TextList {
          text:lang
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              idLangList2.currentIndex = index
              idLangPair.text = idLangModel.get(idLangList1.currentIndex).code + "-" + code
            }
          }
        }
      }
    }
    TextList
    {
      text:" "
    }

    TextList
    {
      height:5
      color: "steelblue"
      text:"Available Quiz's:"
    }

    ListView
    {
      width:parent.width
      height:200
      model:idQuizModel
      delegate:
          Row
      {
      TextList
      {
        width:100
        text:quizname
      }
      TextList
      {
        text:langpair
      }
    }
  }
}
}

