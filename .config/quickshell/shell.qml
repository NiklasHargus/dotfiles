//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: shell

  Theme {
    id: themeData
  }

  SystemState {
    id: stateData
  }

  IpcHandler {
    target: "bar"

    function toggle(): void {
      stateData.toggleBar();
    }

    function showBar(): void {
      stateData.showBar();
    }

    function hideBar(): void {
      stateData.hideBar();
    }

    function isVisible(): bool {
      return stateData.barVisible;
    }

    function openControlCenter(screenName: string): void {
      stateData.activePopupScreen = screenName;
    }

    function closeControlCenter(): void {
      stateData.closeControlCenter();
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Bar {
      required property ShellScreen modelData

      screen: modelData
      theme: themeData
      systemState: stateData
    }
  }
}
