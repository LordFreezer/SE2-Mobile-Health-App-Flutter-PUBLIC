class Weather{
  String? cityName;
  double? temp;
  double? wind;
  int? humidity;
  double? feels_like;
  int? pressure;
  double? min_temp;
  double? max_temp;

  Weather({
    this.cityName,
    this.temp,
    this.wind,
    this.humidity,
    this.feels_like,
    this.pressure,
    this.min_temp,
    this.max_temp,
  });

  Weather.fromJson(Map<String,dynamic> json){
    cityName = json["name"];
    temp = json["main"]["temp"];
    wind = json["wind"]["speed"];
    humidity = json["main"]["humidity"];
    feels_like = json["main"]["feels_like"];
    pressure = json["main"]["pressure"];
    min_temp = json["main"]["temp_min"];
    max_temp = json["main"]["temp_max"];
  }

}