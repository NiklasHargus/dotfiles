import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire

PopupWindow {
  id: root

  required property var theme
  required property var systemState
  required property string screenName
  required property var barWindow

  property bool wifiExpanded: false
  property bool audioExpanded: false
  property bool bluetoothExpanded: false

  readonly property var wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) ?? null
  readonly property var wifiNetworks: {
    const networks = wifiDevice?.networks.values ?? [];
    return [...networks]
      .filter(network => network.connected || network.signalStrength >= 0.4)
      .sort((left, right) => {
        if (left.connected !== right.connected)
          return left.connected ? -1 : 1;
        return right.signalStrength - left.signalStrength;
      })
      .slice(0, 5);
  }
  readonly property var audioSinks: [...Pipewire.nodes.values]
    .filter(node => node.audio !== null && node.isSink && !node.isStream)
    .sort((left, right) => {
      if (left === Pipewire.defaultAudioSink)
        return -1;
      if (right === Pipewire.defaultAudioSink)
        return 1;
      return root.audioName(left).localeCompare(root.audioName(right));
    })
  readonly property var bluetoothDevices: Bluetooth.defaultAdapter
    ? [...Bluetooth.defaultAdapter.devices.values]
        .filter(device => device.paired)
        .sort((left, right) => {
          if (left.connected !== right.connected)
            return left.connected ? -1 : 1;
          return left.name.localeCompare(right.name);
        })
    : []

  // Radius of the concave corners that blend the panel into the bar.
  readonly property int flare: 10
  readonly property int cornerRadius: 10

  // The flare only makes sense when a window's rounded top border sits next to
  // it; on an empty workspace the panel's left edge runs straight into the bar.
  // Sway doesn't expose windows per workspace, so it always keeps the flare.
  readonly property bool isHyprland: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
  readonly property bool windowOpen: isHyprland
    ? (Hyprland.monitorFor(barWindow.screen)?.activeWorkspace?.toplevels.values.length ?? 0) > 0
    : true
  property real topFlare: windowOpen ? flare : 0

  Behavior on topFlare {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }
  // Same for the bottom-right corner: 0 = convex corner with its own right
  // border, 1 = concave flare curving down into the window's right border.
  property real rightBlend: windowOpen ? 1 : 0

  Behavior on rightBlend {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }
  readonly property int panelWidth: 350
  readonly property int panelHeight: Math.min(contentColumn.implicitHeight + 24, Math.max(240, (screen?.height ?? 700) - 58))

  readonly property bool open: systemState.activePopupScreen === screenName
  // 0 = fully retracted into the bar, 1 = fully extended.
  property real progress: open ? 1 : 0
  // Smallest height at which the outline still fits. Below it, the panel keeps
  // this shape and slides up behind the bar instead of shrinking further.
  readonly property real minHeight: theme.windowGap + theme.borderWidth + flare + cornerRadius
  readonly property real rawHeight: progress * (panelHeight - 1)
  readonly property real shownHeight: Math.max(minHeight, rawHeight)
  readonly property real retract: Math.min(0, rawHeight - minHeight)

  Behavior on progress {
    // Decelerate into place when opening, accelerate away when closing.
    NumberAnimation { duration: 200; easing.type: root.open ? Easing.OutCubic : Easing.InCubic }
  }

  visible: open || progress > 0
  implicitWidth: panelWidth + flare
  // Extra room below the panel for the bottom-right flare.
  implicitHeight: panelHeight + flare
  color: "transparent"
  grabFocus: false

  // Pin the popup's top edge to the bar's bottom edge and its right edge to
  // the Hyprland gap, so its border lines up with the window borders.
  anchor {
    window: root.barWindow
    rect.x: root.barWindow.width - root.theme.windowGap
    rect.y: root.barWindow.height
    rect.w: 1
    rect.h: 1
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.None
  }

  function audioName(node: var): string {
    return node.description || node.nickname || node.name;
  }

  function resetSections(): void {
    if (wifiDevice)
      wifiDevice.scannerEnabled = false;
    wifiExpanded = false;
    audioExpanded = false;
    bluetoothExpanded = false;
  }

  function wifiIcon(strength: real): string {
    if (strength >= 0.75)
      return "󰤨";
    if (strength >= 0.5)
      return "󰤥";
    if (strength >= 0.25)
      return "󰤢";
    return "󰤟";
  }

  function bluetoothDetail(device: var): string {
    if (device.state === BluetoothDeviceState.Connecting)
      return "Connecting";
    if (device.state === BluetoothDeviceState.Disconnecting)
      return "Disconnecting";
    if (device.connected && device.batteryAvailable)
      return Math.round(device.battery * 100) + "%";
    return device.connected ? "Connected" : "Paired";
  }

  onWifiExpandedChanged: {
    if (visible && wifiDevice)
      wifiDevice.scannerEnabled = wifiExpanded;
  }

  onWifiDeviceChanged: {
    if (visible && wifiDevice)
      wifiDevice.scannerEnabled = wifiExpanded;
  }

  onOpenChanged: {
    if (open) {
      systemState.refreshControls();
      autoClose.restart();
    } else {
      autoClose.stop();
    }
  }

  // Collapse sections only after the close animation finished, so the
  // panel height doesn't jump while retracting.
  onVisibleChanged: {
    if (!visible)
      resetSections();
  }

  component SectionHeader: Rectangle {
    id: section

    property string icon: ""
    property string title: ""
    property string detail: ""
    property bool expanded: false
    signal activated()

    implicitHeight: 36
    radius: 7
    color: sectionMouse.containsMouse ? root.theme.surfaceHover : "transparent"

    Text {
      id: sectionTitle
      anchors {
        left: parent.left
        leftMargin: 8
        right: sectionDetail.left
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      text: section.icon + "  " + section.title
      color: section.expanded ? root.theme.accent : root.theme.foreground
      elide: Text.ElideRight
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize
      font.weight: Font.DemiBold
    }

    Text {
      id: sectionDetail
      anchors {
        right: chevron.left
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      width: Math.min(implicitWidth, 130)
      horizontalAlignment: Text.AlignRight
      elide: Text.ElideRight
      text: section.detail
      color: root.theme.muted
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize - 2
    }

    Text {
      id: chevron
      anchors {
        right: parent.right
        rightMargin: 8
        verticalCenter: parent.verticalCenter
      }
      text: section.expanded ? "󰅀" : "󰅂"
      color: section.expanded ? root.theme.accent : root.theme.muted
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize
    }

    MouseArea {
      id: sectionMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: section.activated()
    }
  }

  component ActionTile: Rectangle {
    id: tile

    property string title: ""
    property string detail: ""
    property bool active: false
    property bool busy: false
    signal activated()

    implicitHeight: 54
    radius: 8
    color: tile.active ? root.theme.activeSurface
                       : tileMouse.containsMouse ? root.theme.surfaceHover : root.theme.surface
    border.width: 1
    border.color: tile.active ? root.theme.success : root.theme.border
    opacity: tile.busy ? 0.65 : 1

    Text {
      anchors {
        left: parent.left
        leftMargin: 12
        top: parent.top
        topMargin: 8
      }
      text: tile.title
      color: tile.active ? root.theme.success : root.theme.foreground
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize
      font.weight: Font.DemiBold
    }

    Text {
      anchors {
        left: parent.left
        leftMargin: 12
        bottom: parent.bottom
        bottomMargin: 8
      }
      width: parent.width - 24
      elide: Text.ElideRight
      text: tile.busy ? "Working..." : tile.detail
      color: root.theme.muted
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize - 2
    }

    MouseArea {
      id: tileMouse
      anchors.fill: parent
      enabled: !tile.busy
      hoverEnabled: true
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.BusyCursor
      onClicked: tile.activated()
    }
  }

  component ListEntry: Rectangle {
    id: entry

    property string title: ""
    property string detail: ""
    property bool active: false
    property bool busy: false
    signal activated()

    implicitHeight: 34
    radius: 6
    color: entry.active ? root.theme.activeSurface
                        : entryMouse.containsMouse ? root.theme.surfaceHover : "transparent"
    opacity: entry.busy ? 0.65 : 1

    Text {
      anchors {
        left: parent.left
        leftMargin: 10
        right: detailText.left
        rightMargin: 10
        verticalCenter: parent.verticalCenter
      }
      text: entry.title
      color: entry.active ? root.theme.success : root.theme.foreground
      elide: Text.ElideRight
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize - 1
    }

    Text {
      id: detailText
      anchors {
        right: parent.right
        rightMargin: 10
        verticalCenter: parent.verticalCenter
      }
      text: entry.detail
      color: root.theme.muted
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize - 3
    }

    MouseArea {
      id: entryMouse
      anchors.fill: parent
      enabled: !entry.busy
      hoverEnabled: true
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.BusyCursor
      onClicked: entry.activated()
    }
  }

  Shape {
    id: surface
    y: root.retract
    width: parent.width
    height: parent.height
    // CurveRenderer antialiases the arcs analytically, so the curves come out
    // smooth at any resolution.
    preferredRendererType: Shape.CurveRenderer

    readonly property real b: root.theme.borderWidth
    readonly property real h: root.shownHeight
    readonly property real f: root.flare
    readonly property real r: root.cornerRadius
    // Current radius of the top-left flare (0 = straight edge). Kept above 0
    // so the arc never degenerates.
    readonly property real t: Math.max(0.01, root.topFlare)
    // Bottom-right corner morphs in two halves: the convex corner shrinks to a
    // point, then the concave flare grows out of it.
    readonly property bool flared: root.rightBlend >= 0.5
    readonly property real rc: Math.max(0.01, r * Math.max(0, 1 - 2 * root.rightBlend))
    readonly property real tr: Math.max(0.01, f * Math.max(0, 2 * root.rightBlend - 1))
    // With a window open the panel covers the window's right border, so no
    // vertical line shows next to it.
    readonly property real fillEdge: flared ? width : edge
    // Right side sits half a stroke inside the window edge, so the stroke
    // covers exactly the same columns as the Hyprland window borders.
    readonly property real edge: width - b / 2
    // The left flare starts on the same row as the windows' top border.
    readonly property real s: root.theme.windowGap + b / 2

    // Filled body: concave flare on the left, rounded corners at the bottom,
    // straight right side running into the bar.
    ShapePath {
      fillColor: root.theme.popupBackground
      strokeColor: "transparent"
      startX: surface.f - surface.t; startY: 0
      PathLine { x: surface.f - surface.t; y: surface.s }
      PathArc { x: surface.f; y: surface.s + surface.t; radiusX: surface.t; radiusY: surface.t }
      PathLine { x: surface.f; y: surface.h - surface.r }
      PathArc { x: surface.f + surface.r; y: surface.h; radiusX: surface.r; radiusY: surface.r; direction: PathArc.Counterclockwise }
      PathLine { x: surface.edge - surface.tr - surface.rc; y: surface.h }
      PathArc { x: surface.edge - surface.tr; y: surface.h - surface.rc; radiusX: surface.rc; radiusY: surface.rc; direction: PathArc.Counterclockwise }
      PathArc { x: surface.edge; y: surface.h - surface.rc + surface.tr; radiusX: surface.tr; radiusY: surface.tr }
      PathLine { x: surface.fillEdge; y: surface.h - surface.rc + surface.tr }
      PathLine { x: surface.fillEdge; y: 0 }
      PathLine { x: surface.f - surface.t; y: 0 }
    }

    // Outline along the same path, left open at the top where it meets the bar
    // and, with a window open, on the right where the window border takes over.
    ShapePath {
      fillColor: "transparent"
      strokeColor: root.theme.windowBorder
      strokeWidth: surface.b
      capStyle: ShapePath.FlatCap
      joinStyle: ShapePath.RoundJoin
      // Without a flare the outline continues straight up to the bar.
      startX: surface.f - surface.t; startY: surface.s * root.topFlare / surface.f
      PathLine { x: surface.f - surface.t; y: surface.s }
      PathArc { x: surface.f; y: surface.s + surface.t; radiusX: surface.t; radiusY: surface.t }
      PathLine { x: surface.f; y: surface.h - surface.r }
      PathArc { x: surface.f + surface.r; y: surface.h; radiusX: surface.r; radiusY: surface.r; direction: PathArc.Counterclockwise }
      PathLine { x: surface.edge - surface.tr - surface.rc; y: surface.h }
      PathArc { x: surface.edge - surface.tr; y: surface.h - surface.rc; radiusX: surface.rc; radiusY: surface.rc; direction: PathArc.Counterclockwise }
      PathArc { x: surface.edge; y: surface.h - surface.rc + surface.tr; radiusX: surface.tr; radiusY: surface.tr }
    }

    // Right side, only without a window: straight edge up to the bar.
    ShapePath {
      fillColor: "transparent"
      strokeColor: surface.flared ? "transparent" : root.theme.windowBorder
      strokeWidth: surface.b
      capStyle: ShapePath.FlatCap
      startX: surface.edge; startY: surface.h - surface.rc
      PathLine { x: surface.edge; y: 0 }
    }
  }

  // Content is laid out at full height and revealed as the panel extends.
  Item {
    id: body
    x: root.flare
    y: root.retract
    width: root.panelWidth
    height: root.shownHeight
    clip: true

    HoverHandler {
      onHoveredChanged: {
        if (hovered)
          autoClose.stop();
        else if (root.open)
          autoClose.restart();
      }
    }

    ScrollView {
      id: scroll
      x: 10
      y: 10
      width: root.panelWidth - 20
      height: root.panelHeight - 20
      clip: true
      contentWidth: availableWidth
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

      ColumnLayout {
        id: contentColumn
        width: scroll.availableWidth
        spacing: 6

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          ActionTile {
            Layout.fillWidth: true
            title: "󰒃  VPN"
            detail: root.systemState.vpnConnected
              ? (root.systemState.vpnServer || "Connected")
              : "Disconnected"
            active: root.systemState.vpnConnected
            busy: root.systemState.vpnBusy
            onActivated: root.systemState.toggleVpn()
          }

          ActionTile {
            Layout.fillWidth: true
            title: "󰢮  dGPU"
            detail: root.systemState.dgpuConnected ? "Available" : "Detached"
            active: root.systemState.dgpuConnected
            busy: root.systemState.dgpuBusy
            onActivated: root.systemState.toggleDgpu()
          }
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 1
          color: root.theme.separator
        }

        SectionHeader {
          Layout.fillWidth: true
          icon: root.wifiDevice?.connected ? "󰤨" : "󰤭"
          title: "WiFi Networks"
          detail: !Networking.wifiEnabled ? "Off"
                  : root.wifiDevice?.connected ? "Connected" : "On"
          expanded: root.wifiExpanded
          onActivated: root.wifiExpanded = !root.wifiExpanded
        }

        Item {
          id: wifiReveal
          Layout.fillWidth: true
          Layout.preferredHeight: revealHeight
          property real revealHeight: root.wifiExpanded ? wifiColumn.implicitHeight : 0
          clip: true
          opacity: root.wifiExpanded ? 1 : 0

          Behavior on opacity {
            NumberAnimation { duration: 120 }
          }

          ColumnLayout {
            id: wifiColumn
            width: parent.width
            spacing: 2

            Text {
              Layout.fillWidth: true
              Layout.leftMargin: 10
              visible: root.wifiNetworks.length === 0
              text: root.wifiDevice ? "No networks found" : "No WiFi adapter"
              color: root.theme.muted
              font.family: root.theme.fontFamily
              font.pixelSize: root.theme.fontSize - 2
            }

            Repeater {
              model: ScriptModel { values: root.wifiNetworks }

              delegate: ListEntry {
                required property var modelData
                Layout.fillWidth: true
                title: root.wifiIcon(modelData.signalStrength) + "  " + modelData.name
                detail: modelData.stateChanging ? "Connecting"
                        : modelData.connected ? "Connected"
                        : Math.round(modelData.signalStrength * 100) + "%"
                active: modelData.connected
                busy: modelData.stateChanging
                onActivated: {
                  if (modelData.connected)
                    modelData.disconnect();
                  else
                    modelData.connect();
                }
              }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 1
          color: root.theme.separator
        }

        SectionHeader {
          Layout.fillWidth: true
          icon: "󰓃"
          title: "Audio Sinks"
          detail: Pipewire.defaultAudioSink ? root.audioName(Pipewire.defaultAudioSink) : "Unavailable"
          expanded: root.audioExpanded
          onActivated: root.audioExpanded = !root.audioExpanded
        }

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: revealHeight
          property real revealHeight: root.audioExpanded ? audioColumn.implicitHeight : 0
          clip: true
          opacity: root.audioExpanded ? 1 : 0

          Behavior on opacity {
            NumberAnimation { duration: 120 }
          }

          ColumnLayout {
            id: audioColumn
            width: parent.width
            spacing: 2

            Text {
              Layout.fillWidth: true
              Layout.leftMargin: 10
              visible: root.audioSinks.length === 0
              text: "No audio sinks found"
              color: root.theme.muted
              font.family: root.theme.fontFamily
              font.pixelSize: root.theme.fontSize - 2
            }

            Repeater {
              model: ScriptModel { values: root.audioSinks }

              delegate: ListEntry {
                required property var modelData
                Layout.fillWidth: true
                title: root.audioName(modelData)
                detail: modelData === Pipewire.defaultAudioSink ? "Default" : ""
                active: modelData === Pipewire.defaultAudioSink
                onActivated: Pipewire.preferredDefaultAudioSink = modelData
              }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 1
          color: root.theme.separator
        }

        SectionHeader {
          Layout.fillWidth: true
          icon: Bluetooth.defaultAdapter?.enabled ? "󰂯" : "󰂲"
          title: "Bluetooth Devices"
          detail: Bluetooth.defaultAdapter?.enabled ? "On" : "Off"
          expanded: root.bluetoothExpanded
          onActivated: root.bluetoothExpanded = !root.bluetoothExpanded
        }

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: revealHeight
          property real revealHeight: root.bluetoothExpanded ? bluetoothColumn.implicitHeight : 0
          clip: true
          opacity: root.bluetoothExpanded ? 1 : 0

          Behavior on opacity {
            NumberAnimation { duration: 120 }
          }

          ColumnLayout {
            id: bluetoothColumn
            width: parent.width
            spacing: 2

            Text {
              Layout.fillWidth: true
              Layout.leftMargin: 10
              visible: root.bluetoothDevices.length === 0
              text: Bluetooth.defaultAdapter ? "No paired devices" : "No Bluetooth adapter"
              color: root.theme.muted
              font.family: root.theme.fontFamily
              font.pixelSize: root.theme.fontSize - 2
            }

            Repeater {
              model: ScriptModel { values: root.bluetoothDevices }

              delegate: ListEntry {
                required property var modelData
                Layout.fillWidth: true
                title: (modelData.connected ? "󰂱" : "󰂲") + "  " + modelData.name
                detail: root.bluetoothDetail(modelData)
                active: modelData.connected
                busy: modelData.state === BluetoothDeviceState.Connecting
                  || modelData.state === BluetoothDeviceState.Disconnecting
                onActivated: {
                  if (modelData.connected)
                    modelData.disconnect();
                  else
                    modelData.connect();
                }
              }
            }
          }
        }
      }
    }
  }

  Timer {
    id: autoClose
    interval: 2000
    onTriggered: root.systemState.closeControlCenter()
  }
}
