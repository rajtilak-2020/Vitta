import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _equation = '';
  String _operand1 = '';
  String _operator = '';
  bool _shouldReset = false;

  static const List<String> _errorMessages = [
    "Nice try, Einstein.",
    "Math.exe has stopped.",
    "Division by zero is a crime.",
    "Black hole created.",
    "A math teacher is crying.",
    "I can't do that, Dave.",
    "Error code: ID-10-T.",
    "Brain overload. Need coffee.",
    "Bold move, human.",
    "Are you testing my limits?",
    "Divide by zero? Brave.",
    "Does not compute.",
    "Kaboom! Just kidding.",
    "404: Logic Not Found.",
    "Try counting on fingers.",
    "Math laws violated.",
    "The universe collapsed.",
    "Calculator says: No.",
    "Error: Ask a human.",
    "Nice try. No cookie.",
    "Dividing by zero is illegal.",
    "My circuits hurt.",
    "Error: Go back to school.",
    "You broke the math rules.",
    "Is this a trick question?",
    "Error: Try addition.",
    "Infinite loop avoided.",
    "Calculation too spicy.",
    "Newton would be mad.",
    "Error: Logic went on vacation.",
    "Please don't do that again.",
    "Error: Quantum paradox.",
    "Zero divide? Strictly prohibited.",
    "System crash in 3, 2, 1...",
    "Error: Absolute nonsense.",
    "You broke the matrix.",
    "Error: Confused calculator.",
    "Math.random() failed.",
    "Error: Too much power.",
    "I'm a calculator, not a wizard.",
    "Divided by zero? Boom.",
    "Error: Math.err",
    "Go ask Siri.",
    "Error: User error.",
    "Error: Sarcastic calculator.",
    "Stop breaking things.",
    "Error: Math police alerted.",
    "Nice try. Try again.",
    "Error: Out of bounds.",
    "Error: Brain not found.",
    "Zero division? Not today.",
    "Error: Do math, not war.",
    "Calculations are hard.",
    "Error: Division.fail",
    "Congratulations, you broke it.",
    "Error: No logic present.",
    "Error: System confused.",
    "Math is hard, isn't it?",
    "Error: Invalid brainwave.",
    "Divide by zero? Highly illegal.",
    "Error: Computer says no.",
    "Error: Glitch in the matrix.",
    "Error: Error displaying error.",
    "Stop. Just stop.",
    "Error: Divide.error",
    "Did you fail third grade?",
    "Error: Sarcasm engaged.",
    "Error: Syntax error.",
    "Zero is not your friend.",
    "Error: Calculator on strike.",
    "Error: Math is broken.",
    "Try another number.",
    "Error: Logic.exe crashed.",
    "Division by zero? Seriously?",
    "Error: Math emergency.",
    "Error: Uncomputable.",
    "Error: Bad input.",
    "Error: Calculator fainted.",
    "Error: Math.rip",
    "Error: System meltdown.",
    "Don't push my buttons.",
    "Error: Division by zero? Nope.",
    "Error: Invalid request.",
    "Error: Try fingers.",
    "Error: Mind blown.",
    "Error: Arithmetic failure.",
    "Error: Calculation failed.",
    "Error: Too hard for me.",
    "Error: Try abacus.",
    "Error: Out of range.",
    "Error: Brain.exe not found.",
    "Error: Math rules broken.",
    "Error: Zero division error.",
    "Error: Math is too hard.",
    "Error: Try counting sheep.",
    "Error: Calculator tired.",
    "Error: Logic error.",
    "Error: Infinite stupidity.",
    "Error: Zero cannot divide.",
    "Error: Game over."
  ];

  void _showError() {
    final randIndex = math.Random().nextInt(_errorMessages.length);
    setState(() {
      _display = _errorMessages[randIndex];
      _equation = '';
      _operand1 = '';
      _operator = '';
      _shouldReset = true;
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_display == '0' || _shouldReset || _errorMessages.contains(_display)) {
        _display = number;
        _shouldReset = false;
      } else {
        _display += number;
      }
    });
  }

  void _onDotPressed() {
    setState(() {
      if (_shouldReset || _errorMessages.contains(_display)) {
        _display = '0.';
        _shouldReset = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPressed(String op) {
    if (_errorMessages.contains(_display)) return;
    setState(() {
      if (_operand1.isNotEmpty && _operator.isNotEmpty && !_shouldReset) {
        _evaluateInternal();
      }
      _operand1 = _display;
      _operator = op;
      _equation = '$_operand1 $_operator';
      _shouldReset = true;
    });
  }

  void _onEqualPressed() {
    if (_operand1.isEmpty || _operator.isEmpty || _errorMessages.contains(_display)) return;
    setState(() {
      _equation = '$_operand1 $_operator $_display =';
      _evaluateInternal();
    });
  }

  void _evaluateInternal() {
    double num1 = double.tryParse(_operand1) ?? 0.0;
    double num2 = double.tryParse(_display) ?? 0.0;
    double result = 0.0;

    if (_operator == '/' && num2 == 0.0) {
      _showError();
      return;
    }

    switch (_operator) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '*':
        result = num1 * num2;
        break;
      case '/':
        result = num1 / num2;
        break;
    }

    String resultStr = result.toString();
    if (resultStr.endsWith('.0')) {
      resultStr = resultStr.substring(0, resultStr.length - 2);
    }
    _display = resultStr;
    _operand1 = '';
    _operator = '';
    _shouldReset = true;
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _equation = '';
      _operand1 = '';
      _operator = '';
      _shouldReset = false;
    });
  }

  void _onToggleSignPressed() {
    if (_errorMessages.contains(_display) || _display == '0') return;
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _onPercentPressed() {
    if (_errorMessages.contains(_display)) return;
    double val = double.tryParse(_display) ?? 0.0;
    setState(() {
      double result = val / 100.0;
      String resultStr = result.toString();
      if (resultStr.endsWith('.0')) {
        resultStr = resultStr.substring(0, resultStr.length - 2);
      }
      _display = resultStr;
      _shouldReset = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'CALCULATOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_equation.isNotEmpty)
                      Text(
                        _equation,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: TextStyle(
                          color: _errorMessages.contains(_display)
                              ? const Color(0xFFFF1E1E)
                              : Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Grid of buttons
            Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xFF808080), width: 1),
                verticalInside: BorderSide(color: Color(0xFF808080), width: 1),
              ),
              children: [
                TableRow(
                  children: [
                    _buildButton('C', color: const Color(0xFFFF1E1E), isOperator: true),
                    _buildButton('+/-', isOperator: true),
                    _buildButton('%', isOperator: true),
                    _buildButton('/', isOperator: true, accentColor: const Color(0xFF00FF66)),
                  ],
                ),
                TableRow(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('*', isOperator: true, accentColor: const Color(0xFF00FF66)),
                  ],
                ),
                TableRow(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', isOperator: true, accentColor: const Color(0xFF00FF66)),
                  ],
                ),
                TableRow(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', isOperator: true, accentColor: const Color(0xFF00FF66)),
                  ],
                ),
                TableRow(
                  children: [
                    _buildButton('0'),
                    _buildButton('.'),
                    _buildButton('=', colspan: 2, isOperator: true, accentColor: const Color(0xFF00FF66), isFillAccent: true),
                    // Invisible placeholder to keep table structure correct
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String label, {
    int colspan = 1,
    bool isOperator = false,
    Color? color,
    Color? accentColor,
    bool isFillAccent = false,
  }) {
    if (label.isEmpty) return const SizedBox.shrink();

    return TableCell(
      child: GestureDetector(
        onTap: () {
          if (label == 'C') {
            _onClearPressed();
          } else if (label == '+/-') {
            _onToggleSignPressed();
          } else if (label == '%') {
            _onPercentPressed();
          } else if (label == '/' || label == '*' || label == '-' || label == '+') {
            _onOperatorPressed(label);
          } else if (label == '=') {
            _onEqualPressed();
          } else if (label == '.') {
            _onDotPressed();
          } else {
            _onNumberPressed(label);
          }
        },
        child: Container(
          height: 80,
          color: isFillAccent && accentColor != null ? accentColor : Colors.black,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isFillAccent
                  ? Colors.black
                  : (color ?? accentColor ?? (isOperator ? const Color(0xFFAAAAAA) : Colors.white)),
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
