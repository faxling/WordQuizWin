import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Button
{
  id:idButtonQuiz
  width : n4BtnWidth
  height : nBtnHeight
  property bool bProgVisible
  property bool bIsPressedIn : false
  property int  nButtonFontSize : nFontSize
  property int  nTextWidth



  BusyIndicator {
    anchors.centerIn: parent
    running: bProgVisible
  }


  style: ButtonStyle {
    background: Rectangle {
      border.width: control.activeFocus ? 2 : 1
      border.color: "#888"
      radius: 4
      color:
      {
        if (control.pressed)
          return "steelblue"

        if (bProgVisible)
          return "orange"

        if (bIsPressedIn)
          return  "#009bff"

        return "lightsteelblue"

      }
    }

    label: Text {
      id: idTextLabel
      renderType: Text.NativeRendering
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      font.pointSize: nButtonFontSize
      text: control.text
      TextMetrics {
        id:     t_metrics
        font: idTextLabel.font
        text:    idTextLabel.text
        onWidthChanged: idButtonQuiz.nTextWidth = width
      }
    }
  }
}
