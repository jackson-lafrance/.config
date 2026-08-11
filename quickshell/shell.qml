import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
  readonly property var primaryScreens: Quickshell.screens[1] ? [Quickshell.screens[1]] : []
  readonly property var secondaryScreens: [Quickshell.screens[0], Quickshell.screens[2]].filter(function(screen) {
    return screen !== undefined && screen !== null
  })

  Variants {
    model: primaryScreens

    Bar {}
  }

  Variants {
    model: secondaryScreens

    SecondaryBar {}
  }

  DictationWordPopup {}
}
