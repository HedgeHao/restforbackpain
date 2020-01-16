Map<String, dynamic> configure;

dynamic getConfigure(String key){
  if(configure == null){
    return null;
  }else{
    return configure[key];
  }
}