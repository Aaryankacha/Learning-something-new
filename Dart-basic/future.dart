
void main(){
  Future<String> getUserName(){
    return Future.delayed(Duration(seconds: 2),(){
        return "Welcome Aryan!";
    });
  }
  getUserName().then((onValue){
    print(onValue);
  });
  print("Loading...");
}

//onValue is just a temporary variable that holds the result of the Future.
