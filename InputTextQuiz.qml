import QtQuick 2.0

Rectangle
{
  property alias text : idTextInput.text
  color:"grey"
  width: parent.width
  height: 23
  TextInput
  {
    anchors.leftMargin: 5
    font.pointSize: 12
    anchors.fill: parent
    id:idTextInput
  }
}
