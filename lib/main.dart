  import 'dart:convert';
  //import 'dart:html';
  import 'dart:io';
  import 'dart:typed_data';
  import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:luna_app_flutter/notification.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  main() {
    runApp(const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }

  class HomeScreen extends StatefulWidget {
    const HomeScreen({Key? key}) : super(key: key);

    @override
    HomeScreenState createState() => HomeScreenState();
  }

  class HomeScreenState extends State<HomeScreen> {
    final TextEditingController _tecIP = TextEditingController(text: '192.168.0.108');
    final TextEditingController _tecPort = TextEditingController(text: "5001");
    final TextEditingController _tecMsg = TextEditingController();
    final TextEditingController _captureMsg = TextEditingController();

    Socket? _socket ;
    String receivedData = '';
    bool isConnecting = false;
    String gps = "";
    String temperature = "";
    String date = "";
    String acc = "";
    String gyro = "";
    String volt = "";
    String isNotificationOn = "0";
    var imageUrl = "";
    Map<String, dynamic> receivedJson = {};


    void showConfigDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 300,
                  child: Column(
                    children: [
                      const Spacer(),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "IP Address",
                        ),
                        controller: _tecIP,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Port",
                        ),
                        controller: _tecPort,
                      ),
                      Center(
                          child: isConnecting
                              ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                              : ElevatedButton(
                              onPressed: () async {
                                if (_tecPort.text.isEmpty ||
                                    _tecIP.text.isEmpty) {
                                  return;
                                }
                                try {
                                  setState(() {
                                    isConnecting = true;
                                  });
                                  _socket = await Socket.connect( //Establishing socket connection
                                      _tecIP.text, int.parse(_tecPort.text));
                                  //_socket = await Socket.connect("192.168.0.108", 5001);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Connected"),
                                  ));
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(e.toString()),
                                  ));
                                }

                                setState(() {
                                  isConnecting = false;
                                });

                                Navigator.pop(context);
                              },
                              child: const Text('Connect'))),
                      const Spacer(),
                    ],
                  ),
                ));
          });
    }


    @override
    void initState() {
      super.initState();
      print("Initstate");
    }

    @override
    Widget build(BuildContext context) {
      print("Build Method...............######################################################");

  /*
      Future<void> connectServer() async {
        try{
          print("Connectins...");
          _socket = await Socket.connect("192.168.0.105", 5001);
          print("Connected ...");
          setState(() {
            isConnecting = false;
          });
        }
        catch(e){
          print(e);
          print("Not Connected");
        }
      }
      isConnecting?false:connectServer();
  */


      return Scaffold(
        appBar: AppBar(
          title: const Text('Luna Client App'),
          actions: [
            IconButton(
                onPressed: () {
                  showConfigDialog();
                },
                icon: const Icon(Icons.settings))
          ],
        ),

        body: ListView(
          children: [
            //Data Input Container
            Container(
              margin: const EdgeInsets.all(12),
              child: TextFormField(
                controller: _tecMsg,
                decoration: const InputDecoration(hintText: 'Write Command...'), //Write Message Field
              ),
            ),

            //Data Output Container

            //{"imageUrl":"n","gps":"40.741895,-73.989308","date":"1stmay","temp":"37.5","acc":"x:0.59,y:0.39,z:0.44","gyro":"x:0.76,y:0.23,z:0.54","volt":"12.9", "N":"1"}
            //Data Output Container
              Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  //color: Colors.white,
                  child:  Column(
                      children: [
                        if (_socket == null) const Text('Not connected.',) else StreamBuilder(
                          stream: _socket!,
                          builder: (context, snapshot) {

                            void evictImage() {
                              final NetworkImage provider = NetworkImage(imageUrl);
                              provider.evict().then<void>((bool success) {
                                if (success){
                                print('removed image!');
                                  }
                              });
                            }
                              evictImage();

                            //imageUrl = 'http://192.168.0.108:8000/shot3.jpg';
                            print("Image URL : ${imageUrl}");
                            if (snapshot.data != null) {
                              List<int> receivedRawData = snapshot.data as List<int>;
                              receivedData = utf8.decode(receivedRawData) ;
                              String trimmedData = receivedData.substring(4);

                              print("receivedJson: ${receivedJson}");
                              try {
                                receivedJson = json.decode(trimmedData);
                                String rawImageUrl = receivedJson['imageUrl'];
                                if(rawImageUrl != "n"){
                                  imageUrl = rawImageUrl;
                                }
                                gps = receivedJson['gps'];

                                temperature = receivedJson['temp'];
                                date = receivedJson['date'];
                                acc = receivedJson['acc'];
                                gyro = receivedJson['gyro'];
                                volt = receivedJson['volt'];
                                isNotificationOn = receivedJson['N'];

                                print("image url: ${imageUrl}");
                                print("GPS: ${gps}");
                                _socket!.flush();
                                evictImage();
                                if(isNotificationOn == '1') {
                                  //print("Notification On");
                                  sendNotification(
                                      title: "Sensor Value Changed",
                                      body: "GPS: ${gps}, Temp: ${temperature} C, Volt: ${volt} V ");
                                }
                              }
                              catch(e){
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //GPS
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('GPS: ${gps}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Temperature
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('Temperature: ${temperature} deg Celcius',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Date
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('Date: ${date} ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Accelerometer
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('Volt: ${volt} ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Gyro
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('Gyro: ${gyro} ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Volt
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                    child: Text('Accelerometer: ${acc} ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                  //Image
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //Container to Show Image
                                  //Image(image: NetworkImage(imageUrl)),
                                  Container(
                                    width: 400,
                                    height: 375,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        image: DecorationImage(
                                            fit: BoxFit.cover, image: NetworkImage(imageUrl))
                                    ),
                                  ),
                                ],
                              );
                            }
                            evictImage();
                            return Text('OK');
                          },
                        ),
                      ]

                  ),
              ),


            //Data Sending
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          if (_socket == null) {
                            showConfigDialog();
                          } else {
                            String header = "";
                            int rawMessageLength = _tecMsg.text.length;
                            //BOOST ASIO C++ Needed 3 Space for Char Less than 10
                            //2 Space for Character more than 10
                            //1 Space for Character more than 100
                            // Then Character Lenght. So SPACE + Character Length
                            if (rawMessageLength < 10) header = "   ";
                            if (rawMessageLength > 9) header = "  ";
                            if (rawMessageLength >=100) header = " ";
                            String actualMessageTobeSent = header + _tecMsg.text.length.toString() + _tecMsg.text;
                            _socket!.add(utf8.encode(actualMessageTobeSent));

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text("Sent"))); // Show sent in Bottom
                            _tecMsg.text = "";
                            _socket!.flush();
                          }

                        },
                        child: const Text('Send'))
                ),
                const SizedBox(width: 10,),
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          if (_socket == null) {
                            showConfigDialog();
                          } else {
                            //BOOST ASIO C++ Needed 3 Space for Char Less than 10
                            //2 Space for Character more than 10
                            //1 Space for Character more than 100
                            // Then Character Lenght. So SPACE + Character Length
                            String header = "   ";
                            String captureCommand = "#";
                            int rawMessageLength = captureCommand.length;

                            String actualMessageTobeSent = header + rawMessageLength.toString() + captureCommand;
                            _socket!.add(utf8.encode(actualMessageTobeSent));

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text("Capturing"))); // Show sent in Bottom
                            _tecMsg.text = "";
                            _socket!.flush();
                          }

                        },
                        child: const Text('Capture Image'))
                ),
              ],
            ),
          ],
        ),
      );
    }


  }
