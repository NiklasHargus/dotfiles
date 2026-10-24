import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
  id: root

  property bool barVisible: true
  property string activePopupScreen: ""

  property int memoryPercent: 0
  property int brightnessPercent: 0
  property bool brightnessAvailable: false

  property bool vpnConnected: false
  property string vpnServer: ""
  property bool vpnBusy: false
  property bool dgpuConnected: false
  property bool dgpuBusy: false

  readonly property string legacyScriptDir: Quickshell.env("HOME") + "/.config/eww/scripts"

  function toggleBar(): void {
    barVisible = !barVisible;
    if (!barVisible)
      closeControlCenter();
  }

  function showBar(): void {
    barVisible = true;
  }

  function hideBar(): void {
    barVisible = false;
    closeControlCenter();
  }

  function toggleControlCenter(screenName: string): void {
    activePopupScreen = activePopupScreen === screenName ? "" : screenName;
  }

  function closeControlCenter(): void {
    activePopupScreen = "";
  }

  function refreshMemory(): void {
    memoryFile.reload();
    const contents = memoryFile.text();
    const totalMatch = /^MemTotal:\s+(\d+)/m.exec(contents);
    const availableMatch = /^MemAvailable:\s+(\d+)/m.exec(contents);

    if (totalMatch && availableMatch) {
      const total = Number(totalMatch[1]);
      const available = Number(availableMatch[1]);
      memoryPercent = Math.round((total - available) / total * 100);
    }
  }

  function refreshBrightness(): void {
    brightnessFile.reload();
    maxBrightnessFile.reload();

    const current = Number(brightnessFile.text().trim());
    const maximum = Number(maxBrightnessFile.text().trim());
    brightnessAvailable = Number.isFinite(current) && Number.isFinite(maximum) && maximum > 0;

    if (brightnessAvailable)
      brightnessPercent = Math.round(current / maximum * 100);
  }

  function setBrightness(value: real): void {
    pendingBrightness = Math.max(0, Math.min(100, Math.round(value)));
    brightnessPercent = pendingBrightness;
    brightnessWrite.restart();
  }

  function refreshControls(): void {
    if (activePopupScreen === "")
      return;

    if (!vpnStatusProcess.running)
      vpnStatusProcess.running = true;
    if (!vpnServerProcess.running)
      vpnServerProcess.running = true;
    if (!dgpuStatusProcess.running)
      dgpuStatusProcess.running = true;
  }

  function toggleVpn(): void {
    if (vpnBusy)
      return;

    vpnBusy = true;
    vpnToggleProcess.running = true;
  }

  function toggleDgpu(): void {
    if (dgpuBusy)
      return;

    dgpuBusy = true;
    dgpuToggleProcess.running = true;
  }

  property int pendingBrightness: brightnessPercent

  FileView {
    id: memoryFile
    path: "/proc/meminfo"
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: brightnessFile
    path: "/sys/class/backlight/intel_backlight/brightness"
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: maxBrightnessFile
    path: "/sys/class/backlight/intel_backlight/max_brightness"
    blockLoading: true
    printErrors: false
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refreshMemory()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      if (!brightnessWrite.running && !brightnessRefresh.running)
        root.refreshBrightness();
    }
  }

  Timer {
    id: brightnessWrite
    interval: 60
    onTriggered: {
      Quickshell.execDetached(["brightnessctl", "set", root.pendingBrightness + "%"]);
      brightnessRefresh.restart();
    }
  }

  Timer {
    id: brightnessRefresh
    interval: 250
    onTriggered: root.refreshBrightness()
  }

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  Process {
    id: vpnStatusProcess
    command: [root.legacyScriptDir + "/get-vpn-status.sh"]
    stdout: StdioCollector {
      onStreamFinished: root.vpnConnected = text.trim() === "true"
    }
  }

  Process {
    id: vpnServerProcess
    command: [root.legacyScriptDir + "/get-vpn-server.sh"]
    stdout: StdioCollector {
      onStreamFinished: root.vpnServer = text.trim()
    }
  }

  Process {
    id: dgpuStatusProcess
    command: [root.legacyScriptDir + "/get-dgpu-status.sh"]
    stdout: StdioCollector {
      onStreamFinished: root.dgpuConnected = text.trim() === "true"
    }
  }

  Process {
    id: vpnToggleProcess
    command: [root.legacyScriptDir + "/toggle-vpn"]
    onExited: {
      root.vpnBusy = false;
      controlRefreshDelay.restart();
    }
  }

  Process {
    id: dgpuToggleProcess
    command: [root.legacyScriptDir + "/toggle-dgpu"]
    onExited: {
      root.dgpuBusy = false;
      controlRefreshDelay.restart();
    }
  }

  Timer {
    interval: 2000
    running: root.activePopupScreen !== ""
    repeat: true
    onTriggered: root.refreshControls()
  }

  Timer {
    id: controlRefreshDelay
    interval: 350
    onTriggered: root.refreshControls()
  }

  onActivePopupScreenChanged: {
    if (activePopupScreen !== "")
      refreshControls();
  }

  Component.onCompleted: {
    refreshMemory();
    refreshBrightness();
  }
}
