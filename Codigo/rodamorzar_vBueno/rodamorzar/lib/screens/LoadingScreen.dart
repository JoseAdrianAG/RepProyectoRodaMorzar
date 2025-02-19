import 'package:flutter/material.dart';

//Falsear una pantalla de carga con animacion de incio
//no implementado
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
