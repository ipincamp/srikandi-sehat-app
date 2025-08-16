import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/cycle_history_model.dart';
import 'package:srikandi_sehat_app/provider/cycle_history_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CycleTrackingScreen extends StatefulWidget {
  const CycleTrackingScreen({super.key});

  @override
  State<CycleTrackingScreen> createState() => _CycleTrackingScreenState();
}

class _CycleTrackingScreenState extends State<CycleTrackingScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CycleHistoryProvider>();
      provider.fetchCycleHistory(refresh: true, context: context);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = context.read<CycleHistoryProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchCycleHistory(context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pelacakan Siklus Haid',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink[400],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<CycleHistoryProvider>()
                .fetchCycleHistory(refresh: true, context: context),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Consumer<CycleHistoryProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchCycleHistory(refresh: true, context: context);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildLegendaKalender()),
                SliverToBoxAdapter(
                  child: _buildKalender(provider.cycleHistory),
                ),
                if (provider.isLoading && provider.cycleHistory.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                      ),
                    ),
                  ),
                // if (provider.error != null)
                //   SliverFillRemaining(
                //     child: Center(
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Text(
                //             provider.error!,
                //             style: const TextStyle(color: Colors.pink),
                //           ),
                //           const SizedBox(height: 16),
                //           ElevatedButton(
                //             onPressed: () => provider.fetchCycleHistory(
                //               refresh: true,
                //               context: context,
                //             ),
                //             child: const Text('Coba Lagi'),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                if (provider.emptyMessage != null &&
                    provider.cycleHistory.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.emptyMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                if (provider.cycleHistory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildStatistikSiklus(provider.cycleHistory),
                  ),
                if (provider.isLoading && provider.cycleHistory.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendaKalender() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildItemLegenda(
            warna: Colors.purple,
            teks: 'HPHT',
            ikon: Icons.fiber_manual_record,
          ),
          const SizedBox(width: 24),
          _buildItemLegenda(
            warna: Colors.pink[300]!,
            teks: 'Durasi Haid',
            ikon: Icons.fiber_manual_record,
          ),
          const SizedBox(width: 24),
          _buildItemLegenda(
            warna: Colors.orange,
            teks: 'Prediksi',
            ikon: Icons.fiber_manual_record,
          ),
        ],
      ),
    );
  }

  Widget _buildItemLegenda({
    required Color warna,
    required String teks,
    required IconData ikon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 16, color: warna),
        const SizedBox(width: 8),
        Text(
          teks,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKalender(List<CycleData> dataSiklus) {
    final tanggalHaid = dataSiklus.map((siklus) {
      return DateTimeRange(start: siklus.startDate, end: siklus.finishDate);
    }).toList();

    final predictedCycles = _calculatePredictedCycles(dataSiklus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.grey[700]),
            weekendStyle: TextStyle(color: Colors.pink[400]),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.pink[100],
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.pink[400],
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(color: Colors.pink[400]),
            outsideDaysVisible: false,
            cellMargin: const EdgeInsets.all(4),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Colors.pink[400],
              borderRadius: BorderRadius.circular(8),
            ),
            formatButtonTextStyle: const TextStyle(color: Colors.white),
            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.pink),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: Colors.pink,
            ),
            headerMargin: const EdgeInsets.only(bottom: 8),
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildSelTanggal(day, tanggalHaid, predictedCycles);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildSelTanggal(
                day,
                tanggalHaid,
                predictedCycles,
                hariIni: true,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildSelTanggal(
                day,
                tanggalHaid,
                predictedCycles,
                terpilih: true,
              );
            },
          ),
        ),
      ),
    );
  }

  List<DateTimeRange> _calculatePredictedCycles(List<CycleData> cycles) {
    if (cycles.length < 2) return [];

    // Filter cycles that have cycleLength data
    final validCycles = cycles.where((c) => c.cycleLength != null).toList();
    if (validCycles.length < 2) return [];

    final lastCycle = validCycles.first;
    final averageCycleLength =
        validCycles.map((c) => c.cycleLength!).reduce((a, b) => a + b) ~/
        validCycles.length;

    final nextPredictedStart = lastCycle.startDate.add(
      Duration(days: averageCycleLength),
    );
    final nextPredictedEnd = nextPredictedStart.add(
      Duration(days: lastCycle.periodLength),
    );

    return [DateTimeRange(start: nextPredictedStart, end: nextPredictedEnd)];
  }

  Widget _buildSelTanggal(
    DateTime hari,
    List<DateTimeRange> tanggalHaid,
    List<DateTimeRange> predictedCycles, {
    bool hariIni = false,
    bool terpilih = false,
  }) {
    bool adalahHariHaid = false;
    bool adalahHariPertama = false;
    bool adalahPrediksi = false;

    for (final range in tanggalHaid) {
      if (hari.isAfter(range.start.subtract(const Duration(days: 1))) &&
          hari.isBefore(range.end.add(const Duration(days: 1)))) {
        adalahHariHaid = true;
        adalahHariPertama = isSameDay(hari, range.start);
        break;
      }
    }

    if (!adalahHariHaid) {
      for (final range in predictedCycles) {
        if (hari.isAfter(range.start.subtract(const Duration(days: 1))) &&
            hari.isBefore(range.end.add(const Duration(days: 1)))) {
          adalahPrediksi = true;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: terpilih
            ? Colors.pink[400]
            : hariIni
            ? Colors.pink[100]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              '${hari.day}',
              style: TextStyle(
                color: terpilih
                    ? Colors.white
                    : hariIni
                    ? Colors.pink[400]
                    : Colors.grey[800],
                fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (adalahHariHaid)
            Positioned(
              bottom: 4,
              child: Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                  color: adalahHariPertama ? Colors.purple : Colors.pink[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          if (adalahPrediksi && !adalahHariHaid)
            Positioned(
              bottom: 4,
              child: Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatistikSiklus(List<CycleData> dataSiklus) {
    if (dataSiklus.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Belum ada data siklus',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final siklusTerakhir = dataSiklus.first;
    final cyclesWithLength = dataSiklus.where((c) => c.cycleLength != null);

    final averagePeriod = dataSiklus.length > 1
        ? dataSiklus.map((c) => c.periodLength).reduce((a, b) => a + b) ~/
              dataSiklus.length
        : siklusTerakhir.periodLength;

    final averageCycle = cyclesWithLength.length > 1
        ? cyclesWithLength.map((c) => c.cycleLength!).reduce((a, b) => a + b) ~/
              cyclesWithLength.length
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.pink[400]),
                const SizedBox(width: 8),
                Text(
                  'Statistik Siklus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildItemStatistik(
              ikon: Icons.calendar_today,
              label: 'HPHT (Hari Pertama Haid Terakhir)',
              nilai: DateFormat(
                'EEEE, dd MMMM yyyy',
              ).format(siklusTerakhir.startDate),
            ),
            _buildItemStatistik(
              ikon: Icons.calendar_today_outlined,
              label: 'Selesai Haid Terakhir',
              nilai: DateFormat(
                'EEEE, dd MMMM yyyy',
              ).format(siklusTerakhir.finishDate),
            ),
            _buildItemStatistik(
              ikon: Icons.timelapse,
              label: 'Durasi Haid Terakhir',
              nilai: '${siklusTerakhir.periodLength} hari',
            ),
            if (siklusTerakhir.cycleLength != null)
              _buildItemStatistik(
                ikon: Icons.cyclone,
                label: 'Panjang Siklus Terakhir',
                nilai: '${siklusTerakhir.cycleLength} hari',
              ),
            const Divider(height: 24),
            _buildItemStatistik(
              ikon: Icons.av_timer,
              label: 'Rata-rata Durasi Haid',
              nilai: '$averagePeriod hari',
            ),
            if (averageCycle != null)
              _buildItemStatistik(
                ikon: Icons.timeline,
                label: 'Rata-rata Panjang Siklus',
                nilai: '$averageCycle hari',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemStatistik({
    required IconData ikon,
    required String label,
    required String nilai,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: Colors.pink[400], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  nilai,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
