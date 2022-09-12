import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

//"min":153,"max":454
var appropriateHourToColor = {};

int appropriateCt(int mins) {
  final pins = {
    0: 454,
    6: 153,
    12: 153,
    17: 250,
    29: 250,
    24: 454,
  };

  return between(pins, mins);
}

int appropriateBri(int mins) {
  final pins = {
    0: 1,
    3: 1,
    4: 60,
    6: 255,
    20: 255,
    24: 1
  };

  return between(pins, mins);
}

int between(Map<int, int> pins, int mins) {
  var before = -1;
  var after = -1;
  for (final key in pins.keys) {
    if (key * 60 <= mins) {
      before = key;
    }
    if (key * 60 > mins) {
      after = key;
      break;
    }
  }

  //print('mins $mins, $before ${pins[before]} $after ${pins[after]} ');

  final slope = (pins[after] - pins[before]) / ((after - before) * 60);
  final result = pins[before] + slope * (mins - before*60);
  print('${mins/60}, $slope, $result');
  return result.floor();
}


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


  //await rename('Hue ambiance lamp 8', 'Nursery');
  await setAppropriateColor();




  //	{"on":true, "sat":254, "bri":254,"hue":10000}

  
  
  
  //  print("${r.runtimeType}");

  //print(await http.read(Uri.https('example.com', 'foobar.txt')));

}

void setAppropriateColor() async {
  var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights');
  var response = await http.get(url);
  final r = jsonDecode(response.body);
  final now = DateTime.now();
  final mins = now.hour * 60 + now.minute;
  //final mins = 12*60;

  for (final key in r.keys) {
    if (r[key]['name'] == 'Nursery') continue;

    var url = Uri.http('192.168.0.3', '/api/q14kgE9c6eZ6ja35eAH3DSByiYVhhc14bRLQeYC1/lights/$key/state');

    //print("yo ${r[key]['name']} ${r[key]['state']}");
    if (r[key]['state']['on']) {
      print("${r[key]['name']} is on");
      var response = await http.put(url, body: '{"ct":${appropriateCt(mins)}, "bri": ${appropriateBri(mins)}, "transitiontime": 5}');
      print('    ${response.body}');
    }
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
