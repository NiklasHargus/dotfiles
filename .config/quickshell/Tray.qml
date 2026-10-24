import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
  id: root

  required property var theme
  required property var parentWindow

  spacing: 8

  Repeater {
    model: SystemTray.items

    delegate: Item {
      id: entry
      required property SystemTrayItem modelData

      visible: modelData.status !== Status.Passive
      width: visible ? 24 : 0
      height: 32

      function showMenu(): void {
        const point = entry.mapToItem(root.parentWindow.contentItem, 0, entry.height);
        modelData.display(root.parentWindow, Math.round(point.x), Math.round(point.y));
      }

      Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 6
        color: mouse.containsMouse ? root.theme.surfaceHover : "transparent"
      }

      IconImage {
        anchors.centerIn: parent
        implicitSize: 20
        source: entry.modelData.icon
      }

      MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
          if (event.button === Qt.MiddleButton) {
            entry.modelData.secondaryActivate();
          } else if (event.button === Qt.RightButton || entry.modelData.onlyMenu) {
            entry.showMenu();
          } else {
            entry.modelData.activate();
          }
        }

        onWheel: event => {
          entry.modelData.scroll(event.angleDelta.y, false);
          event.accepted = true;
        }
      }
    }
  }
}
