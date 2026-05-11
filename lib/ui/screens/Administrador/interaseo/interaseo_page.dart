import 'package:flutter/material.dart';

class InterAseoPage extends StatelessWidget {
    final int autoridadId;
  const InterAseoPage({super.key, required this.autoridadId});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InterAseo"),
        backgroundColor: Colors.blueGrey,
      ),
      body: const Center(
        child: Text(
          "Bienvenido a InterAseo 🧹",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}