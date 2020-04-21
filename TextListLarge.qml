import QtQuick 2.0

Text {
  id:idText
  signal click
  signal pressAndHold
  verticalAlignment: Text.AlignVCenter
  font.pointSize:nFontSize * 1.5
 // height:23
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
    onPressAndHold:idText.pressAndHold()
  }
}

