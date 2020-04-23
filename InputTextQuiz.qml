import QtQuick 2.0

Rectangle
{
  property alias displayText : idTextInput.displayText
  property alias text : idTextInput.text
  color:"grey"
  width: parent.width -10
  x:5
  height:   nBtnHeight / 2
  TextInput
  {
    selectByMouse : true
    anchors.leftMargin: 5
    font.pixelSize: nBtnHeight / 2.5
    anchors.fill: parent
    id:idTextInput
  }
}
