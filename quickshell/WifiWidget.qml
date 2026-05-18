import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property bool popupOpen: false
  property bool wifiEnabled: false
  property string wifiConnection: ""
  property string wifiDeviceName: ""
  property string ethernetDevice: ""
  property string ethernetConnection: ""
  property var wifiNetworks: []
  readonly property int pillWidth: Math.min(Math.max(wifiText.implicitWidth + 18, 100), 164)
  readonly property int networkRowHeight: 24
  readonly property int networkListSpacing: 4
  readonly property int networkVisibleRows: 4
  readonly property int visibleNetworkRows: Math.min(root.wifiNetworks.length, root.networkVisibleRows)
  readonly property int networkListHeight: root.visibleNetworkRows > 0
    ? root.visibleNetworkRows * root.networkRowHeight + (root.visibleNetworkRows - 1) * root.networkListSpacing
    : 0

  implicitWidth: pillWidth
  Layout.preferredWidth: pillWidth
  Layout.minimumWidth: pillWidth
  Layout.maximumWidth: pillWidth
  Layout.fillHeight: true
  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse || popupOpen ? Theme.foam : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function updateStatus(line) {
    const fields = line.trim().split(";")
    root.wifiEnabled = (fields[0] || "").trim() !== "disabled"
    root.wifiConnection = (fields[1] || "").trim()
    root.wifiDeviceName = (fields[2] || "").trim()

    const ethernet = (fields[3] || "").trim().split("|")
    root.ethernetDevice = (ethernet[0] || "").trim()
    root.ethernetConnection = (ethernet[1] || "").trim()
  }

  function parseWifiScan(text) {
    const next = []
    const lines = text.split(/\r?\n/)

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (!line) {
        continue
      }

      const bits = line.split(":")
      if (bits.length < 4) {
        continue
      }

      const ssid = bits[0].replace(/\\:/g, ":")
      if (!ssid) {
        continue
      }

      next.push({
        ssid: ssid,
        signal: Number(bits[1]) || 0,
        security: bits[2] || "",
        active: bits.slice(3).join(":").trim() === "*",
      })
    }

    next.sort((a, b) => b.signal - a.signal)
    root.wifiNetworks = next
  }

  function scanWifi() {
    wifiScanner.exec(["sh", "-c", root.wifiScanScript])
  }

  function connectToWifi(network) {
    if (!network || !network.ssid) {
      return
    }

    if (network.active && root.wifiDeviceName) {
      Quickshell.execDetached(["nmcli", "dev", "disconnect", root.wifiDeviceName])
      return
    }

    Quickshell.execDetached(["sh", "-c", `nmcli dev wifi connect ${root.shellQuote(network.ssid)}`])
  }

  function toggleWifi() {
    Quickshell.execDetached(["sh", "-c", root.wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"])
  }

  function wifiSummary() {
    if (root.wifiConnection) {
      return root.wifiConnection
    }

    if (root.ethernetConnection) {
      return root.ethernetConnection
    }

    if (!root.wifiEnabled) {
      return "wifi off"
    }

    return "offline"
  }

  property string statusScript: `
while :; do
  wifi_enabled=$(nmcli radio wifi 2>/dev/null)
  wifi_connection=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '
    $2 == "802-11-wireless" {
      print $1
      found = 1
      exit
    }
    END {
      if (!found) {
        print ""
      }
    }
  ')
  wifi_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '
    $2 == "wifi" {
      print $1
      found = 1
      exit
    }
    END {
      if (!found) {
        print ""
      }
    }
  ')
  ethernet=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null | awk -F: '
    $2 == "ethernet" && $3 == "connected" {
      print $1 "|" $4
      found = 1
      exit
    }
    END {
      if (!found) {
        print "|"
      }
    }
  ')
  echo "$wifi_enabled;$wifi_connection;$wifi_device;$ethernet"
  sleep 2
done
`

  property string wifiScanScript: `
nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list --rescan no 2>/dev/null
`

  Process {
    running: true
    command: ["stdbuf", "-oL", "sh", "-c", root.statusScript]
    stdout: SplitParser {
      onRead: function(line) {
        root.updateStatus(line)
      }
    }
  }

  Process {
    id: wifiScanner
    running: false
    command: ["stdbuf", "-oL", "sh", "-c", root.wifiScanScript]
    stdout: StdioCollector {
      onStreamFinished: function() {
        root.parseWifiScan(this.text)
      }
    }
  }

  Component.onCompleted: root.scanWifi()

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.popupOpen = !root.popupOpen
  }

  Text {
    id: wifiText
    anchors.centerIn: parent
    width: parent.width - 10
    font.pointSize: 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    text: root.wifiSummary()
    horizontalAlignment: Text.AlignHCenter
    color: root.wifiConnection ? Theme.foam : root.ethernetConnection ? Theme.gold : Theme.subtle
    elide: Text.ElideRight
  }

  PopupWindow {
    id: popup
    anchor.window: root.barWindow
    anchor.rect.x: root.x + root.width / 2 - width / 2
    anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : root.height + 6
    implicitWidth: 264
    implicitHeight: wifiContent.implicitHeight + 12
    color: "transparent"
    visible: root.popupOpen

    onVisibleChanged: {
      if (!visible) {
        root.popupOpen = false
      } else {
        root.scanWifi()
      }
    }

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
        id: wifiContent
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        GridLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: implicitHeight
          columns: 3
          columnSpacing: 6
          rowSpacing: 6

          PanelButton {
            text: root.wifiEnabled ? "off" : "on"
            accent: Theme.foam
            checked: root.wifiEnabled
            onClicked: root.toggleWifi()
          }

          PanelButton {
            text: "scan"
            accent: Theme.gold
            onClicked: root.scanWifi()
          }

          PanelButton {
            text: "edit"
            accent: Theme.rose
            onClicked: Quickshell.execDetached(["nm-connection-editor"])
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: implicitHeight
          spacing: 6

          Text {
            text: "ethernet"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 58
          }

          Text {
            Layout.fillWidth: true
            text: root.ethernetConnection ? `${root.ethernetDevice} · ${root.ethernetConnection}` : "no wired link"
            color: Theme.rose
            elide: Text.ElideRight
            font.family: "AgaveNerdFontMono"
            font.pointSize: 10
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          height: 1
          color: Theme.highlightLow
          opacity: 0.8
        }

        Text {
          Layout.fillWidth: true
          Layout.preferredHeight: implicitHeight
          visible: root.wifiNetworks.length === 0
          text: "no networks found"
          color: Theme.subtle
          font.family: "AgaveNerdFontMono"
          font.pointSize: 10
        }

        ListView {
          Layout.fillWidth: true
          Layout.preferredHeight: visible ? root.networkListHeight : 0
          Layout.maximumHeight: root.networkRowHeight * root.networkVisibleRows + root.networkListSpacing * (root.networkVisibleRows - 1)
          visible: root.wifiNetworks.length > 0
          clip: true
          spacing: root.networkListSpacing
          model: root.wifiNetworks

          delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: root.networkRowHeight
            radius: 10
            color: modelData.active ? Theme.highlightMed : Theme.overlay
            border.width: 1
            border.color: modelData.active ? Theme.foam : Theme.highlightLow

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.connectToWifi(modelData)
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 8
              anchors.rightMargin: 8
              spacing: 8

              Text {
                Layout.fillWidth: true
                text: modelData.ssid
                color: modelData.active ? Theme.foam : Theme.text
                font.family: "AgaveNerdFontMono"
                font.pointSize: 10
                elide: Text.ElideRight
              }

              Text {
                text: `${Math.round(modelData.signal)}%`
                color: Theme.subtle
                font.family: "AgaveNerdFontMono"
                font.pointSize: 10
              }

              Text {
                text: modelData.security && modelData.security !== "" ? modelData.security : "open"
                color: modelData.security && modelData.security !== "" ? Theme.rose : Theme.gold
                font.family: "AgaveNerdFontMono"
                font.pointSize: 10
              }
            }
          }
        }
      }
    }
  }
}
