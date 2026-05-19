class ApiConstants {
  // Si pruebas en Emulador Android usa '10.0.2.2'. Si es Web o Windows usa 'localhost'
  // Si lo pruebas en tu celular físico por USB, pon la IP de tu PC (ej: 192.168.1.X)
  //static const String baseUrl = 'http://10.0.2.2:8080/api';
  //static const String baseUrl = 'http://192.168.1.20:8080/api';
  static const String baseUrl = 'http://localhost:8080/api';

  static const String loginEndpoint = '$baseUrl/auth/login';
}