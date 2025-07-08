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
    List<List<RRect>> allGroupingSolutions = _findAllGroupingSolutions(kMap);
    List<MapEntry<List<RRect>, String>> allSolutionsWithExpr =
        allGroupingSolutions.map((groups) {
      String expr = _generateSolution(groups);
      return MapEntry(groups, expr);
    }).toList();

    int minLength = allSolutionsWithExpr
        .map((e) => e.value.split(' + ').length)
        .reduce((a, b) => a < b ? a : b);

    List<MapEntry<List<RRect>, String>> minimalSolutions = allSolutionsWithExpr
        .where((e) => e.value.split(' + ').length == minLength)
        .toList();

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
            child: ListView.builder(
              itemCount: minimalSolutions.length,
              itemBuilder: (context, index) {
                final groups = minimalSolutions[index].key;
                final expression = minimalSolutions[index].value;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solution ${index + 1}:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: CustomPaint(
                          size: Size(100, 100),
                          painter: KMapPainter(kMap, groups),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Boolean Expression: ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Text(
                              expression,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<List<RRect>> _findAllGroupingSolutions(List<List<String>> kMap) {
    final cellSize = 50.0;
    final double padding = 6.0;

    List<List<Offset>> candidateGroups = [];

    bool isExpandable(int x, int y) => kMap[x][y] == '1' || kMap[x][y] == 'X';
    bool isOne(int row, int col) {
      return kMap[row][col] == '1';
    }

    void addGroup(List<Offset> cells) {
      candidateGroups.add(cells);
    }

    if (isExpandable(0, 0) && isExpandable(0, 1)) {
      addGroup([Offset(0, 0), Offset(0, 1)]);
    }
    if (isExpandable(1, 0) && isExpandable(1, 1)) {
      addGroup([Offset(1, 0), Offset(1, 1)]);
    }
    if (isExpandable(0, 0) && isExpandable(1, 0)) {
      addGroup([Offset(0, 0), Offset(1, 0)]);
    }
    if (isExpandable(0, 1) && isExpandable(1, 1)) {
      addGroup([Offset(0, 1), Offset(1, 1)]);
    }
    if (isExpandable(0, 0) &&
        isExpandable(0, 1) &&
        isExpandable(1, 0) &&
        isExpandable(1, 1)) {
      addGroup([
        Offset(0, 0),
        Offset(0, 1),
        Offset(1, 0),
        Offset(1, 1),
      ]);
    }

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        if (isOne(i, j)) {
          addGroup([Offset(i.toDouble(), j.toDouble())]);
        }
      }
    }

    List<List<RRect>> allSolutions = [];

    void backtrack(List<List<Offset>> path, int index, Set<Offset> used) {
      if (index == candidateGroups.length) {
        if (used.any((c) => isOne(c.dx.toInt(), c.dy.toInt()))) {
          allSolutions.add(path.map((group) {
            final topLeft = group.first;
            final bottomRight = group.last;
            return RRect.fromRectAndRadius(
              Rect.fromLTWH(
                topLeft.dy * cellSize + padding,
                topLeft.dx * cellSize + padding,
                (bottomRight.dy - topLeft.dy + 1) * cellSize - 2 * padding,
                (bottomRight.dx - topLeft.dx + 1) * cellSize - 2 * padding,
              ),
              Radius.circular(15),
            );
          }).toList());
        }
        return;
      }

      final group = candidateGroups[index];
      if (group.any((c) => used.contains(c))) {
        backtrack(path, index + 1, used);
      } else {
        path.add(group);
        backtrack(path, index + 1, {...used, ...group});
        path.removeLast();
        backtrack(path, index + 1, used);
      }
    }

    backtrack([], 0, {});
    return allSolutions;
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