import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/addition_info_items.dart';
import 'package:weather_app/hourly_forcast_items.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWheather() async {
    try {
      String cityName = 'Mumbai';

      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey'),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An Unecpected error occured';
      }

      // temp = data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWheather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                weather = getCurrentWheather();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: getCurrentWheather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final data = snapshot.data!;
            final currentWeatherdata = data['list'][0];
            final currentTemp = currentWeatherdata['main']['temp'];
            final currentSky = currentWeatherdata['weather'][0]['main'];
            final currentPressure = currentWeatherdata['main']['pressure'];
            final currentHumidity = currentWeatherdata['main']['humidity'];
            final currentWindSpeed = currentWeatherdata['wind']['speed'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp k',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSky == 'Rain' || currentSky == 'Clouds'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentSky,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Weather Forecast",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int i) {
                        final time =
                            DateTime.parse(data['list'][i + 1]['dt_txt']);
                        final hourlyTemp = data['list'][i + 1]['main']['temp'];

                        return HourlyForcastItems(
                          icon: currentWeatherdata['weather'][0]['main'] ==
                                      'Clouds' ||
                                  currentWeatherdata['weather'][0]['main'] ==
                                      'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          temperature: hourlyTemp.toString(),
                          time: DateFormat.j().format(time),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionInfoItems(
                        iconData: Icons.water_drop,
                        temp: '$currentHumidity',
                        title: 'Humidity',
                      ),
                      AdditionInfoItems(
                        iconData: Icons.air,
                        temp: '$currentWindSpeed',
                        title: 'Wind Speed',
                      ),
                      AdditionInfoItems(
                        iconData: Icons.beach_access,
                        temp: '$currentPressure',
                        title: 'Pressure',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
