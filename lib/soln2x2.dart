import 'package:flutter/material.dart';
import 'dart:math';

class KMapPage extends StatefulWidget {
  final List<List<String>> kMap;

  KMapPage({required this.kMap});

  @override
  State<KMapPage> createState() => _KMapPageState();
}

class _KMapPageState extends State<KMapPage> {
  List<List<int>> onesList = [];
  List<List<int>> xList = [];
  List<List<List<List<int>>>> solutions = [];
  int currentSolutionIndex = 0;

  @override
  void initState() {
    super.initState();
    _extractValues();
    solutions = _findAllSolutions(widget.kMap);
  }

  void _extractValues() {
    for (int row = 0; row < widget.kMap.length; row++) {
      for (int col = 0; col < widget.kMap[row].length; col++) {
        if (widget.kMap[row][col] == '1') {
          onesList.add([row, col]);
        } else if (widget.kMap[row][col].toUpperCase() == 'X') {
          xList.add([row, col]);
        }
      }
    }
  }

  List<List<List<int>>> allPossibleGroups(List<List<String>> kMap) {
    List<List<List<int>>> groups = [];

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        if (kMap[i][j] == '1' || kMap[i][j].toUpperCase() == 'X') {
          groups.add([
            [i, j]
          ]);
        }
      }
    }

    if ((kMap[0][0] == '1' || kMap[0][0].toUpperCase() == 'X') &&
        (kMap[0][1] == '1' || kMap[0][1].toUpperCase() == 'X')) {
      groups.add([
        [0, 0],
        [0, 1]
      ]);
    }
    if ((kMap[1][0] == '1' || kMap[1][0].toUpperCase() == 'X') &&
        (kMap[1][1] == '1' || kMap[1][1].toUpperCase() == 'X')) {
      groups.add([
        [1, 0],
        [1, 1]
      ]);
    }
    if ((kMap[0][0] == '1' || kMap[0][0].toUpperCase() == 'X') &&
        (kMap[1][0] == '1' || kMap[1][0].toUpperCase() == 'X')) {
      groups.add([
        [0, 0],
        [1, 0]
      ]);
    }
    if ((kMap[0][1] == '1' || kMap[0][1].toUpperCase() == 'X') &&
        (kMap[1][1] == '1' || kMap[1][1].toUpperCase() == 'X')) {
      groups.add([
        [0, 1],
        [1, 1]
      ]);
    }

    bool allCovered = true;
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        if (kMap[i][j] != '1' && kMap[i][j].toUpperCase() != 'X') {
          allCovered = false;
          break;
        }
      }
    }
    if (allCovered) {
      groups.add([
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1]
      ]);
    }

    return groups;
  }

  bool _coversAllOnes(List<List<int>> ones, List<List<List<int>>> groupCombo) {
    Set<String> covered = {};
    for (var group in groupCombo) {
      for (var pos in group) {
        covered.add('${pos[0]}-${pos[1]}');
      }
    }
    for (var one in ones) {
      if (!covered.contains('${one[0]}-${one[1]}')) return false;
    }
    return true;
  }

  List<List<List<List<int>>>> _findAllSolutions(List<List<String>> kMap) {
    final allGroups = allPossibleGroups(kMap);
    final List<List<List<List<int>>>> validSolutions = [];

    int n = allGroups.length;
    for (int i = 1; i < (1 << n); i++) {
      List<List<List<int>>> combo = [];
      for (int j = 0; j < n; j++) {
        if ((i & (1 << j)) != 0) {
          combo.add(allGroups[j]);
        }
      }
      if (_coversAllOnes(onesList, combo)) {
        validSolutions.add(combo);
      }
    }

    final List<List<List<List<int>>>> nonRedundant = [];
    for (var sol in validSolutions) {
      final solSet = sol
          .map((group) => group.map((e) => '${e[0]}-${e[1]}').toSet())
          .toList();

      bool isRedundant = false;
      for (var other in validSolutions) {
        if (identical(sol, other)) continue;
        if (other.length > sol.length) continue;

        final otherSet = other
            .map((group) => group.map((e) => '${e[0]}-${e[1]}').toSet())
            .toList();

        bool allCovered = solSet.every(
            (sGroup) => otherSet.any((oGroup) => oGroup.containsAll(sGroup)));

        if (allCovered) {
          isRedundant = true;
          break;
        }
      }

      if (!isRedundant) {
        nonRedundant.add(sol);
      }
    }

    final uniqueSolutions = <String, List<List<List<int>>>>{};
    for (var sol in nonRedundant) {
      final key = sol
          .map((group) => group.map((e) => '${e[0]}${e[1]}').toList()..sort())
          .toList()
        ..sort((a, b) => a.join().compareTo(b.join()));
      uniqueSolutions[key.map((e) => e.join(',')).join('|')] = sol;
    }

    return uniqueSolutions.values.toList();
  }

  List<RRect> _convertGroupsToRects(List<List<List<int>>> groups) {
    const double cellSize = 50.0;
    List<RRect> rrects = [];
    for (var group in groups) {
      int minRow = group.map((e) => e[0]).reduce(min);
      int maxRow = group.map((e) => e[0]).reduce(max);
      int minCol = group.map((e) => e[1]).reduce(min);
      int maxCol = group.map((e) => e[1]).reduce(max);

      final left = minCol * cellSize;
      final top = minRow * cellSize;
      final width = (maxCol - minCol + 1) * cellSize;
      final height = (maxRow - minRow + 1) * cellSize;

      rrects.add(RRect.fromLTRBR(
          left, top, left + width, top + height, Radius.circular(15)));
    }
    return rrects;
  }

  Widget _buildKMapGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 50, height: 50),
            _buildLabel("B'"),
            _buildLabel('B'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                _buildLabel("A'"),
                _buildLabel('A'),
              ],
            ),
            Stack(
              children: [
                CustomPaint(
                  size: Size(100, 100),
                  painter: KMapPainter(
                    widget.kMap,
                    [],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('2x2 K-Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildKMapGrid(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solutions found: ${solutions.length}'),
                  const SizedBox(height: 20),
                  ...solutions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final groups = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solution ${index + 1}:'),
                        SizedBox(height: 8),
                        CustomPaint(
                          size: Size(100, 100),
                          painter: KMapPainter(
                            widget.kMap,
                            _convertGroupsToRects(groups),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KMapPainter extends CustomPainter {
  final List<List<String>> kMap;
  final List<RRect> highlightedGroups;

  KMapPainter(this.kMap, this.highlightedGroups);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cellSize = size.width / 2;

    for (int i = 0; i <= 2; i++) {
      canvas.drawLine(
          Offset(i * cellSize, 0), Offset(i * cellSize, size.height), paint);
      canvas.drawLine(
          Offset(0, i * cellSize), Offset(size.width, i * cellSize), paint);
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(color: Colors.black, fontSize: 20);

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        final textSpan = TextSpan(text: kMap[i][j], style: textStyle);
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(j * cellSize + cellSize / 4, i * cellSize + cellSize / 4),
        );
      }
    }

    final rectPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var group in highlightedGroups) {
      canvas.drawRRect(group, rectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}