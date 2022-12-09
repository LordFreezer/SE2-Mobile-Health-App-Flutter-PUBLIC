class ChangeCity{
  String? city;

  String? validateCity(String? value){
    if(value == null || (value.contains(RegExp(r'[0-9]')) && value.contains('.'))){
      return 'Invalid City, only use letters';
    } else{
      return null;
    }
  }

  void saveCity(String? value){
    city = value;
  }
}