import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyDetailsScreen extends StatelessWidget {
  final DateTime startOfMonth;
  final DateTime endOfMonth;

  const MonthlyDetailsScreen({
    super.key,
    required this.startOfMonth,
    required this.endOfMonth,
  });

  @override
  Widget build(BuildContext context) {
    String formattedStartOfMonth = DateFormat('MMMM y', 'th_TH')
        .format(startOfMonth.add(const Duration(days: 198326)));

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedStartOfMonth),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .where('timestamp',
                isLessThan:
                    Timestamp.fromDate(endOfMonth.add(const Duration(days: 1))))
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Initialize weeklyData with all weeks set to 0 income
            Map<int, Map<String, Map<String, double>>> weeklyData = {};
            int totalWeeks =
                ((endOfMonth.day + startOfMonth.weekday - 1) / 7).ceil();
            for (int i = 1; i <= totalWeeks; i++) {
              weeklyData[i] = {};
            }

            return buildContent(weeklyData);
          }

          Map<int, Map<String, Map<String, double>>> weeklyData = {};
          int totalWeeks =
              ((endOfMonth.day + startOfMonth.weekday - 1) / 7).ceil();

          for (var doc in snapshot.data!.docs) {
            var timestamp = (doc['timestamp'] as Timestamp).toDate();
            var weekOfMonth =
                ((timestamp.day + startOfMonth.weekday - 1) / 7).ceil();
            var productName = doc['name'];
            var quantity = doc['quantity'] as int;
            var price = doc['price'] as double;

            if (!weeklyData.containsKey(weekOfMonth)) {
              weeklyData[weekOfMonth] = {};
            }

            if (weeklyData[weekOfMonth]!.containsKey(productName)) {
              weeklyData[weekOfMonth]![productName]!['quantity'] =
                  weeklyData[weekOfMonth]![productName]!['quantity']! +
                      quantity;
              weeklyData[weekOfMonth]![productName]!['price'] =
                  weeklyData[weekOfMonth]![productName]!['price']! + price;
            } else {
              weeklyData[weekOfMonth]![productName] = {
                'quantity': quantity.toDouble(),
                'price': price
              };
            }
          }

          for (int i = 1; i <= totalWeeks; i++) {
            if (!weeklyData.containsKey(i)) {
              weeklyData[i] = {};
            }
          }

          return buildContent(weeklyData);
        },
      ),
    );
  }

  Widget buildContent(Map<int, Map<String, Map<String, double>>> weeklyData) {
    // Sort weeklyData by week number
    var sortedWeeklyData = weeklyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    var weeklyIncomeData = sortedWeeklyData
        .map((entry) => BarChartGroupData(
              x: entry.key,
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
                  width: weeklyIncomeData.length *
                      100.0, // Make the chart scrollable
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: weeklyData.values
                              .map((weekData) => weekData.values
                                  .map((data) => data['price']!)
                                  .fold(0.0, (a, b) => a + b))
                              .reduce((a, b) => a > b ? a : b) +
                          10,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData group) =>
                              Colors.black,
                          tooltipPadding: const EdgeInsets.all(2),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toStringAsFixed(
                                  2), // Display two decimal places
                              const TextStyle(
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
                                  style: const TextStyle(
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
                                  'สัปดาห์ที่ ${value.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: weeklyIncomeData,
                    ),
                  )),
            ),
          ),
          Column(
            children: sortedWeeklyData.map((weekEntry) {
              var weekNumber = weekEntry.key;
              var productData = weekEntry.value;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'สัปดาห์ที่ $weekNumber',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (productData.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productData.length,
                      itemBuilder: (context, index) {
                        var entry = productData.entries.elementAt(index);
                        var productName = entry.key;
                        var quantity = entry.value['quantity']!.toInt();
                        var price = entry.value['price']!;

                        return Card(
                          margin: const EdgeInsets.all(10),
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
}
