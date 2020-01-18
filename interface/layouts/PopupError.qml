import QtQuick 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Controls.Material.impl 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Popup {
    id: popup
    rightPadding: 20
    bottomPadding: 10
    leftPadding: 20
    topPadding: 20
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 5
        anchors.fill: parent
        color: Material.color(Material.Grey, Material.Shade100)
    }

    ColumnLayout {
        id: columnLayout
        anchors.rightMargin: -1
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        anchors.fill: parent

        Label {
            font.bold: false
            font.pointSize: 14
            anchors.right: parent.right
            anchors.left: parent.left
            text: "Произошла ошибка"
            color: Material.color(Material.Grey, Material.Shade800)
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
        MenuSeparator {
            Layout.fillWidth: true
            topPadding: 0
            bottomPadding: 0
            contentItem: Rectangle {
                implicitWidth: 200
                implicitHeight: 3
                color: "#E57373"
            }
        }
        Label {
            id: popupErrorText
            text: {
                switch (errorText) {
                case "mainInputEmptyError":
                    return "Ввод не может быть пустым.\nПримеры ввода находятся в разделе помощь."
                case "PyToMathError":
                    return "Неверный формат Python кода.\nПримеры указаны в разделе помощь."
                case "MathToPyError":
                    return "Неверный формат Мат. представления.\nПримеры указаны в разделе помощь."
                default:
                    return "Все в порядке."
                }
            }
            color: Material.color(Material.Grey, Material.Shade600)
            bottomPadding: 0
            topPadding: 7
            anchors.right: parent.right
            anchors.left: parent.left
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pointSize: 12
        }
        RowLayout {
            width: 100
            height: 100
            spacing: 25
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Button {
                text: qsTr("Помощь")
                font.weight: Font.DemiBold
                font.capitalization: Font.MixedCase
                flat: true
                Material.foreground: Material.primary
                font.pointSize: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                display: AbstractButton.TextOnly
                TapHandler {
                    onTapped: popup.close() //todo open help menu
                }
            }
            Button {
                text: qsTr("Ок")
                font.weight: Font.DemiBold
                font.capitalization: Font.MixedCase
                flat: true
                Material.foreground: Material.primary
                font.pointSize: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                display: AbstractButton.TextOnly
                TapHandler {
                    onTapped: popup.close()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1;anchors_height:100;anchors_width:100}
D{i:4;anchors_height:100;anchors_width:100}D{i:5;anchors_height:100;anchors_width:100}
D{i:3;anchors_height:100;anchors_width:100}
}
##^##*/

