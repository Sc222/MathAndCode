import QtQuick 2.13
import QtQuick.Controls.Material 2.13
import Qt.labs.platform 1.1


FileDialog {
    id:fileDialog
    title: "Экспортировать в файл"
    folder: shortcuts.home
    fileMode: FileDialog.SaveFile
   // defaultSuffix: "docx"
    //acceptLabel : "Сохранить"
    //rejectLabel: "Отмена"
    selectedNameFilter.index: 1  //0 - txt, 1 - html
    nameFilters: ["Обычный текст (*.txt)", "Веб страница (*.html)"]
    onAccepted: {
        converter.export(fileDialog.file.toString(),fileDialog.selectedNameFilter.index, textAreaInput.text, textAreaOutput.text,isPythonToMath);
    }
}

