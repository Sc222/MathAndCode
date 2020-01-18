import QtQuick 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Controls.Material.impl 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Popup {
    id: popup
    property bool isSolveError: false
    property string solveStatus: "notSolved"
    //property alias stackLayout: stackLayout
    //contentWidth: stackLayout.layer.
    //contentHeight: columnLayout.implicitHeight
    rightPadding: 20
    bottomPadding: 10
    leftPadding: 20
    topPadding: 20
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    onAboutToHide: {
        textFieldN.text = "";
        textSolveResult.text = "";
        solveStatus = "notSolved";
        isSolveError = false;
        //todo reset all values to default on hide
    }

    background: Rectangle {
        radius: 5
        anchors.fill: parent
        color: Material.color(Material.Grey, Material.Shade100)
    }

    ColumnLayout {
        anchors.rightMargin: -1
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        anchors.fill: parent
        RowLayout {
            transformOrigin: Item.Center
            spacing: 0
            Layout.fillWidth: true
            Label {
                font.pointSize: 14
                Layout.topMargin: -20
                anchors.right: parent.right
                anchors.left: parent.left
                text: "Решить для N = "
                color: Material.color(Material.Grey, Material.Shade800)
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignLeft | Qt.Top
            }
            TextField {
                id: textFieldN
                Layout.topMargin: -10
                font.weight: Font.DemiBold
                Material.primary: isSolveError ? Material.Red : Material.Indigo
                color: Material.primary
                maximumLength: 10
                Layout.alignment: Qt.AlignLeft | Qt.Top
                placeholderTextColor: isSolveError ? Material.color(
                                                         Material.Red,
                                                         Material.Shade100) : Material.color(
                                                         Material.Indigo,
                                                         Material.Shade100)
                placeholderText: qsTr("Введите N")
                background: null
                selectByMouse: true
                font.pointSize: 14
            }
        }

        MenuSeparator {
            Layout.fillWidth: true
            Layout.topMargin: -20
            topPadding: 0
            bottomPadding: 0
            contentItem: Rectangle {
                id: rectSeparator
                implicitWidth: 200
                implicitHeight: 3
                color: isSolveError ? "#E57373" : "#3F51B5"
            }
        }
        Label {
            Layout.minimumWidth:  700
            id: labelSolveStatus
            text: {
                switch (solveStatus) {
                case "codeInputEmptyError":
                    return "Сначала введите рекурсию\nв главном меню программы."
                case "nInputEmptyError":
                    return "Сначала введите N.\nN должно быть целым числом."
                case "nNotIntError":
                    return "N должно быть целым числом."
                case "CodeSolveError":
                    return "Проблема при решении рекурсии.\nСкорее всего введенный код не соответствовал\nописанным в помощи правилам."
                case "notSolved":
                    //not solved, but no errors
                    return "Подсчет возвращаемого значения (или вывода)\nвведенных рекурсий для заданного N"
                case "solved":
                    //solved, no errors
                    return "Вывод программы"
                }
            }
            color: Material.color(Material.Grey, Material.Shade600)
            bottomPadding: 0
            topPadding: 7
            visible: true
            anchors.right: parent.right
            anchors.left: parent.left
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pointSize: 12
        }
        ScrollView {
            visible: solveStatus == "solved"? true: false
            id: scrollViewResult
            Layout.bottomMargin: -14
            Layout.topMargin: -7
            Layout.maximumHeight: appHeight - 240
            Layout.maximumWidth: appWidth - 80
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            //anchors.right: parent.right
            //anchors.left: parent.left
            //anchors.top: labelSolveStatus.bottom
            //anchors.bottom: buttonsRow.top
            TextArea {
                //bottomPadding: -5
                //anchors.centerIn: parent
               // Layout.bottomMargin: -50
               // Layout.topMargin: -10
                //Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                id: textSolveResult
                text: ""
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                color: Material.color(Material.Grey, Material.Shade800)
                placeholderText: ""
                background: null
                readOnly: true
                selectByKeyboard: true
                selectByMouse: true
                font.pointSize: 9
            }
        }
        RowLayout {
            id: buttonsRow
            spacing: 25
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Button {
                text: qsTr("Решить")
                font.weight: Font.DemiBold
                font.capitalization: Font.MixedCase
                flat: true
                Material.foreground: Material.Green
                font.pointSize: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                display: AbstractButton.TextOnly
                TapHandler {
                    onTapped: {
                        if (textAreaInput.text == "") {
                            isSolveError = true;
                            solveStatus = "codeInputEmptyError";
                        }
                        else if (textFieldN.text == "") {
                            isSolveError = true;
                            solveStatus = "nInputEmptyError";
                        }
                        else {
                            converter.count_value(textFieldN.text,
                                                 textAreaInput.text,
                                                 isPythonToMath)
                        }
                    }
                }
            }
            Button {
                id: okButton
                text: qsTr("Закрыть")
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

    Connections {
        target: converter

        //count for n result here
        onCountValueResult: {
            if (count_value == "nNotIntError"
                    || count_value == "CodeSolveError") {
                solveStatus = count_value;
                isSolveError = true;
            } else {
                solveStatus = "solved";
                isSolveError = false;
                textSolveResult.text = count_value;
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1;anchors_height:100;anchors_width:100}
D{i:4;anchors_height:100;anchors_width:100}D{i:5;anchors_height:100;anchors_width:100}
D{i:3;anchors_height:100;anchors_width:100}D{i:6;anchors_height:100;anchors_width:100}
}
##^##*/

