from transitions import Machine


class condition:
    def __init__(self):
        self.cond = None
        self.action = None

    cond: str
    action: str


class func:
    def __init__(self):
        self.name = None
        self.conditions = []

    name: str
    conditions: list


class math_to_py:
    _states = ["empty", "f_reading", "f_open", "f_n", "f_num", "f_n_close", "f_num_close",
               "f_n_reading", "f_num_reading", "f_num_end", "cond_first", "cond_second", "cond_third", "f_n_end"]

    def __init__(self):
        self.machine = Machine(model=self, states=math_to_py._states, initial="empty")
        self.cur_symbol: str = ""
        self.cur_string: str = ""
        self.cur_func: func = None
        self._create_casual_transitions()
        self.funcs_dict: dict = {}
        self.funcs: list[func] = []

    def _start_again(self):
        self.cur_symbol = ""
        self.cur_string = ""
        self.machine.set_state("empty")

    def on_enter_f_num(self):
        cond = condition()
        cond.cond = "n == " + self.cur_symbol
        self.cur_func.conditions.append(cond)

    def on_enter_f_num_end(self):
        self.cur_func.conditions[-1].action = self.cur_string[:-1].strip()
        self._start_again()

    def on_enter_cond_first(self):
        cond = condition()
        action = self.cur_string[:-1].strip()
        action = action.replace("×", "*")
        action = action.replace("·", "*")
        action = action.replace("−", "-")
        action = action.replace("–", "-")
        action = action.replace("/", "//")
        action = action.replace(":", "//")
        cond.action = action
        self.cur_func.conditions.append(cond)
        self.cur_string = ""

    def on_enter_f_n_end(self):
        cond = self.cur_string[:-1].strip()
        cond = cond.replace("=", "==")
        cond = cond.replace("≤", "<=")
        cond = cond.replace("≥", ">=")
        self.cur_func.conditions[-1].cond = cond
        self._start_again()

    def on_enter_f_open(self):
        self.cur_string = self.cur_string[:-1]
        if not self.cur_string in self.funcs_dict:
            self.funcs_dict[self.cur_string] = func()
            self.funcs_dict[self.cur_string].name = self.cur_string
        self.cur_func = self.funcs_dict[self.cur_string]
        self.cur_string = ""

    def on_enter_f_reading(self):
        self.cur_string += self.cur_symbol

    def is_f(self):
        return self.cur_symbol.isalpha()

    def is_open_bracket(self):
        return self.cur_symbol == "("

    def is_num(self):
        return self.cur_symbol.isdigit()

    def is_close_bracket(self):
        return self.cur_symbol == ")"

    def is_n(self):
        return self.cur_symbol == "n"

    def is_eq(self):
        return self.cur_symbol == "="

    def is_c0(self):
        return self.cur_symbol == "п"

    def is_c00(self):
        return self.cur_symbol == "р"

    def is_c000(self):
        return self.cur_symbol == "и"

    def is_end(self):
        return self.cur_symbol == ";" or self.cur_symbol == "."

    def _create_casual_transitions(self):
        self.machine.add_transition("move", "empty", "f_reading", conditions="is_f")
        self.machine.add_transition("move", "f_reading", "f_open", conditions="is_open_bracket")
        self.machine.add_transition("move", "f_open", "f_num", conditions="is_num")
        self.machine.add_transition("move", "f_num", "f_num_close", conditions="is_close_bracket")
        self.machine.add_transition("move", "f_open", "f_n", conditions="is_n")
        self.machine.add_transition("move", "f_n", "f_n_close", conditions="is_close_bracket")
        self.machine.add_transition("move", "f_n_close", "f_n_reading", conditions="is_eq")
        self.machine.add_transition("move", "f_num_close", "f_num_reading", conditions="is_eq")
        self.machine.add_transition("move", "f_num_reading", "f_num_end", conditions="is_end")
        self.machine.add_transition("move", "f_n_reading", "cond_first", conditions="is_c0")
        self.machine.add_transition("move", "cond_first", "cond_second", conditions="is_c00")
        self.machine.add_transition("move", "cond_second", "cond_third", conditions="is_c000")
        self.machine.add_transition("move", "cond_third", "f_n_end", conditions="is_end")

    def break_to_funcs(self, lines):
        for line in lines:
            for i in line.lower() + ".":  # Точка нужна, чтобы последовательность ТОЧНО закончилась
                if (i == ","):
                    continue
                self.cur_symbol = i
                if (self.machine.is_state("f_num_reading", self) or self.machine.is_state("f_reading", self) or
                        self.machine.is_state("f_n_reading", self) or self.machine.is_state("cond_third", self)):
                    self.cur_string += self.cur_symbol
                self.move()
        self.funcs = list(self.funcs_dict.values())
        return self.funcs


class math_to_py_converter:
    def convert_math_to_py(self, funcs: list) -> str:
        code: str = ""
        for f in funcs:
            code += "def " + f.name + "(n):"
            for cond in f.conditions:
                code += "\n    if " + cond.cond + ":"
                code += "\n        return " + cond.action
            code += "\n"
        return code


