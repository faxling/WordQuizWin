import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4

TabButton {
  id: control2
  text: "Edit"
  onPressed: {
    checked = true
    idSwipeView.currentIndex = 1
  }
  background: Rectangle {
    color: control2.checked ?"#626567" :"#BDC3C7"
    opacity: control2.down ? 1 :0.9
   // implicitHeight : nBtnHeight
    //border.color:  "#797D7F"
  }
  contentItem: Text {
    text: control2.text
    font.pointSize: 10
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: control2.checked ? "white" : "black"
  }
}
