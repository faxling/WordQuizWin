import QtQuick 2.0

Image
{
  id:idImageBtn
  fillMode: Image.Stretch
  width:nBtnHeight / 2
  height : nBtnHeight / 2
  signal clicked()
  MouseArea
  {
    anchors.fill: parent
    onClicked: idImageBtn.clicked()
    onPressed: idRect.opacity = 0.6
    onReleased: idRect.opacity  = 0.4
  }
  Rectangle
  {
    id:idRect
    opacity:0.4
    radius: 4
    color: "steelblue"
    anchors.fill: parent
  }
}
