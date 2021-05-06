import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;
import 'dart:io' show Platform;

void main() {
  runApp(NourishMySoul());
}

class NourishMySoul extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Calender',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;
  Map<DateTime,List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime,List<dynamic>>.from(decodeMap(json.decode(prefs.getString
        ("events") ?? "{}")));
    });
  }

  Map<String,dynamic> encodeMap(Map<DateTime,dynamic> map) {
    Map<String,dynamic> newMap = {};
    map.forEach((key,value) {
      newMap[key.toString()] =map[key];
    });
    return newMap;
  }

  Map<DateTime,dynamic> decodeMap(Map<String,dynamic> map) {
    Map<DateTime,dynamic> newMap = {};
    map.forEach((key,value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Calender'),
      ),
      // build app view
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // run build add button (appears at top of screen currently)
            _buildAddButton(),
            // create new calendar from plugin TableCalendar
            TableCalendar(
              events: _events,
              initialCalendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                  todayColor: Colors.tealAccent,
                  selectedColor: Theme.of(context).primaryColor,
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white
                  )
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.sunday,
              onDaySelected: (date, events, fuckDart){
                setState(() {
                  _selectedEvents = events;
                });
              },
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) =>
                    Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(date.day.toString(), style: TextStyle
                          (color: Colors.blueGrey),)),
                todayDayBuilder: (context, date, events) =>
                    Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Text(date.day.toString(), style: TextStyle
                          (color: Colors.blueGrey),)),
              ),
              calendarController: _controller,
            ),
            ... _selectedEvents.map((event) => ListTile(
              title: Text(event),
            )),
          ],
        ),
      ),
    );
  }

  // check to see if person has perms to add events (only providers, proof of concept)
  bool provider = false;
  // since not everyone can add events, the add button only appears if the account
  // is a provider account
  Widget _buildAddButton() {
    // check if person is provider (if they are, build button and run _showAddDialog)
    return provider == true
        ? ElevatedButton(
      onPressed: _showAddDialog,
      child: Icon(Icons.add),
    )
        : Container();
  }

  // the code for what the add button actually does (called on press)
  _showAddDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: _eventController,
          ),
          // create add button and create pop up that allows person to create
          // new events (currently pre-fills nothing)
          actions: <Widget>[
            TextButton(
              child: Text("Save"),
              onPressed: (){
                if(_eventController.text.isEmpty) return;
                setState(() {
                  if(_events[_controller.selectedDay] != null) {
                    _events[_controller.selectedDay].add
                      (_eventController.text);
                  } else {
                    _events[_controller.selectedDay] =
                    [_eventController.text];
                  }
                  prefs.setString("events", json.encode(encodeMap(_events)));
                  _eventController.clear();
                  Navigator.pop(context);
                });
              },
            )
          ],
        )
    );
  }
}

// create class user to allow for new user objects
// constructors will get data from databases/registration
class User {
  // provider constructor
  // volunteer constructor
  // guest constructor (can't see anything, just login page)
}