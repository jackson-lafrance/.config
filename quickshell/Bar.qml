import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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
    }

    HardwareStats {
      Layout.fillHeight: true
      barWindow: root
    }

    Item {
      Layout.fillWidth: true
    }

    VolumeWidget {
      Layout.fillHeight: true
      barWindow: root
    }

    WifiWidget {
      Layout.fillHeight: true
      barWindow: root
    }

    UtilityWidget {
      Layout.fillHeight: true
      barWindow: root
    }

    MusicWidget {
      Layout.fillHeight: true
      barWindow: root
    }

    Clock {
      Layout.fillHeight: true
    }
  }
}
