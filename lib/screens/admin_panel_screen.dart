// lib/screens/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';
import '../services/firebase_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Dashboard', 'Users', 'Logs'];
  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.history_rounded,
  ];

  bool get _isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile;

    Widget body;
    if (_selectedIndex == 0) {
      body = const _DashboardTab();
    } else if (_selectedIndex == 1) {
      body = const _UsersTab();
    } else {
      body = const _LogsTab();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0D7377), Color(0xFF14A085)]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Vixo Admin',
                style: TextStyle(
                    color: const Color(0xFF1A2634),
                    fontSize: mobile ? 14 : 16,
                    fontWeight: FontWeight.w700)),
            if (!mobile)
              const Text('Management Dashboard',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              icon: Icon(Icons.logout_rounded,
                  color: Colors.red.shade400, size: 15),
              label: Text('Logout',
                  style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red.shade100)),
              ),
              onPressed: () async {
                await FirebaseService.logout();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      // Mobile: bottom nav bar, Desktop: side rail
      bottomNavigationBar: mobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedItemColor: const Color(0xFF0D7377),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 8,
              selectedLabelStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: List.generate(_tabs.length, (i) {
                return BottomNavigationBarItem(
                  icon: Icon(_icons[i], size: 22),
                  label: _tabs[i],
                );
              }),
            )
          : null,
      body: mobile
          ? body
          : Row(children: [
              // Desktop sidebar
              Container(
                width: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(right: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('MENU',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_tabs.length, (i) {
                    final selected = _selectedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0D7377)
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: selected
                                ? Border.all(
                                    color: const Color(0xFF0D7377)
                                        .withValues(alpha: 0.2))
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Row(children: [
                            Icon(_icons[i],
                                color: selected
                                    ? const Color(0xFF0D7377)
                                    : Colors.grey.shade400,
                                size: 19),
                            const SizedBox(width: 10),
                            Text(_tabs[i],
                                style: TextStyle(
                                    color: selected
                                        ? const Color(0xFF0D7377)
                                        : Colors.grey.shade500,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13)),
                            if (selected) ...[
                              const Spacer(),
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF0D7377),
                                      shape: BoxShape.circle)),
                            ],
                          ]),
                        ),
                      ),
                    );
                  }),
                ]),
              ),
              Expanded(child: body),
            ]),
    );
  }
}

