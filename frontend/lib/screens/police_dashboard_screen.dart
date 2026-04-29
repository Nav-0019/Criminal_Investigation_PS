import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/history_service.dart';

class PoliceDashboardScreen extends StatefulWidget {
  @override
  _PoliceDashboardScreenState createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  List<HistoryItem> _historyItems = [];
  int _totalScams = 0;
  int _highRisk = 0;
  Map<String, int> _locations = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await HistoryService.getHistory();
    int high = 0;
    Map<String, int> locs = {};

    for (var item in items) {
      if (item.risk == 'HIGH') high++;
      String loc = item.location;
      if (loc.isEmpty) loc = 'Unknown';
      locs[loc] = (locs[loc] ?? 0) + 1;
    }

    if (mounted) {
      setState(() {
        _historyItems = items;
        _totalScams = items.length;
        _highRisk = high;
        _locations = locs;
      });
    }
  }

  final Map<String, LatLng> _cityCoords = {
    'Bangalore': LatLng(12.9716, 77.5946),
    'Delhi': LatLng(28.7041, 77.1025),
    'Mumbai': LatLng(19.0760, 72.8777),
    'Chennai': LatLng(13.0827, 80.2707),
    'Kolkata': LatLng(22.5726, 88.3639),
    'Hyderabad': LatLng(17.3850, 78.4867),
    'Pune': LatLng(18.5204, 73.8567),
    'Mysore': LatLng(12.2958, 76.6394),
  };

  Color getColor(int value) {
    if (value >= 300) return AppColors.highRed;
    if (value >= 150) return AppColors.medAmber;
    return AppColors.lowGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Command Dashboard', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refreshing dashboard data...')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operations Overview', style: AppTextStyles.subtitle),
            SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('Total Scam Reports', '$_totalScams'),
                _buildStatCard('High-Risk Cases', '$_highRisk'),
                _buildStatCard('Victim Count', '$_totalScams'),
                _buildStatCard('Cities Affected', '${_locations.length}'),
              ],
            ),
            SizedBox(height: 24),
            
            Text('Threat Density Map', style: AppTextStyles.subtitle),
            SizedBox(height: 8),
            Text('Live geographic monitoring of scam clusters.', style: AppTextStyles.caption),
            SizedBox(height: 12),
            _buildHeatmap(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.textMid)),
        ],
      ),
    );
  }

  Widget _buildHeatmap() {
    List<Marker> markers = [];
    _locations.forEach((city, count) {
      LatLng coord = _cityCoords[city] ?? LatLng(20.0, 75.0);
      markers.add(
        Marker(
          point: coord,
          width: 50,
          height: 50,
          child: Tooltip(
            message: '$city: $count incidents',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
              decoration: BoxDecoration(
                color: getColor(count).withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: getColor(count), width: 2),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(20.5937, 78.9629),
            initialZoom: 3.5,
          ),
          children: [
            TileLayer(
              urlTemplate: AppTheme.isDark 
                ? 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.nammashield',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
