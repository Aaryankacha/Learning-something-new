Future<int> fetchMarks() async {
  await Future.delayed(Duration(seconds: 3));
  return 88;
}

Future<String> evaluate(int marks) async {
  if (marks > 85) {
    return "Excellent";
  } else if (marks >= 60) {
    return "Good";
  } else {
    return "Needs Improvement";
  }
}

void main() async {
  print("Fetching marks...");
  int marks = await fetchMarks();
  print("Marks received: $marks");

  String result = await evaluate(marks);
  print("Evaluation: $result");
}
