import QtQuick 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Controls.Material.impl 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

ApplicationWindow {
    id: window
    minimumHeight: 400
    minimumWidth: 1150
    width: 1200
    height: 500
    visible: true
    title: qsTr("Math and Code")
    color: Material.color(Material.Grey, Material.Shade100)

    property bool isPythonToMath: true
    property string errorText: ""
    property int appWidth: 1200
    property int appHeight: 500

    onWidthChanged: {
        //textAreaOutput.text=appWidth+"x"+appHeight;
        appWidth = window.width;
    }

    onHeightChanged: {
        //textAreaOutput.text=appWidth+"x"+appHeight;
        appHeight = window.height;
    }

    Drawer {
        id: drawer

        width: 175
        height: window.height
        modal: false
        interactive: false
        position: 1
        visible: true
        Material.elevation: 5
        ButtonGroup {
            id: buttonGroup
        }
        ListView {
            id: listView
            anchors.fill: parent
            interactive: true
            headerPositioning: ListView.OverlayHeader
            header: Pane {
                id: header
                z: 2
                width: parent.width
                background: Rectangle {
                    color: Material.primary
                }

                Label {
                    font.bold: true
                    font.pixelSize: 14
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    text: qsTr("Math and Code")
                    color: "#ffffff"
                }

                MenuSeparator {
                    parent: header
                    width: parent.width
                    anchors.verticalCenter: parent.bottom
                    visible: !listView.atYBeginning
                }
            }

            // Flickable:
            model: LeftMenuModel {}
            delegate: ItemDelegate {
                icon.source: ic
                text: name
                width: parent.width
                onClicked: {
                    switch (click) {
                    case "solve":
                        solvePopup.open()
                        break
                    case "export":
                        exportPopup.open()
                        break
                    }
                    //todo new menu items
                }
            }

            //highlight: Rectangle { color: Material.color(Material.Indigo,Material.Shade100); } //for highlighting curr item


            /*delegate: Button {
                       text: name
                       Material.background : Material.primary
                       icon.source: ic
                       checked: true
                       font.capitalization: Font.MixedCase
                       ButtonGroup.group: buttonGroup
                       width: parent.width

                       HoverHandler {
                           onHoveredChanged: {
                               if (hovered == true)
                                   Material.background = Material.primary
                               else
                                   Material.background = Material.color(
                                               Material.Grey,
                                               Material.Shade200)
                           }
                       }
                   }*/
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }

    RowLayout {
        id: rowLayout
        anchors.rightMargin: 20
        anchors.leftMargin: 20 + drawer.width
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        anchors.fill: parent

        Rectangle {
            id: cardInput
            color: Material.backgroundColor
            radius: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            layer.enabled: true
            layer.effect: ElevationEffect {
                elevation: 5
            }

            ColumnLayout {
                anchors.rightMargin: 15
                anchors.leftMargin: 15
                anchors.bottomMargin: 15
                anchors.topMargin: 15
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                //todo add load from file and delete buttons (like yandex translate has)
                Label {
                    id: inputHeader
                    color: Material.accent
                    text: isPythonToMath ? qsTr("Python код") : qsTr(
                                               "Математическое представление")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 12
                    font.bold: true
                }

                /* ComboBox {
                    displayText: currentIndex == -1 ? "Выберите тип задания" : currentText
                    currentIndex: -1
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    Material.elevation: 0
                    model: ["Первый тип задания", "Второй тип задания", "Третий тип задания"]
                }*/
                Rectangle {
                    id: rectInput
                    Layout.rightMargin: 0
                    border.color: textAreaInput.activeFocus ? Material.primary : Material.color(
                                                                  Material.Grey,
                                                                  Material.Shade200)
                    border.width: 1
                    Layout.minimumWidth: 250
                    Layout.minimumHeight: 300
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    ScrollView {
                        id: view
                        anchors.fill: parent
                        padding: 10

                        //todo scrollbar style
                        //ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        //ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        TextArea {
                            id: textAreaInput
                            text: ""
                            placeholderText: isPythonToMath ? qsTr("Введите Python код") : qsTr(
                                                                  "Введите математическое представление")
                            background: null
                            selectByKeyboard: true
                            selectByMouse: true
                            font.pointSize: 9
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: column
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            RoundButton {
                Material.background: Material.primary
                id: swapButton
                text: "Swap"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                display: AbstractButton.IconOnly
                icon.source: "images/swap.png"
                icon.color: "#ffffff"

                //code swap click swaps python and math
                TapHandler {
                    onTapped: isPythonToMath = !isPythonToMath
                }
            }

            RoundButton {
                Material.background: Material.LightGreen
                id: translateButton
                text: "Translate"
                Layout.topMargin: rowLayout.height / 2 - swapButton.height
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                display: AbstractButton.IconOnly
                icon.source: "images/translate.png"
                icon.color: "#ffffff"

                onClicked: {
                    if (textAreaInput.text == "") {
                        //PopupEmptyInput
                        textAreaOutput.text="";//clearing output area when error
                        errorText = "mainInputEmptyError";
                        popupError.open();
                    } else {
                        converter.convert(textAreaInput.text, isPythonToMath);
                    }
                }
            }
        }

        Rectangle {
            id: cardOutput
            color: Material.backgroundColor
            radius: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            layer.enabled: true
            layer.effect: ElevationEffect {
                elevation: 5
            }

            ColumnLayout {
                anchors.rightMargin: 15
                anchors.leftMargin: 15
                anchors.bottomMargin: 15
                anchors.topMargin: 15
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Label {
                    id: outputHeader
                    color: Material.accent
                    text: isPythonToMath ? qsTr("Математическое представление") : qsTr(
                                               "Python код")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 12
                    font.bold: true
                }
                Rectangle {
                    id: rectOutput
                    Layout.rightMargin: 0
                    border.color: Material.color(Material.Grey,
                                                 Material.Shade200)
                    border.width: 1
                    Layout.minimumWidth: 250
                    Layout.minimumHeight: 300
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    ScrollView {
                        padding: 10
                        anchors.fill: parent

                        //ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        //ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        //todo scrollview style

                        /*style: ScrollViewStyle {
                               handle: Rectangle {
                                   implicitWidth: 50
                                   implicitHeight: 30
                                   color: "red"
                               }
                               scrollBarBackground: Rectangle {
                                   implicitWidth: 50
                                   implicitHeight: 30
                                   color: "black"
                               }
                               decrementControl: Rectangle {
                                   implicitWidth: 50
                                   implicitHeight: 30
                                   color: "green"
                               }
                               incrementControl: Rectangle {
                                   implicitWidth: 50
                                   implicitHeight: 30
                                   color: "blue"
                               }
                           }*/
                        TextArea {

                            id: textAreaOutput
                            text: ""
                            placeholderText: ""
                            background: null
                            readOnly: true
                            selectByKeyboard: true
                            selectByMouse: true
                            font.pointSize: 9
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: converter

        // convertion result there
        onConvertResult: {
            if (convert == "PyToMathError") //error converting python to math, wrong input
            {
                textAreaOutput.text = "";
                errorText = "PyToMathError";
                popupError.open();
            } else if (convert == "MathToPyError") //error converting math to python, wrong input
            {
                textAreaOutput.text = "";
                errorText = "MathToPyError";
                popupError.open();
            } else//success
                textAreaOutput.text = convert;
        }
    }

    PopupError {
        id: popupError
    }

    PopupSolve {
        id: solvePopup
    }

    PopupExport {
        id: exportPopup
    }
}
