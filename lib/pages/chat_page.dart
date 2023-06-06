import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapp/pages/group_info.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/message_tile.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        _getLocation();
                      },
                      child: Text('yes')),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        _getLocation();
                      },
                      child: Text('no')),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        _getLocation2();
                      },
                      child: Text('with different \n composition')),
                ),
                const SizedBox(
                  width: 12,
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    //
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": 'medigaze',
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  Future<void> _getLocation() async {
    LocationPermission permission;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");

    Map<String, String> datatosave = {
      'lattitude': "Latitude: ${position.latitude}",
      'longitude': "Longitude: ${position.longitude}"
    };
    FirebaseFirestore.instance.collection('location');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? Phone = prefs.getString("Start");
    {
      Map<String, dynamic> chatMessageMap = {
        "message":
            "We have this medicine and  My location: Latitude: ${position.latitude} Longitude: ${position.longitude}" +
                ' https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}',
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
    permission = await Geolocator.requestPermission();
  }

  Future<void> _getLocation2() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");

    Map<String, String> datatosave = {
      'lattitude': "Latitude: ${position.latitude}",
      'longitude': "Longitude: ${position.longitude}"
    };
    FirebaseFirestore.instance.collection('location');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? Phone = prefs.getString("Start");
    {
      Map<String, dynamic> chatMessageMap = {
        "message":
            "We have this medicine but of different composition and My location: Latitude: ${position.latitude} Longitude: ${position.longitude}" +
                ' https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}',
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  // void triggerNotification() {
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //         id: 5,
  //         channelKey: 'basic_channel',
  //         title: 'someone in need',
  //         body: 'help her asap'),
  //   );
  // }
}
