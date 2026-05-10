import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property bool compact: false
  Layout.fillHeight: true
  implicitWidth: compact ? activeWorkspaceText.implicitWidth + 24 : layout.implicitWidth + 24
  Layout.preferredWidth: implicitWidth
  Layout.minimumWidth: implicitWidth
  Layout.maximumWidth: implicitWidth
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

  function currentWorkspaceLabel() {
    return Hyprland.focusedWorkspace ? `ws ${Hyprland.focusedWorkspace.id}` : "ws -"
  }

  MouseArea {
    id: rectangleMouse
    anchors.fill: parent
    hoverEnabled: true
  }

  Text {
    id: activeWorkspaceText
    anchors.centerIn: parent
    visible: root.compact
    text: root.currentWorkspaceLabel()
    font.pointSize: 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    color: Theme.foam
  }

  RowLayout {
    id: layout
    anchors.centerIn: parent
    visible: !root.compact
    spacing: 12

    Repeater {
      model: 5
      Rectangle {
        width: 10
        height: 10
        radius: 2
        property var ws: Hyprland.workspaces.values.find(function(workspace) {
          return workspace.id === index + 1
        })
        property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)
        color: isActive ? Theme.foam : wsMouseArea.containsMouse ? Theme.rose : Theme.pine

        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
          }
        }

        MouseArea {
          id: wsMouseArea
          anchors.fill: parent
          anchors.margins: -5
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          onClicked: Hyprland.dispatch("workspace " + (index + 1))
        }
      }
    }
  }
}
