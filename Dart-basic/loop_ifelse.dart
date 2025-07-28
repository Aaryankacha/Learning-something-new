void main(){
  int marks=45;

  if(marks>=90){
    print("Outstanding");
  }
  else if(marks<90 && marks>75){
    print("Very good");
  }
  else if(marks<74 && marks>60){
    print("Good");
  }
  else{
    print("Need to improve");
  }


  for(int i=1;i<=5;i++){
    print(i);
  }
}