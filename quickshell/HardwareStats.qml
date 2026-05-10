import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property bool compact: false
  property bool popupOpen: false
  property real cpuUsage: 0
  property real memoryUsage: 0
  property real cpuTemp: 0
  property var prevCpu: ({ total: 0, idle: 0 })
  property string uptimeText: "up --"
  property string tempPath: ""

  implicitWidth: compact
    ? Math.min(Math.max(statsText.implicitWidth + 24, 118), 182)
    : Math.max(statsText.implicitWidth + 32, 190)
  Layout.preferredWidth: implicitWidth
  Layout.minimumWidth: implicitWidth
  Layout.maximumWidth: implicitWidth
  Layout.fillHeight: true
  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse || popupOpen ? Theme.love : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  function parseCpuSample(text) {
    const parts = text.trim().split(/\s+/)
    if (parts[0] !== "cpu" || parts.length < 6) {
      return null
    }

    const nums = parts.slice(1).map(Number)
    return {
      total: nums.reduce((sum, n) => sum + (isFinite(n) ? n : 0), 0),
      idle: (nums[3] || 0) + (nums[4] || 0),
    }
  }

  function parseMemoryUsage(text) {
    const totalMatch = text.match(/^MemTotal:\s+(\d+)/m)
    const availableMatch = text.match(/^MemAvailable:\s+(\d+)/m)
    const total = Number(totalMatch && totalMatch[1] || 0)
    const available = Number(availableMatch && availableMatch[1] || 0)
    return total > 0 ? 100 * (total - available) / total : null
  }

  function parseTemp(text) {
    const value = Number(text.trim())
    return isFinite(value) ? value / 1000 : null
  }

  function formatUptime(text) {
    let total = Math.floor(Number(text.trim().split(/\s+/)[0]) || 0)
    const days = Math.floor(total / 86400)
    total %= 86400
    const hours = Math.floor(total / 3600)
    const minutes = Math.floor((total % 3600) / 60)

    if (days > 0) {
      return `${days}d ${hours}h`
    }
    if (hours > 0) {
      return `${hours}h ${minutes}m`
    }
    return `${minutes}m`
  }

  function refreshStats() {
    cpuFile.reload()
    memFile.reload()
    uptimeFile.reload()
    if (root.tempPath) {
      tempFile.reload()
    }
  }

  function updateStats() {
    const cpuSample = parseCpuSample(cpuFile.text())
    if (cpuSample) {
      if (root.prevCpu.total > 0) {
        const dTotal = cpuSample.total - root.prevCpu.total
        if (dTotal > 0) {
          const dIdle = cpuSample.idle - root.prevCpu.idle
          root.cpuUsage = Math.max(0, 100 * (dTotal - dIdle) / dTotal)
        }
      }
      root.prevCpu = cpuSample
    }

    const memory = parseMemoryUsage(memFile.text())
    if (memory !== null) {
      root.memoryUsage = memory
    }
  }

  function updateTemp() {
    const temp = parseTemp(tempFile.text())
    if (temp !== null) {
      root.cpuTemp = temp
    }
  }

  function updateUptime() {
    root.uptimeText = formatUptime(uptimeFile.text())
  }

  FileView {
    id: cpuFile
    path: "/proc/stat"
    preload: true
    onTextChanged: root.updateStats()
  }

  FileView {
    id: memFile
    path: "/proc/meminfo"
    preload: true
    onTextChanged: root.updateStats()
  }

  FileView {
    id: uptimeFile
    path: "/proc/uptime"
    preload: true
    onTextChanged: root.updateUptime()
  }

  FileView {
    id: tempFile
    path: root.tempPath
    preload: true
    onTextChanged: root.updateTemp()
  }

  Process {
    id: tempProbe
    running: true
    command: ["sh", "-c", `
for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do
  [ -r "$f" ] || continue
  echo "$f"
  break
done
`]
    stdout: StdioCollector {
      onStreamFinished: function() {
        root.tempPath = this.text.trim()
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refreshStats()
  }

  Component.onCompleted: {
    root.refreshStats()
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.popupOpen = !root.popupOpen
  }

  Text {
    id: statsText
    anchors.centerIn: parent
    width: parent.width - 16
    font.pointSize: root.compact ? 10.5 : 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    text: root.compact
      ? `cpu ${cpuUsage.toFixed(0)}% · mem ${memoryUsage.toFixed(0)}% · ${cpuTemp > 0 ? cpuTemp.toFixed(0) + "°" : "--°"}`
      : `${root.uptimeText} ·  ${cpuUsage.toFixed(1)}% ·  ${memoryUsage.toFixed(1)}% · ${cpuTemp > 0 ? cpuTemp.toFixed(1) + "°C" : "--°C"}`
    color: Theme.rose
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
  }

  PopupWindow {
    id: popup
    anchor.window: root.barWindow
    anchor.rect.x: root.x + root.width / 2 - width / 2
    anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : root.height + 6
    implicitWidth: 280
    implicitHeight: 205
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
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
          Layout.fillWidth: true
          text: "hardware"
          color: Theme.subtle
          font.family: "AgaveNerdFontMono"
          font.bold: true
          font.pointSize: 10
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "uptime"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 60
          }

          Text {
            text: root.uptimeText
            color: Theme.rose
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "cpu"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 40
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            Rectangle {
              anchors.fill: parent
              radius: 4
              color: Theme.overlay
              clip: true

              Rectangle {
                width: parent.width * Math.max(0, Math.min(root.cpuUsage, 100)) / 100
                height: parent.height
                radius: 4
                color: Theme.foam
              }
            }
          }

          Text {
            text: `${root.cpuUsage.toFixed(1)}%`
            color: Theme.rose
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 60
            horizontalAlignment: Text.AlignRight
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "mem"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 40
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            Rectangle {
              anchors.fill: parent
              radius: 4
              color: Theme.overlay
              clip: true

              Rectangle {
                width: parent.width * Math.max(0, Math.min(root.memoryUsage, 100)) / 100
                height: parent.height
                radius: 4
                color: Theme.rose
              }
            }
          }

          Text {
            text: `${root.memoryUsage.toFixed(1)}%`
            color: Theme.rose
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 60
            horizontalAlignment: Text.AlignRight
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "temp"
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 40
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            Rectangle {
              anchors.fill: parent
              radius: 4
              color: Theme.overlay
              clip: true

              Rectangle {
                width: parent.width * Math.max(0, Math.min(root.cpuTemp, 100)) / 100
                height: parent.height
                radius: 4
                color: Theme.gold
              }
            }
          }

          Text {
            text: root.cpuTemp > 0 ? `${root.cpuTemp.toFixed(1)}°C` : "n/a"
            color: Theme.rose
            font.family: "AgaveNerdFontMono"
            font.bold: true
            font.pointSize: 10
            Layout.preferredWidth: 60
            horizontalAlignment: Text.AlignRight
          }
        }
      }
    }
  }
}
