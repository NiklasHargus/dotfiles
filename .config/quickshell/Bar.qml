import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Wayland

PanelWindow {
  id: root

  required property var theme
  required property var systemState

  readonly property var audioSink: Pipewire.defaultAudioSink
  readonly property var battery: UPower.displayDevice

  visible: systemState.barVisible
  implicitHeight: 32
  exclusiveZone: 32
  color: "transparent"

  anchors {
    top: true
    left: true
    right: true
  }

  WlrLayershell.namespace: "quickshell-bar"

  Rectangle {
    anchors.fill: parent
    color: root.theme.barBackground
  }

  Workspaces {
    anchors {
      left: parent.left
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
    theme: root.theme
  }

  Tray {
    anchors.centerIn: parent
    theme: root.theme
    parentWindow: root
  }

  RowLayout {
    anchors {
      right: parent.right
      rightMargin: 10
      top: parent.top
      bottom: parent.bottom
    }
    spacing: 10

    MetricSlider {
      visible: root.systemState.brightnessAvailable
      theme: root.theme
      icon: ""
      value: root.systemState.brightnessPercent
      onMoved: value => root.systemState.setBrightness(value)
    }

    MetricSlider {
      visible: root.audioSink?.audio !== null && root.audioSink?.audio !== undefined
      theme: root.theme
      icon: root.audioSink?.audio.muted || (root.audioSink?.audio.volume ?? 0) === 0 ? "" : ""
      value: (root.audioSink?.audio.volume ?? 0) * 100
      maximum: 101
      iconClickable: true
      onMoved: value => {
        if (root.audioSink?.audio) {
          root.audioSink.audio.volume = value / 100;
          if (value > 0 && root.audioSink.audio.muted)
            root.audioSink.audio.muted = false;
        }
      }
      onIconClicked: {
        if (root.audioSink?.audio)
          root.audioSink.audio.muted = !root.audioSink.audio.muted;
      }
    }

    Text {
      text: " " + root.systemState.memoryPercent + "%"
      color: root.theme.foreground
      font.family: root.theme.fontFamily
      Layout.fillHeight: true
      font.pixelSize: root.theme.fontSize
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      visible: root.battery?.isLaptopBattery ?? false
      text: {
        const charging = root.battery?.state === UPowerDeviceState.Charging
          || root.battery?.state === UPowerDeviceState.PendingCharge;
        return (charging ? "󰂄" : "󰁹") + Math.round((root.battery?.percentage ?? 0) * 100) + "%";
      }
      color: (root.battery?.percentage ?? 1) < 0.15 ? root.theme.error : root.theme.foreground
      font.family: root.theme.fontFamily
      font.pixelSize: root.theme.fontSize
      Layout.fillHeight: true
      verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
      id: clockButton
      Layout.preferredWidth: clockText.implicitWidth + 14
      Layout.fillHeight: true
      color: clockMouse.containsMouse || controlCenter.open ? root.theme.surfaceHover : "transparent"
      radius: 6

      SystemClock {
        id: clock
        precision: SystemClock.Minutes
      }

      Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: controlCenter.open ? root.theme.accent : root.theme.foreground
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.fontSize
        font.weight: Font.DemiBold
      }

      MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.systemState.toggleControlCenter(root.screen.name)
      }
    }
  }

  ControlCenter {
    id: controlCenter
    theme: root.theme
    systemState: root.systemState
    screenName: root.screen.name
    barWindow: root
  }
}
