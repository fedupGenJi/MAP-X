import 'package:flutter/material.dart';

class KMap2x4Page extends StatelessWidget {
  final List<List<String>> kMap;

  KMap2x4Page({required this.kMap});

  final List<List<int>> positions = [
    [0, 1, 3, 2],
    [4, 5, 7, 6]
  ];

  Widget _buildCell(String text, {bool isValue = false}) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isValue ? Colors.blueGrey[100] : Colors.transparent,
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSlantedHeader() {
    return Container(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          CustomPaint(
            painter: DiagonalLinePainter(),
            child: Container(),
          ),
          Align(
            alignment: Alignment(-0.5, 0.5),
            child: Text("A", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Align(
            alignment: Alignment(0.5, -0.5),
            child: Text("BC", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("2×4 K-Map Output"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  _buildSlantedHeader(),
                  _buildCell("B̅C̅"),
                  _buildCell("B̅C"),
                  _buildCell("BC"),
                  _buildCell("BC̅"),
                ]),
                for (int i = 0; i < 2; i++)
                  TableRow(
                    children: [
                      _buildCell(i == 0 ? "A̅" : "A"),
                      for (int j = 0; j < 4; j++)
                        _buildCell(kMap[i][j], isValue: true),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}