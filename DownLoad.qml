import QtQuick 2.0
import QtQuick.Controls 1.4

Flipable {
  id:idContainer
  x:-width
  property bool bIsDownloading : false
  property bool bIsDeleting : false
  property string sSelectedQ
  property string sImportMsg: ""
  property string sDesc1: ""
  property string sDescDate : ""
  property alias currentIndex: idServerListView.currentIndex
  function positionViewAtIndex(nIndex)
  {
    idServerListView.positionViewAtIndex(nIndex,
                                         ListView.Center)
  }

  function showPane()
  {
    idImport.sImportMsg = ""
    idNumberAnimation.duration = 500
    idContainer.state = "Show"
  }

  front: RectRounded {
    radius: 0
    gradient:  "StrongStick"
    // color: "black"
    anchors.fill: idContainer


    onCloseClicked:  {
      bIsDeleting = false
      idContainer.state = ""
      idPwdTextInput.text = ""
    }

    GridView {
      clip: true
      id:idGrid
      anchors.top: parent.bottomClose
      anchors.bottom: parent.bottom
      width: parent.width
      model: idLangModel

      cellHeight : 170
      cellWidth : 150

      delegate :
          Item {
        width: idGrid.cellWidth
        height: idGrid.cellHeight
        // height : 150
        Image
        {
          anchors.horizontalCenter: parent.horizontalCenter
          //  height :idContainer.width / 3 -5
          //  width : height
          source:imgsource
          MouseArea{
            anchors.fill:parent
            onClicked:
            {
              bIsDownloading = true
              MyDownloader.listQuizLang(code)
              idContainer.state = "Back"
              idNumberAnimation.duration = 1000
            }
          }
        }
        TextListLarge
        {
          text :lang
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 10
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }
    }
  }


  back : RectRounded
  {
    id:idImportList
    radius: 0
    gradient:  "StrongStick"
    anchors.fill: idContainer

    BusyIndicator {
      anchors.centerIn: parent
      running:bIsDownloading
    }

    onCloseClicked:  {
      idPwdDialog.visible = false;
      idImport.state = ""
      bIsDeleting = false
      idPwdTextInput.text = ""
    }

    WhiteText
    {
      id:idDescText
      anchors.top :idImportTitle.bottom
      x:20
      text:sDesc1
    }

    WhiteText
    {
      id:idDescDate
      font.pointSize: 9
      anchors.top :idDescText.bottom
      x:20
      text:"-"
    }

    TextList {
      id:idImportMsg
      x:70
      y:25
      color:"red"
      text:sImportMsg
    }

    WhiteText {
      id: idImportTitle
      x:20
      text:"Available Quiz's"
    }

    WhiteText {
      id: idNameLabel
      x:20
      y: idQuestionsLabel.y
      text:"Name"
    }

    WhiteText {
      id:idQuestionsLabel
      anchors.top :idDescDate.bottom
      x : idServerListView.width * (5 / 6 )
      text:"Questions"
    }

    ListViewHi
    {
      id:idServerListView
      anchors.top :idQuestionsLabel.bottom
      anchors.topMargin :10
      x:10
      width:idImport.width - 20
      height:parent.height - nBtnHeight*2  - idServerListView.y
      model: idServerQModel
      delegate: Item {
        id:idImportRow
        property int nW : idServerListView.width / 6
        width:idServerListView.width
        height : idTextQname.height
        Row
        {

          TextListLarge {
            width: nW *4
            id:idTextQname
            text:qname
          }

          TextListLarge
          {
            width:nW
            text:code
          }

          TextListLarge
          {
            width:nW
            text:state1
          }

        }
        MouseArea
        {
          anchors.fill:idImportRow
          onClicked:
          {
            idImportMsg.text = ""
            idImport.sDesc1 = desc1
            idImport.sDescDate = date1
            idImport.sSelectedQ = qname;
            idServerListView.currentIndex = index
          }
        }
      }
    }
    RectRounded
    {
      id:idPwdDialog
      visible:false
      height:70
      radius:7
      color: "#202020"
      anchors.bottom: idDeleteQuiz.top
      anchors.bottomMargin: 20
      width:idServerListView.width
      function closeThisDlg()
      {
        idPwdDialog.closeClicked()
      }
      onVisibleChanged: {
        if (visible)
          idWindow.oPopDlg = idPwdDialog
        else
          idWindow.oPopDlg = idImport
      }
      onCloseClicked:
      {
        idContainer.state = ""
        idPwdDialog.visible = false
        idDeleteQuiz.bProgVisible = false
      }
      Row
      {
        x:20
        anchors.verticalCenter:parent.verticalCenter
        spacing:20
        Text
        {
          anchors.verticalCenter:parent.verticalCenter
          color: "white"
          text: "Password to remove '" + idImport.sSelectedQ +"'"
        }

        InputTextQuiz
        {
          width:parent.width / 3
          id:idPwdTextInput
        }
      }
    }


    ButtonQuiz
    {
      id:idDeleteQuiz
      text: "Remove"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: parent.right
      anchors.rightMargin: 20
      bProgVisible : bIsDeleting
      onClicked:
      {
        idTextInputQuizName.text = idImport.sSelectedQ + " "
        if (idPwdTextInput.displayText.length > 0)
        {
          idPwdDialog.visible = false;
          MyDownloader.deleteQuiz(idImport.sSelectedQ, idPwdTextInput.displayText,idServerListView.currentIndex)
          idPwdTextInput.text = ""
        }
        else
          idPwdDialog.visible = true
      }
    }

    ButtonQuiz
    {
      id:idLoadQuiz
      text: "Download"
      bProgVisible : bIsDownloading
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.right: idDeleteQuiz.left
      anchors.rightMargin: 20
      onClicked:
      {
        bIsDownloading = true
        idTextInputQuizName.text = idImport.sSelectedQ + " "
        sQuizName  = idImport.sSelectedQ
        MyDownloader.importQuiz(idImport.sSelectedQ)
      }
    }
  }

  transform: Rotation {
    id: itemRotation
    origin.x: idContainer.width / 2;
    axis.y: 1;
    axis.z: 0
  }

  transitions: Transition {
    NumberAnimation { easing.type: Easing.InOutQuad; properties: "angle"; duration: 500 }
    NumberAnimation {
      id:idNumberAnimation
      easing.type: Easing.InOutQuad; properties: "x"; duration: 1000
    }
  }

  states: [
    State {
      name: "Back"
      PropertyChanges { target: itemRotation; angle: 180 }
      PropertyChanges { target: idContainer; x: 0 }
    } ,
    State {
      name: "Show"
      PropertyChanges { target: idContainer; x: 0 }
    } ]

}
