import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
  Variants {
    model: [Quickshell.screens[1]]

    Bar {}
  }

  Variants {
    model: [Quickshell.screens[0], Quickshell.screens[2]]

    PanelWindow {
      property var modelData
      screen: modelData
      anchors.top: true
      anchors.left: true
      anchors.right: true

      implicitHeight: 32 
      color: "transparent"

      Rectangle {
        anchors.fill: parent
        anchors.topMargin: Theme.margin / 2
        anchors.leftMargin: Theme.margin
        anchors.rightMargin: Theme.margin
        color: Theme.surface
        radius: 10
      }
    } 
  }
}
