import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyDetailsScreen extends StatelessWidget {
  final DateTime startOfWeek;
  final DateTime endOfWeek;

  const WeeklyDetailsScreen({
    super.key,
    required this.startOfWeek,
    required this.endOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    var startYear = startOfWeek.year + 543;
    var endYear = endOfWeek.year + 543;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${startOfWeek.day}/${startOfWeek.month}/$startYear - ${endOfWeek.day}/${endOfWeek.month}/$endYear'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
            .where('timestamp',
                isLessThan:
                    Timestamp.fromDate(endOfWeek.add(Duration(days: 1))))
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Initialize weeklyData with all days set to 0 income
            Map<DateTime, Map<String, Map<String, double>>> weeklyData = {};
            for (int i = 0; i < 7; i++) {
              var date = startOfWeek.add(Duration(days: i));
              weeklyData[date] = {};
            }

            return buildContent(weeklyData);
          }

          Map<DateTime, Map<String, Map<String, double>>> weeklyData = {};

          for (var doc in snapshot.data!.docs) {
            var timestamp = (doc['timestamp'] as Timestamp).toDate();
            var normalizedDate =
                DateTime(timestamp.year, timestamp.month, timestamp.day);
            var productName = doc['name'];
            var quantity = doc['quantity'] as int;
            var price = doc['price'] as double;

            if (!weeklyData.containsKey(normalizedDate)) {
              weeklyData[normalizedDate] = {};
            }

            if (weeklyData[normalizedDate]!.containsKey(productName)) {
              weeklyData[normalizedDate]![productName]!['quantity'] =
                  weeklyData[normalizedDate]![productName]!['quantity']! +
                      quantity;
              weeklyData[normalizedDate]![productName]!['price'] =
                  weeklyData[normalizedDate]![productName]!['price']! + price;
            } else {
              weeklyData[normalizedDate]![productName] = {
                'quantity': quantity.toDouble(),
                'price': price
              };
            }
          }

          // Ensure all days of the week are included in the map
          for (int i = 0; i < 7; i++) {
            var date = startOfWeek.add(Duration(days: i));
            if (!weeklyData.containsKey(date)) {
              weeklyData[date] = {};
            }
          }

          // Sort weeklyData by day of the week
          var sortedWeeklyData = weeklyData.entries.toList()
            ..sort((a, b) => a.key.weekday.compareTo(b.key.weekday));

          return buildContent(Map.fromEntries(sortedWeeklyData));
        },
      ),
    );
  }

  Widget buildContent(
      Map<DateTime, Map<String, Map<String, double>>> weeklyData) {
    var dailyIncomeData = weeklyData.entries
        .map((entry) => BarChartGroupData(
              x: entry.key.weekday,
              barRods: [
                BarChartRodData(
                  toY: entry.value.values
                      .map((data) => data['price']!)
                      .fold(0.0, (a, b) => a + b),
                  color: Colors.red,
                  width: 30,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              showingTooltipIndicators: [0],
            ))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 5, top: 20, bottom: 30, right: 20),
              child: SizedBox(
                  height: 500,
                  width: dailyIncomeData.length *
                      60.0, // Make the chart scrollable
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: weeklyData.values
                              .map((dayData) => dayData.values
                                  .map((data) => data['price']!)
                                  .fold(0.0, (a, b) => a + b))
                              .reduce((a, b) => a > b ? a : b) +
                          10,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData group) =>
                              Colors.black,
                          tooltipPadding: EdgeInsets.all(2),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toStringAsFixed(
                                  2), // Display two decimal places
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  dayOfWeek(value.toInt()),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: dailyIncomeData,
                    ),
                  )),
            ),
          ),
          Column(
            children: weeklyData.entries.map((dayEntry) {
              var dailyDate = dayEntry.key;
              var productData = dayEntry.value;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'วันที่ ${dailyDate.day}/${dailyDate.month}/${dailyDate.year + 543}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (productData.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'ไม่มีการสั่งซื้อ',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: productData.length,
                      itemBuilder: (context, index) {
                        var entry = productData.entries.elementAt(index);
                        var productName = entry.key;
                        var quantity = entry.value['quantity']!.toInt();
                        var price = entry.value['price']!;

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text('สินค้า: $productName'),
                            subtitle: Text(
                              'จำนวน: $quantity แพ็ค, ราคา: ${price.toStringAsFixed(2)} บาท',
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  String dayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'จันทร์';
      case DateTime.tuesday:
        return 'อังคาร';
      case DateTime.wednesday:
        return 'พุธ';
      case DateTime.thursday:
        return 'พฤหัสบดี';
      case DateTime.friday:
        return 'ศุกร์';
      case DateTime.saturday:
        return 'เสาร์';
      case DateTime.sunday:
        return 'อาทิตย์';
      default:
        return '';
    }
  }
}
