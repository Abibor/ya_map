import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:ya_map/examples/widgets/control_button.dart';
import 'package:ya_map/examples/widgets/map_page.dart';

class ClusterizedPlacemarkCollectionPage extends MapPage {
  const ClusterizedPlacemarkCollectionPage() : super('ClusterizedPlacemarkCollection example');

  @override
  Widget build(BuildContext context) {
    return _ClusterizedPlacemarkCollectionExample();
  }
}

class _ClusterizedPlacemarkCollectionExample extends StatefulWidget {
  @override
  _ClusterizedPlacemarkCollectionExampleState createState() => _ClusterizedPlacemarkCollectionExampleState();
}

class _ClusterizedPlacemarkCollectionExampleState extends State<_ClusterizedPlacemarkCollectionExample> {
  // Список объектов MapObject, пустой
  final List<MapObject> mapObjects = [];
  // Целочисленная переменная
  final int kPlacemarkCount = 500;
  // Генератор случайных значений bool, int или double.
  final Random seed = Random();
  // MapObjectId уникально идентифицирует объект среди всех [MapObjectCollection.mapObjects] определенного типа.
  final MapObjectId mapObjectId = MapObjectId('clusterized_placemark_collection');
  // MapObjectId уникально идентифицирует объект среди всех [MapObjectCollection.mapObjects] определенного типа.
  final MapObjectId largeMapObjectId = MapObjectId('large_clusterized_placemark_collection');
  // Список фиксированной длины 8-битных целых чисел без знака.
  // Для длинных списков эта реализация может быть значительно более эффективной
  // с точки зрения пространства и времени, чем реализация [List] по умолчанию.
  // Целые числа, хранящиеся в списке, усекаются до младших восьми бит,
  // интерпретируемых как 8-битное целое без знака со значениями в диапазоне от 0 до 255.
  // Cluster cluster - Количество меток, сгруппированных в одну метку, созданную для [ClusterizedPlacemarkCollection]
  // Метот который строит форму cluster, используется для 500 меток
  Future<Uint8List> _buildClusterAppearance(Cluster cluster) async {
    print("!!CLUSTER CLUSTER!!");
    // PictureRecorder - записывает [Изображение], содержащее последовательность графических операций.
    final recorder = PictureRecorder();
    // Интерфейс для записи графических операций.
    // Объекты [Canvas] используются для создания объектов [Picture],
    // которые сами по себе могут использоваться с [SceneBuilder] для построения [Scene].
    // Однако при обычном использовании все это обрабатывается фреймворком.
    final canvas = Canvas(recorder);
    // Создает [Размер] с заданными [шириной] и [высотой].
    final size = Size(200, 200);
    // Создает пустой объект [Paint] со всеми полями, инициализированными значениями по умолчанию.
    final fillPaint = Paint()
      ..color = Colors.white
    // PaintingStyle - Стратегии рисования фигур и путей на холсте.
    /// Применяем [Paint] к внутренней части фигуры.
    /// Например, при применении к вызову [Canvas.drawCircle] это приводит к рисованию диска заданного размера.
      ..style = PaintingStyle.fill;
    /// Создает пустой объект [Paint] со всеми полями, инициализированными значениями по умолчанию.
    final strokePaint = Paint()
      ..color = Colors.black
      // Применяем [Paint] к краю фигуры. Например, при применении к вызову [Canvas.drawCircle]
      // это приводит к рисованию кольца заданного размера.
      // Линия, нарисованная на краю, будет иметь ширину, заданную свойством [Paint.strokeWidth].
      ..style = PaintingStyle.stroke
      // strokeWidth - Насколько широкими должны быть нарисованные края,
      // когда для [стиля] установлено значение [PaintingStyle.stroke].
      // Ширина указывается в логических пикселях, измеренных в направлении, ортогональном направлению пути.
        // По умолчанию 0.0, что соответствует ширине волосяной линии.
      ..strokeWidth = 10;
    // Просто переменная = 60
    final radius = 60.0;

    // TextPainter - Создает текстовый рисовальщик, который рисует заданный текст.
    final textPainter = TextPainter(
        // TextSpan - Создает [TextSpan] с заданными значениями.
        text: TextSpan(
            //преобразование размера списка cluster в строку
            // вывод количества точек внутри кластера
            text: cluster.size.toString(),
            // цвет и размер текста
            style: TextStyle(color: Colors.black, fontSize: 50)
        ),
        // TextDirection - направление текста
        textDirection: TextDirection.ltr
    );

    // Вычисляет визуальное положение глифов для рисования текста.
    // Ширина текста будет максимально приближена к его максимальной внутренней ширине,
    // но при этом будет больше или равна `minWidth` и меньше или равна `maxWidth`.
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Offset - создает смещение. Первый аргумент устанавливает [dx] горизонтальную составляющую,
    // а второй устанавливает [dy] вертикальную составляющую.
    // Вычисление положения картинки кластера на карте
    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);
    final circleOffset = Offset(size.height / 2, size.width / 2);

