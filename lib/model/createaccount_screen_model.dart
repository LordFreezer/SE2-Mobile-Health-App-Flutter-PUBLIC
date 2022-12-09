class CreateAccountScreenModel{
  String? email;
  String? password;
  String? passwordConfirm;
  bool showPasswords = false;
  String? username;

  String? validateEmail(String? value){
    if(value == null || !(value.contains('@') && value.contains('.'))){
      return 'Invalid Email';
    } else{
      return null;
    }
  }

  String? validatePassword(String? value){
    if(value == null || value.length<6){
      return 'Password too short (min 6 chars)';
    } else{
      return null;
    }
  }

  String? validateUsername(String? value){
    if(value == null || value.length < 4){
      return 'Invalid Email, Must be 4 characters long';
    } else{
      return null;
    }
  }

  void saveEmail(String? value){
    email = value;
  }

  void savePassword(String? value){
    password = value;
  }

  void savePasswordConfirm(String? value){
    passwordConfirm = value;
  }

  void saveUsername(String? value){
    username = value;
  }
}