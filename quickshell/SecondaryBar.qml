import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  property var modelData
  readonly property int topInset: 4
  screen: modelData
  anchors.top: true
  anchors.left: true
  anchors.right: true

  color: "transparent"
  implicitHeight: 22 + topInset

  RowLayout {
    anchors.fill: parent
    anchors.topMargin: root.topInset
    anchors.bottomMargin: 0
    anchors.leftMargin: Theme.margin
    anchors.rightMargin: Theme.margin
    spacing: 6

    Workspaces {
      Layout.fillHeight: true
      compact: true
    }

    HardwareStats {
      Layout.fillHeight: true
      barWindow: root
      compact: true
    }

    Item {
      Layout.fillWidth: true
    }

    WifiWidget {
      Layout.fillHeight: true
      barWindow: root
    }

    VolumeWidget {
      Layout.fillHeight: true
      barWindow: root
      compact: true
    }

    Clock {
      Layout.fillHeight: true
    }
  }
}
