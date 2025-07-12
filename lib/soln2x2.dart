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

  Widget _buildKMapGrid() {
    return Column(
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
                      child: Text(
                        cell,
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      ],
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
                children: List.generate(
                  20,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Scrollable content line ${index + 1}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}