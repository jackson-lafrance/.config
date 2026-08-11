import QtQuick

Rectangle {
  id: root

  property string text: ""
  property color accent: Theme.iris
  property bool primary: false
  signal clicked()

  implicitWidth: Math.max(label.implicitWidth + 28, 86)
  implicitHeight: 36
  radius: 12
  color: primary
    ? (mouseArea.pressed ? Theme.iris : mouseArea.containsMouse || activeFocus ? Theme.highlightHigh : Theme.highlightMed)
    : (mouseArea.pressed ? Theme.highlightHigh : mouseArea.containsMouse || activeFocus ? Theme.highlightMed : Theme.surface)
  border.width: 1.5
  border.color: mouseArea.containsMouse || activeFocus || primary ? root.accent : Theme.highlightMed
  focus: true
  activeFocusOnTab: true

  Behavior on color {
    ColorAnimation {
      duration: 130
      easing.type: Easing.InOutQuad
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: 130
      easing.type: Easing.InOutQuad
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: root.primary ? Theme.text : root.accent
    font.family: "AgaveNerdFontMono"
    font.pointSize: 10
    font.bold: true
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()
}
