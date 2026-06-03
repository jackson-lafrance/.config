import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property bool popupOpen: false
  readonly property int itemCount: SystemTray.items.values.length
  readonly property int iconSize: 18
  readonly property int itemSize: 26
  readonly property int pillWidth: itemCount > 0 ? Math.min(Math.max(trayText.implicitWidth + 16, 54), 72) : 0

  implicitWidth: pillWidth
  Layout.preferredWidth: pillWidth
  Layout.minimumWidth: pillWidth
  Layout.maximumWidth: pillWidth
  Layout.fillHeight: true
  visible: itemCount > 0

  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse || popupOpen ? Theme.rose : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 200
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
    id: trayText
    anchors.centerIn: parent
    width: parent.width - 8
    font.pointSize: 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    text: itemCount > 1 ? "tray " + itemCount : "tray"
    horizontalAlignment: Text.AlignHCenter
    color: Theme.rose
    elide: Text.ElideRight
  }

  PopupWindow {
    id: popup
    anchor.window: root.barWindow
    anchor.rect.x: root.x + root.width / 2 - width / 2
    anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : root.height + 6
    implicitWidth: Math.max(148, trayContent.implicitWidth + 12)
    implicitHeight: trayContent.implicitHeight + 12
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
        id: trayContent
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Text {
          Layout.fillWidth: true
          text: "background apps"
          color: Theme.subtle
          font.family: "AgaveNerdFontMono"
          font.bold: true
          font.pointSize: 8
          horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 6

          Repeater {
            model: SystemTray.items

            delegate: MouseArea {
              id: trayItem
              required property SystemTrayItem modelData

              Layout.preferredWidth: root.itemSize
              Layout.preferredHeight: root.itemSize
              acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              function openMenu() {
                if (!root.barWindow || !modelData.hasMenu) {
                  return false
                }

                modelData.display(root.barWindow, root.x + root.width / 2, root.barWindow.height + 6)
                return true
              }

              onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                  if (!openMenu()) {
                    modelData.activate()
                  }
                } else if (mouse.button === Qt.RightButton) {
                  openMenu()
                } else if (mouse.button === Qt.MiddleButton) {
                  modelData.secondaryActivate()
                }
              }

              Rectangle {
                anchors.fill: parent
                radius: 8
                color: trayItem.containsMouse ? Theme.highlightMed : Theme.overlay
                border.width: 1
                border.color: trayItem.containsMouse ? Theme.rose : Theme.highlightLow

                Behavior on color {
                  ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                  }
                }
              }

              IconImage {
                anchors.centerIn: parent
                width: root.iconSize
                height: root.iconSize
                source: trayItem.modelData.icon
                asynchronous: true
                mipmap: true
              }
            }
          }
        }
      }
    }
  }
}
