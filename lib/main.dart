import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:ya_map/examples/widgets/map_page.dart';
import 'package:ya_map/examples/circle_map_object_page.dart';
import 'package:ya_map/examples/clusterized_placemark_collection_page.dart';
import 'package:ya_map/examples/bicycle_page.dart';
import 'package:ya_map/examples/driving_page.dart';
import 'package:ya_map/examples/map_controls_page.dart';
import 'package:ya_map/examples/map_object_collection_page.dart';
import 'package:ya_map/examples/placemark_map_object_page.dart';
import 'package:ya_map/examples/polyline_map_object_page.dart';
import 'package:ya_map/examples/polygon_map_object_page.dart';
import 'package:ya_map/examples/reverse_search_page.dart';
import 'package:ya_map/examples/search_page.dart';
import 'package:ya_map/examples/suggest_page.dart';
import 'package:ya_map/examples/user_layer_page.dart';

void main() {
  runApp(MaterialApp(home: MainPage()));
}

const List<MapPage> _allPages = <MapPage>[
  MapControlsPage(),
  ClusterizedPlacemarkCollectionPage(),
  MapObjectCollectionPage(),
  PlacemarkMapObjectPage(),
  PolylineMapObjectPage(),
  PolygonMapObjectPage(),
  CircleMapObjectPage(),
  TrafficLayerPage(),
  SuggestionsPage(),
  SearchPage(),
  ReverseSearchPage(),
  BicyclePage(),
  DrivingPage(),
];

class MainPage extends StatelessWidget {
  void _pushPage(BuildContext context, MapPage page) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) =>
            Scaffold(
                appBar: AppBar(title: Text(page.title)),
                body: Container(
                    padding: const EdgeInsets.all(8),
                    child: page
                )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('YandexMap examples')),
        body: Column(
            children: <Widget>[
              //Карта
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const YandexMap()
                  )
              ),
              //Список примеров функциональности yandexMap
              Expanded(
                  child: ListView.builder(
                    itemCount: _allPages.length,
                    itemBuilder: (_, int index) => ListTile(
                      title: Text(_allPages[index].title),
                      onTap: () => _pushPage(context, _allPages[index]),
                    ),
                  )
              )
            ]
        )
    );
  }
}











/*
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final Completer<YandexMapController> _completer = Completer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YandexMap(
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            child: const Icon(Icons.add)
          ),
          const SizedBox(height: 16,),
          FloatingActionButton(
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(YandexMapController controller) {
    _completer.complete(controller);
    controller.getUserCameraPosition();
  }


  Future<void> _zoomIn() async {
    YandexMapController controller = await _completer.future;
    controller.getMaxZoom();
  }

  Future<void> _zoomOut() async {
    YandexMapController controller = await _completer.future;
    controller.getMinZoom();
  }

}
*/