    // drawCircle - Рисует круг с центром в точке, заданной первым аргументом, и имеет радиус,
    // заданный вторым аргументом, с [Paint], заданным третьим аргументом.
    // Заполнение круга или обводка (или и то, и другое) контролируется [Paint.style].
    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);
    // paint - Рисует текст на заданном холсте с заданным смещением
    textPainter.paint(canvas, textOffset);

    // endRecording() - Завершает запись графических операций.
    // Возвращает изображение, содержащее графические операции, которые были записаны до сих пор.
    // После вызова этой функции и записывающее устройство
    // и объекты холста становятся недействительными и не могут использоваться дальше.
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    //toByteData Преобразует объект [Image] в массив байтов.
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  //Метод генератор случайных чисел
  double _randomDouble() {
    //nextInt - Генерирует неотрицательное случайное целое число,
    // равномерно распределенное в диапазоне от 0 включительно до [max] исключая.
    // Реализация по умолчанию поддерживает значения [max] от 1 до (1<<32) включительно.
    return (500 - seed.nextInt(1000))/1000;
  }

  @override
  Widget build(BuildContext context) {
    //Column - Создает вертикальный массив дочерних элементов.
    return Column(
        // spaceEvenly - Равномерно распределите свободное пространство между дочерними элементами,
        // а также до и после первого и последнего дочерних элементов.
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // stretch - Попросите children заполнить поперечную ось.
        // Это приводит к тому, что ограничения, передаваемые дочерним элементам,
        // становятся жесткими по поперечной оси.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Expanded - Создает виджет, который расширяет дочерний элемент [Row], [Column] или [Flex],
          // чтобы дочерний элемент заполнил доступное пространство вдоль главной оси гибкого виджета.
          Expanded(
              child: YandexMap(
                  // mapObjects - Объекты карты для отображения на карте
                  // пустой  изначально
                  mapObjects: mapObjects
              )
          ),
          SizedBox(height: 20),
          Expanded(
              // SingleChildScrollView - Создает поле, в котором можно прокручивать один виджет.
              child: SingleChildScrollView(
                  // Создает вертикальный массив дочерних элементов.
                  child: Column(
                      children: <Widget>[
                        //Row Создает горизонтальный массив дочерних элементов.
                        Row(
                          // spaceAround - Равномерно распределите свободное пространство между дочерними элементами,
                          // а также половину этого пространства до и после первого и последнего дочерних элементов.
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // Кнопка добавляет ClusterizedPlacemarkCollection - список
                            // из трех заданных PlacemarkMapObject - точек на карту
                            ControlButton(
                                onPressed: () async {
                                  // any - Проверяет, удовлетворяет ли какой-либо элемент этой итерации [test].
                                  // Проверяет каждый элемент в порядке итерации и возвращает `true`,
                                  // если какой-либо из них заставляет [test] вернуть `true`, иначе возвращает false.
                                  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
                                  /// var result = number.any((element) => element >= 5); // true;
                                  /// результат = number.any((element) => element >= 10); // false;
                                  /// mapId - Уникальный идентификатор этого объекта в рамках единого [ЯндексКарта].
                                  /// Условие которое проверяет список mapObjects на пустоту и если в нем есть элементы
                                  /// то програма дальше не работает не добавляет опять элементы в список
                                  if (mapObjects.any((el) => el.mapId == mapObjectId)) {
                                    print("has elelments");
                                    return;
                                  }
                                  // ClusterizedPlacemarkCollection - коллекция [PlacemarkMapObject] для отображения на [ЯндексКарте]
                                  /// В зависимости от удаленности друг от друга и текущего уровня масштабирования
                                  /// могут быть сгруппированы в один или несколько [Кластер]
                                  final mapObject = ClusterizedPlacemarkCollection(
                                    mapId: mapObjectId,
                                    // если метки будут расположены в пределах этого радиуса
                                    // они будут объеденины в кластер - в круг
                                    radius: 30,
                                    minZoom: 15,
                                    // Обратный вызов при добавлении кластера на [ЯндексКарту].
                                    /// Вы можете вернуть [Cluster] с измененным [Cluster.appearance],
                                    /// чтобы изменить способ его отображения на карте.
                                    onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) async {
                                      // copyWith - Возвращает копию [Cluster] с новым внешним видом.
                                      return cluster.copyWith(
                                          // PlacemarkMapObject? appearance - Метка, которая будет отображаться
                                          // на [ЯндексКарте] в определенной точке
                                          appearance: cluster.appearance.copyWith(
                                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                                  image: BitmapDescriptor.fromAssetImage('lib/assets/cluster.png'),
                                                  scale: 1
                                              ))
                                          )
                                      );
                                    },
                                    // Обратный вызов, который будет вызван при касании ранее созданного [кластера].
                                    onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                                      print('Tapped cluster');
                                    },
                                    // метки
                                    placemarks: [
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_1'),
                                          point: Point(latitude: 55.756, longitude: 37.618),
                                          // consumeTapEvents - Значение true, если метка использует события касания.
                                          // В противном случае карта будет распространять события касания
                                          // на другие объекты карты в точке касания.
                                          consumeTapEvents: true,
                                          onTap: (PlacemarkMapObject self, Point point) => print('Tapped placemark 1 at $point'),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_2'),
                                          point: Point(latitude: 59.956, longitude: 30.313),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_3'),
                                          point: Point(latitude: 39.956, longitude: 30.313),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                    ],
                                    onTap: (ClusterizedPlacemarkCollection self, Point point) => print('Tapped me at $point'),
                                  );

                                  setState(() {
                                    // добавляем в список объекты mapObject содержащие картинку и метку
                                    mapObjects.add(mapObject);
                                    printWrapped("add1 +$mapObjects");
                                  });
                                },
                                title: 'Add'
                            ),
                            // Кнопка
                            ControlButton(
                                onPressed: () async {
                                  // Условие которое проверяет есть ли элементы в mapObjects и не дает программе идти дальше
                                  // если список не пустой!
                                  if (!mapObjects.any((el) => el.mapId == mapObjectId)) {
                                    print("null elements");
                                    return;
                                  }

                                  final mapObject = mapObjects
                                      .firstWhere((el) => el.mapId == mapObjectId) as ClusterizedPlacemarkCollection;

                                  setState(() {
                                    // В массиве mapObjects происходит замена placemarks (меток) путем создания измененной копии copyWith
                                    // Указанные поля - placemarks, получат указанное значение,
                                    // все остальные поля получат такое же значение из текущего объекта.
                                    mapObjects[mapObjects.indexOf(mapObject)] = mapObject.copyWith(placemarks: [
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_2'),
                                          point: Point(latitude: 59.956, longitude: 30.313),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_3'),
                                          point: Point(latitude: 39.956, longitude: 31.313),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                      PlacemarkMapObject(
                                          mapId: MapObjectId('placemark_4'),
                                          point: Point(latitude: 59.945933, longitude: 30.320045),
                                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                              image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                              scale: 1
                                          ))
                                      ),
                                    ]);
                                  });
                                  printWrapped("update + $mapObjects");
                                },
                                title: 'Update'
                            ),
                            ControlButton(
                                onPressed: () async {
                                  setState(() {
                                    //Удаляет из mapObjects списка все объекты.
                                    mapObjects.removeWhere((el) => el.mapId == mapObjectId);
                                    printWrapped("removed + $mapObjects");
                                  });
                                },
                                title: 'Remove'
                            )
                          ],
                        ),
                        // Text создает строку из kPlacemarkCount - 500 случайных элементов
                        Text('Set of $kPlacemarkCount placemarks'),
                        // Создает горизонтальный массив дочерних элементов Add и Remove
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              // При нажатии на кнопку создается область - кластер состоящая из
                              // kPlacemarkCount - 500 меток, координаты которых определяются рандомно
                              ControlButton(
                                  onPressed: () async {
                                    printWrapped("mapObjects before add2: $mapObjects");
                                    // Проверка если какой-либо из el массива mapObjects
                                    if (mapObjects.any((el) => el.mapId == largeMapObjectId)) {
                                      print("tyt");
                                      return;
                                    }
                                    print("tyt1");
                                    // Создаем массив с ID = largeMapObjectId
                                    final largeMapObject = ClusterizedPlacemarkCollection(
                                      mapId: largeMapObjectId,
                                      radius: 30,
                                      minZoom: 15,
                                      onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) async {
                                        return cluster.copyWith(
                                            // cluster.appearance - appearance это метка, указывающая, как визуально отображать кластер на [ЯндексКарте]
                                            /// берется метка из картинок
                                            appearance: cluster.appearance.copyWith(
                                                // opacity затемнение картинки(метки)
                                                opacity: 0.75,
                                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                                    image: BitmapDescriptor.fromBytes(await _buildClusterAppearance(cluster)),
                                                    scale: 1
                                                ))
                                            )
                                        );
                                      },
                                      // При нажатии на зону cluster выходит сообщение
                                      onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                                        print('Tapped cluster');
                                      },
                                      // Создается массив меток длиной = kPlacemarkCount
                                      placemarks: List<PlacemarkMapObject>.generate(kPlacemarkCount, (i) {
                                        return PlacemarkMapObject(
                                            mapId: MapObjectId('placemark_$i'),
                                            point: Point(latitude: 55.756 + _randomDouble(), longitude: 37.618 + _randomDouble()),
                                            icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                                image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                                scale: 1
                                            ))
                                        );
                                      }),
                                      //при нажатии на метку выводится сообщние с координатами
                                      onTap: (ClusterizedPlacemarkCollection self, Point point) => print('Tapped me at $point'),
                                    );

                                    setState(() {
                                      // В массив объектов - mapObjects, добавляем массив объектов largeMapObject,
                                      // а это ClusterizedPlacemarkCollection - коллекция [PlacemarkMapObject] для отображения на [ЯндексКарте] с 500 метками
                                      mapObjects.add(largeMapObject);
                                      printWrapped("add2 + $mapObjects");
                                      Future.delayed(Duration(milliseconds: 1000), () {
                                        // Do something
                                      });
                                    });
                                  },
                                  title: 'Add'
                              ),
                              ControlButton(
                                  onPressed: () async {
                                    setState(() {
                                      //Удаляет из этого списка объекты cодержащие Id массива largeMapObjectId
                                      mapObjects.removeWhere((el) => el.mapId == largeMapObjectId);
                                      printWrapped("Removed mapObjects: + $mapObjects");
                                    });
                                  },
                                  title: 'Remove'
                              )
                            ]
                        )
                      ]
                  )
              )
          )
        ]
    );
  }

  // Метод который выводит все
  void printWrapped(String text) {
    //final pattern = RegExp('.{1,100000}'); // 800 is the size of each chunk
    final pattern = RegExp('.{1,1000}'); // 800 is the size of each chunk 1000 символов это максимум

    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}