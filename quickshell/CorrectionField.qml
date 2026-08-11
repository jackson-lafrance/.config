import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property alias text: input.text
  property string label: ""
  property string placeholder: ""
  property color accent: Theme.iris
  signal accepted()

  function forceActiveFocus() {
    input.forceActiveFocus()
  }

  implicitHeight: 72
  radius: 14
  color: input.activeFocus ? Theme.highlightLow : Theme.surface
  border.width: 1.5
  border.color: input.activeFocus ? root.accent : Theme.highlightMed

  Behavior on color {
    ColorAnimation {
      duration: 140
      easing.type: Easing.InOutQuad
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: 140
      easing.type: Easing.InOutQuad
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    anchors.topMargin: 9
    anchors.bottomMargin: 9
    spacing: 4

    Text {
      Layout.fillWidth: true
      text: root.label
      color: root.accent
      font.family: "AgaveNerdFontMono"
      font.pointSize: 8
      font.bold: true
      elide: Text.ElideRight
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholder
        visible: input.text.length === 0 && !input.activeFocus
        color: Theme.muted
        font.family: "AgaveNerdFontMono"
        font.pointSize: 11
        elide: Text.ElideRight
      }

      TextInput {
        id: input
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.text
        selectionColor: root.accent
        selectedTextColor: Theme.base
        font.family: "AgaveNerdFontMono"
        font.pointSize: 11
        clip: true
        activeFocusOnTab: true
        selectByMouse: true
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
      }
    }
  }
}
