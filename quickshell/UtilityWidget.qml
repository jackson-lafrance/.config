import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property bool popupOpen: false
  readonly property int pillWidth: Math.min(Math.max(utilText.implicitWidth + 12, 60), 72)

  implicitWidth: pillWidth
  Layout.preferredWidth: pillWidth
  Layout.minimumWidth: pillWidth
  Layout.maximumWidth: pillWidth
  Layout.fillHeight: true
  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse || popupOpen ? Theme.gold : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.popupOpen = !root.popupOpen
  }

  Text {
    id: utilText
    anchors.centerIn: parent
    width: parent.width - 8
    font.pointSize: 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    text: "util"
    horizontalAlignment: Text.AlignHCenter
    color: Theme.gold
    elide: Text.ElideRight
  }

  PopupWindow {
    id: popup
    anchor.window: root.barWindow
    anchor.rect.x: root.x + root.width / 2 - width / 2
    anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : root.height + 6
    implicitWidth: 176
    implicitHeight: utilContent.implicitHeight + 12
    color: "transparent"
    visible: root.popupOpen

    onVisibleChanged: if (!visible) root.popupOpen = false

    HyprlandFocusGrab {
      active: root.popupOpen
      windows: [popup]
      onCleared: root.popupOpen = false
    }

    Rectangle {
      anchors.fill: parent
      color: Theme.surface
      border.width: 1.5
      border.color: Theme.highlightMed
      radius: 14

      ColumnLayout {
        id: utilContent
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: implicitHeight
          spacing: 6

          PanelButton {
            Layout.fillWidth: true
            text: "shot"
            accent: Theme.foam
            onClicked: Quickshell.execDetached(["sh", "-c", "grim -g \"$(slurp)\" - | wl-copy"])
          }

          PanelButton {
            Layout.fillWidth: true
            text: "pick"
            accent: Theme.gold
            onClicked: Quickshell.execDetached(["hyprpicker", "-a", "-f", "hex", "-l"])
          }
        }
      }
    }
  }
}
