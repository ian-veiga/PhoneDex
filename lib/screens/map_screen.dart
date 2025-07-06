// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pphonedex/models/store_model.dart';
import 'package:pphonedex/services/geoapify_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // !! Lembre-se de colocar sua chave de API aqui !!
  final GeoapifyService _geoapifyService = GeoapifyService('6628cac146e048dc98eb4e09fb926399');

  LatLng? _currentPosition;
  List<Store> _nearbyStores = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final position = await _determinePosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      await _getNearbyStores();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('O serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('A permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'A permissão de localização foi negada permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getNearbyStores() async {
    if (_currentPosition == null) return;

    try {
      final stores = await _geoapifyService.findNearbyStores(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      setState(() {
        _nearbyStores = stores;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao buscar lojas: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lojas Próximas'),
        backgroundColor: Colors.red,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Ocorreu um erro: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return const Center(child: Text('Não foi possível obter a localização.'));
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentPosition!,
          child: const Icon(
            Icons.my_location,
            color: Colors.blueAccent,
            size: 40.0,
          ),
        ),
      );
    }

    markers.addAll(
      _nearbyStores.map(
        (store) => Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(store.lat, store.lon),
          child: Tooltip(
            message: store.name,
            child: const Icon(
              Icons.store,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        ),
      ),
    );

    return markers;
  }
}