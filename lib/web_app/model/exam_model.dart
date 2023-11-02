class ClassModel {
  final String className;

  ClassModel(this.className);

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(json['class']);
  }
}

class SubjectModel {
  final String subjectName;

  SubjectModel(this.subjectName);

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(json['subject']);
  }
}

class ExamModel {
  final String examName;

  ExamModel(this.examName);

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(json['exam']);
  }
}

class SubExamModel {
  final String subExamName;

  SubExamModel(this.subExamName);

  factory SubExamModel.fromJson(Map<String, dynamic> json) {
    return SubExamModel(json['sub_exam']);
  }
}

class StudentModel {
  final String sno;
  final String admNo;
  final String name;
  String marksObtained;
  final String maxMarks;

  StudentModel({
    required this.sno,
    required this.admNo,
    required this.name,
    required this.marksObtained,
    required this.maxMarks,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      sno: json['sno'],
      admNo: json['adm_no'],
      name: json['name'],
      marksObtained: json['marks_obtained'],
      maxMarks: json['max_marks'],
    );
  }
}
