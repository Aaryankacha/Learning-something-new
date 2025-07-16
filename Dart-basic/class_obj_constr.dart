class Student{
  String name;
  int rollNum;
  bool isEnrolled;
  Student(this.name,this.rollNum,this.isEnrolled);

  void showDetails(){
    print("My name is $name. My roll number is $rollNum. Am i enrolled? $isEnrolled");
  }

}

void main(){
  Student s1 = Student("Aryan", 23, true);    //creating obj
  s1.showDetails();   //calling method
}
//obj:An object is an actual thing made from the class.
//Constructor: A special method that runs when an object is created

/*this Keyword
Used to refer to the current object’s properties:
this.name = name;
Used inside a class when parameter name and property name are same.*/

