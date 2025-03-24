import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeattendance/api.dart';
import 'package:timeattendance/provider.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  late Position userLocation;
  late GoogleMapController mapController;
  final String date = DateFormat('d MMMM y', 'th').format(DateTime.now());
  final String datetime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  final ValueNotifier<bool> _isButtonDisabled = ValueNotifier(false);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Position?> getLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // แจ้งเตือนให้เปิด GPS
      if (context.mounted) {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "กรุณาเปิด GPS",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "เพื่อแสดงตำแหน่งของคุณ",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnOkText: "เปิด GPS",
          btnOkOnPress: () async {
            await Geolocator.openLocationSettings();
          },
        ).show();
      }

      // รอ 5 วินาทีแล้วตรวจสอบอีกครั้ง
      await Future.delayed(const Duration(seconds: 5));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      for (int i = 0; i < 5; i++) {
        if (serviceEnabled) break;
        await Future.delayed(const Duration(seconds: 2));
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      if (!serviceEnabled) {
        // แสดง AwesomeDialog ว่าผู้ใช้ยังไม่เปิด GPS
        if (context.mounted) {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ไม่สามารถใช้ตำแหน่งได้",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'lib/img/PSS Sticker-07.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const Text(
                  "กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            btnOkText: "ตกลง",
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          ).show();
        }
        return Future.error('Location services are disabled.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ไม่สามารถใช้ตำแหน่งได้",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'lib/img/PSS Sticker-07.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const Text(
                  "กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            btnOkText: "ตกลง",
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          ).show();
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ไม่สามารถใช้ตำแหน่งได้",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                'lib/img/PSS Sticker-07.png',
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                "กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          btnOkText: "ตกลง",
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  // void checkNotificationPermission() async {
  //   bool hasPermission = await OneSignal.Notifications.permission;
  //   print("Notification Permission: $hasPermission");

  //   if (!hasPermission) {
  //     print("User has not enabled notifications!");
  //     // ทำอะไรต่อ เช่น แสดงคำแนะนำให้เปิด
  //   }
  // }

  // void checkOneSignalStatus() async {
  //   var playerId = await OneSignal.User.getOnesignalId();
  //   print("Player ID: $playerId");

  //   bool hasPermission = await OneSignal.Notifications.permission;
  //   print("Notification Permission: $hasPermission");

  //   bool? isSubscribed = await OneSignal.User.pushSubscription.optedIn;
  //   print("Subscribed to OneSignal: $isSubscribed");
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Providerpreferrent>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.red,
        title: const Text('ลงเวลางาน', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Position?>(
        future: getLocation(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.discreteCircle(
              color: Colors.greenAccent,
              secondRingColor: Colors.yellowAccent,
              thirdRingColor: Colors.redAccent,
              size: MediaQuery.of(context).size.height * 0.08,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('ไม่สามารถดึงตำแหน่งได้'));
          } else {
            userLocation = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        onMapCreated: _onMapCreated,
                        buildingsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        compassEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        markers: {
                          Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                            markerId: MarkerId(provider.locationName),
                            position:
                                LatLng(provider.latitude!, provider.longitude!),
                          )
                        },
                        circles: {
                          Circle(
                            circleId: CircleId(provider.locationName),
                            center:
                                LatLng(provider.latitude!, provider.longitude!),
                            radius: provider.radius!
                                .toDouble(), // หน่วยเป็นเมตร (500m = 0.5km)
                            strokeWidth: 2, // ความหนาของเส้นขอบ
                            strokeColor:
                                Colors.redAccent.withOpacity(0.5), // สีขอบวงกลม
                            fillColor: Colors.greenAccent
                                .withOpacity(0.2), // สีพื้นหลังแบบโปร่งแสง
                          ),
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              userLocation.latitude, userLocation.longitude),
                          zoom: 17,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Clock(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      Text(' ${userLocation.latitude.toStringAsFixed(6)}'),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      Text(' ${userLocation.longitude.toStringAsFixed(6)}')
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isButtonDisabled,
                    builder: (context, isDisabled, child) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDisabled ? Colors.grey : Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isDisabled
                              ? null
                              : () async {
                                  _isButtonDisabled.value = true;

                                  try {
                                    await Api.getDistance(
                                      latitude: userLocation.latitude,
                                      longitude: userLocation.longitude,
                                      datetime: datetime,
                                      context: context,
                                    );
                                  } catch (e) {
                                    print("Error: $e");
                                    if (mounted) {
                                      _isButtonDisabled.value = false;
                                    }
                                  }
                                },
                          child: const Text(
                            'สแกนใบหน้า',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
