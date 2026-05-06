import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
  Layout.fillHeight: true
  width: clock.implicitWidth + 30 
  color: Theme.surface
  border.width: 1.5
  border.color: rectangleMouse.containsMouse ? Theme.love : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  MouseArea {
    id: rectangleMouse
    anchors.fill: parent
    hoverEnabled: true
  }

  Text {
    id: clock
    anchors.centerIn: parent
    font.pointSize: 12
    font.family: "AgaveNerdFontMono"
    font.bold: true

    text: Qt.formatDateTime(new Date(), "dd - HH:mm")
    color: Theme.rose

    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: clock.text = Qt.formatDateTime(new Date(), "dd - HH:mm")
    }
  }
}
