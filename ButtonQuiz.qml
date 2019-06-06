import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Button
{
  height:32
  width:100
  style: ButtonStyle {
          background: Rectangle {
              border.width: control.activeFocus ? 2 : 1
              border.color: "#888"
              radius: 4
              color: control.pressed ? "steelblue" :"lightsteelblue"
          }
      }
}