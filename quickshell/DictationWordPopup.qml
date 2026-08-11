import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

FloatingWindow {
  id: root

  title: "Add Dictation Word"
  visible: false
  width: 520
  height: 332
  color: "transparent"

  property string statusText: ""
  property color statusColor: Theme.subtle

  function clean(value) {
    return String(value || "").replace(/[\t\n\r]+/g, " ").trim()
  }

  function open() {
    heardInput.text = ""
    replacementInput.text = ""
    statusText = ""
    statusColor = Theme.subtle
    root.visible = true
    focusDelay.restart()
  }

  function closePopup() {
    root.visible = false
  }

  function save() {
    const heard = clean(heardInput.text)
    const replacement = clean(replacementInput.text)

    if (!heard) {
      statusText = "Add what dictation heard first."
      statusColor = Theme.gold
      heardInput.forceActiveFocus()
      return
    }

    if (!replacement) {
      statusText = "Add the replacement text."
      statusColor = Theme.gold
      replacementInput.forceActiveFocus()
      return
    }

    Quickshell.execDetached([
      "/home/jacksonlafrance/.local/bin/voice-dictate-save-word",
      heard,
      replacement,
    ])

    statusText = "Saved"
    statusColor = Theme.foam
    closeDelay.restart()
  }

  IpcHandler {
    target: "dictation"

    function showAddWord(): void {
      root.open()
    }
  }

  Timer {
    id: focusDelay
    interval: 80
    repeat: false
    onTriggered: heardInput.forceActiveFocus()
  }

  Timer {
    id: closeDelay
    interval: 420
    repeat: false
    onTriggered: root.closePopup()
  }

  Rectangle {
    anchors.fill: parent
    radius: 24
    color: Theme.base
    border.width: 1.5
    border.color: Theme.highlightMed

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: 23
      color: "transparent"
      border.width: 1
      border.color: Theme.highlightLow
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 22
      spacing: 14

      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Rectangle {
          Layout.preferredWidth: 42
          Layout.preferredHeight: 42
          radius: 14
          color: Theme.highlightLow
          border.width: 1
          border.color: Theme.iris

          Text {
            anchors.centerIn: parent
            text: "󰑊"
            color: Theme.iris
            font.family: "AgaveNerdFontMono"
            font.pointSize: 18
            font.bold: true
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 2

          Text {
            text: "Add dictation correction"
            color: Theme.text
            font.family: "AgaveNerdFontMono"
            font.pointSize: 14
            font.bold: true
          }

          Text {
            text: "Teach Vosk what to replace next time."
            color: Theme.subtle
            font.family: "AgaveNerdFontMono"
            font.pointSize: 9
          }
        }

        Text {
          text: "Esc"
          color: Theme.muted
          font.family: "AgaveNerdFontMono"
          font.pointSize: 9
          font.bold: true
        }
      }

      CorrectionField {
        id: heardInput
        Layout.fillWidth: true
        label: "Dictation heard"
        placeholder: "get hub"
        accent: Theme.gold
        KeyNavigation.tab: replacementInput
        onAccepted: replacementInput.forceActiveFocus()
        Keys.onEscapePressed: root.closePopup()
      }

      CorrectionField {
        id: replacementInput
        Layout.fillWidth: true
        label: "Replace with"
        placeholder: "GitHub"
        accent: Theme.foam
        KeyNavigation.tab: saveButton
        onAccepted: root.save()
        Keys.onEscapePressed: root.closePopup()
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
          Layout.fillWidth: true
          text: root.statusText
          color: root.statusColor
          font.family: "AgaveNerdFontMono"
          font.pointSize: 9
          elide: Text.ElideRight
        }

        PopupActionButton {
          text: "Cancel"
          accent: Theme.muted
          onClicked: root.closePopup()
          Keys.onEscapePressed: root.closePopup()
        }

        PopupActionButton {
          id: saveButton
          text: "Save"
          accent: Theme.iris
          primary: true
          onClicked: root.save()
          Keys.onReturnPressed: root.save()
          Keys.onEnterPressed: root.save()
          Keys.onEscapePressed: root.closePopup()
        }
      }
    }
  }
}
