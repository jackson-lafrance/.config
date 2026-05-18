import QtQuick

Rectangle {
  id: root
  property string text: ""
  property color accent: Theme.rose
  property bool checked: false
  signal clicked()

  implicitWidth: label.implicitWidth + 16
  implicitHeight: 26
  radius: 8
  opacity: enabled ? 1 : 0.5
  color: !enabled ? Theme.highlightLow : mouseArea.pressed ? Theme.highlightHigh : (mouseArea.containsMouse || root.checked ? Theme.highlightMed : Theme.overlay)
  border.width: 1
  border.color: root.checked || mouseArea.containsMouse ? root.accent : Theme.highlightLow

  Behavior on color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.InOutQuad
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.InOutQuad
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: root.checked ? root.accent : Theme.text
    font.family: "AgaveNerdFontMono"
    font.bold: true
    font.pointSize: 9
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    enabled: root.enabled
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: root.clicked()
  }
}
