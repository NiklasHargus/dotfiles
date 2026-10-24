import QtQuick

QtObject {
  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property int fontSize: 16

  // Keep in sync with hyprland general:gaps_out / general:border_size.
  readonly property int windowGap: 2
  readonly property int borderWidth: 2

  readonly property color foreground: "#cdd6f4"
  readonly property color muted: "#9399b2"
  readonly property color accent: "#d35d6e"
  readonly property color success: "#a6e3a1"
  readonly property color warning: "#f9e2af"
  readonly property color error: "#f38ba8"

  readonly property color barBackground: Qt.rgba(0, 0, 0, 0.22)
  readonly property color popupBackground: Qt.rgba(0.055, 0.055, 0.085, 0.94)
  readonly property color surface: Qt.rgba(0.80, 0.84, 0.96, 0.08)
  readonly property color surfaceHover: Qt.rgba(0.80, 0.84, 0.96, 0.15)
  readonly property color activeSurface: Qt.rgba(0.65, 0.89, 0.63, 0.15)
  readonly property color border: Qt.rgba(0.80, 0.84, 0.96, 0.55)
  // How hyprland's general:col.active_border (rgba(205,214,244,0.7)) looks
  // on screen over the dark wallpaper. Opaque, so it looks identical no matter
  // what is behind the panel.
  readonly property color windowBorder: "#979eb3"
  readonly property color separator: Qt.rgba(0.80, 0.84, 0.96, 0.35)
  readonly property color track: Qt.rgba(0.80, 0.84, 0.96, 0.20)
  readonly property color transparent: Qt.rgba(0.0, 0.0, 0.0, 0.0)
}
