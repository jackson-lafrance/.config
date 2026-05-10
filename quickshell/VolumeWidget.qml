import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property bool compact: false
  property bool popupOpen: false
  property real currentVolume: 0
  property bool currentMuted: false
  property bool volumeKnown: false
  property string currentSinkName: ""
  property string currentSourceName: ""
  property var sinkDevices: []
  property var sourceDevices: []
  readonly property string volumeGlyph: currentMuted ? "󰝟" : currentVolume < 0.34 ? "󰕿" : currentVolume < 0.67 ? "󰖀" : "󰕾"
  readonly property string volumePercentText: volumeKnown ? `${Math.round(currentVolume * 100)}%` : "--"
  readonly property string sinkLabel: shortDeviceName(currentSinkName || "audio")
  readonly property string sourceLabel: shortDeviceName(currentSourceName || "input")
  readonly property int pillWidth: compact
    ? 40
    : Math.min(Math.max(deviceText.implicitWidth + volumePercentLabel.implicitWidth + 28, 136), 236)

  implicitWidth: pillWidth
  Layout.preferredWidth: pillWidth
  Layout.minimumWidth: pillWidth
  Layout.maximumWidth: pillWidth
  Layout.fillHeight: true
  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse || popupOpen ? Theme.rose : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  function clampVolume(value) {
    const vol = Number(value)
    return isFinite(vol) ? Math.max(0, Math.min(1, vol)) : 0
  }

  function shortDeviceName(name) {
    let value = String(name || "").trim()
    value = value.replace(/\s+(Analog Stereo|Digital Stereo(?:\s*\([^)]*\))?|Mono|Stereo)$/i, "")
    value = value.replace(/\s+\([^)]*\)$/, "")
    return value || "audio"
  }

  function parseStatus(line) {
    const fields = String(line || "").split("\t")
    root.parseVolumeState(fields[0] || "")
    root.currentSinkName = (fields[1] || "").trim()
    root.currentSourceName = (fields[2] || "").trim()
  }

  function parseVolumeState(text) {
    const raw = String(text || "").trim()
    const match = raw.match(/Volume:\s*([0-9]*\.?[0-9]+)/i)
    if (!match || match[1] === undefined) {
      return
    }

    root.currentVolume = root.clampVolume(match[1])
    root.currentMuted = /\[MUTED\]/i.test(raw)
    root.volumeKnown = true
  }

  function parseDeviceList(text) {
    const sinks = []
    const sources = []
    const lines = String(text || "").split(/\r?\n/)

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (!line) {
        continue
      }

      const bits = line.split("\t")
      if (bits.length < 4) {
        continue
      }

      const item = {
        active: bits[1] === "1",
        id: bits[2].trim(),
        name: bits.slice(3).join("\t").trim(),
      }

      if (bits[0] === "sink") {
        sinks.push(item)
      } else if (bits[0] === "source") {
        sources.push(item)
      }
    }

    root.sinkDevices = sinks
    root.sourceDevices = sources
  }

  function setVolume(value) {
    const vol = root.clampVolume(value)
    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", String(vol)])
    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
    root.currentVolume = vol
    root.currentMuted = false
    root.volumeKnown = true
  }

  function setVolumeFromMouse(x, width) {
    if (!root.volumeKnown || width <= 0) {
      return
    }

    root.setVolume(x / width)
  }

  function toggleMute() {
    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    root.currentMuted = !root.currentMuted
    root.volumeKnown = true
  }

  function setDefaultDevice(id) {
    if (!id) {
      return
    }

    Quickshell.execDetached(["wpctl", "set-default", String(id)])
    root.refreshDevices()
  }

  function refreshDevices() {
    deviceScanner.exec(["stdbuf", "-oL", "sh", "-c", root.deviceScanScript])
  }

  property string statusScript: `
describe_default() {
  wpctl inspect "$1" 2>/dev/null | awk -F'"' '
    /node.description/ {
      print $2
      found = 1
      exit
    }
    /node.nick/ && nick == "" {
      nick = $2
    }
    END {
      if (!found) {
        print nick
      }
    }
  '
}

while :; do
  volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  sink=$(describe_default @DEFAULT_AUDIO_SINK@)
  source=$(describe_default @DEFAULT_AUDIO_SOURCE@)
  printf '%s\t%s\t%s\n' "$volume" "$sink" "$source"
  sleep 2
done
`

  property string deviceScanScript: `
describe_node() {
  wpctl inspect "$1" 2>/dev/null | awk -F'"' '
    /node.description/ {
      print $2
      found = 1
      exit
    }
    /node.nick/ && nick == "" {
      nick = $2
    }
    END {
      if (!found) {
        print nick
      }
    }
  '
}

wpctl status 2>/dev/null | awk '
  /^Audio$/ {
    audio = 1
    section = ""
    next
  }
  /^Video$/ {
    audio = 0
    section = ""
    next
  }
  audio && /Sinks:/ {
    section = "sink"
    next
  }
  audio && /Sources:/ {
    section = "source"
    next
  }
  audio && /Filters:/ {
    section = ""
  }
  audio && section != "" && match($0, /([0-9]+)\./, ids) {
    active = index($0, "*") ? 1 : 0
    print section "\t" active "\t" ids[1]
  }
' | while read -r section active id; do
  [ -n "$id" ] || continue
  description=$(describe_node "$id")
  printf '%s\t%s\t%s\t%s\n' "$section" "$active" "$id" "$description"
done
`

  Process {
    running: true
    command: ["stdbuf", "-oL", "sh", "-c", root.statusScript]
    stdout: SplitParser {
      onRead: function(line) {
        root.parseStatus(line)
      }
    }
  }

  Process {
    id: deviceScanner
    running: false
    command: ["stdbuf", "-oL", "sh", "-c", root.deviceScanScript]
    stdout: StdioCollector {
      onStreamFinished: function() {
        root.parseDeviceList(this.text)
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.popupOpen = !root.popupOpen
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    spacing: 8
    visible: !root.compact

    Text {
      id: deviceText
      Layout.fillWidth: true
      text: root.sinkLabel
      color: Theme.rose
      elide: Text.ElideNone
      clip: true
      font.pointSize: 11
      font.family: "AgaveNerdFontMono"
      font.bold: true
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: volumePercentLabel
      text: root.volumePercentText
      color: root.currentMuted ? Theme.subtle : Theme.foam
      font.pointSize: 10
      font.family: "AgaveNerdFontMono"
      font.bold: true
      verticalAlignment: Text.AlignVCenter
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.compact
    text: root.volumeGlyph
    color: root.currentMuted ? Theme.subtle : Theme.rose
    font.pointSize: 12
    font.family: "AgaveNerdFontMono"
    font.bold: true
  }

  PopupWindow {
    id: popup
    anchor.window: root.barWindow
    anchor.rect.x: root.x + root.width / 2 - width / 2
    anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : root.height + 6
    implicitWidth: 308
    implicitHeight: 296
    color: "transparent"
    visible: root.popupOpen

    onVisibleChanged: {
      if (!visible) {
        root.popupOpen = false
      } else {
        root.refreshDevices()
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
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          Text {
            Layout.fillWidth: true
            text: root.sinkLabel
            color: Theme.rose
            elide: Text.ElideNone
            clip: true
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
          }

          Text {
            text: root.volumeKnown ? `${Math.round(root.currentVolume * 100)}%` : "n/a"
            color: Theme.foam
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
          }

          PanelButton {
            text: root.currentMuted ? "unmute" : "mute"
            accent: Theme.foam
            checked: root.currentMuted
            onClicked: root.toggleMute()
          }
        }

        Item {
          Layout.fillWidth: true
          implicitHeight: 18
          opacity: root.volumeKnown ? 1 : 0.45

          Rectangle {
            x: 0
            y: parent.height / 2 - height / 2
            width: parent.width
            height: 8
            radius: 4
            color: Theme.overlay
            clip: true

            Rectangle {
              width: Math.max(0, Math.min(1, root.currentVolume)) * parent.width
              height: parent.height
              radius: 4
              color: Theme.foam
            }
          }

          Rectangle {
            x: Math.max(0, Math.min(1, root.currentVolume)) * (parent.width - width)
            y: parent.height / 2 - height / 2
            width: 18
            height: 18
            radius: 9
            color: root.currentMuted ? Theme.subtle : Theme.rose
            border.width: 1
            border.color: Theme.surface
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.volumeKnown
            hoverEnabled: true
            preventStealing: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            function applyVolume(mouseX) {
              root.setVolumeFromMouse(mouseX, width)
            }

            onPressed: applyVolume(mouse.x)
            onPositionChanged: if (pressed) applyVolume(mouse.x)
            onReleased: applyVolume(mouse.x)
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "out"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 26
          }

          Text {
            Layout.fillWidth: true
            text: root.sinkLabel
            color: Theme.rose
            elide: Text.ElideNone
            clip: true
            font.family: "AgaveNerdFontMono"
            font.pointSize: 10
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "in"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 26
          }

          Text {
            Layout.fillWidth: true
            text: root.sourceLabel
            color: Theme.foam
            elide: Text.ElideNone
            clip: true
            font.family: "AgaveNerdFontMono"
            font.pointSize: 10
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Theme.highlightLow
          opacity: 0.8
        }

        Flickable {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          contentWidth: width
          contentHeight: deviceContent.implicitHeight
          boundsBehavior: Flickable.StopAtBounds

          ColumnLayout {
            id: deviceContent
            width: parent.width
            spacing: 10

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 4

              Text {
                Layout.fillWidth: true
                text: "outputs"
                color: Theme.subtle
                font.family: "AgaveNerdFontMono"
                font.bold: true
                font.pointSize: 10
              }

              Repeater {
                model: root.sinkDevices

                delegate: Rectangle {
                  required property var modelData
                  Layout.fillWidth: true
                  implicitHeight: 28
                  radius: 10
                  color: modelData.active ? Theme.highlightMed : Theme.overlay
                  border.width: 1
                  border.color: modelData.active ? Theme.rose : Theme.highlightLow

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setDefaultDevice(modelData.id)
                  }

                  RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Text {
                      Layout.fillWidth: true
                      text: root.shortDeviceName(modelData.name)
                      color: modelData.active ? Theme.rose : Theme.text
                      font.family: "AgaveNerdFontMono"
                      font.pointSize: 10
                      elide: Text.ElideNone
                      clip: true
                    }

                    Text {
                      text: modelData.active ? "default" : "set"
                      color: modelData.active ? Theme.foam : Theme.subtle
                      font.family: "AgaveNerdFontMono"
                      font.pointSize: 10
                    }
                  }
                }
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 4

              Text {
                Layout.fillWidth: true
                text: "inputs"
                color: Theme.subtle
                font.family: "AgaveNerdFontMono"
                font.bold: true
                font.pointSize: 10
              }

              Repeater {
                model: root.sourceDevices

                delegate: Rectangle {
                  required property var modelData
                  Layout.fillWidth: true
                  implicitHeight: 28
                  radius: 10
                  color: modelData.active ? Theme.highlightMed : Theme.overlay
                  border.width: 1
                  border.color: modelData.active ? Theme.foam : Theme.highlightLow

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setDefaultDevice(modelData.id)
                  }

                  RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Text {
                      Layout.fillWidth: true
                      text: root.shortDeviceName(modelData.name)
                      color: modelData.active ? Theme.foam : Theme.text
                      font.family: "AgaveNerdFontMono"
                      font.pointSize: 10
                      elide: Text.ElideNone
                      clip: true
                    }

                    Text {
                      text: modelData.active ? "default" : "set"
                      color: modelData.active ? Theme.rose : Theme.subtle
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
    }
  }
}
