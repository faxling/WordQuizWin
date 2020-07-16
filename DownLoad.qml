import QtQuick 2.0
import QtQuick.Controls 1.4

Flipable {
  id:idContainer
  x:-width
  property bool bIsDownloading : false
  property bool bIsDownloadingList : false
  property bool bIsDeleting : false
  property string sSelectedQ
  property string sImportMsg
  property string sDesc1
  property string sLang
  property string sDescDate
  property alias currentIndex: idServerListView.currentIndex
  function positionViewAtIndex(nIndex)
  {
    idServerListView.positionViewAtIndex(nIndex,
                                         ListView.Center)
  }

  function showPane()
  {
    idContainer.sImportMsg = ""
  // idNumberAnimation.duration = 500
    idContainer.state = "Show"
    idContainer.forceActiveFocus()
  }

  front: RectRounded {
    radius: 0
    bIgnoreBackHandling : true
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

      cellHeight : n3BtnWidth
      cellWidth : n3BtnWidth

      delegate :
          Item {
        width: idGrid.cellWidth
        height: idGrid.cellHeight
        // height : 150
        Image
        {
          id: idLangImage
          anchors.centerIn: parent
          height :n5BtnWidth
          width : n5BtnWidth
          source:imgsource
          MouseArea{
            anchors.fill:parent
            onClicked:
            {
              bIsDownloadingList = true
              sLang = lang
              idNumberAnimation.duration = 1500
              MyDownloader.listQuizLang(code)
              idContainer.state = "Back"
            }
          }
        }
        TextListLarge
        {
          text :lang
          y : idLangImage.x + n5BtnWidth + 20
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
    bIgnoreBackHandling : true
    BusyIndicator {
      anchors.centerIn: parent
      running:bIsDownloadingList
    }

    onCloseClicked:  {
      idPwdDialog.visible = false;
      idNumberAnimation.duration = 500
      idContainer.state = "Flip"
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
      text:sDescDate
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

    TextListLarge
    {
      anchors.centerIn: parent
      visible: idServerQModel.count === 0
      text: "No Quiz aviailable in "+ sLang +"\nplease create one and upload"
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
            idContainer.sImportMsg = ""
            idContainer.sDesc1 = desc1
            idContainer.sDescDate = date1
            idContainer.sSelectedQ = qname;
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
        idTextInputQuizName.text = idContainer.sSelectedQ + " "
        sQuizName  = idContainer.sSelectedQ
        MyDownloader.importQuiz(idContainer.sSelectedQ)
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
    NumberAnimation {
      id:idNumberAnimation
      easing.type: Easing.InOutQuad;
      properties: "angle"; duration: 1000
    }
    NumberAnimation {
      easing.type: Easing.InOutQuad;
      properties: "x"; duration: 500
    }
  }

  states: [
    State {
      name: "Back"
      PropertyChanges { target: itemRotation; angle: 180 }
      PropertyChanges { target: idContainer; x: 0 }
    } ,
    State {
      name: "Flip"
      PropertyChanges { target: itemRotation; angle: 0 }
      PropertyChanges { target: idContainer; x: 0 }
    } ,
    State {
      name: "Show"
      PropertyChanges { target: idContainer; x: 0 }
    } ]

}
