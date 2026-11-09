import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/weather_provider.dart';
import 'weather_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final searchController = TextEditingController();
  final latController = TextEditingController(text: '17.3850');
  final lonController = TextEditingController(text: '78.4867');

  final mapController = MapController();

  Timer? debounce;
  Place? chosen;
  bool mapReady = false;

  static const Color accent = Color(0xFF397D83);

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  void moveMap(double latitude, double longitude, {double zoom = 7}) {
    if (!mapReady) return;
    mapController.move(LatLng(latitude, longitude), zoom);
  }

  void selectPlace(Place place) {
    setState(() {
      chosen = place;
      latController.text = place.latitude.toStringAsFixed(4);
      lonController.text = place.longitude.toStringAsFixed(4);
    });

    moveMap(place.latitude, place.longitude, zoom: 9);
  }

  void selectCoordinates() {
    final lat = double.tryParse(latController.text.trim());
    final lon = double.tryParse(lonController.text.trim());

    if (lat == null ||
        lon == null ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter valid coordinates: Latitude -90 to 90 and Longitude -180 to 180.',
          ),
        ),
      );
      return;
    }

    final place = Place(
      name: 'Selected location',
      country: 'Coordinates',
      latitude: lat,
      longitude: lon,
    );

    setState(() => chosen = place);
    moveMap(lat, lon, zoom: 9);
  }

  void selectMapLocation(LatLng point) {
    final place = Place(
      name: 'Map selection',
      country: 'Coordinates',
      latitude: point.latitude,
      longitude: point.longitude,
    );

    setState(() {
      chosen = place;
      latController.text = point.latitude.toStringAsFixed(4);
      lonController.text = point.longitude.toStringAsFixed(4);
    });
  }

  Future<void> continueToWeather() async {
    if (chosen == null) return;

    await context.read<WeatherProvider>().loadWeather(chosen!);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WeatherScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Explore a location',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF397D83),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/seasons/spring.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xCFF4F7F5)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 950;

                if (isDesktop) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 370,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: _controls(provider),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: _map()),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _controls(provider),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: constraints.maxWidth < 600 ? 350 : 450,
                      child: _map(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(WeatherProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find your place',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            color: Color(0xFF244D50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Search for a city, tap the map, or enter coordinates.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 20),

        // City search
        glassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: accent),
              hintText: 'Search city or country',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              debounce?.cancel();

              if (value.trim().isEmpty) return;

              debounce = Timer(const Duration(milliseconds: 450), () {
                if (mounted) {
                  provider.search(value.trim());
                }
              });
            },
          ),
        ),

        if (provider.isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(color: accent),
          ),

        // Search results
        if (provider.searchResults.isNotEmpty) ...[
          const SizedBox(height: 10),
          glassCard(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: provider.searchResults.map((place) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: accent,
                  ),
                  title: Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(place.displayName),
                  trailing: const Icon(
                    Icons.add_circle_outline,
                    color: accent,
                  ),
                  onTap: () {
                    selectPlace(place);
                    FocusScope.of(context).unfocus();
                  },
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 22),

        // Coordinate input
        glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.my_location_rounded, color: accent),
                  SizedBox(width: 9),
                  Text(
                    'Use coordinates',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF244D50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.north),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lonController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.east),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: const BorderSide(color: accent),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: selectCoordinates,
                  icon: const Icon(Icons.pin_drop_outlined),
                  label: const Text('Use these coordinates'),
                ),
              ),
            ],
          ),
        ),

        // Selected location
        if (chosen != null) ...[
          const SizedBox(height: 16),
          glassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: accent,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chosen!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF244D50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chosen!.latitude.toStringAsFixed(4)}, '
                        '${chosen!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed:
                chosen == null || provider.isLoading ? null : continueToWeather,
            icon: provider.isLoading
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.cloud_rounded),
            label: Text(
              provider.isLoading ? 'Loading weather...' : 'Show weather report',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),

        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _map() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(20, 0),
              initialZoom: 2,
              onMapReady: () {
                mapReady = true;
                if (chosen != null) {
                  moveMap(chosen!.latitude, chosen!.longitude, zoom: 9);
                }
              },
              onTap: (tapPosition, point) {
                selectMapLocation(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.atmosphere_weather',
              ),
              if (chosen != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(chosen!.latitude, chosen!.longitude),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          // Map instruction
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    color: Colors.white.withValues(alpha: 0.85),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: accent,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap anywhere on the map to select a location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF244D50),
                            ),
                          ),
                        ),
                      ],
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
