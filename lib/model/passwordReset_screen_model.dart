class PasswordResetScreenModel{
  String? email;

  String? validateEmail(String? value){
    if(value == null || !(value.contains('@') && value.contains('.'))){
      return 'Invalid Email, Include @ & .';
    } else{
      return null;
    }
  }

  void saveEmail(String? value){
    email = value;
  }
}