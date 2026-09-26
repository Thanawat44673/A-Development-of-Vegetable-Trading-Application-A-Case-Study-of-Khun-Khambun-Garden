import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_appshop1/Pagesuse_admin/Statistics_Screen/MonthDetailsScreen.dart';
import 'package:flutter_appshop1/Pagesuse_admin/Statistics_Screen/WeeklyDetailsScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StatisticsAdmin extends StatefulWidget {
  const StatisticsAdmin({super.key});

  @override
  _StatisticsAdminState createState() => _StatisticsAdminState();
}

class _StatisticsAdminState extends State<StatisticsAdmin> {
  final CollectionReference _incomeCollection =
      FirebaseFirestore.instance.collection('orders');
  final Map<DateTime, double> _incomeData = {};
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _startOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    return _normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  DateTime _endOfWeek(DateTime date) {
    int daysToAdd = DateTime.sunday - date.weekday;
    return _normalizeDate(date.add(Duration(days: daysToAdd)));
  }

  DateTime _startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroud2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _incomeCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            _incomeData.clear();
            for (var doc in snapshot.data!.docs) {
              try {
                var date = (doc['timestamp'] as Timestamp).toDate();
                var dateKey = _normalizeDate(date);
                var income = doc['price'] as double;

                if (_incomeData.containsKey(dateKey)) {
                  _incomeData[dateKey] = _incomeData[dateKey]! + income;
                } else {
                  _incomeData[dateKey] = income;
                }
              } catch (e) {
                print('Error processing document: $e');
              }
            }

            var startOfWeek = _startOfWeek(_selectedDate);
            var endOfWeek = _endOfWeek(_selectedDate);
            var startOfMonth = _startOfMonth(_selectedDate);
            var endOfMonth = _endOfMonth(_selectedDate);

            double weeklyIncome = 0;
            double monthlyIncome = 0;

            for (var i = 0; i < 7; i++) {
              var currentDate = startOfWeek.add(Duration(days: i));
              var normalizedCurrentDate = _normalizeDate(currentDate);
              if (_incomeData.containsKey(normalizedCurrentDate)) {
                weeklyIncome += _incomeData[normalizedCurrentDate]!;
              }
            }

            for (var i = 0; i < endOfMonth.day; i++) {
              var currentDate = startOfMonth.add(Duration(days: i));
              var normalizedCurrentDate = _normalizeDate(currentDate);
              if (_incomeData.containsKey(normalizedCurrentDate)) {
                monthlyIncome += _incomeData[normalizedCurrentDate]!;
              }
            }

            String formattedSelectedDate = DateFormat('d MMMM y', 'th_TH')
                .format(_selectedDate.add(const Duration(days: 198326)));
            String formattedStartOfWeek = DateFormat('d MMM y', 'th_TH')
                .format(startOfWeek.add(const Duration(days: 198326)));
            String formattedEndOfWeek = DateFormat('d MMM y', 'th_TH')
                .format(endOfWeek.add(const Duration(days: 198326)));
            String formattedStartOfMonth = DateFormat('MMMM y', 'th_TH')
                .format(startOfMonth.add(const Duration(days: 198326)));

            return Column(
              children: [
                TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  calendarFormat: _calendarFormat,
                  locale: 'th_TH', // Set locale to Thai
                  selectedDayPredicate: (day) => isSameDay(
                      _normalizeDate(_selectedDate), _normalizeDate(day)),
                  eventLoader: (day) {
                    var normalizedDay = _normalizeDate(day);
                    if (_incomeData[normalizedDay] != null) {
                      return [
                        Text(
                            '${_incomeData[normalizedDay]!.toStringAsFixed(2)} ฿')
                      ];
                    }
                    return [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, locale) {
                      return DateFormat('MMMM y', 'th_TH')
                          .format(date.add(const Duration(days: 198326)));
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_incomeData[_normalizeDate(_selectedDate)] != null)
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DailyDetailsScreen(date: _selectedDate),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('วันที่: $formattedSelectedDate'),
                        subtitle: Text(
                            'รายได้ที่ได้รับ: ${_incomeData[_normalizeDate(_selectedDate)]!.toStringAsFixed(2)} บาท'),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'ไม่มีข้อมูลรายได้สำหรับวันที่เลือก',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
                if (weeklyIncome > 0)
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeeklyDetailsScreen(
                              startOfWeek: startOfWeek,
                              endOfWeek: endOfWeek,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                            'สัปดาห์ที่: $formattedStartOfWeek - $formattedEndOfWeek'),
                        subtitle: Text(
                            'รายได้ที่ได้รับ: ${weeklyIncome.toStringAsFixed(2)} บาท'),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'ไม่มีข้อมูลรายได้สำหรับสัปดาห์ที่เลือก',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
                if (monthlyIncome > 0)
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonthlyDetailsScreen(
                              startOfMonth: startOfMonth,
                              endOfMonth: endOfMonth,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('เดือน: $formattedStartOfMonth'),
                        subtitle: Text(
                            'รายได้ที่ได้รับ: ${monthlyIncome.toStringAsFixed(2)} บาท'),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'ไม่มีข้อมูลรายได้สำหรับเดือนที่เลือก',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DailyDetailsScreen extends StatelessWidget {
  final DateTime date;

  const DailyDetailsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    var buddhistYear = date.year + 543;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('สถิติรายได้วันที่ ${date.day}/${date.month}/$buddhistYear'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime(date.year, date.month, date.day)))
            .where('timestamp',
                isLessThan: Timestamp.fromDate(
                    DateTime(date.year, date.month, date.day + 1)))
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลสินค้าในวันนี้'));
          }

          Map<String, Map<String, double>> productData = {};

          for (var doc in snapshot.data!.docs) {
            var productName = doc['name'];
            var quantity = doc['quantity'] as int;
            var price = doc['price'] as double;

            if (productData.containsKey(productName)) {
              productData[productName]!['quantity'] =
                  productData[productName]!['quantity']! + quantity;
              productData[productName]!['price'] =
                  productData[productName]!['price']! + price;
            } else {
              productData[productName] = {
                'quantity': quantity.toDouble(),
                'price': price
              };
            }
          }

          var barChartGroupData = productData.entries
              .toList()
              .asMap()
              .map((index, entry) => MapEntry(
                    index,
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['price']!, // Change to quantity
                          color: Colors.red,
                          width: 30,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ))
              .values
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, top: 20, bottom: 30, right: 20),
                  child: SizedBox(
                    height: 500,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: productData.values
                              .map((data) => data['price']!)
                              .reduce((a, b) => a > b ? a : b) +
                          10,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData group) =>
                              Colors.black,
                          tooltipPadding: const EdgeInsets.all(2),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toString(),
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
                                  '${value.toInt()}',
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
                                  productData.keys.elementAt(value.toInt()),
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
                      barGroups: barChartGroupData,
                    )),
                  ),
                ),
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
                            'จำนวน: $quantity แพ็ค, ราคา: ${price.toStringAsFixed(2)} บาท'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
