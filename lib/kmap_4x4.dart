import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlantedCell extends StatelessWidget {
  final String text;

  SlantedCell(this.text);

  @override
  Widget build(BuildContext context) {
    List<String> parts = text.split(r"\");
    String leftText = parts.isNotEmpty ? parts[0] : "";
    String rightText = parts.length > 1 ? parts[1] : "";

    return Container(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          CustomPaint(
            painter: SlantedCellPainter(),
            child: Container(),
          ),
          Align(
            alignment: Alignment(-0.5, 0.5),
            child: Text(
              leftText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment(0.5, -0.5),
            child: Text(
              rightText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class SlantedCellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CommaInputFormatter extends TextInputFormatter {
  final Set<int> existingValues;
  CommaInputFormatter(this.existingValues);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    if (!RegExp(r'^[0-9,\s]*$').hasMatch(text)) {
      return oldValue;
    }

    List<String> parts = text.split(',').map((e) => e.trim()).toList();

    Set<int> uniqueValues = {};
    String formattedText = '';
    String lastPart = parts.isNotEmpty ? parts.last : '';

    for (int i = 0; i < parts.length - 1; i++) {
      String part = parts[i];

      if (RegExp(r'^[0-9]+$').hasMatch(part) &&
          int.tryParse(part) != null &&
          int.parse(part) <= 15) {
        int num = int.parse(part);
        if (!existingValues.contains(num) && uniqueValues.add(num)) {
          formattedText += (formattedText.isEmpty ? '' : ',') + part;
        }
      }
    }

    if (lastPart.isEmpty ||
        RegExp(r'^[0-9]+$').hasMatch(lastPart) &&
            int.tryParse(lastPart) != null &&
            int.parse(lastPart) <= 15) {
      formattedText += (formattedText.isEmpty ? '' : ',') + lastPart;
    }

    cursorPosition = cursorPosition.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class KMap4x4 extends StatefulWidget {
  @override
  _KMap4x4State createState() => _KMap4x4State();
}

class _KMap4x4State extends State<KMap4x4> {
  Set<int> primeImplicants = {};
  Set<int> dontCares = {};
  TextEditingController piemController = TextEditingController();
  TextEditingController dController = TextEditingController();

  List<List<int>> positions = [
    [0, 1, 3, 2],
    [4, 5, 7, 6],
    [12, 13, 15, 14],
    [8, 9, 11, 10]
  ];

  void updateMap(String input, bool isPrime) {
    if (input.isEmpty) {
      setState(() {
        if (isPrime) {
          primeImplicants.clear();
        } else {
          dontCares.clear();
        }
      });
      return;
    }

    Set<int> newValues = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && int.tryParse(e) != null)
        .map((e) => int.parse(e))
        .where((num) => num >= 0 && num <= 15)
        .toSet();

    setState(() {
      if (isPrime) {
        newValues.forEach((num) => dontCares.remove(num));
        primeImplicants.addAll(newValues);
      } else {
        newValues.forEach((num) => primeImplicants.remove(num));
        dontCares.addAll(newValues);
      }

      primeImplicants.removeAll(dontCares);
      dontCares.removeAll(primeImplicants);
    });
  }

  Widget _buildInputField(
      String label, TextEditingController controller, bool isPrime) {
    FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        updateMap(controller.text, isPrime);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          focusNode: focusNode,
          inputFormatters: [
            CommaInputFormatter(isPrime ? dontCares : primeImplicants)
          ],
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty && value.endsWith(',')) {
              updateMap(value, isPrime);
            }
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter values separated by commas (0-15)",
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
          "4×4 Karnaugh Map",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                SlantedCell("AB\\CD"),
                _buildCell("C̅D̅"),
                _buildCell("C̅D"),
                _buildCell("CD"),
                _buildCell("CD̅"),
              ],
            ),
            for (int i = 0; i < 4; i++)
              TableRow(
                children: [
                  _buildCell(i == 0
                      ? "A̅B̅"
                      : i == 1
                          ? "A̅B"
                          : i == 2
                              ? "AB"
                              : "AB̅"),
                  for (int j = 0; j < 4; j++)
                    _buildCell(
                      primeImplicants.contains(positions[i][j])
                          ? "1"
                          : (dontCares.contains(positions[i][j]) ? "X" : "0"),
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
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      piemController.clear();
                      dController.clear();
                      primeImplicants.clear();
                      dontCares.clear();
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.black),
                  label: Text("Clear", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
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
}