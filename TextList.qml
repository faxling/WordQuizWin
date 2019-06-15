import QtQuick 2.0

Text {
  id:idText
  signal click
  font.pointSize: 12
  height:23
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
  }
}

