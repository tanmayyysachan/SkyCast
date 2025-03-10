import 'package:flutter/material.dart';

class CityForecast extends StatelessWidget {
  final String city;

  const CityForecast({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
  return Card(
    elevation: 20,
    child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(
              city,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    ),
  );
}

}
