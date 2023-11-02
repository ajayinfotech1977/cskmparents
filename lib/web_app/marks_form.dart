import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
//import exam_model.dart
import 'model/exam_model.dart';

const baseUrl = 'https://www.cskm.com/schoolexpert/cskmparents/';

class MarksEntryForm extends StatefulWidget {
  @override
  _MarksEntryFormState createState() => _MarksEntryFormState();
}

class _MarksEntryFormState extends State<MarksEntryForm> {
  String? selectedClass;
  String? selectedSubject;
  String? selectedExam;
  String? selectedSubExam;
  List<StudentModel> studentsData = [];

  Future<List<ClassModel>> _fetchClasses() async {
    final response = await http.post(Uri.parse('${baseUrl}fetch_classes.php'));
    if (response.statusCode == 200) {
      setState(() {
        selectedClass = null;
        selectedSubject = null;
        selectedExam = null;
        selectedSubExam = null;
      });
      final classesData = json.decode(response.body) as List;
      return classesData.map((json) => ClassModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<List<SubjectModel>> _fetchSubjects() async {
    if (selectedClass == null) return [];
    final response = await http.post(
      Uri.parse('${baseUrl}fetch_subjects.php'),
      body: {'class': selectedClass!},
    );
    if (response.statusCode == 200) {
      setState(() {
        selectedSubject = null;
        selectedExam = null;
        selectedSubExam = null;
      });
      final subjectsData = json.decode(response.body) as List;
      return subjectsData.map((json) => SubjectModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<List<ExamModel>> _fetchExams() async {
    if (selectedClass == null || selectedSubject == null) return [];
    final response = await http.post(
      Uri.parse('${baseUrl}fetch_exams.php'),
      body: {
        'class': selectedClass!,
        'subject': selectedSubject!,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        selectedExam = null;
        selectedSubExam = null;
      });
      final examsData = json.decode(response.body) as List;
      return examsData.map((json) => ExamModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exams');
    }
  }

  Future<List<SubExamModel>> _fetchSubExams() async {
    if (selectedClass == null ||
        selectedSubject == null ||
        selectedExam == null) return [];
    final response = await http.post(
      Uri.parse('${baseUrl}fetch_subexams.php'),
      body: {
        'class': selectedClass!,
        'subject': selectedSubject!,
        'exam': selectedExam!,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        selectedSubExam = null;
      });
      final subExamsData = json.decode(response.body) as List;
      return subExamsData.map((json) => SubExamModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subexams');
    }
  }

  Future<void> _fetchMarks() async {
    if (selectedClass == null ||
        selectedSubject == null ||
        selectedExam == null ||
        selectedSubExam == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('${baseUrl}fetch_marks.php'),
      body: {
        'class': selectedClass!,
        'subject': selectedSubject!,
        'exam': selectedExam!,
        'sub_exam': selectedSubExam!,
      },
    );

    if (response.statusCode == 200) {
      final marksData = json.decode(response.body) as List;
      setState(() {
        studentsData =
            marksData.map((json) => StudentModel.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load student marks');
    }
  }

  Future<void> _saveMarks(StudentModel studentData) async {
    final response = await http.post(
      Uri.parse('${baseUrl}save_marks.php'),
      body: {
        'adm_no': studentData.admNo,
        'subject': selectedSubject!,
        'exam': selectedExam!,
        'sub_exam': selectedSubExam!,
        'marks_obtained': studentData.marksObtained,
        'max_marks': studentData.maxMarks,
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Marks saved successfully.');
    } else {
      Fluttertoast.showToast(msg: 'Failed to save marks.');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<ClassModel>>(
              future: _fetchClasses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final classes = snapshot.data;
                  return DropdownButton<String>(
                    value: selectedClass,
                    hint: Text('Select Class'),
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                        _fetchSubjects();
                      });
                    },
                    items: classes!.map((classModel) {
                      return DropdownMenuItem(
                        value: classModel.className,
                        child: Text(classModel.className),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            FutureBuilder<List<SubjectModel>>(
              future: _fetchSubjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final subjects = snapshot.data;
                  return DropdownButton<String>(
                    value: selectedSubject,
                    hint: Text('Select Subject'),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                        selectedExam = null;
                        selectedSubExam = null;
                        _fetchExams();
                      });
                    },
                    items: subjects!.map((subjectModel) {
                      return DropdownMenuItem(
                        value: subjectModel.subjectName,
                        child: Text(subjectModel.subjectName),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            FutureBuilder<List<ExamModel>>(
              future: _fetchExams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final exams = snapshot.data;
                  return DropdownButton<String>(
                    value: selectedExam,
                    hint: Text('Select Exam'),
                    onChanged: (value) {
                      setState(() {
                        selectedExam = value;
                        selectedSubExam = null;
                        _fetchSubExams();
                      });
                    },
                    items: exams!.map((examModel) {
                      return DropdownMenuItem(
                        value: examModel.examName,
                        child: Text(examModel.examName),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            FutureBuilder<List<SubExamModel>>(
              future: _fetchSubExams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final subExams = snapshot.data;
                  return DropdownButton<String>(
                    value: selectedSubExam,
                    hint: Text('Select Sub Exam'),
                    onChanged: (value) {
                      setState(() {
                        selectedSubExam = value;
                        _fetchMarks();
                      });
                    },
                    items: subExams!.map((subExamModel) {
                      return DropdownMenuItem(
                        value: subExamModel.subExamName,
                        child: Text(subExamModel.subExamName),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                _fetchMarks();
              },
              child: Text('Fetch Marks'),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: studentsData.length,
              itemBuilder: (context, index) {
                final studentData = studentsData[index];
                return ListTile(
                  title: Text(studentData.name),
                  subtitle: Text(studentData.admNo),
                  trailing: SizedBox(
                    width: 100,
                    child: TextField(
                      onChanged: (value) {
                        // Validate the entered marks and save to server
                        final marks = int.tryParse(value);
                        if (marks != null) {
                          if (marks <= int.parse(studentData.maxMarks)) {
                            studentData.marksObtained = value;
                            _saveMarks(studentData);
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Marks cannot be greater than max marks.',
                            );
                          }
                        } else if (value.toLowerCase() == 'ab') {
                          studentData.marksObtained = value;
                          _saveMarks(studentData);
                        }
                      },
                      controller: TextEditingController(
                        text: studentData.marksObtained,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Marks',
                      ),
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Logic to send SMS
              },
              child: Text('Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}

// Rest of the model classes are the same as mentioned before...

// ClassModel, SubjectModel, ExamModel, SubExamModel, StudentModel


