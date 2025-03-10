import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:skycast/additional_info_item.dart';
import 'package:skycast/constants.dart';
import 'package:skycast/hourly_forecast_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String selectedCity = "Bengaluru"; // Default city
  late Future<Map<String, dynamic>> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getCurrentWeather(selectedCity);
  }

  // Fetch weather data from API
  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$appWeatherAPIKey",
        ),
      );

      final data = jsonDecode(res.body);

      if (data["cod"] != '200') {
        throw "City not found. Please try again.";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Updates the selected city and refreshes the weather data
  void updateCity(String newCity) {
    setState(() {
      selectedCity = newCity;
      weatherData = getCurrentWeather(newCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "skyCast",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                selectedCity = "Bengaluru";
                weatherData = getCurrentWeather(selectedCity);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!;

          final currentWeather = data["list"][0];
          final currentTemp = (currentWeather["main"]["temp"] - 273.15).toStringAsFixed(1); 
          final currentSky = (currentWeather["weather"][0]["main"]).toString();
          final currentPressure = (currentWeather["main"]["pressure"]).toString();
          final currentHumidity = (currentWeather["main"]["humidity"]).toString();
          final currentWindSpeed = (currentWeather["wind"]["speed"]).toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCity,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const SizedBox(height: 20),

                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search city...",
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[900], 
                    border: InputBorder.none, 
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      updateCity(value);
                    }
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp°C",
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Icon(
                                switch (currentSky) {
                                  'Cloud' => Icons.cloud_sharp,
                                  'Clouds' => Icons.cloud_sharp,
                                  'Sunny' => Icons.wb_sunny,
                                  'Clear' => Icons.brightness_5,
                                  'Rainy' => Icons.beach_access,
                                  'Snowy' => Icons.ac_unit,
                                  _ => Icons.help_outline,
                                },
                                size: 64,
                                color: Colors.white,
                              ),

                              const SizedBox(height: 10),

                              Text(currentSky,
                                  style: const TextStyle(fontSize: 22, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    additionInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: "$currentHumidity%",
                    ),
                    additionInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: "$currentWindSpeed m/s",
                    ),
                    additionInfoItem(
                      icon: Icons.speed,
                      label: "Pressure",
                      value: "$currentPressure hPa",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Hourly Forecast Title
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 125,
                  child: ListView.builder(
                    itemCount: min(38, data["list"].length - 1),
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlyTemp = (hourlyForecast["main"]["temp"] - 273.15).toStringAsFixed(1);
                      final time = DateTime.parse(hourlyForecast["dt_txt"]);

                       
                        return HourlyForecastItem(
                          time: DateFormat('MMM dd, hh:mm a').format(time),
                          temperature: "$hourlyTemp°C",
                          icon: Icons.cloud,
                        );
                      }
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "7-Day Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: min(38, data["list"].length ~/ 8),
                    itemBuilder: (context, index) {
                      final dailyData = data["list"][index * 8];
                      final dayTemp = (dailyData["main"]["temp"] - 273.15).toStringAsFixed(1);
                      final date = DateTime.parse(dailyData["dt_txt"]);

                      return ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.white),
                        title: Text(DateFormat('EEEE').format(date),
                            style: const TextStyle(color: Colors.white)),
                        trailing: Text("$dayTemp°C",
                            style: const TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
