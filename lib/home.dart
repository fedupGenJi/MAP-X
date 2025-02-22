import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kmap_2x4.dart';
import 'kmap_4x4.dart';

class CommaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    if (!RegExp(r'^[0-3,\s]*$').hasMatch(text)) {
      return oldValue;
    }

    bool isDeletingComma = oldValue.text.length > newValue.text.length &&
        oldValue.text.endsWith(", ") &&
        cursorPosition > 0;

    List<String> parts = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isEmpty || RegExp(r'^[0-3]$').hasMatch(e))
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedGrid = -1;
  Set<int> primeImplicants = {};
  Set<int> dontCares = {};
  TextEditingController piemController = TextEditingController();
  TextEditingController dController = TextEditingController();

  void updateDisplay(int gridType) {
    setState(() {
      selectedGrid = gridType;
    });
  }

  void updateMap(String input, bool isPrime) {
    Set<int> oldValues = isPrime ? primeImplicants : dontCares;
    Set<int> newValues = {};

    List<String> inputValues = input.split(',').map((e) => e.trim()).toList();
    for (String value in inputValues) {
      if (value.isNotEmpty && RegExp(r'^[0-3]$').hasMatch(value)) {
        newValues.add(int.parse(value));
      }
    }

    if (newValues.isEmpty) {
      setState(() {
        if (isPrime) {
          primeImplicants.clear();
        } else {
          dontCares.clear();
        }
      });
      return;
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

    if (oldValues.difference(newValues).isNotEmpty) {
      refreshTextFields(isPrime);
    }
  }

  void refreshTextFields(bool isPrime) {
    setState(() {
      if (isPrime) {
        piemController.text = primeImplicants.join(', ');
      } else {
        dController.text = dontCares.join(', ');
      }
    });
  }

  Widget buildKMap() {
    List<List<int>> positions = [
      [0, 1],
      [2, 3]
    ];

    return Column(
      children: [
        const Text(
          "2×2 Karnaugh Map",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                _buildCell(""),
                _buildCell("B̅"),
                _buildCell("B"),
              ],
            ),
            for (int i = 0; i < 2; i++)
              TableRow(
                children: [
                  _buildCell(i == 0 ? "A̅" : "A"),
                  for (int j = 0; j < 2; j++)
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
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isValueCell ? Colors.blueGrey[100] : Colors.transparent,
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isValueCell ? Colors.black87 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, bool isPrime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          inputFormatters: [CommaInputFormatter()],
          keyboardType: TextInputType.number,
          onChanged: (value) {
            updateMap(value, isPrime);
          },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("MAP-X"),
        actions: [
          _buildGridButton("2×2", 1),
          _buildGridButton("2×4", 2),
          _buildGridButton("4×4", 3),
        ],
      ),
      body: Center(
        child: selectedGrid == 1
            ? buildKMap()
            : selectedGrid == 2
                ? KMap2x4()
                : selectedGrid == 3
                    ? KMap4x4()
                    : Text(
                        selectedGrid == -1
                            ? "Welcome to K Map Solver\n\nMini Project for Digital Logic"
                            : "Unavailable",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
      ),
    );
  }

  Widget _buildGridButton(String label, int gridType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => updateDisplay(gridType),
        style: TextButton.styleFrom(
          foregroundColor:
              selectedGrid == gridType ? Colors.white : Colors.black,
          backgroundColor:
              selectedGrid == gridType ? Colors.blue : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}