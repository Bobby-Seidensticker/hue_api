import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

//"min":153,"max":454
var appropriateHourToColor = {};

void main() async {
  for (var i = 0; i < 24; i++) {
    if (i < 7) {
      appropriateHourToColor[i] = 454;
    } else if (i < 9) {
      appropriateHourToColor[i] = 153;
    } else if (i < 17) {
      appropriateHourToColor[i] = 250;
    } else if (i < 22) {
      appropriateHourToColor[i] = 400;
    } else if (i < 24) {
      appropriateHourToColor[i] = 454;
    }
  }

  print(appropriateHourToColor);

  
  //'https://192.168.0.3/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights'

  var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights');
  var response = await http.get(url);
  // print('Response status: ${response.statusCode}');
  // print('Response body: ${response.body}');


  final r = jsonDecode(response.body);

  //  print('${r["1"]}');


  // for (final value in r.values) { 
  //  print(value['name']);
  // }



  // for (final key in r.keys) {
  //   if (r[key]['name'] == 'Living room light') {
  //     print(r[key]);
  //     final livingRoomLight = Light(r[key]);
  //     print(livingRoomLight);

  //     var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights/$key/state');
  //     var response = await http.put(url, body: '{"on":true, "ct":1, "bri":254}');
  //     //var response = await http.put(url, body: '{"on":false}');

  //     // var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights/$key');
  //     // var response = await http.put(url, body: '{"name":"Living room light"}');
  //     print(response.body);
  //     print(response.headers);
  //     print(response.statusCode);
  //   }
  // }


  //await rename('Hue ambiance downlight 2', 'Living room light 1');
    await setAppropriateColor();

  final now = DateTime.now();

  print(now.hour);

  



  //	{"on":true, "sat":254, "bri":254,"hue":10000}

  
  
  
  //  print("${r.runtimeType}");

  //print(await http.read(Uri.https('example.com', 'foobar.txt')));

}

void setAppropriateColor() async {
  var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights');
  var response = await http.get(url);
  final r = jsonDecode(response.body);
  final now = DateTime.now();

  for (final key in r.keys) {
    var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights/$key/state');
    print("yo ${r[key]['name']} ${r[key]['state']}");
    if (r[key]['state']['on']) {
      print("${r[key]['name']} is on");
      var response = await http.put(url, body: '{"ct":${appropriateHourToColor[now.hour]}}');
    }
        var response = await http.put(url, body: '{"name":"Living room light"}');
  }
}

void rename(String from, String to) async {
  var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights');
  var response = await http.get(url);
  final r = jsonDecode(response.body);

  var found = false;

  for (final key in r.keys) {
    if (r[key]['name'] == from) {
      found = true;

      var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights/$key');
      var response = await http.put(url, body: '{"name":"$to"}');
      // print(response.body);
      // print(response.headers);
      // print(response.statusCode);

      print('successfully renamed light $from to $to\n${response.headers}\n${response.body}');
    }
  }
  if (!found) {
    print('did not find light named $from');
  }

}


class Light {
  bool on = false;
  int bri = 0;
  int ct = 0;
  
  Light(Map m) {
    this.on = m['state']['on'] ?? false;
    this.bri = m['state']['bri'];
    this.ct = m['state']['ct'];
  }

  String toString() => 'Light(${on ? "on" : "off"}, bri: $bri, ct: $ct)';
}
