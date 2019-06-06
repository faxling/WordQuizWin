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
      ButtonQuiz
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

      ListViewHi
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
      }


      ListViewHi
      {
        id:idLangList2
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

    ListViewHi
    {
      id:idQuizList
      width:parent.width
      height:200
      model:idQuizModel


      onCurrentIndexChanged:
      {
        sQuizName = idQuizModel.get(currentIndex).quizname
        sLangLang = idQuizModel.get(currentIndex).langpair
        var res = sLangLang.split("-");
        sLangLangRev = res[1] + "-" + res[0];
        sLangLangEn = "en"+ "-" + res[1];
        sReqDictUrl = sReqDictUrlBase +  sLangLang + "&text="
        sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text="
        sReqDictUrlEn= sReqDictUrlBase + sLangLangEn + "&text="
      }

      delegate:
          Row
      {
      TextList
      {
        width:100
        text:quizname
        MouseArea
        {
          anchors.fill: parent
          onClicked:
          {
            idQuizList.currentIndex = index
          }
        }
      }
      TextList
      {
        text:langpair
      }

    }
  }
  Component.onCompleted: {

  }
}
}

