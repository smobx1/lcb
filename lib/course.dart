import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:liceucubrio/main.dart';
import 'package:liceucubrio/quiz.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util/data.dart';
import 'lesson.dart';
import 'package:liceucubrio/util/ui_components.dart';
import 'package:http/http.dart' as http;

class Course extends StatefulWidget {
  // declare the util/Data class

  // course
  Map<String, dynamic> course;
  // lessons of the course
  Map<String, dynamic> lessons;
  Course(this.course, this.lessons);

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final String url = "https://smobx1.github.io/lcb_quiz.json";
  Data app_data = Data();
  List<RaisedButton> buttonsList = new List<RaisedButton>();
  List data;

  Future<int> getIntFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final startupNumber = prefs.getInt('startupNumber');

    if (startupNumber == null) {
      return 0;
    }
    return startupNumber;
  }

  @override
  void initState() {
    super.initState();

    /// this.jsonData e pt cand voi implementa quiz sau alte chestii din json
    //  this.getJsonData();

    _getCheckboxValues();
  }

  List<String> checkboxValues = [];
  _getCheckboxValues() async {
    final prefs = await SharedPreferences.getInstance();
    checkboxValues = prefs.getStringList('checkboxesSts');
    if (checkboxValues.isEmpty) {
      print('is empty');
    } else {
      print('its not');
    }
    print(checkboxValues);
    print('get all statuses called');
  }

//  Future<String> getJsonData() async {
//    var response = await http.get(
//      // Encode the URL
//      Uri.encodeFull(url),
//      // Only accept JSON response
//      headers: {"Accept": "application/json"},
//    );
////    print(response.body);
//
//    setState(() {
//      //TODO: print something to tell the user if the internet is not working
//      if (response.statusCode == 200) {
//        print('200s');
//      } else {
//        print('nu e 200');
//      }
//      var jsonBody = json.decode(response.body);
//      //TODO continua si stocheaza jsonul intr-o variabila in dart
//      //TODO ca mai apoi sa fie mai usor de manipulat decat asa
//      print(jsonBody["c1_quiz1"][0]["question1"]);
//
////      print(jsonBody);
//
//      data = jsonBody['quizzes'];
//      print(data.length);
////      print(data);
//      print(data[0]);
//
////      if (jsonBody["c1_quiz3"] != null) {
////        print("avel quiz1");
////      }
//    });
//
//    return "Success";
//  }
  bool checkBoxValue = false;

  int totalNoOfLessons = 0;
  List<dynamic> _buildButtonsWithNames() {
    for (int i = 1; i < widget.course.length; i++) {
      if (widget.course['lesson$i'] != null) {
        totalNoOfLessons++;

        print('Index ' + i.toString());

        buttonsList.add(
          RaisedButton(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () async {
              //TODO don't allow the user to enter if viewCount <= 0
              int tempRemainingViewsNo = await getIntFromSharedPref();
              if (tempRemainingViewsNo <= 0) {
                noMoreViewsAlert(context);
              } else {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Lesson(widget.lessons, i, totalNoOfLessons)));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.course['lesson$i' + '_time'],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: 200,
                    child: Text(
                      widget.course['lesson$i'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    height: 20,
                    child: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        value: checkBoxValue,
                        onChanged: (bool value) {
                          print(value);
                          setState(() {
                            checkBoxValue = value;
                          });
                        },
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        );
      } else {
        /// aici printez si zic daca am gasit si alte activitati in afara de lectii
//        print('alt tip de buton (nu spre curs) ');
      }
    }
    return buttonsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: courseAppBar(context, widget.course['name'], HomePage()),
//      drawer: new Drawer(),
      body: ListView(
        children: _buildButtonsWithNames(),
      ),
    );
  }
}
