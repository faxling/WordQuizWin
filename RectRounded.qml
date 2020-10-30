import QtQuick 2.0

Rectangle {
  id: idDlgPopup
  property alias showClose: idBtnCancel.visible
  property alias leftClose: idBtnCancel.left
  property alias bottomClose: idBtnCancel.bottom
  radius: 10
  color: "black"
  property bool bIgnoreBackHandling : false

  MouseArea
  {
    anchors.fill: parent
  }

  onVisibleChanged: {

    idDlgPopup.forceActiveFocus()
    if (bIgnoreBackHandling)
      return

    if (visible)
    {
      idWindow.oPopDlg = idDlgPopup
    }
    else
    {
      idWindow.oPopDlg = undefined
    }
  }

  signal closeClicked

  function closeThisDlg() {
    idDlgPopup.closeClicked()
  }

  ButtonQuizImg {
    id: idBtnCancel
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 10
    anchors.rightMargin: 10
    source: "qrc:quit.png"
    onClicked: {
      idDlgPopup.closeThisDlg()
    }
  }
}
