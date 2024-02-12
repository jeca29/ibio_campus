import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/view/pages/report_page.dart';
import 'package:get/get.dart';

class MonitoringPage2 extends StatefulWidget {
  @override
  _MonitoringPage2State createState() => _MonitoringPage2State();
}

class _MonitoringPage2State extends State<MonitoringPage2> {
  List<int> floraData = [0, 0, 0]; // Aerial, Aquatic, Terrestrial counts for Flora
  List<int> faunaData = [0, 0, 0]; // Aerial, Aquatic, Terrestrial counts for Fauna
  final List<Color> colors = [Colors.green, Colors.blue, Colors.brown]; // Chart section colors
  final List<String> labels = ['Aerial', 'Aquatic', 'Terrestrial'];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void fetchDataFromFirestore() async {
    // Assuming 'species' is your collection name
    final collection = FirebaseFirestore.instance.collection('species');
    final snapshot = await collection.get();

    // Initialize count variables
    int floraAerial = 0, floraAquatic = 0, floraTerrestrial = 0;
    int faunaAerial = 0, faunaAquatic = 0, faunaTerrestrial = 0;

    // Iterate through the documents and count
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final category = data['category'];
      final habitat = data['habitat'];

      if (category == 'Flora') {
        switch (habitat) {
          case 'Aerial':
            floraAerial++;
            break;
          case 'Aquatic':
            floraAquatic++;
            break;
          case 'Terrestrial':
            floraTerrestrial++;
            break;
        }
      } else if (category == 'Fauna') {
        switch (habitat) {
          case 'Aerial':
            faunaAerial++;
            break;
          case 'Aquatic':
            faunaAquatic++;
            break;
          case 'Terrestrial':
            faunaTerrestrial++;
            break;
        }
      }
    }

    setState(() {
      floraData = [floraAerial, floraAquatic, floraTerrestrial];
      faunaData = [faunaAerial, faunaAquatic, faunaTerrestrial];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.file_present),
            onPressed: () async {
              await Get.to(ReportPage());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text('iBioCampus Flora'),
            Container(
              height: 200, // Specify the height
              width: 200, // Specify the width
              child: PieChart(
                PieChartData(
                  sections: _getSections(floraData, isFlora: true),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            _buildLegend(),
            SizedBox(
              height: 50,
            ),
            Text('iBioCampus Fauna'),
            Container(
              height: 200, // Specify the height
              width: 200, // Specify the width
              child: PieChart(
                PieChartData(
                  sections: _getSections(faunaData),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (index) {
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(labels[index]),
            SizedBox(width: 16), // Add spacing between legend items
          ],
        );
      }),
    );
  }

  List<PieChartSectionData> _getSections(List<int> data, {bool isFlora = false}) {
    // Define color palette
    final colors = [Colors.green, Colors.blue, Colors.brown];

    return List.generate(data.length, (i) {
      final isTouched = false; // This can be modified to highlight a section when tapped
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
        color: colors[i],
        value: data[i].toDouble(),
        title: '${data[i]}',
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
      );
    });
  }
}
