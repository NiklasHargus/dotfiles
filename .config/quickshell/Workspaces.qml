import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.I3

Item {
  id: root

  required property var theme

  // Pick the IPC backend from the environment. The Hyprland/I3 singletons are
  // only touched inside the matching branch, so the unused one never connects.
  readonly property bool isHyprland: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
  readonly property bool isSway: !isHyprland && (!!Quickshell.env("SWAYSOCK") || !!Quickshell.env("I3SOCK"))

  readonly property var workspaces: isHyprland ? Hyprland.workspaces.values
                                  : isSway ? I3.workspaces.values
                                  : []
  readonly property int focusedId: (isHyprland ? Hyprland.focusedWorkspace?.id
                                  : isSway ? I3.focusedWorkspace?.number
                                  : 1) ?? 1

  readonly property int maxWorkspace: {
    const ids = workspaces
      .map(workspace => idOf(workspace))
      .filter(id => id > 0 && id <= 10);
    return ids.length === 0 ? 1 : Math.max(...ids);
  }
  readonly property var workspaceIds: Array.from({ length: maxWorkspace }, (_, index) => index + 1)

  implicitWidth: workspaceRow.implicitWidth
  implicitHeight: 32

  function idOf(workspace: var): int {
    return isHyprland ? workspace.id : workspace.number;
  }

  function workspaceFor(id: int): var {
    return workspaces.find(workspace => idOf(workspace) === id) ?? null;
  }

  function isOccupied(workspace: var): bool {
    if (!workspace)
      return false;
    if (isHyprland)
      return workspace.toplevels.values.length > 0;
    // Sway doesn't list windows per workspace, but it destroys empty
    // workspaces once they lose focus, so any unfocused one has windows.
    return !workspace.focused;
  }

  function goTo(id: int): void {
    if (isHyprland)
      Hyprland.dispatch("workspace " + id);
    else if (isSway)
      I3.dispatch("workspace number " + id);
  }

  function changeWorkspace(step: int): void {
    const current = focusedId;
    if (current < 1)
      return;

    goTo(Math.max(1, Math.min(10, current + step)));
  }

  Row {
    id: workspaceRow
    anchors.verticalCenter: parent.verticalCenter
    spacing: 15

    Repeater {
      model: ScriptModel {
        values: root.workspaceIds
      }

      delegate: Item {
        id: entry
        required property int modelData

        readonly property var workspace: root.workspaceFor(modelData)
        readonly property bool current: workspace?.focused ?? false
        readonly property bool occupied: root.isOccupied(workspace)

        width: 8
        height: 24

        Text {
          anchors.centerIn: parent
          text: entry.current ? "" : ""
          color: entry.current ? "#ffffff"
                               : entry.occupied ? root.theme.foreground : root.theme.muted
          font.family: root.theme.fontFamily
          font.pixelSize: root.theme.fontSize + 1
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.goTo(entry.modelData)
        }
      }
    }
  }

  WheelHandler {
    onWheel: event => {
      root.changeWorkspace(event.angleDelta.y < 0 ? 1 : -1);
      event.accepted = true;
    }
  }
}
