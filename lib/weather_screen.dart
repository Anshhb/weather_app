import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Hourly_forecast.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String,dynamic>> getCurrentWeather() async {
    try{
    String cityName = 'London';
    final res = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=4e5ff045695bbb688b9a75a16acc5255'),
      );
      final data = jsonDecode(res.body);

      if(data['cod'] != '200'){
        throw 'An unexpected error occured';
      }
      return data;
    }
    catch(e){
      throw e.toString();
    }

  }
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            setState(() {
              weather = getCurrentWeather();
            });
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          print(snapshot);
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherdata = data['list'][0];
          final currentTemp = currentWeatherdata['main']['temp'];
          final currentSky = currentWeatherdata['weather'][0]['main'];
          final currentPressure = currentWeatherdata['main']['pressure'];
          final currentWindSpeed = currentWeatherdata['wind']['speed'];
          final currentHumidity = currentWeatherdata['main']['humidity'];
          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child:  Padding(
                        padding: const  EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp K',
                              style:const  TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const  SizedBox(height: 16),
                             Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'? Icons.cloud : Icons.sunny,
                              size: 64,
                            ),
                            const  SizedBox(height: 16),
                             Text(
                            currentSky,
                            style: const TextStyle(   
                              fontSize: 20,
                            ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Hourly Forecast', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final hourlyForecast = data['list'][index+1];
                  final hourlySky = data['list'][index+1]['weather'][0]['main'];
                  final hourlyTemp = hourlyForecast['main']['temp'].toString();
                  final time = DateTime.parse(hourlyForecast['dt_txt'].toString());
                  return HourleyForecastItem(
                    time: DateFormat.jm().format(time),
                    temperature: hourlyTemp,
                    icon: hourlySky == 'Clouds' || 
                    hourlySky == 'Rain' ? Icons.cloud: Icons.sunny,
                  );
                }
              ),
            ),
              const SizedBox(height: 20),
              const Text('Additional Information', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Padding(
                  padding:  const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[ const Icon(
                      Icons.water_drop,
                      size: 32),
                               
                     const SizedBox(height: 10),
                    const Text(
                      textAlign: TextAlign.left,
                      'Humidity',
                      style: TextStyle(
                        fontSize: 16,
                    ),
                  ),
                     const SizedBox(height: 6),
                    Text(
                      '$currentHumidity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                      ]
                    ),
                ),
                // SizedBox(width: 35),
                 Padding(
                  padding:  const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[ const Icon(
                      Icons.air,
                      size: 32),
                               
                     const SizedBox(height: 10),
                    const Text(
                      textAlign: TextAlign.left,
                      'Wind Speed',
                      style: TextStyle(
                        fontSize: 16,
                    ),
                  ),
                     const SizedBox(height: 6),
                    Text(
                      '$currentWindSpeed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                      ]
                    ),
                ),
                // SizedBox(width: 35),
                Padding(
                  padding:  const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[ const Icon(
                      Icons.beach_access,
                      size: 32),
                               
                     const SizedBox(height: 6),
                    const Text(
                      textAlign: TextAlign.left,
                      'Pressure',
                      style: TextStyle(
                        fontSize: 16,
                    ),
                  ),
                     const SizedBox(height: 10),
                    Text(
                      '$currentPressure',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                      ]
                    ),
                ),
              ],
            )
            ],
          ),
        );
        },
      ),
    );
  }
}