// ── DASHBOARD ──────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await AdminService.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: Color(0xFF0D7377)),
        SizedBox(height: 16),
        Text('Loading dashboard...', style: TextStyle(color: Colors.grey)),
      ]));
    }
    if (_error != null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
        const SizedBox(height: 12),
        Text('Error loading data',
            style: TextStyle(
                color: Colors.red.shade400, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377)),
        ),
      ]));
    }

    final stats = _stats!;
    final categoryCount = Map<String, int>.from(stats['categoryCount'] as Map);
    final totalRecords = stats['totalRecords'] as int;
    final totalUsers = stats['totalUsers'] as int;
    final avgBmi = (stats['avgBmi'] as num).toDouble();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF0D7377),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Dashboard',
                style: TextStyle(
                    color: const Color(0xFF1A2634),
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 15),
              label: const Text('Refresh', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0D7377)),
            ),
          ]),
          SizedBox(height: isMobile ? 12 : 20),

          // Stat Cards — 2 columns on mobile, 4 on desktop
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: isMobile ? 10 : 16,
            crossAxisSpacing: isMobile ? 10 : 16,
            childAspectRatio: isMobile ? 1.4 : 1.3,
            children: [
              _StatCard(
                  title: 'Total Users',
                  value: '$totalUsers',
                  subtitle: 'Accounts',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF0D7377)),
              _StatCard(
                  title: 'Total Records',
                  value: '$totalRecords',
                  subtitle: 'BMI entries',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF6C63FF)),
              _StatCard(
                  title: 'Average BMI',
                  value: totalRecords > 0 ? avgBmi.toStringAsFixed(1) : 'N/A',
                  subtitle: _getBmiLabel(avgBmi),
                  icon: Icons.monitor_weight_rounded,
                  color: _getBmiColor(avgBmi)),
              _StatCard(
                  title: 'Avg Records',
                  value: totalUsers > 0
                      ? (totalRecords / totalUsers).toStringAsFixed(1)
                      : '0',
                  subtitle: 'Per user',
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFFFF9800)),
            ],
          ),

          SizedBox(height: isMobile ? 14 : 24),

          // Charts — stacked on mobile, side-by-side on desktop
          if (isMobile) ...[
            _BmiPieCard(
                categoryCount: categoryCount, totalRecords: totalRecords),
            const SizedBox(height: 12),
            _CategoryCard(
                'Underweight',
                categoryCount['Underweight'] ?? 0,
                totalRecords,
                const Color(0xFF6C63FF),
                Icons.trending_down_rounded),
            const SizedBox(height: 10),
            _CategoryCard('Normal', categoryCount['Normal'] ?? 0, totalRecords,
                const Color(0xFF14A085), Icons.check_circle_rounded),
            const SizedBox(height: 10),
            _CategoryCard(
                'Overweight',
                categoryCount['Overweight'] ?? 0,
                totalRecords,
                const Color(0xFFFFB347),
                Icons.trending_up_rounded),
            const SizedBox(height: 10),
            _CategoryCard('Obese', categoryCount['Obese'] ?? 0, totalRecords,
                const Color(0xFFFF6B6B), Icons.warning_rounded),
          ] else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 6,
                child: _BmiPieCard(
                    categoryCount: categoryCount, totalRecords: totalRecords),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Column(children: [
                  _CategoryCard(
                      'Underweight',
                      categoryCount['Underweight'] ?? 0,
                      totalRecords,
                      const Color(0xFF6C63FF),
                      Icons.trending_down_rounded),
                  const SizedBox(height: 12),
                  _CategoryCard(
                      'Normal',
                      categoryCount['Normal'] ?? 0,
                      totalRecords,
                      const Color(0xFF14A085),
                      Icons.check_circle_rounded),
                  const SizedBox(height: 12),
                  _CategoryCard(
                      'Overweight',
                      categoryCount['Overweight'] ?? 0,
                      totalRecords,
                      const Color(0xFFFFB347),
                      Icons.trending_up_rounded),
                  const SizedBox(height: 12),
                  _CategoryCard(
                      'Obese',
                      categoryCount['Obese'] ?? 0,
                      totalRecords,
                      const Color(0xFFFF6B6B),
                      Icons.warning_rounded),
                ]),
              ),
            ]),
        ]),
      ),
    );
  }

  String _getBmiLabel(double bmi) {
    if (bmi == 0) return 'No data';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return const Color(0xFF6C63FF);
    if (bmi < 25) return const Color(0xFF14A085);
    if (bmi < 30) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }
}

// Extracted pie chart card widget
class _BmiPieCard extends StatelessWidget {
  final Map<String, int> categoryCount;
  final int totalRecords;
  const _BmiPieCard({required this.categoryCount, required this.totalRecords});

  PieChartSectionData _pieSection(int count, int total, Color color) {
    final pct = total > 0 ? count / total * 100 : 0.0;
    return PieChartSectionData(
      value: count > 0 ? count.toDouble() : 0.001,
      color: count > 0 ? color : Colors.grey.shade200,
      title: pct > 8 ? '${pct.toStringAsFixed(0)}%' : '',
      titleStyle: const TextStyle(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      radius: 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('BMI Distribution',
            style: TextStyle(
                color: Color(0xFF1A2634),
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text('$totalRecords total records',
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 16),
        SizedBox(
          height: isMobile ? 170 : 200,
          child: totalRecords == 0
              ? const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.pie_chart_outline,
                          color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text('No data yet', style: TextStyle(color: Colors.grey)),
                    ]))
              : Row(children: [
                  Expanded(
                    child: PieChart(PieChartData(
                      sections: [
                        _pieSection(categoryCount['Underweight'] ?? 0,
                            totalRecords, const Color(0xFF6C63FF)),
                        _pieSection(categoryCount['Normal'] ?? 0, totalRecords,
                            const Color(0xFF14A085)),
                        _pieSection(categoryCount['Overweight'] ?? 0,
                            totalRecords, const Color(0xFFFFB347)),
                        _pieSection(categoryCount['Obese'] ?? 0, totalRecords,
                            const Color(0xFFFF6B6B)),
                      ],
                      centerSpaceRadius: 38,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(enabled: false),
                    )),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: isMobile ? 110 : 130,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendItem('Underweight', const Color(0xFF6C63FF),
                              categoryCount['Underweight'] ?? 0, totalRecords),
                          const SizedBox(height: 10),
                          _legendItem('Normal', const Color(0xFF14A085),
                              categoryCount['Normal'] ?? 0, totalRecords),
                          const SizedBox(height: 10),
                          _legendItem('Overweight', const Color(0xFFFFB347),
                              categoryCount['Overweight'] ?? 0, totalRecords),
                          const SizedBox(height: 10),
                          _legendItem('Obese', const Color(0xFFFF6B6B),
                              categoryCount['Obese'] ?? 0, totalRecords),
                        ]),
                  ),
                ]),
        ),
      ]),
    );
  }
}

