import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:ya_map/examples/widgets/control_button.dart';
import 'package:ya_map/examples/widgets/map_page.dart';

class MapControlsPage extends MapPage {
  const MapControlsPage() : super('Map controls example');

  @override
  Widget build(BuildContext context) {
    return _MapControlsExample();
  }
}

class _MapControlsExample extends StatefulWidget {
  @override
  _MapControlsExampleState createState() => _MapControlsExampleState();
}

class _MapControlsExampleState extends State<_MapControlsExample> {
  late YandexMapController controller;
  //Пустой лис объектов карты
  final List<MapObject> mapObjects = [];

  //Уникальный объект со значением = 'target_placemark'
  final MapObjectId targetMapObjectId = MapObjectId('target_placemark');
  //static final Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  //Дом
  static final Point _point = Point(latitude: 51.822418, longitude: 107.643000);
  final animation = MapAnimation(type: MapAnimationType.smooth, duration: 2.0);

  //Включить жесты наклона, такие как параллельное панорамирование двумя пальцами.
  bool tiltGesturesEnabled = true;
  //Включить жесты вращения, например приближение двумя пальцами.
  bool zoomGesturesEnabled = true;
  //Включить жесты вращения, например вращение двумя пальцами
  bool rotateGesturesEnabled = true;
  //Включить жесты прокрутки, например жест панорамирования
  bool scrollGesturesEnabled = true;
  //Включает подробные 3D-модели на карте.
  bool modelsEnabled = true;
  // Включить/отключить ночной режим
  bool nightModeEnabled = false;
  //Включает/убирает задержку в 300 мс при выполнении жеста касания.
  //Однако двойное касание будет сопровождаться жестом касания вместе с двойным касанием.
  bool fastTapEnabled = false;
  //Делает карту плоской.
    // true - Все загруженные плитки начинают показывать анимацию "сглаживания";
           // все новые плитки не запускают 3D анимацию.
    // false - Все плитки начинают показывать анимацию "подъема".
  bool mode2DEnabled = false;
  //Включает планы помещений на карте.
  bool indoorEnabled = false;
  //Включает облегченный режим рендеринга.
  bool liteModeEnabled = false;
  //Прямоугольник на экране устройства.
  ScreenRect? focusRect;
  //Указывется тип карты по умолчанию
  MapType mapType = MapType.vector;
  //Ограничивает количество видимых POI базовой карты
  int? poiLimit;

  //Преобразования к карте в стиле JSON.
  // Установите пустую строку, чтобы очистить предыдущий стиль.
  // Возвращает true, если стиль был успешно проанализирован, и false в противном случае.
  // Если возвращаемое значение ложно, текущий стиль карты остается неизменным.
  // Подробную информацию о стилях см. на странице https://yandex.com/dev/maps/mapkit/doc/dg/concepts/style.html#style__format

  //Для смены стиля карты использую переменную style по умолчанию
  // ей из метода setStyleMap присваивается значение многострочной переменной styleLandscape
  String style = "";

