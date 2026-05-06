import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  property var modelData
  screen: modelData
  anchors.top: true
  anchors.left: true
  anchors.right: true

  color: "transparent"
  implicitHeight: 32

  RowLayout {
    anchors.fill: parent
    anchors.topMargin: Theme.margin / 2
    anchors.leftMargin: Theme.margin
    anchors.rightMargin: Theme.margin
    spacing: Theme.margin

    Workspaces {
      Layout.fillHeight: true
    }

    Item {
      Layout.fillWidth: true
    }

    Clock {
      Layout.fillHeight: true
    }
  }
}