##УЖНО ОТРЕФАКТОРИТЬ!!!!)))) :( :( :( :( :( :( :(
class py_to_math:

    def __init__(self):
        self.cur_cond: condition = None
        self.cur_func: func = None
        self.funcs: list[func] = []
        self.code: str = None

    def _get_identation_size(self, line: str):
        count = 0
        for i in line:
            if i != " " and i != "\t":
                return count
            count += 1
        return count

    def _read_func(self, line: str):
        self.cur_func = func()
        self.funcs.append(self.cur_func)
        func_str = line.strip()
        self.cur_func.name = func_str[func_str.find(" ") + 1: func_str.find("(")]

    def _read_if_statement(self, line: str):
        self.cur_cond = condition()
        self.cur_func.conditions.append(self.cur_cond)
        cond = line.strip()
        self.cur_cond.cond = cond[cond.find(" ") + 1: -1]

    def _read_else_statement(self):
        self.cur_cond = condition()
        self.cur_func.conditions.append(self.cur_cond)
        self.cur_cond.cond = "else"

    def _read_conditionless_action(self, line: str):
        self.cur_cond = condition()
        self.cur_func.conditions.append(self.cur_cond)
        self.cur_cond.cond = "conditionless"
        line = line.strip()
        action = line if line.find("return") == -1 else line[line.find(" ") + 1:]
        self.cur_cond.action = action

    def _read_action(self, line: str):
        line = line.strip()
        action = line if line.find("return") == -1 else line[line.find(" ") + 1:]
        self.cur_cond.action = self.cur_cond.action + " + " + action if self.cur_cond.action != None else action

    def break_to_funcs(self, lines: list):
        self.code = "globals()['text_result'] = ''\n"  # Для случаев с print
        cur_indentation = -1
        is_previous_cond = False  # Нужен для случаев действий вне блока if
        for line in map(lambda s: s.lower(), lines):
            if line == "":
                continue
            indentation = self._get_identation_size(line)
            if indentation != cur_indentation:
                cur_indentation = indentation
                if line.find("def") != -1:
                    self._read_func(line)
                    is_previous_cond = False
                elif line.find("if") != -1:
                    self._read_if_statement(line)
                    is_previous_cond = True
                elif line.find("else") != -1:
                    self._read_else_statement()
                    is_previous_cond = True
                elif is_previous_cond:
                    self._read_action(line)
                    is_previous_cond = False
                else:
                    self._read_conditionless_action(line)
            elif line.find("if") != -1:
                self._read_if_statement(line)
                is_previous_cond = True
            else:
                self._read_action(line)
                is_previous_cond = False
            self.code += line.replace("print",
                                      "globals()['text_result'] += str") + "\n"  # print(n) => globals()['text_result'] += str(n)
        return self.funcs


class py_to_math_converter:
    def convert_py_to_math(self, funcs: list) -> str:
        text: str = ""
        for f in funcs:
            for cond in f.conditions:
                cond_text = cond.cond
                cond_text = cond_text.replace("==", "=")
                cond_text = cond_text.replace("<=", "≤")
                cond_text = cond_text.replace(">=", "≥")
                if cond.cond == "conditionless":
                    text += ("{0}(n) = {1} при любом n;".format(f.name, cond.action))
                elif cond.cond == "else":
                    text += ("{0}(n) = {1} при всех остальных n;".format(f.name, cond.action))
                else:
                    text += ("{0}(n) = {1} при {2};".format(f.name, cond.action, cond_text))
                text += "\n"
            text += "\n"
        return text


# exec для math->py: exec(compile(code, "<int>", "exec"), globals()) - код получать через math_to_py_converter
# exec для py->math: exec(compile(code, "<int>", "exec"), globals()) - код в экземпляре класса py_to_math после выполнения break_to_funcs
# в случае с return просто вызываешь функцию (можешь хоть прямо так её написать, типа f(7), но лучше через eval("f(7)")
# в случае со звёздочками и принтами вызываешь функцию, а потом выводишь через globals()["text_result"]

def get_int_result_for(func_call: str, code: str):
    exec(compile(code, "<int>", "exec"), globals())
    return eval(func_call)


def get_str_result_for(func_call: str, code: str):
    exec(compile(code, "<int>", "exec"), globals())
    eval(func_call)
    return globals()["text_result"]


##ПРИМЕРЫ
'''
wm = math_to_py()
funcs = wm.break_to_funcs(["alpha(7) = 'asdsad'", "gamma(9) = 1000", "beta(n) = beta(n-1) + 1 при n > 1; beta(1) = 10"])
math_to_py_code = math_to_py_converter.convert_math_to_py(math_to_py_converter, funcs)
print(math_to_py_code)
print(get_int_result_for("beta(7)", math_to_py_code))
cm = py_to_math()
cm.break_to_funcs([
    "def F(n):",
    "   if n > 2:",
    "       return F(n-1)+F(n-2)+F(n-3)",
    "   else:",
    "       return n",
    "def G(n):",
    "   if n > 2:",
    "       return G(n-1)+G(n-2)+G(n-3)",
    "   else:",
    "       return n", "", ""
])
print(get_int_result_for("f(6)", cm.code))
print(py_to_math_converter.convert_py_to_math(py_to_math_converter, cm.funcs))
'''

