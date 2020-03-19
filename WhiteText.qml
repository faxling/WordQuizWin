import QtQuick 2.0

Text {
  id:idText
  signal click
  font.pointSize: 11
  height:22
  color: "white"
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
  }
}

