import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property var barWindow
  property string artist: ""
  property string title: ""

  Layout.fillHeight: true
  width: Math.min(musicText.implicitWidth + 24, 240)
  color: Theme.surface
  border.width: 1.5
  border.color: mouseArea.containsMouse ? Theme.love : Theme.surface
  radius: 10

  Behavior on border.color {
    ColorAnimation {
      duration: 400
      easing.type: Easing.InOutQuad
    }
  }

  function updateTrack(line) {
    const bits = line.trim().split("|")
    root.artist = (bits[0] || "").trim()
    root.title = (bits[1] || "").trim()
  }

  property string musicScript: `
while :; do
  player=$(playerctl -l 2>/dev/null | awk '
    BEGIN { IGNORECASE = 1 }
    /cider/ {
      print
      found = 1
      exit
    }
    /chromium/ {
      chromium = $0
    }
    END {
      if (!found && chromium != "") {
        print chromium
      }
    }
  ')
  if [ -n "$player" ] && [ "$(playerctl -p "$player" status 2>/dev/null)" = "Playing" ]; then
    playerctl -p "$player" metadata --format '{{artist}}|{{title}}' 2>/dev/null
  else
    echo "|"
  fi
  sleep 2
done
`

  Process {
    running: true
    command: ["stdbuf", "-oL", "sh", "-c", root.musicScript]
    stdout: SplitParser {
      onRead: function(line) {
        root.updateTrack(line)
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["cider"])
  }

  Text {
    id: musicText
    anchors.centerIn: parent
    width: parent.width - 24
    font.pointSize: 11
    font.family: "AgaveNerdFontMono"
    font.bold: true
    text: artist || title ? (artist ? `${artist} — ${title}` : title) : "cider"
    color: artist || title ? Theme.foam : Theme.subtle
    elide: Text.ElideRight
  }
}
