import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:geographic_information_system/components/custom_button.dart';
import 'package:geographic_information_system/components/custom_form_text.dart';
import 'package:geographic_information_system/components/base_wrapper.dart';
import 'package:geographic_information_system/controllers/auth.dart';
import 'package:geographic_information_system/controllers/road.dart';
import 'package:geographic_information_system/models/composition.dart';
import 'package:geographic_information_system/models/condition.dart';
import 'package:geographic_information_system/models/district.dart';
import 'package:geographic_information_system/models/province.dart';
import 'package:geographic_information_system/models/road_type.dart';
import 'package:geographic_information_system/models/road_unit.dart';
import 'package:geographic_information_system/models/subdistrict.dart';
import 'package:geographic_information_system/models/village.dart';
import 'package:geographic_information_system/providers/composition_provider.dart';
import 'package:geographic_information_system/providers/condition_provider.dart';
import 'package:geographic_information_system/providers/information_location_provider.dart';
import 'package:geographic_information_system/providers/road_provider.dart';
import 'package:geographic_information_system/providers/type_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

const input_state = ["location", "detail", "submission"];

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final _formKey_location = GlobalKey<FormState>();
  final _formKey_information = GlobalKey<FormState>();
  final province_controller = TextEditingController(text: "Pick The Province");
  final distric_controller = TextEditingController();
  final subdistric_controller = TextEditingController();
  final village_controller = TextEditingController();
  final code_controller = TextEditingController();
  final name_controller = TextEditingController();
  final length_controller = TextEditingController();
  final width_controller = TextEditingController();
  final composition_controller = TextEditingController();
  final condition_controller = TextEditingController();
  final type_controller = TextEditingController();
  final description_controller = TextEditingController();
  final polyline_controller = TextEditingController();

  late MapController map_controller;

  var current_state = input_state[0];
  var disable_input = true;
  var show_tabular = false;

  double _x = 0;
  double _y = 0;
  double _x1 = 0;
  double _y1 = 0;
  double _x2 = 0;
  double _y2 = 0;

  late double panel_width;
  late double panel_height;

  var pick_points = <LatLng>[];
  var provinces = <Province>[];
  var districts = <District>[];
  var subdistricts = <SubDistrict>[];
  var villages = <Village>[];
  var compositions = <Composition>[];
  var conditions = <Condition>[];
  var types = <RoadType>[];
  var roads = <RoadUnit>[];

  var selected_road = null;
  var selected_province;
  var selected_district;
  var selected_subdistrict;
  var selected_village;
  var selected_composition;
  var selected_condition;
  var selected_type;
  var selected_road_index = null;

  Future fetch_data() async {
    return await Future.wait([
      InformationLocationProvider().fetch(),
      CompositionProvider().fetch(),
      ConditionProvider().fetch(),
      TypeProvider().fetch(),
      RoadProvider().fetch()
    ]);
  }

  void enable_road_points_panel_position() {
    current_state = input_state[1];
    disable_input = false;
  }

  void disable_road_points_panel_position() {
    current_state = input_state[0];
    disable_input = true;
  }

  void set_road_points_panel_position() {
    this._x1 = MediaQuery.of(context).size.width -
        MediaQuery.of(context).size.width * 0.25;
    this._y1 = 0;
  }

  void set_edit_road_panel(RoadUnit road) {
    name_controller.text = road.name;
    code_controller.text = road.code;
    length_controller.text = road.length.toString();
    width_controller.text = road.width.toString();
    description_controller.text = road.description;
    polyline_controller.text = road.paths;

    selected_road = road.id;
    selected_village = road.id_village;
    selected_composition = road.composition;
    selected_condition = road.condition;
    selected_type = road.type;

    pick_points = decodePolyline(road.paths).map((point) {
      return LatLng(point[0].toDouble(), point[1].toDouble());
    }).toList();

    if (this.compositions.isNotEmpty) {
      for (var composition in compositions) {
        if (composition.id == selected_composition) {
          composition_controller.text = composition.name;
        }
      }
    }

    if (this.conditions.isNotEmpty) {
      for (var condition in conditions) {
        if (condition.id == selected_condition) {
          condition_controller.text = condition.name;
        }
      }
    }

    if (this.types.isNotEmpty) {
      for (var type in types) {
        if (type.id == selected_type) {
          type_controller.text = type.name;
        }
      }
    }
  }

  void reset_road_panel() {
    // remove selected value
    selected_road = null;
    selected_province = null;
    selected_district = null;
    selected_subdistrict = null;
    selected_village = null;
    selected_composition = null;
    selected_condition = null;
    selected_type = null;
    pick_points = [];

    // reset form value
    village_controller.text = "";
    name_controller.text = "";
    code_controller.text = "";
    length_controller.text = "";
    width_controller.text = "";
    description_controller.text = "";
    polyline_controller.text = "";
    composition_controller.text = "";
    condition_controller.text = "";
    type_controller.text = "";
    province_controller.text = "";
    distric_controller.text = "";
    subdistric_controller.text = "";
  }

  double calculateDistane(List<LatLng> polyline) {
    double totalDistance = 0;
    for (int i = 0; i < polyline.length; i++) {
      if (i < polyline.length - 1) {
        // skip the last index
        totalDistance += getStraightLineDistance(
            polyline[i + 1].latitude,
            polyline[i + 1].longitude,
            polyline[i].latitude,
            polyline[i].longitude);
      }
    }
    return totalDistance;
  }

  double getStraightLineDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);
    var dLon = deg2rad(lon2 - lon1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d * 1000; //in m
  }

  dynamic deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  @override
  void initState() {
    map_controller = MapController();
  }

  @override
  Widget build(BuildContext context) {
    panel_width = MediaQuery.of(context).size.width * 0.25;
    panel_height = MediaQuery.of(context).size.height * 0.25;
    this._x2 = MediaQuery.of(context).size.width * 0.45;
    this._y2 = 10;

    return FutureBuilder(
        future: fetch_data(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (provinces.isEmpty) {
              for (var province in snapshot.data?[0]["provinsi"]) {
                provinces.add(Province(province["id"], province["provinsi"]));
              }
            }

            if (districts.isEmpty) {
              for (var district in snapshot.data?[0]["kabupaten"]) {
                districts.add(District(district["id"], district["prov_id"],
                    district["kabupaten"]));
              }
            }

            if (subdistricts.isEmpty) {
              for (var subdistrict in snapshot.data?[0]["kecamatan"]) {
                subdistricts.add(SubDistrict(subdistrict["id"],
                    subdistrict["kab_id"], subdistrict["kecamatan"]));
              }
            }

            if (villages.isEmpty) {
              for (var village in snapshot.data?[0]["desa"]) {
                villages.add(
                    Village(village["id"], village["kec_id"], village["desa"]));
              }
            }

            if (compositions.isEmpty) {
              for (var composition in snapshot.data?[1]) {
                compositions.add(Composition(
                    composition["id"], composition["eksisting"].toString()));
              }
            }

            if (conditions.isEmpty) {
              for (var condition in snapshot.data?[2]) {
                conditions
                    .add(Condition(condition["id"], condition["kondisi"]));
              }
            }

            if (types.isEmpty) {
              for (var type in snapshot.data?[3]) {
                types.add(RoadType(type["id"], type["jenisjalan"]));
              }
            }

            if (roads.isEmpty) {
              for (var road in snapshot.data?[4]) {
                roads.add(RoadUnit(
                  road["id"],
                  road["paths"],
                  road["desa_id"],
                  road["kode_ruas"],
                  road["nama_ruas"],
                  road["panjang"],
                  road["lebar"],
                  road["eksisting_id"],
                  road["kondisi_id"],
                  road["jenisjalan_id"],
                  road["keterangan"],
                ));
              }
            }

            set_road_points_panel_position();

            return BaseWrapper(
                child: show_tabular
                    ? Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: ListView(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    show_tabular = false;
                                  });
                                }, icon: Icon(Icons.arrow_back)),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Jalan Provinsi"),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Jalan Kabupaten"),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Jalan Desa"),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            ),
                            Table(
                              border: TableBorder.all(),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: {...{
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Name"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Village"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Kecamatan"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Kabupaten"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Provinsi"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Tipe"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Komposisi"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Kondisi"),
                                        )),
                                    TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Aksi"),
                                        )),
                                  ]
                                )
                              }.toList(), ...roads.mapIndexed((index, road) {
                                var current_village;
                                var current_sub_district;
                                var current_district;
                                var current_province;
                                var current_type;
                                var current_condition;
                                var current_composition;

                                for (var type in types){
                                  if(type.id.toString() == road.type.toString()){
                                    current_type = type.name;
                                  }
                                }

                                for (var condition in conditions){
                                  if(condition.id.toString() == road.condition.toString()){
                                    current_condition = condition.name;
                                  }
                                }

                                for (var composition in compositions){
                                  if(composition.id.toString() == road.composition.toString()){
                                    current_composition = composition.name;
                                  }
                                }

                                for (var village in villages) {
                                  if (village.id.toString() ==
                                      road.id_village.toString()) {
                                    current_village = village.name;

                                    for (var sub_district in subdistricts) {
                                      if (sub_district.id.toString() ==
                                          village.subdistrict_id.toString()) {
                                        current_sub_district =
                                            sub_district.name;

                                        for (var district in districts) {
                                          if (district.id.toString() ==
                                              sub_district.district_id
                                                  .toString()) {
                                            current_district = district.name;

                                            for (var province in provinces) {
                                              if (province.id.toString() ==
                                                  district.province_id
                                                      .toString()) {
                                                current_province =
                                                    province.name;
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }

                                return TableRow(children: [
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${road.name}"),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_village}"),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_sub_district}"),
                                  )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_district}"),
                                  )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_province}"),
                                  )),
                                  TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("${current_type}"),
                                      )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_composition}"),
                                  )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${current_condition}"),
                                  )),
                                  TableCell(
                                      child: CustomButton(
                                          onPressed: () async {
                                            return showDialog<void>(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                          "Delete Road"),
                                                      content: const Text(
                                                          "Are you sure to delete this road ?"),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              return Navigator
                                                                  .pop(context,
                                                                      "Cancel");
                                                            },
                                                            child:
                                                                Text("Cancel")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Road()
                                                                  .deleteRoad(
                                                                      road.id)
                                                                  .then((val) {
                                                                Navigator.pop(
                                                                    context,
                                                                    "delete");
                                                                setState(() {
                                                                  roads.removeWhere(
                                                                      (item) {
                                                                    return item
                                                                            .id ==
                                                                        road.id;
                                                                  });
                                                                  disable_road_points_panel_position();
                                                                  reset_road_panel();
                                                                });
                                                              });
                                                            },
                                                            child: Text("Yes")),
                                                      ],
                                                    ));
                                          },
                                          child: Text("Delete")))
                                ]);
                              }).toList()}.toList(),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          FlutterMap(
                            mapController: map_controller,
                            options: MapOptions(
                              initialCenter: LatLng(-8.340, 115.091),
                              initialZoom: 10,
                              onTap: (TapPosition position, LatLng latlng) {
                                if (!disable_input) {
                                  setState(() {
                                    pick_points.add(latlng);
                                    polyline_controller.text = encodePolyline(
                                        pick_points
                                            .map((points) => [
                                                  points.latitude,
                                                  points.longitude
                                                ])
                                            .toList());
                                    length_controller.text =
                                        calculateDistane(pick_points)
                                            .toInt()
                                            .toString();
                                  });
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              PolylineLayer(
                                  polylines: roads.map((val) {
                                return Polyline(
                                    strokeWidth: 5,
                                    points:
                                        decodePolyline(val.paths).map((point) {
                                      return LatLng(point[0].toDouble(),
                                          point[1].toDouble());
                                    }).toList(),
                                    color: val.type.toString() == "1"
                                        ? Colors.green
                                        : val.type.toString() == "2"
                                            ? Colors.amber
                                            : Colors.red);
                              }).toList()),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    strokeWidth: 5,
                                    points: pick_points,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                              if (disable_input)
                                MarkerLayer(
                                    markers: roads.expandIndexed((index, val) {
                                  return decodePolyline(val.paths)
                                      .mapIndexed((pathIndex, point) {
                                    return Marker(
                                      point: LatLng(point[0].toDouble(),
                                          point[1].toDouble()),
                                      width: 25,
                                      height: 25,
                                      child: GestureDetector(
                                        child: Stack(children: [
                                          Image.asset(
                                            "assets/images/marker.png",
                                          ),
                                        ]),
                                        onTap: () {
                                          setState(() {
                                            enable_road_points_panel_position();
                                            set_road_points_panel_position();
                                            set_edit_road_panel(val);
                                            selected_road_index = index;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList();
                                }).toList()),
                              if (disable_input)
                                MarkerLayer(
                                    markers: roads.mapIndexed((index, val) {
                                  var polyline = decodePolyline(val.paths);
                                  var point = polyline[0];
                                  return Marker(
                                    point: LatLng(point[0].toDouble() + 0.01,
                                        point[1].toDouble() + 0.01),
                                    width: 100,
                                    height: 25,
                                    child: Card(
                                        child: Center(child: Text(val.name))),
                                  );
                                }).toList()),
                              DragMarkers(
                                  markers: pick_points.mapIndexed((index, val) {
                                return DragMarker(
                                    key: GlobalKey<DragMarkerWidgetState>(),
                                    point: val,
                                    builder: (_, __, ___) => GestureDetector(
                                          onTap: () {
                                            var current_lat =
                                                pick_points[index].latitude;
                                            var current_lon =
                                                pick_points[index].longitude;

                                            setState(() {
                                              if (index <
                                                  pick_points.length - 1) {
                                                var next_lat =
                                                    pick_points[index + 1]
                                                        .latitude;
                                                var next_lon =
                                                    pick_points[index + 1]
                                                        .longitude;
                                                var next_point_lat =
                                                    (current_lat + next_lat) /
                                                        2;
                                                var next_point_lon =
                                                    (current_lon + next_lon) /
                                                        2;
                                                pick_points.insert(
                                                    index + 1,
                                                    LatLng(next_point_lat,
                                                        next_point_lon));
                                              }

                                              if (index > 0) {
                                                var prev_lat =
                                                    pick_points[index - 1]
                                                        .latitude;
                                                var prev_lon =
                                                    pick_points[index - 1]
                                                        .longitude;
                                                var prev_point_lat =
                                                    (current_lat + prev_lat) /
                                                        2;
                                                var prev_point_lon =
                                                    (current_lon + prev_lon) /
                                                        2;
                                                pick_points.insert(
                                                    index,
                                                    LatLng(prev_point_lat,
                                                        prev_point_lon));
                                              }
                                            });
                                          },
                                          child: Stack(children: [
                                            Container(
                                              child: Center(
                                                child: Text("${index}"),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                color: Colors.white,
                                              ),
                                            )
                                          ]),
                                        ),
                                    onDragEnd: (details, latLng) {
                                      setState(() {
                                        pick_points[index] = latLng;

                                        polyline_controller.text =
                                            encodePolyline(pick_points
                                                .map((points) => [
                                                      points.latitude,
                                                      points.longitude
                                                    ])
                                                .toList());
                                      });

                                      roads[selected_road_index].paths =
                                          polyline_controller.text;
                                    },
                                    size: Size.square(50));
                              }).toList()),
                            ],
                          ),
                          Positioned(
                            left: this._x,
                            top: this._y,
                            width: panel_width,
                            height: (current_state == input_state[0])
                                ? null
                                : MediaQuery.of(context).size.height,
                            child: Draggable(
                              feedback: Card(
                                child: SizedBox(
                                  width: panel_width,
                                  height: panel_height,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                              child: Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: (current_state == input_state[0])
                                          ? Form(
                                              // Road Location Panel
                                              key: _formKey_location,
                                              child: Column(
                                                children: [
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon:
                                                              Icon(Icons.map),
                                                          hintText: "Bali",
                                                          labelText: "Province",
                                                          focusNode: focusNode,
                                                        );
                                                      },
                                                      controller:
                                                          province_controller,
                                                      itemBuilder: (contex,
                                                          Province province) {
                                                        return ListTile(
                                                          title: Text(province
                                                              .name
                                                              .toString()),
                                                        );
                                                      },
                                                      onSelected:
                                                          (Province province) {
                                                        setState(() {
                                                          this
                                                                  .province_controller
                                                                  .text =
                                                              province.name
                                                                  .toString();
                                                          this.selected_province =
                                                              province.id;

                                                          //Refresh
                                                          this
                                                              .distric_controller
                                                              .text = "";
                                                          this
                                                              .subdistric_controller
                                                              .text = "";
                                                          this
                                                              .village_controller
                                                              .text = "";
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        return this.provinces;
                                                      }),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon:
                                                              Icon(Icons.map),
                                                          hintText: "Denpasar",
                                                          labelText: "Distric",
                                                          focusNode: focusNode,
                                                          enabled:
                                                              (this.selected_province !=
                                                                      null)
                                                                  ? true
                                                                  : false,
                                                        );
                                                      },
                                                      controller:
                                                          distric_controller,
                                                      itemBuilder: (contex,
                                                          District district) {
                                                        return ListTile(
                                                          title: Text(district
                                                              .name
                                                              .toString()),
                                                        );
                                                      },
                                                      onSelected:
                                                          (District district) {
                                                        setState(() {
                                                          this
                                                                  .distric_controller
                                                                  .text =
                                                              district.name
                                                                  .toString();
                                                          this.selected_district =
                                                              district.id;

                                                          //Refresh
                                                          this
                                                              .subdistric_controller
                                                              .text = "";
                                                          this
                                                              .village_controller
                                                              .text = "";
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result = this
                                                            .districts
                                                            .where((district) =>
                                                                district
                                                                    .province_id ==
                                                                this.selected_province)
                                                            .toList();

                                                        return result;
                                                      }),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon:
                                                              Icon(Icons.map),
                                                          hintText:
                                                              "Denpasar Barat",
                                                          labelText:
                                                              "Sub Distric",
                                                          focusNode: focusNode,
                                                          enabled:
                                                              (this.selected_district !=
                                                                      null)
                                                                  ? true
                                                                  : false,
                                                        );
                                                      },
                                                      controller:
                                                          subdistric_controller,
                                                      itemBuilder: (contex,
                                                          SubDistrict
                                                              subdistrict) {
                                                        return ListTile(
                                                          title: Text(
                                                              subdistrict.name
                                                                  .toString()),
                                                        );
                                                      },
                                                      onSelected: (SubDistrict
                                                          subdistrict) {
                                                        setState(() {
                                                          this
                                                                  .subdistric_controller
                                                                  .text =
                                                              subdistrict.name
                                                                  .toString();
                                                          this.selected_subdistrict =
                                                              subdistrict.id;

                                                          //Refresh
                                                          this
                                                              .village_controller
                                                              .text = "";
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result = this
                                                            .subdistricts
                                                            .where((subdistrict) =>
                                                                subdistrict
                                                                    .district_id ==
                                                                this.selected_district)
                                                            .toList();

                                                        return result;
                                                      }),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              village_controller,
                                                          prefixIcon:
                                                              Icon(Icons.map),
                                                          hintText:
                                                              "Padangsambian Kelod",
                                                          labelText: "Village",
                                                          focusNode: focusNode,
                                                          enabled:
                                                              (this.selected_subdistrict !=
                                                                      null)
                                                                  ? true
                                                                  : false,
                                                        );
                                                      },
                                                      controller:
                                                          village_controller,
                                                      itemBuilder: (contex,
                                                          Village village) {
                                                        return ListTile(
                                                          title: Text(village
                                                              .name
                                                              .toString()),
                                                        );
                                                      },
                                                      onSelected:
                                                          (Village village) {
                                                        setState(() {
                                                          this
                                                                  .village_controller
                                                                  .text =
                                                              village.name
                                                                  .toString();
                                                          this.selected_village =
                                                              village.id;
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result = this
                                                            .villages
                                                            .where((village) =>
                                                                village
                                                                    .subdistrict_id ==
                                                                this.selected_subdistrict)
                                                            .toList();

                                                        return result;
                                                      }),
                                                  CustomButton(
                                                      onPressed: () {
                                                        if (_formKey_location
                                                            .currentState!
                                                            .validate()) {
                                                          setState(() {
                                                            enable_road_points_panel_position();
                                                            set_road_points_panel_position();
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        "Add Road",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ))
                                                ],
                                              ),
                                            )
                                          : Form(
                                              // Road Information form
                                              key: _formKey_information,
                                              child: ListView(
                                                children: [
                                                  CustomFormText(
                                                    controller: code_controller,
                                                    prefixIcon:
                                                        Icon(Icons.code),
                                                    hintText: "R1M",
                                                    labelText: "Road Code",
                                                  ),
                                                  CustomFormText(
                                                    controller: name_controller,
                                                    prefixIcon: Icon(Icons.map),
                                                    hintText: "10 - 12",
                                                    labelText: "Road Name",
                                                  ),
                                                  CustomFormText(
                                                    controller:
                                                        length_controller,
                                                    prefixIcon:
                                                        Icon(Icons.numbers),
                                                    hintText: "100",
                                                    labelText: "Road Length",
                                                  ),
                                                  CustomFormText(
                                                    controller:
                                                        width_controller,
                                                    prefixIcon:
                                                        Icon(Icons.numbers),
                                                    hintText: "3",
                                                    labelText: "Road Width",
                                                  ),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon: Icon(
                                                              Icons.category),
                                                          hintText: "Tanah",
                                                          labelText:
                                                              "Road Combination",
                                                          focusNode: focusNode,
                                                        );
                                                      },
                                                      controller:
                                                          composition_controller,
                                                      itemBuilder: (contex,
                                                          Composition
                                                              composition) {
                                                        return ListTile(
                                                          title: Text(
                                                              composition.name
                                                                  .toString()),
                                                        );
                                                      },
                                                      onSelected: (Composition
                                                          composition) {
                                                        setState(() {
                                                          this
                                                                  .composition_controller
                                                                  .text =
                                                              composition.name
                                                                  .toString();
                                                          this.selected_composition =
                                                              composition.id;
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result =
                                                            this.compositions;

                                                        return result;
                                                      }),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon: Icon(
                                                              Icons.category),
                                                          hintText: "Rusak",
                                                          labelText:
                                                              "Road Condition",
                                                          focusNode: focusNode,
                                                        );
                                                      },
                                                      controller:
                                                          condition_controller,
                                                      itemBuilder: (contex,
                                                          Condition condition) {
                                                        return ListTile(
                                                          title: Text(condition
                                                              .name
                                                              .toString()),
                                                        );
                                                      },
                                                      onSelected: (Condition
                                                          condition) {
                                                        setState(() {
                                                          this
                                                                  .condition_controller
                                                                  .text =
                                                              condition.name
                                                                  .toString();
                                                          this.selected_condition =
                                                              condition.id;
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result =
                                                            this.conditions;

                                                        return result;
                                                      }),
                                                  TypeAheadField(
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return CustomFormText(
                                                          controller:
                                                              controller,
                                                          prefixIcon: Icon(
                                                              Icons.category),
                                                          hintText: "Kabupaten",
                                                          labelText:
                                                              "Road Type",
                                                          focusNode: focusNode,
                                                        );
                                                      },
                                                      controller:
                                                          type_controller,
                                                      itemBuilder: (contex,
                                                          RoadType type) {
                                                        return ListTile(
                                                          title: Text(type.name
                                                              .toString()),
                                                        );
                                                      },
                                                      onSelected:
                                                          (RoadType type) {
                                                        setState(() {
                                                          this
                                                                  .type_controller
                                                                  .text =
                                                              type.name
                                                                  .toString();
                                                          this.selected_type =
                                                              type.id;
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (pattern) {
                                                        var result = this.types;

                                                        return result;
                                                      }),
                                                  CustomFormText(
                                                    controller:
                                                        description_controller,
                                                    prefixIcon:
                                                        Icon(Icons.description),
                                                    hintText:
                                                        "Jalan sangat mantap",
                                                    labelText:
                                                        "Road Description",
                                                  ),
                                                  CustomFormText(
                                                    controller:
                                                        polyline_controller,
                                                    prefixIcon:
                                                        Icon(Icons.code),
                                                    hintText:
                                                        "Jalan sangat mantap",
                                                    labelText:
                                                        "Road Description",
                                                    enabled: false,
                                                  ),
                                                  SizedBox(
                                                    height: 25,
                                                  ),
                                                  CustomButton(
                                                      onPressed: () {
                                                        if (_formKey_information
                                                            .currentState!
                                                            .validate()) {
                                                          if (selected_road !=
                                                              null) {
                                                            Road()
                                                                .updateRoad(
                                                                    selected_road,
                                                                    polyline_controller
                                                                        .text,
                                                                    selected_village,
                                                                    code_controller
                                                                        .text,
                                                                    name_controller
                                                                        .text,
                                                                    length_controller
                                                                        .text,
                                                                    width_controller
                                                                        .text,
                                                                    selected_composition,
                                                                    selected_condition,
                                                                    selected_type,
                                                                    description_controller
                                                                        .text)
                                                                .then(
                                                                    (value) async {
                                                              setState(() {
                                                                // update road offline mode
                                                                roads[selected_road_index]
                                                                        .paths =
                                                                    polyline_controller
                                                                        .text;
                                                                roads[selected_road_index]
                                                                        .id_village =
                                                                    selected_village;
                                                                roads[selected_road_index]
                                                                        .code =
                                                                    code_controller
                                                                        .text;
                                                                roads[selected_road_index]
                                                                        .name =
                                                                    name_controller
                                                                        .text;
                                                                roads[selected_road_index]
                                                                        .length =
                                                                    length_controller
                                                                        .text;
                                                                roads[selected_road_index]
                                                                        .width =
                                                                    width_controller
                                                                        .text;
                                                                roads[selected_road_index]
                                                                        .composition =
                                                                    selected_composition;
                                                                roads[selected_road_index]
                                                                        .condition =
                                                                    selected_condition;
                                                                roads[selected_road_index]
                                                                        .type =
                                                                    selected_type;
                                                                roads[selected_road_index]
                                                                        .description =
                                                                    description_controller
                                                                        .text;

                                                                disable_road_points_panel_position();
                                                                reset_road_panel();
                                                              });
                                                            });
                                                          } else {
                                                            Road()
                                                                .insertRoad(
                                                                    polyline_controller
                                                                        .text,
                                                                    selected_village,
                                                                    code_controller
                                                                        .text,
                                                                    name_controller
                                                                        .text,
                                                                    length_controller
                                                                        .text,
                                                                    width_controller
                                                                        .text,
                                                                    selected_composition,
                                                                    selected_condition,
                                                                    selected_type,
                                                                    description_controller
                                                                        .text)
                                                                .then((value) {
                                                              roads
                                                                  .add(RoadUnit(
                                                                value["id"],
                                                                value["paths"],
                                                                value[
                                                                    "desa_id"],
                                                                value[
                                                                    "kode_ruas"],
                                                                value[
                                                                    "nama_ruas"],
                                                                value[
                                                                    "panjang"],
                                                                value["lebar"],
                                                                value[
                                                                    "eksisting_id"],
                                                                value[
                                                                    "kondisi_id"],
                                                                value[
                                                                    "jenisjalan_id"],
                                                                value[
                                                                    "keterangan"],
                                                              ));
                                                              setState(() {
                                                                disable_road_points_panel_position();
                                                                reset_road_panel();
                                                              });
                                                            });
                                                          }
                                                        }
                                                      },
                                                      child: Text(
                                                        "Save Road",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              disable_road_points_panel_position();
                                                              reset_road_panel();
                                                            });
                                                          },
                                                          child: Text(
                                                            "Back",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CustomButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              pick_points =
                                                                  <LatLng>[];
                                                            });
                                                          },
                                                          child: Text(
                                                            "Reset Road",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ))),
                              onDragEnd: (dragDetails) {
                                setState(() {
                                  _x = dragDetails.offset.dx;
                                  _y = dragDetails.offset.dy;
                                });
                              },
                            ),
                          ),
                          if (disable_input && provinces != [])
                            Positioned(
                                left: this._x1,
                                top: this._y1,
                                width: panel_width,
                                child: Draggable(
                                  onDragEnd: (dragDetails) {
                                    setState(() {
                                      this._x1 = dragDetails.offset.dx;
                                      this._y1 = dragDetails.offset.dy;
                                    });
                                  },
                                  feedback: Card(
                                    child: SizedBox(
                                      width: panel_width,
                                      height: panel_height,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    child: Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text("Your Roads"),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "Jalan Provinsi"),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "Jalan Kabupaten"),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "Jalan Desa"),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Column(
                                                      children: roads
                                                          .mapIndexed(
                                                              (index, road) {
                                                        var current_village;
                                                        var current_sub_district;
                                                        var current_district;
                                                        var current_province;

                                                        for (var village
                                                            in villages) {
                                                          if (village.id
                                                                  .toString() ==
                                                              road.id_village
                                                                  .toString()) {
                                                            current_village =
                                                                village.name;

                                                            for (var sub_district
                                                                in subdistricts) {
                                                              if (sub_district
                                                                      .id
                                                                      .toString() ==
                                                                  village
                                                                      .subdistrict_id
                                                                      .toString()) {
                                                                current_sub_district =
                                                                    sub_district
                                                                        .name;

                                                                for (var district
                                                                    in districts) {
                                                                  if (district
                                                                          .id
                                                                          .toString() ==
                                                                      sub_district
                                                                          .district_id
                                                                          .toString()) {
                                                                    current_district =
                                                                        district
                                                                            .name;

                                                                    for (var province
                                                                        in provinces) {
                                                                      if (province
                                                                              .id
                                                                              .toString() ==
                                                                          district
                                                                              .province_id
                                                                              .toString()) {
                                                                        current_province =
                                                                            province.name;
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }

                                                        return GestureDetector(
                                                          onTap: () {
                                                            var current_points =
                                                                decodePolyline(road
                                                                        .paths)
                                                                    .map(
                                                                        (point) {
                                                              return LatLng(
                                                                  point[0]
                                                                      .toDouble(),
                                                                  point[1]
                                                                      .toDouble());
                                                            }).toList();

                                                            map_controller.move(
                                                                current_points[
                                                                    0],
                                                                13);
                                                          },
                                                          child: Card(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        RichText(
                                                                      text: TextSpan(
                                                                          text:
                                                                              "${road.name}, ${current_village}, ${current_sub_district}, ${current_district}, ${current_province}"),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  CustomButton(
                                                                      onPressed:
                                                                          () async {
                                                                        return showDialog<
                                                                                void>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                                  title: const Text("Delete Road"),
                                                                                  content: const Text("Are you sure to delete this road ?"),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          return Navigator.pop(context, "Cancel");
                                                                                        },
                                                                                        child: Text("Cancel")),
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          Road().deleteRoad(road.id).then((val) {
                                                                                            Navigator.pop(context, "delete");
                                                                                            setState(() {
                                                                                              roads.removeWhere((item) {
                                                                                                return item.id == road.id;
                                                                                              });
                                                                                              disable_road_points_panel_position();
                                                                                              reset_road_panel();
                                                                                            });
                                                                                          });
                                                                                        },
                                                                                        child: Text("Yes")),
                                                                                  ],
                                                                                ));
                                                                      },
                                                                      child: Text(
                                                                          "Delete"))
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ]),
                                            ))),
                                  ),
                                )),
                          if (!disable_input)
                            Positioned(
                                left: this._x1,
                                top: this._y1,
                                width: panel_width,
                                child: Draggable(
                                  onDragEnd: (dragDetails) {
                                    setState(() {
                                      this._x1 = dragDetails.offset.dx;
                                      this._y1 = dragDetails.offset.dy;
                                    });
                                  },
                                  feedback: Card(
                                    child: SizedBox(
                                      width: panel_width,
                                      height: panel_width,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    child: Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                          "Your Road Point"),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    if (selected_road != null)
                                                      CustomButton(
                                                          onPressed: () async {
                                                            return showDialog<
                                                                    void>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                      title: const Text(
                                                                          "Delete Road"),
                                                                      content:
                                                                          const Text(
                                                                              "Are you sure to delete this road ?"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              return Navigator.pop(context, "Cancel");
                                                                            },
                                                                            child:
                                                                                Text("Cancel")),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Road().deleteRoad(selected_road).then((val) {
                                                                                Navigator.pop(context, "insert");
                                                                                setState(() {
                                                                                  roads.removeWhere((item) {
                                                                                    return item.id.toString() == selected_road.toString();
                                                                                  });
                                                                                  disable_road_points_panel_position();
                                                                                  reset_road_panel();
                                                                                });
                                                                              });
                                                                            },
                                                                            child:
                                                                                Text("Yes")),
                                                                      ],
                                                                    ));
                                                          },
                                                          child: Text(
                                                              "Delete The Road")),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Column(
                                                      children: pick_points
                                                          .mapIndexed((index,
                                                              pick_point) {
                                                        return Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "index : ${index} coor : (${pick_point.latitude.toStringAsFixed(4)}, ${pick_point.longitude.toStringAsFixed(4)})"),
                                                                CustomButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        pick_points
                                                                            .removeAt(index);
                                                                        polyline_controller.text = encodePolyline(pick_points
                                                                            .map((points) =>
                                                                                [
                                                                                  points.latitude,
                                                                                  points.longitude
                                                                                ])
                                                                            .toList());
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        "Delete"))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ]),
                                            ))),
                                  ),
                                )),
                          Positioned(
                              left: this._x1,
                              top: this._y1,
                              child: IconButton(
                                color: Colors.redAccent,
                                icon: Icon(Icons.logout),
                                onPressed: () {
                                  Auth().logout().then((val) {
                                    context.goNamed("login");
                                  });
                                },
                              )),
                          Positioned(
                              left: this._x2,
                              top: this._y2,
                              child: CustomButton(
                                child: Text(
                                  "Show Tabular Data",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    show_tabular = true;
                                  });
                                },
                              )),
                        ],
                      ));
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Text Error"),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