  static const String styleLandscape = '''
    [
      {
        "tags": {
          "all": ["landscape"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  static const String styleWater = '''
    [
      {
        "tags": {
          "all": ["water"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  static const String styleRoad = '''
    [
      {
        "tags": {
          "all": ["road"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //Points of interest (POI).
  // park: National parks, gardens, parks.
  static const String stylePoi = '''
    [
      {
        "tags": {
          "all": ["poi"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //Labels and borders of regions, polygons of localities.
  static const String styleAdmin = '''
    [
      {
        "tags": {
          "all": ["admin"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //All the map objects related to (связанные с) public transit.
  static const String styleTransit = '''
    [
      {
        "tags": {
          "all": ["transit"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //Structures.
  // building: Buildings.
  // entrance: Building entrances.
  // fence: Fences.
  static const String styleStructure = '''
    [
      {
        "tags": {
          "all": ["structure"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //A section of road or track passing through a tunnel.
  //Участок дороги или пути, проходящий через туннель.
  static const String styleIsTunnel = '''
    [
      {
        "tags": {
          "all": ["is_tunnel"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  //Метод возвращающий строку on или off
  String _enabledText(bool enabled) {
    return enabled ? 'on' : 'off';
  }

  // метод для смены режима карты
  // но сегодня работает только .map и .vector
  MapType _nextMapType(MapType oldMapType) {
    switch (oldMapType) {
      case MapType.map:
        return MapType.hybrid;
      case MapType.hybrid:
        return MapType.satellite;
      case MapType.satellite:
        return MapType.vector;
      case MapType.vector:
        return MapType.none;
      case MapType.none:
        return MapType.map;
      default:
        return MapType.map;
    }
  }

  // метод для смены стиля карты
  String setStyleMap(String style) {
    switch (style) {
      case styleLandscape:
        return styleWater;
      case styleWater:
        return styleRoad;
      case styleRoad:
        return stylePoi;
      case stylePoi:
        return styleAdmin;
      case styleAdmin:
        return styleTransit;
      case styleTransit:
        return styleStructure;
      case styleStructure:
        return styleIsTunnel;
      case styleIsTunnel:
        return styleLandscape;
      default:
        return styleLandscape;
    }
  }

  @override
  Widget build(BuildContext context) {
    var nameMapStyle;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: YandexMap(
                mapType: mapType,
                poiLimit: poiLimit, // достопримечательности
                tiltGesturesEnabled: tiltGesturesEnabled,
                zoomGesturesEnabled: zoomGesturesEnabled,
                rotateGesturesEnabled: rotateGesturesEnabled,
                scrollGesturesEnabled: scrollGesturesEnabled,
                modelsEnabled: modelsEnabled,
                nightModeEnabled: nightModeEnabled,
                fastTapEnabled: fastTapEnabled,
                mode2DEnabled: mode2DEnabled,
                indoorEnabled: indoorEnabled,
                //Включает облегченный режим рендеринга.
                liteModeEnabled: liteModeEnabled,
                //Установить выравнивание логотипа на карте
                logoAlignment: MapAlignment(horizontal: HorizontalAlignment.left, vertical: VerticalAlignment.bottom),
                // Позволяет установить фокус карты на определенный прямоугольник, а не на всю карту
                  // Для получения дополнительной информации см. https://yandex.com/dev/maps/mapkit/doc/ios-ref/full/Classes/YMKMapWindow.html#focusRect
                focusRect: focusRect,
                // Объекты карты для отображения на карте
                mapObjects: mapObjects,

                //Метод обратного вызова, когда карта готова к использованию.
                  //Передаем в [YandexMap.onMapCreated], чтобы получить [YandexMapController] при создании карты.
                onMapCreated: (YandexMapController yandexMapController) async {
                  controller = yandexMapController;

                  // Returns current camera position
                  final cameraPosition = await controller.getCameraPosition();
                  // Returns min available zoom for visible map region
                  final minZoom = await controller.getMinZoom();
                  // Returns max available zoom for visible map region
                  final maxZoom = await controller.getMaxZoom();

                  print('Camera position: $cameraPosition');
                  print('Min zoom: $minZoom, Max zoom: $maxZoom');
                },
                // Called every time a [YandexMap] is tapped.
                onMapTap: (Point point) async {
                  print('Tapped map at $point');

                  // Resets the currently selected geo object.
                  await controller.deselectGeoObject();
                },
                // Called every time a [YandexMap] is long tapped.
                onMapLongTap: (Point point) => print('Long tapped map at $point'),
                // Called every time when the camera position on [YandexMap] is changed.
                // reasons - gestures (жесты) или application (приложение, например нажатие на кнопку
                  // с сохраненными координатами)
                onCameraPositionChanged: (CameraPosition cameraPosition, CameraUpdateReason reason, bool finished) {
                  print('Camera position: $cameraPosition, Reason: $reason');

                  if (finished) {
                    print('Camera position movement has been finished');
                  }
                },
                // Called every time a [YandexMap] geo object is tapped.
                /// GeoObject (Геообъект)
                /// Может отображаться как метка, полилиния, многоугольник и т. д. в зависимости от типа геометрии.
                /// работает только когда тип карты - vector!
                onObjectTap: (GeoObject geoObject) async {
                  //Возвращает имя объекта если оно есть в карте
                  print('Tapped object: ${geoObject.name}');
                  //Если дополнительные данные по объектам есть
                  if (geoObject.selectionMetadata != null) {
                    await controller.selectGeoObject(geoObject.selectionMetadata!.id, geoObject.selectionMetadata!.layerId);
                  }
                },
              )
          ),
          SizedBox(height: 20),
          Expanded(
            // Создает поле, в котором можно прокручивать один виджет.
            child: SingleChildScrollView(
              //Вложенный виджет Creates a table.
              child: Table(
                //Создает строку
                children: <TableRow>[
                  TableRow(children: <Widget>[
                    //Создает кнопку
                    ControlButton(
                        onPressed: () async {
                          //При нажатии Changes the map camera position.
                          await controller.moveCamera(
                            //Определяет движение камеры, поддерживая как абсолютные перемещения,
                              // так и перемещения относительно текущего положения.
                            //Перемещение происходит в точку с кооржинатами _point
                            //Объект CameraPosition по умолчанию увеличвает до 15
                            //Я переопределил на 17 и угол под 45°
                            CameraUpdate.newCameraPosition(CameraPosition(target: _point, zoom: 18 /*, tilt: 45*/)),
                            animation: animation
                          );
                        },
                        //Имя на кнопке
                        title: 'Specific position'
                    ),
                    ControlButton(
                        //Кнопка со специальным увеличением задаеется как CameraUpdate.zoomTo(18),
                        //Обращаемся к методу zoomTo объекта CameraUpdate и устанавливаем zoom 1
                        onPressed: () async {
                          await controller.moveCamera(CameraUpdate.zoomTo(1), animation: animation);
                        },
                        title: 'Specific zoom'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          //Поворот экрана согласно азимуту
                          //метод azimuthTo не создает изменений в координатах просто разово меняет азимут - 90°
                          await controller.moveCamera(CameraUpdate.azimuthTo(90), animation: animation);
                        },
                        title: 'Specific azimuth'
                    ),
                    ControlButton(
                        onPressed: () async {
                          //Устанавливает однократно угол наклона 30°
                          await controller.moveCamera(CameraUpdate.tiltTo(30), animation: animation);
                        },
                        title: 'Specific tilt'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          //Увеличивает на 1
                          await controller.moveCamera(CameraUpdate.zoomIn(), animation: animation);
                        },
                        title: 'Zoom in'
                    ),
                    ControlButton(
                        onPressed: () async {
                          //Уменьшает на 1
                          await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
                        },
                        title: 'Zoom out'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          //BoundingBox - создает прямоугольные границы видимой области карты.
                          final newBounds = BoundingBox(
                            //Координаты северо-восточного угла коробки.
                            //northEast: Point(latitude: 65.0, longitude: 40.0),
                            northEast: Point(latitude: 51.82246181477291, longitude: 107.64395208131788),
                            //southWest: Point(latitude: 60.0, longitude: 30.0),
                            //Координаты юго-западного угла коробки.
                            southWest: Point(latitude: 51.82204454842426, longitude: 107.64276821414587),
                          );
                          //Возвращает обновление камеры,
                            // которое перемещает цель камеры в указанное географическое положение
                            // в пользовательском прямоугольнике фокуса.
                          //Если [focusRect] имеет значение null, то используется текущий прямоугольник фокуса.
                          await controller.moveCamera(CameraUpdate.newBounds(newBounds), animation: animation);
                        },
                        title: 'New bounds' //Новые границы
                    ),
                    ControlButton(
                        onPressed: () async {
                          //Новые границы
                          final newBounds = BoundingBox(
                            northEast: Point(latitude: 51.823245940897095, longitude: 107.64541481472662),
                            southWest: Point(latitude: 51.821446787026574, longitude: 107.64165475092267),
                          );
                          await controller.moveCamera(
                              CameraUpdate.newTiltAzimuthBounds(newBounds, azimuth: 90, tilt: 45),
                              animation: animation
                          );
                        },
                        title: 'New bounds with tilt and azimuth'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          //Метка, которая будет отображаться на [ЯндексКарте] в определенной точке
                          final placemark = PlacemarkMapObject(
                              mapId: targetMapObjectId,
                              //Устанваливается точка текущего положения карты - по центру экрана
                              point: (await controller.getCameraPosition()).target,
                              //Множитель непрозрачности содержимого метки.
                                //Значения ниже 0 будут установлены на 0.
                              opacity: 5,
                              //Внешний вид [PlacemarkMapObject] на карте.
                              icon: PlacemarkIcon.single(
                                  PlacemarkIconStyle(
                                      image: BitmapDescriptor.fromAssetImage('lib/assets/place.png')
                                  )
                              )
                          );
                          //Изменение точки через функцию seState()
                          setState(() {
                            //Удаляет старую точку
                            mapObjects.removeWhere((el) => el.mapId == targetMapObjectId);
                            //Устанавливает точку
                            mapObjects.add(placemark);
                          });
                        },
                        title: 'Target point'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //для переключения режимов карты использкется метод _nextMapType
                              //в методу _nextMapType передается значени карты по умолчанию
                            mapType = _nextMapType(mapType);
                          });
                        },
                        title: 'Map type: ${mapType.name}'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() async {
                            style = setStyleMap(style);
                            //для переключения режимов карты использкется метод _nextMapType
                            //в методу _nextMapType передается значени карты по умолчанию
                            await controller.setMapStyle(style);
                          });
                          //Применяет к карте преобразования в стиле JSON.
                          //КАК реализовать перекключение стилей как вид карты!
                          //await controller.setMapStyle(style);
                        },
                        title: 'Set Style'
                    ),
                    //Кнопка удаления стилей для карты
                    ControlButton(
                        onPressed: () async {
                          //setMapStyle(''); устанавливает пустой стиль
                          await controller.setMapStyle('');
                        },
                        title: 'Remove style'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(
                    children: <Widget>[
                      ControlButton(
                          onPressed: () async {
                            //получаем текущую область камеры координаты, zomm, azimuth, tilt
                            final cameraPosition = await controller.getCameraPosition();
                            //getScreenPoint() - преобразует положение из координат карты в координаты экрана.
                              // [ScreenPoint] относится к левому верхнему углу карты.
                                // Возвращает ноль, если [Point] находится за камерой.
                            //cameraPosition.target точка с координатами, на которую смотрит камера.
                            final screenPoint = await controller.getScreenPoint(cameraPosition.target);

                            setState(() {
                              //получаем рамку
                              focusRect = ScreenRect(
                                  //Положение верхнего левого угла прямоугольника.
                                  topLeft: ScreenPoint(x: 0, y: 0),
                                  // bottomRight - Положение правого нижнего угла прямоугольника.
                                  // не нулевое значение screenPoint!
                                  bottomRight: screenPoint!
                              );
                            });
                          },
                          title: 'Focus rect'
                      ),
                      //Удаление области фокусировки
                      ControlButton(
                          onPressed: () async {
                            setState(() {
                              focusRect = null;
                            });
                          },
                          title: 'Clear focus rect'
                      )
                    ],
                  ),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(
                    children: <Widget>[
                      ControlButton(
                          onPressed: () async {
                            //getFocusRegion() получает область, соответствующую текущему focusRect
                            //или видимой области, если focusRect не был установлен.
                              //В отличие от [getVisibleRegion] здесь также учитывается focusRect.
                            final region = await controller.getFocusRegion();
                            //переменная region хранит координаты вершин видимой области карты
                            print(region);
                          },
                          title: 'Focus region'
                      ),
                      ControlButton(
                          onPressed: () async {
                            //getVisibleRegion() - получает границы видимой области карты без учета focusRect
                            final region = await controller.getVisibleRegion();
                            //переменная region хранит координаты вершин видимой области карты
                            print(region);
                          },
                          title: 'Visible region'
                      )
                    ],
                  ),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          //Получаем точку на которую смотрит камера
                          final screenPoint = await controller.getScreenPoint(
                              (await controller.getCameraPosition()).target
                          );
                          //Вывод координат точки
                          print(screenPoint);
                        },
                        title: 'Map point to screen'
                    ),
                    ControlButton(
                        onPressed: () async {
                          // MediaQuery - устанавливает поддерево, в котором медиа-запросы разрешаются для заданных данных.
                          // Например, чтобы узнать размер текущего носителя (например, окно
                          // содержащее ваше приложение), вы можете прочитать свойство [MediaQueryData.size] из
                          // [MediaQueryData], возвращаемый [MediaQuery.of]:
                          // `MediaQuery.of(context).size`.
                          // [MediaQueryData.size] содержит ширину и высоту текущего окна.
                          final mediaQuery = MediaQuery.of(context);
                          //получаем точку
                          final point = await controller.getPoint(
                              //ScreenPoint - точка на экране устройства
                                //mediaQuery - медиа-запрос для context'а
                                  //size - размер носителя в логических пикселях (например, размер экрана)
                                    //width - горизонтальная протяженность этого размера
                                    //height - Вертикальная протяженность этого размера.
                              ScreenPoint(x: mediaQuery.size.width, y: mediaQuery.size.height)
                          );
                          //выводим точку с координатами
                          print(point);
                        },
                        title: 'Screen point to map'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Вкл., откл. жесты наклона, параллельное парананомирование двумя пальцами
                            tiltGesturesEnabled = !tiltGesturesEnabled;
                          });
                        },
                        // Метод _enabledText в засисимоти от значения логической переменной tiltGesturesEnabled
                        // возвращает имя-состояние кнопки
                        title: 'Tilt gestures: ${_enabledText(tiltGesturesEnabled)}'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Вкл., откл. жесты вращения двумя пальцами
                            rotateGesturesEnabled = !rotateGesturesEnabled;
                          });
                        },
                        title: 'Rotate gestures: ${_enabledText(rotateGesturesEnabled)}'
                    ),
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //отключение жесты вращения, например приближение двумя пальцами.
                            zoomGesturesEnabled = !zoomGesturesEnabled;
                          });
                        },
                        title: 'Zoom gestures: ${_enabledText(zoomGesturesEnabled)}'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Вкл., откл. жестов прокрутки
                            scrollGesturesEnabled = !scrollGesturesEnabled;
                          });
                        },
                        title: 'Scroll gestures: ${_enabledText(scrollGesturesEnabled)}'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //Вкл. / откл. 3D моделей на карте
                            modelsEnabled = !modelsEnabled;
                          });
                        },
                        title: 'Models: ${_enabledText(modelsEnabled)}'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Включить/отключить ночной режим
                            nightModeEnabled = !nightModeEnabled;
                          });
                        },
                        title: 'Night mode: ${_enabledText(nightModeEnabled)}'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //Включает/убирает задержку в 300 мс при выполнении жеста касания.
                            //Однако двойное касание будет сопровождаться жестом касания вместе с двойным касанием.
                            fastTapEnabled = !fastTapEnabled;
                          });
                        },
                        title: 'Fast tap: ${_enabledText(fastTapEnabled)}'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //делает карту 2D
                            mode2DEnabled = !mode2DEnabled;
                          });
                        },
                        title: '2D mode: ${_enabledText(mode2DEnabled)}'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //Вкл., откл. планов помещений на карте
                            indoorEnabled = !indoorEnabled;
                          });
                        },
                        title: 'Indoor mode: ${_enabledText(indoorEnabled)}'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            //Вкл. откл. облегченный режим рендеринга
                            liteModeEnabled = !liteModeEnabled;
                          });
                        },
                        title: 'Lite mode: ${_enabledText(liteModeEnabled)}'
                    )
                  ]),
                  //Следующая строка кнопок в виджете TableRow в общем виджете Table
                  TableRow(children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Устанавливает количество видимых достопримечательностей базовой карты
                            poiLimit = 10;
                          });
                        },
                        title: 'Set poi limit'
                    ),
                    ControlButton(
                        onPressed: () async {
                          setState(() {
                            // Удаляет ограничение количества видимых достопримечательностей базовой карты
                            poiLimit = null;
                          });
                        },
                        title: 'Remove poi limit'
                    )
                  ]),
                ],
              ),
            ),
          )
        ]
    );
  }
}
