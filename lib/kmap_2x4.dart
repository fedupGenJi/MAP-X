import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    if (!RegExp(r'^[0-7,\s]*$').hasMatch(text)) {
      return oldValue;
    }

    bool isDeletingComma = oldValue.text.length > newValue.text.length &&
        oldValue.text.endsWith(", ") &&
        cursorPosition > 0;

    List<String> parts = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isEmpty || RegExp(r'^[0-7]$').hasMatch(e))
        .toList();

    String formattedText = parts.join(', ');

    if (cursorPosition > 0 &&
        cursorPosition < formattedText.length &&
        formattedText[cursorPosition - 1] == ',') {
      cursorPosition++;
    }

    if (isDeletingComma) {
      cursorPosition -= 2;
    }

    cursorPosition = cursorPosition.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class KMap2x4 extends StatefulWidget {
  @override
  _KMap2x4State createState() => _KMap2x4State();
}

class _KMap2x4State extends State<KMap2x4> {
  Set<int> primeImplicants = {};
  Set<int> dontCares = {};
  TextEditingController piemController = TextEditingController();
  TextEditingController dController = TextEditingController();

  List<List<int>> positions = [
    [0, 1, 3, 2],
    [4, 5, 7, 6]
  ];

  void updateMap(String input, bool isPrime) {
    Set<int> newValues = {};
    List<String> inputValues = input.split(',').map((e) => e.trim()).toList();
    
    for (String value in inputValues) {
      if (value.isNotEmpty && RegExp(r'^[0-7]$').hasMatch(value)) {
        newValues.add(int.parse(value));
      }
    }

    setState(() {
      if (isPrime) {
        newValues.removeWhere((num) => dontCares.contains(num));
        primeImplicants = newValues;
      } else {
        newValues.removeWhere((num) => primeImplicants.contains(num));
        dontCares = newValues;
      }
    });
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isPrime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          inputFormatters: [CommaInputFormatter()],
          keyboardType: TextInputType.number,
          onChanged: (value) => updateMap(value, isPrime),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter values separated by commas",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "2×4 Karnaugh Map",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                _buildCell(""),
                _buildCell("B̅C̅"),
                _buildCell("B̅C"),
                _buildCell("BC"),
                _buildCell("BC̅"),
              ],
            ),
            for (int i = 0; i < 2; i++)
              TableRow(
                children: [
                  _buildCell(i == 0 ? "A̅" : "A"),
                  for (int j = 0; j < 4; j++)
                    _buildCell(
                      primeImplicants.contains(positions[i][j])
                          ? "1"
                          : (dontCares.contains(positions[i][j]) ? "X" : ""),
                      true,
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField("∑m:", piemController, true),
              const SizedBox(height: 10),
              _buildInputField("d:", dController, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(String text, [bool isValueCell = false]) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      color: isValueCell ? Colors.grey[300] : Colors.transparent,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}