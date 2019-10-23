import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.LocalStorage 2.0 as Sql

/// Faxling     Raggo100 trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f

// https://cloud.yandex.com/docs/speechkit/tts/request
// https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&text=groda&lang=sv-ru
// dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739

// speaker=<jane|oksana|alyss|omazh|zahar|ermil>
//http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=ermil&text=да&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7

//https://dictionary.yandex.net/api/v1/dicservice/getLangs?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739


Window {

  id:idWindow
  property string sReqDictUrlBase : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang="
  property string sReqDictUrl : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text="
  property string sReqDictUrlRev : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=ru-sv&text="
  property string sReqDictUrlEn : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=en-ru&text="

  property string sReqUrlBase: "https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang="
  property string sReqUrl
  property variant db
  property string sLangLangSelected
  property string sLangLang
  property string sLangLangRev
  property bool bHasDictTo : sToLang ==="ru" || sToLang ==="en"
  property bool bHasDictFrom : sFromLang ==="ru" || sFromLang ==="en"
  property string sToLang
  property string sFromLang
  property bool bHasSpeech : sToLang !=="hu"
  //  property bool bHasFromSpeech : sToLang ==="ru" || sToLang ==="en" ||  sToLang ==="sv" ||  sToLang ==="fr"||  sToLang ==="pl"||  sToLang ==="de"||  sToLang ==="it"
  property string sLangLangEn
  property string sQuizName : "-"
  property string sScoreText : "-"
  property int nDbNumber : 0;
  property int nQuizIndex: 1
  property int nGlosaDbLastIndex

  onSScoreTextChanged:
  {
    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);

            var nC = glosModelIndex.count
            for ( var i = 0; i < nC;++i) {
              if (glosModelIndex.get(i).dbnumber === nDbNumber)
              {
                glosModelIndex.setProperty(i,"state1", sScoreText)
                break;
              }
            }
          }
          )
  }

  function loadQuiz()
  {
    if (glosModel.count < 1)
      return;
    var nC = glosModel.count
    glosModelWorking.clear();

    for ( var i = 0; i < nC;++i) {
      if (glosModel.get(i).state1 === 0)
        glosModelWorking.append(glosModel.get(i))
    }

    var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

    // sScoreText =  glosModelWorking.count + "/" + nC

    if (glosModelWorking.count < 1)
    {
      idQuizModel.get(1).question =  "-";
      idQuizModel.get(1).answer = "-";
      idQuizModel.get(1).number = -1;
    }
    else
    {
      idQuizModel.get(1).question =  glosModelWorking.get(nIndexOwNewWord).question;
      idQuizModel.get(1).answer = glosModelWorking.get(nIndexOwNewWord).answer;
      idQuizModel.get(1).number = glosModelWorking.get(nIndexOwNewWord).number;
    }

  }

  ListModel {
    objectName:"glosModel"
    id: glosModel

    function sortModel()
    {

      db.transaction(
            function(tx) {
              glosModel.clear();

              var rs = tx.executeSql("SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort);

              for(var i = 0; i < rs.rows.length; i++) {

                var sA;
                var sE = "";
                var ocA = rs.rows.item(i).answer.split("###")
                sA = ocA[0]
                if (ocA.length > 1)
                  sE = ocA[1]

                glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE,  "state1" : rs.rows.item(i).state })

              }
            }
            )
    }
  }
  ListModel {
    id: glosModelWorkingRev
  }
  ListModel {
    id: glosModelWorking
  }
  ListModel {
    id: glosModelIndex
  }

  ListModel {
    id:idQuizModel

    ListElement {
      question: "-"
      answer:"-"
      number:0
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      number:1
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      number:2
      visible1:false
      allok:false
    }
  }


  Component.onCompleted:
  {

    db =  Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

    Sql.LocalStorage.openDatabaseSync()

    db.transaction(
          function(tx) {

            // tx.executeSql('DROP TABLE GlosaDbIndex');

            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbLastIndex( dbindex INT )');
            var rs = tx.executeSql('SELECT * FROM GlosaDbLastIndex')
            if (rs.rows.length===0)
            {
              tx.executeSql('INSERT INTO GlosaDbLastIndex VALUES(0)')
            }
            else
            {
              nGlosaDbLastIndex = rs.rows.item(0).dbindex
            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbDesc( dbnumber INT , desc1 TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbIndex( dbnumber INT , quizname TEXT, state1 TEXT, langpair TEXT )');

            rs = tx.executeSql('SELECT * FROM GlosaDbDesc');
            var oc = [];

            for(var i = 0; i < rs.rows.length; i++) {
              var oDescription = {dbnumber:rs.rows.item(i).dbnumber, desc1:rs.rows.item(i).desc1}
              oc.push(oDescription)
            }

            rs = tx.executeSql('SELECT * FROM GlosaDbIndex');


            Array.prototype.indexOfObject = function arrayObjectIndexOf(property, value) {
              for (var i = 0, len = this.length; i < len; i++) {
                if (this[i][property] === value) return i;
              }
              return -1;
            }

            var nRowLen = rs.rows.length


            for(i = 0; i < nRowLen; i++) {
              var nDbnumber = rs.rows.item(i).dbnumber
              var nN = oc.indexOfObject("dbnumber",nDbnumber)
              var sDesc = "-"
              if (nN >= 0)
              {
                sDesc = oc[nN].desc1
              }

              glosModelIndex.append({"dbnumber": nDbnumber, "quizname": rs.rows.item(i).quizname , "state1": rs.rows.item(i).state1, "langpair" : rs.rows.item(i).langpair,"desc1" : sDesc  })
            }

          }
          )
  }

  width:500
  height:700
  visible: true
  TextList
  {
    text: sQuizName + " " + sLangLang + " " + sScoreText
    anchors.horizontalCenter: parent.horizontalCenter
  }

  TabView {
    id:idTabMain
    anchors.fill : parent
    anchors.leftMargin : 50
    anchors.rightMargin : 50
    anchors.bottomMargin:  150
    anchors.topMargin : 50

    Tab
    {
      title: "Create"
      CreateNewQuiz
      {
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Edit"
      EditQuiz
      {
        id:idEditQuiz
        anchors.fill: parent
      }
    }
    Tab
    {
      title: "Quiz"
      TakeQuiz
      {
        id:idTakeQuiz
        width : idTabMain.width
        height : idTabMain.width
      }
    }
    style: TabViewStyle {

      tab: Rectangle {
        color: styleData.selected ? "steelblue" :"lightsteelblue"
        border.color:  "steelblue"
        implicitWidth: idTabMain.width / 3
        implicitHeight: 40
        radius: 2
        Text {
          id: text
          anchors.centerIn: parent
          text: styleData.title
          color: styleData.selected ? "white" : "black"
        }
      }
      frame: Rectangle { color: "white" }
    }
  }

}

