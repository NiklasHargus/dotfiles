import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  id: root

  required property var theme
  property string icon: ""
  property real value: 0
  property real maximum: 100
  property bool iconClickable: false

  signal moved(real value)
  signal iconClicked()

  implicitWidth: 90
  implicitHeight: 32

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Text {
      id: iconText
      Layout.preferredWidth: 18
      horizontalAlignment: Text.AlignHCenter
      text: root.icon
      color: iconMouse.containsMouse && root.iconClickable ? root.theme.accent : root.theme.foreground
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize 

      MouseArea {
        id: iconMouse
        anchors.fill: parent
        enabled: root.iconClickable
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.iconClicked()
      }
    }

    Slider {
      id: slider
      Layout.fillWidth: true
      from: 0
      to: root.maximum
      value: root.value
      onMoved: root.moved(value)

      background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 4
        radius: 2
        color: root.theme.track

        Rectangle {
          width: slider.visualPosition * parent.width
          height: parent.height
          radius: parent.radius
          color: root.theme.foreground
        }
      }

      handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: 10
        implicitHeight: 4
        radius: 4
        color: slider.pressed ? root.theme.accent : root.theme.transparent
      }
    }
  }
}
