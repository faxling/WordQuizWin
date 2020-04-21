import QtQuick 2.0

Text {
  id:idText
  signal click
  font.pointSize: nFontSize
  color: "white"
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
  }
}


