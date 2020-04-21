import QtQuick 2.0
import QtQuick.Controls 2.1

ListView
{
  clip:true
  highlightMoveDuration :500
  highlight: Rectangle {
    opacity:0.5
    color: "#009bff"
  }
   ScrollBar.vertical: ScrollBar {}
}
