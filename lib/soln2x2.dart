import 'package:flutter/material.dart';

class KMapPage extends StatelessWidget {
  final List<List<String>> kMap;

  KMapPage({required this.kMap});

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
    List<RRect> highlightedGroups = _findGroups(kMap);
    String solution = _generateSolution(highlightedGroups);

    return Scaffold(
      appBar: AppBar(title: Text('2x2 k-Map Solver')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 50, height: 50),
                          _buildLabel('B\''),
                          _buildLabel('B'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              _buildLabel('A\''),
                              _buildLabel('A'),
                            ],
                          ),
                          Column(
                            children: kMap.asMap().entries.map((rowEntry) {
                              List<String> row = rowEntry.value;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: row.asMap().entries.map((cellEntry) {
                                  String cell = cellEntry.value;
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Text(cell,
                                        style: TextStyle(fontSize: 20)),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPaint(
                      size: Size(100, 100),
                      painter: KMapPainter(kMap, highlightedGroups),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Solution: $solution',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<RRect> _findGroups(List<List<String>> kMap) {
    final cellSize = 50.0;
    final double padding = 6.0;
    List<RRect> groups = [];
    List<List<Offset>> tempGroups = [];
    Set<Offset> coveredCells = {};

    bool isOne(int x, int y) {
      return kMap[x][y] == '1';
    }

    bool isExpandable(int x, int y) {
      return kMap[x][y] == '1' || kMap[x][y] == 'X';
    }

    void addTempGroup(int x, int y, double width, double height, double radius,
        List<Offset> cells) {
      tempGroups.add(cells);
    }

    void prioritizeGroups() {
      tempGroups.sort((a, b) {
        int countA =
            a.where((cell) => isOne(cell.dx.toInt(), cell.dy.toInt())).length;
        int countB =
            b.where((cell) => isOne(cell.dx.toInt(), cell.dy.toInt())).length;
        return countB.compareTo(countA);
      });
    }

    void confirmGroups() {
      for (var group in tempGroups) {
        bool hasUncoveredOne = false;
        for (var cell in group) {
          if (isOne(cell.dx.toInt(), cell.dy.toInt()) &&
              !coveredCells.contains(cell)) {
            hasUncoveredOne = true;
            break;
          }
        }
        if (hasUncoveredOne) {
          groups.add(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  group.first.dy * cellSize + padding,
                  group.first.dx * cellSize + padding,
                  (group.last.dy - group.first.dy + 1) * cellSize - 2 * padding,
                  (group.last.dx - group.first.dx + 1) * cellSize -
                      2 * padding),
              Radius.circular(15),
            ),
          );
          coveredCells.addAll(group);
        }
      }
    }

    if (isExpandable(0, 0) &&
        isExpandable(0, 1) &&
        isExpandable(1, 0) &&
        isExpandable(1, 1)) {
      addTempGroup(0, 0, cellSize * 2 - 2 * padding, cellSize * 2 - 2 * padding,
          20, [Offset(0, 0), Offset(0, 1), Offset(1, 0), Offset(1, 1)]);
    }

    if (isExpandable(0, 0) && isExpandable(0, 1)) {
      addTempGroup(0, 0, cellSize * 2 - 2 * padding, cellSize - 2 * padding, 15,
          [Offset(0, 0), Offset(0, 1)]);
    }
    if (isExpandable(1, 0) && isExpandable(1, 1)) {
      addTempGroup(1, 0, cellSize * 2 - 2 * padding, cellSize - 2 * padding, 15,
          [Offset(1, 0), Offset(1, 1)]);
    }
    if (isExpandable(0, 0) && isExpandable(1, 0)) {
      addTempGroup(0, 0, cellSize - 2 * padding, cellSize * 2 - 2 * padding, 15,
          [Offset(0, 0), Offset(1, 0)]);
    }
    if (isExpandable(0, 1) && isExpandable(1, 1)) {
      addTempGroup(0, 1, cellSize - 2 * padding, cellSize * 2 - 2 * padding, 15,
          [Offset(0, 1), Offset(1, 1)]);
    }

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        if (isOne(i, j) &&
            !coveredCells.contains(Offset(i.toDouble(), j.toDouble()))) {
          addTempGroup(i, j, cellSize - 2 * padding, cellSize - 2 * padding, 30,
              [Offset(i.toDouble(), j.toDouble())]);
        }
      }
    }

    prioritizeGroups();
    confirmGroups();
    return groups;
  }

  String _generateSolution(List<RRect> groups) {
    final cellVariables = {
      Offset(0, 0): ["A'", "B'"],
      Offset(0, 1): ["A'", "B"],
      Offset(1, 0): ["A", "B'"],
      Offset(1, 1): ["A", "B"],
    };

    List<String> expressions = [];

    for (var group in groups) {
      List<Offset> cells = [];

      double top = group.top;
      double left = group.left;
      double cellSize = 50.0;

      int startRow = (top / cellSize).round();
      int startCol = (left / cellSize).round();
      int rows = (group.height / cellSize).round();
      int cols = (group.width / cellSize).round();

      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          Offset offset =
              Offset((startRow + i).toDouble(), (startCol + j).toDouble());
          cells.add(offset);
        }
      }

      if (cells.isEmpty) continue;

      // Start with variable set of the first cell
      Set<String> commonVars = Set.from(cellVariables[cells[0]]!);

      for (int i = 1; i < cells.length; i++) {
        final vars = Set.from(cellVariables[cells[i]]!);
        commonVars = commonVars.intersection(vars);
      }

      expressions.add(commonVars.join());
    }

    if (expressions.isEmpty) return '0';
    if (expressions.length == 1 && expressions[0] == '') return '1';

    return expressions.join(' + ');
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
      ..color = Colors.red.withOpacity(1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var group in highlightedGroups) {
      canvas.drawRRect(group, rectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}