Widget _legendItem(String label, Color color, int count, int total) {
  final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Flexible(
      child: Text('$label\n$count · $pct%',
          style: const TextStyle(color: Color(0xFF444444), fontSize: 10),
          overflow: TextOverflow.ellipsis),
    ),
  ]);
}

Widget _StatCard(
    {required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
      border: Border.all(color: color.withValues(alpha: 0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.arrow_upward_rounded, color: color, size: 9),
        ),
      ]),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(
              color: Color(0xFF1A2634),
              fontSize: 20,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(title,
          style: const TextStyle(
              color: Color(0xFF1A2634),
              fontSize: 11,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 1),
      Text(subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

Widget _CategoryCard(
    String label, int count, int total, Color color, IconData icon) {
  final pct = total > 0 ? count / total : 0.0;
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3))
      ],
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 15),
      ),
      const SizedBox(width: 10),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF1A2634),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          Text('$count',
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5),
        ),
      ])),
    ]),
  );
}

// ── USERS TAB ──────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await AdminService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _filtered = users;
        _loading = false;
      });
      if (_search.isNotEmpty) _filter(_search);
    }
  }

  void _filter(String q) {
    _search = q;
    setState(() {
      _filtered = _users
          .where((u) =>
              u['name'].toString().toLowerCase().contains(q.toLowerCase()) ||
              u['email'].toString().toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text('Users',
              style: TextStyle(
                  color: const Color(0xFF1A2634),
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          if (!_loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFF0D7377).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_filtered.length}',
                  style: const TextStyle(
                      color: Color(0xFF0D7377),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Color(0xFF0D7377), size: 20),
              onPressed: _load,
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ]),
        const SizedBox(height: 10),
        // Search
        TextField(
          onChanged: _filter,
          style: const TextStyle(color: Color(0xFF1A2634), fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Colors.grey, size: 17),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0D7377))),
          ),
        ),
        const SizedBox(height: 10),

        // Table header — hidden on mobile (cards instead)
        if (!isMobile) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              SizedBox(width: 36),
              SizedBox(width: 12),
              Expanded(
                  flex: 3,
                  child: Text('USER',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1))),
              Expanded(
                  flex: 2,
                  child: Text('EMAIL',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1))),
              Expanded(
                  child: Text('RECORDS',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1))),
              Expanded(
                  child: Text('AVG BMI',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1))),
              SizedBox(width: 70),
            ]),
          ),
          const SizedBox(height: 8),
        ],

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D7377)))
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.people_outline,
                              color: Colors.grey.shade300, size: 56),
                          const SizedBox(height: 12),
                          const Text('No users found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                        ]))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final user = _filtered[i];
                        if (isMobile) {
                          return _UserCard(
                            user: user,
                            onDelete: () => _confirmDelete(ctx, user),
                            onViewRecords: () => _viewRecords(ctx, user),
                          );
                        }
                        return _UserRow(
                          user: user,
                          onDelete: () => _confirmDelete(ctx, user),
                          onViewRecords: () => _viewRecords(ctx, user),
                        );
                      },
                    ),
        ),
      ]),
    );
  }

  void _viewRecords(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => _UserRecordsDialog(uid: user['uid'], name: user['name']),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete User',
            style: TextStyle(
                color: Color(0xFF1A2634), fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 44),
          const SizedBox(height: 12),
          Text(
              'Delete "${user['name']}"? This will permanently remove their account and all BMI records.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await AdminService.deleteUser(user['uid']);
      _load();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('User "${user['name']}" deleted'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}

// Mobile: card layout for each user
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onDelete;
  final VoidCallback onViewRecords;
  const _UserCard(
      {required this.user,
      required this.onDelete,
      required this.onViewRecords});

  Color _bmiColor(double bmi) {
    if (bmi <= 0) return Colors.grey;
    if (bmi < 18.5) return const Color(0xFF6C63FF);
    if (bmi < 25) return const Color(0xFF14A085);
    if (bmi < 30) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  String _bmiLabel(double bmi) {
    if (bmi <= 0) return 'N/A';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final avgBmi = (user['avgBmi'] as num).toDouble();
    final name = user['name'] as String;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF0D7377).withValues(alpha: 0.1),
          child: Text(initial,
              style: const TextStyle(
                  color: Color(0xFF0D7377),
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    color: Color(0xFF1A2634),
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(user['email'],
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('${user['recordCount']} records',
                    style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
              if (avgBmi > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: _bmiColor(avgBmi).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                      'BMI ${avgBmi.toStringAsFixed(1)} · ${_bmiLabel(avgBmi)}',
                      style: TextStyle(
                          color: _bmiColor(avgBmi),
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
          ]),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: const Icon(Icons.visibility_rounded,
                  size: 18, color: Color(0xFF0D7377)),
              onPressed: onViewRecords,
              tooltip: 'View Records',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
          IconButton(
              icon: Icon(Icons.delete_rounded,
                  size: 18, color: Colors.red.shade400),
              onPressed: onDelete,
              tooltip: 'Delete',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ]),
      ]),
    );
  }
}

// Desktop: row layout
class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onDelete;
  final VoidCallback onViewRecords;
  const _UserRow(
      {required this.user,
      required this.onDelete,
      required this.onViewRecords});

  Color _bmiColor(double bmi) {
    if (bmi <= 0) return Colors.grey;
    if (bmi < 18.5) return const Color(0xFF6C63FF);
    if (bmi < 25) return const Color(0xFF14A085);
    if (bmi < 30) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  String _bmiLabel(double bmi) {
    if (bmi <= 0) return 'N/A';
    if (bmi < 18.5) return 'Under';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Over';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final avgBmi = (user['avgBmi'] as num).toDouble();
    final name = user['name'] as String;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF0D7377).withValues(alpha: 0.1),
          child: Text(initial,
              style: const TextStyle(
                  color: Color(0xFF0D7377),
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
            flex: 3,
            child: Text(name,
                style: const TextStyle(
                    color: Color(0xFF1A2634),
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text(user['email'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6)),
            child: Text('${user['recordCount']} recs',
                style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: avgBmi > 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      color: _bmiColor(avgBmi).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                      '${avgBmi.toStringAsFixed(1)} ${_bmiLabel(avgBmi)}',
                      style: TextStyle(
                          color: _bmiColor(avgBmi),
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                )
              : const Text('No data',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
        ),
        SizedBox(
          width: 70,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                icon: const Icon(Icons.visibility_rounded, size: 18),
                color: const Color(0xFF0D7377),
                onPressed: onViewRecords,
                tooltip: 'View Records',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
            IconButton(
                icon: Icon(Icons.delete_rounded,
                    size: 18, color: Colors.red.shade400),
                onPressed: onDelete,
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
          ]),
        ),
      ]),
    );
  }
}

class _UserRecordsDialog extends StatefulWidget {
  final String uid;
  final String name;
  const _UserRecordsDialog({required this.uid, required this.name});
  @override
  State<_UserRecordsDialog> createState() => _UserRecordsDialogState();
}

class _UserRecordsDialogState extends State<_UserRecordsDialog> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await AdminService.getUserRecords(widget.uid);
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF6C63FF);
    if (bmi < 25) return const Color(0xFF14A085);
    if (bmi < 30) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 40, vertical: isMobile ? 20 : 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: isMobile ? double.infinity : 650,
        height: isMobile ? double.infinity : 560,
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D7377).withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0D7377).withValues(alpha: 0.1),
                child: Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFF0D7377), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name,
                          style: const TextStyle(
                              color: Color(0xFF1A2634),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                      Text('${_records.length} BMI records',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                    ]),
              ),
              IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          // Body
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D7377)))
                : _records.isEmpty
                    ? const Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Icon(Icons.bar_chart_outlined,
                                color: Colors.grey, size: 44),
                            SizedBox(height: 12),
                            Text('No BMI records found',
                                style: TextStyle(color: Colors.grey)),
                          ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _records.length,
                        itemBuilder: (ctx, i) {
                          final r = _records[i];
                          final bmi = (r['bmi'] as num).toDouble();
                          final dateStr = r['date'] != null
                              ? r['date'].toString().substring(0, 10)
                              : '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _bmiColor(bmi).withValues(alpha: 0.2)),
                            ),
                            child: Row(children: [
                              Container(
                                width: 54,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 5),
                                decoration: BoxDecoration(
                                    color:
                                        _bmiColor(bmi).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(children: [
                                  Text(bmi.toStringAsFixed(1),
                                      style: TextStyle(
                                          color: _bmiColor(bmi),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text('BMI',
                                      style: TextStyle(
                                          color: _bmiColor(bmi), fontSize: 9)),
                                ]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: _bmiColor(bmi)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text(r['category'] ?? '',
                                            style: TextStyle(
                                                color: _bmiColor(bmi),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10)),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(dateStr,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ]),
                                    const SizedBox(height: 5),
                                    Wrap(spacing: 5, runSpacing: 4, children: [
                                      _infoChip('⚖️ ${r['weight']}kg'),
                                      _infoChip('📏 ${r['height']}cm'),
                                      _infoChip('${r['gender'] ?? ''}'),
                                      _infoChip('Age: ${r['age'] ?? ''}'),
                                      if (r['heartRate'] != null)
                                        _infoChip('❤️ ${r['heartRate']} bpm'),
                                      if (r['bloodSugar'] != null)
                                        _infoChip('🩸 ${r['bloodSugar']} mmol'),
                                      if (r['bpSystolic'] != null)
                                        _infoChip(
                                            'BP: ${r['bpSystolic']}/${r['bpDiastolic']}'),
                                    ]),
                                  ])),
                              IconButton(
                                icon: Icon(Icons.delete_rounded,
                                    color: Colors.red.shade400, size: 17),
                                onPressed: () async {
                                  await AdminService.deleteRecord(
                                      widget.uid, r['id']);
                                  _load();
                                },
                                tooltip: 'Delete Record',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 30, minHeight: 30),
                              ),
                            ]),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}

