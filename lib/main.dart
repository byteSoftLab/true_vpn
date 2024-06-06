import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyListScreen(),
    );
  }
}

class ProxyListScreen extends StatefulWidget {
  @override
  _ProxyListScreenState createState() => _ProxyListScreenState();
}

class _ProxyListScreenState extends State<ProxyListScreen> {
  static const platform = MethodChannel('com.bytesoftlab.true_vpn/proxy');

  List<dynamic> proxies = [];
  bool isLoading = true;
  bool isConnected = false;
  String connectedProxy = '';
  String realIp = '';

  @override
  void initState() {
    super.initState();
    fetchRealIp();
    fetchProxies();
  }

  Future<void> fetchRealIp() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          realIp = data['ip'];
        });
      } else {
        setState(() {
          realIp = 'Failed to get IP';
        });
      }
    } catch (e) {
      setState(() {
        realIp = 'Failed to get IP';
      });
    }
  }

  Future<void> fetchProxies() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.75:3000/proxies')); // Replace 192.168.x.x with your local IP address

    if (response.statusCode == 200) {
      setState(() {
        proxies = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load proxies');
    }
  }

  Future<void> connectToProxy(String city, String ip, String port) async {
    try {
      final bool result = await platform.invokeMethod('setProxy', {
        'host': ip,
        'port': port,
      });
      if (result) {
        setState(() {
          isConnected = true;
          connectedProxy = '$city ($ip:$port)';
        });
        print('Connected to proxy: $city ($ip:$port)');
      } else {
        print('Failed to connect to proxy: $city ($ip:$port)');
      }
    } on PlatformException catch (e) {
      print('Failed to set proxy: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proxy List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Real IP: $realIp',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isConnected)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Connected to: $connectedProxy',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: proxies.length,
                    itemBuilder: (context, index) {
                      if (index >= 10)
                        return null; // Display only the first 10 proxies
                      final proxy = proxies[index];
                      return ListTile(
                        title: Text(proxy['city']),
                        subtitle: Text('${proxy['ip']}:${proxy['port']}'),
                        onTap: () => connectToProxy(
                            proxy['city'], proxy['ip'], proxy['port']),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
