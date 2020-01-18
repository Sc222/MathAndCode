import re

from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from converters.translator import *

# noinspection PyUnresolvedReferences
from interface import resource_rc


class Converter(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.__intRegex__ = re.compile(r"^[-]?\d+$")

    def is_int(self, s: str) -> bool:  # todo helper class
        return self.__intRegex__.match(str(s)) is not None

    convert_result = pyqtSignal(str, name="convertResult", arguments=['convert'])
    count_value_result = pyqtSignal(str, name="countValueResult", arguments=['count_value'])

    # слот для расчета значения (вывода) рекурсий в точке
    @pyqtSlot(str, str, bool)
    def count_value(self, n_raw: str, inp: str, is_py_to_math: bool):
        # todo вылетает если N большое (переполнение стека и тд)
        if not self.is_int(n_raw):
            res = "nNotIntError"
        else:
            n = int(n_raw)
            filtered_lines = self.filter_and_split_code_input(inp)
            if is_py_to_math:
                res = self.count_val_py(n, filtered_lines)
            else:
                res = self.count_val_math(n, filtered_lines)
        print(res)
        self.count_value_result.emit(res)

    def count_val_math(self, n: int,
                       filtered_lines: []) -> str:  # returns int value, print output or both (depends on ЕГЭ task)
        python_code = self.convert_math_to_py(filtered_lines, "CodeSolveError")
        return self.count_val_py(n, python_code)

    def count_val_py(self, n: int,
                     filtered_lines: []) -> str:  # returns int value, print output or both (depends on ЕГЭ task)
        py_to_math_obj = py_to_math()
        try:
            funcs = py_to_math_obj.break_to_funcs(filtered_lines)
            res_arr = []
            for f in funcs:
                # print(ff.name)
                int_res = get_int_result_for(f"{f.name}({n})", py_to_math_obj.code)  # todo fix lowercase
                str_res = get_str_result_for(f"{f.name}({n})", py_to_math_obj.code)
                tmp = f"Функция: {f.name}({n})"
                if int_res is not None:
                    tmp = f"{tmp}\n{f.name}({n}) = {str(int_res)}"
                if str_res != "":
                    tmp = f"{tmp}\nВыведено на консоль: {str_res}"
                if int_res is None and str_res == "":
                    tmp = f"{tmp}\nФункция ничего не выводит и ничего не возвращает"
                res_arr.append(tmp)
            result = "\n\n".join(res_arr)
            print(result)
        except BaseException as exception:
            print("solve for n error", exception)
            result = "CodeSolveError"
        return result

    # слот для перевода из одной формы в другую
    @pyqtSlot(str, bool)
    def convert(self, inp: str, is_py_to_math: bool):
        filtered_lines = self.filter_and_split_code_input(inp)

        if is_py_to_math:
            res = self.convert_py_to_math(filtered_lines)
        else:
            # todo если вбить бред, мат. представление не вылетает, сделать, чтобы вылетало
            # todo пока вылет ошибки реализован при условии, что возвращается def f(n):
            res = self.convert_math_to_py(filtered_lines, "MathToPyError")
        print(res)
        self.convert_result.emit(res)

    def convert_py_to_math(self, filtered_lines: []) -> str:
        pyToMath = py_to_math()
        try:
            funcs = pyToMath.break_to_funcs(filtered_lines)
            res = py_to_math_converter().convert(funcs)
        except BaseException as exception:
            print("convert error", exception)
            res = "PyToMathError"  # todo python to math error dialog
        return res

    def convert_math_to_py(self, filtered_lines: [], error_str: str) -> str:
        math_to_py_obj = math_to_py()
        try:
            funcs = math_to_py_obj.break_to_funcs(filtered_lines)
            res = math_to_py_converter().convert(funcs)
            print(res)
            if res.strip() == "def f(n):" or res.strip() == "":  # todo remove this workaround later
                res = error_str
        except BaseException as exception:
            print("convert error", exception)
            res = error_str  # todo math to python error dialog
        return res

    # Преобразование ввода Python-кода или мат. представления
    def filter_and_split_code_input(self, inp: str) -> []:
        lines = inp.splitlines()
        filtered_lines = []
        for line in lines:
            if not (line.strip() == ''):
                filtered_lines.append(line)
        return filtered_lines


if __name__ == "__main__":
    import os
    import sys

    # создаём экземпляр приложения
    app = QGuiApplication(sys.argv)
    # app.setWindowIcon(QIcon(f"{os.path.sep}images{os.path.sep}demo_icon.png"))
    # создаём QML движок
    engine = QQmlApplicationEngine()
    # создаём объект калькулятора
    converter = Converter()
    # и регистрируем его в контексте QML
    engine.rootContext().setContextProperty("converter", converter)
    # загружаем файл qml в движок
    engine.load(os.path.join("layouts", "main.qml"))
    # engine.quit.connect(app.quit) wtf is this
    sys.exit(app.exec_())