Widget _infoChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
        color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
  );
}

// ── LOGS TAB ──────────────────────────────────────────
class _LogsTab extends StatefulWidget {
  const _LogsTab();
  @override
  State<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<_LogsTab> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final logs = await AdminService.getAdminLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Activity Logs',
              style: TextStyle(
                  color: const Color(0xFF1A2634),
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          if (!_loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_logs.length}',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Color(0xFF0D7377), size: 20),
              onPressed: _load,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ]),
        const SizedBox(height: 14),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D7377)))
              : _logs.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.history,
                              color: Colors.grey.shade300, size: 56),
                          const SizedBox(height: 12),
                          const Text('No activity logs yet',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Admin actions will appear here',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ]))
                  : ListView.separated(
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final log = _logs[i];
                        final action = log['action'] as String? ?? '';
                        final ts = log['timestamp'];
                        String timeStr = 'Unknown time';
                        if (ts != null && ts is Timestamp) {
                          final dt = ts.toDate();
                          timeStr =
                              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }
                        final isDeleteUser = action == 'delete_user';
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ],
                            border: Border(
                                left: BorderSide(
                                    color: isDeleteUser
                                        ? Colors.red.shade400
                                        : Colors.orange.shade400,
                                    width: 3)),
                          ),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color:
                                    (isDeleteUser ? Colors.red : Colors.orange)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                  isDeleteUser
                                      ? Icons.person_remove_rounded
                                      : Icons.delete_rounded,
                                  color: isDeleteUser
                                      ? Colors.red.shade400
                                      : Colors.orange.shade400,
                                  size: 17),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      isDeleteUser
                                          ? 'User Account Deleted'
                                          : 'BMI Record Deleted',
                                      style: const TextStyle(
                                          color: Color(0xFF1A2634),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(timeStr,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                ])),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    (isDeleteUser ? Colors.red : Colors.orange)
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(isDeleteUser ? 'User' : 'Record',
                                  style: TextStyle(
                                      color: isDeleteUser
                                          ? Colors.red.shade400
                                          : Colors.orange.shade400,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
