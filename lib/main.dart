import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter cache with dio',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DioCacheManager _dioCacheManager;
  String _myData;
  @override
  Widget build(BuildContext context) {
    print("");
    print("");
    print("rendered");
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          FlatButton(
            child: Text(
              'getData',
            ),
            onPressed: () async {
              setState(() {
                _myData = null;
              });

              _dioCacheManager = DioCacheManager(CacheConfig());

              Options _cacheOptions1 = buildCacheOptions(Duration(days: 7));
              Dio _dio = Dio();
              _dio.interceptors.add(_dioCacheManager.interceptor);
              Response responseCached = await _dio.get('https://jsonplaceholder.typicode.com/users', options: _cacheOptions1);
              setState(() {
                _myData = responseCached.data.toString();
              });
              
              if(responseCached.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE) != null) {
                Options _cacheOptions = buildCacheOptions(Duration(days: 7), forceRefresh: true);
                Response response = await _dio.get('https://jsonplaceholder.typicode.com/users', options: _cacheOptions);
                if(response.data.toString() != responseCached.data.toString()) {
                  setState(() {
                    _myData = response.data.toString();
                  });
                };
                print("data from cache: ${response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)}");
              }

              print(_myData);
            },
          ),
          FlatButton(
            child: Text(
              'Delete Cache',
            ),
            onPressed: () async {
              if (_dioCacheManager != null) {
                bool res = await _dioCacheManager.deleteByPrimaryKey('https://jsonplaceholder.typicode.com/users', requestMethod: "GET");
                print(res);
              }
            },
          ),
          Text(
            _myData ?? '',
            // style: Theme.of(context).textTheme.headline1,
          ),
        ],
      ),
    );
  }
}
