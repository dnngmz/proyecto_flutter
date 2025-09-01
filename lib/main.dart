import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ==================== MyApp ====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Semáforos con Isolates',
      home: const SemaforosScreen(),
    );
  }
}

// ==================== Pantalla principal ====================
class SemaforosScreen extends StatefulWidget {
  const SemaforosScreen({super.key});

  @override
  State<SemaforosScreen> createState() => _SemaforosScreenState();
}

class _SemaforosScreenState extends State<SemaforosScreen> {
  String estadoSemaforo1 = "rojo";
  String estadoSemaforo2 = "verde";

  @override
  void initState() {
    super.initState();
    iniciarSemaforo1();
    iniciarSemaforo2();
  }

  // ==================== Funciones para iniciar semáforos ====================
  void iniciarSemaforo1() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(semaforoIsolate, {
      'sendPort': receivePort.sendPort,
      'inicio': 0, // empieza en rojo
    });

    receivePort.listen((mensaje) {
      setState(() {
        estadoSemaforo1 = mensaje;
      });
    });
  }

  void iniciarSemaforo2() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(semaforoIsolate, {
      'sendPort': receivePort.sendPort,
      'inicio': 2, // empieza en verde
    });

    receivePort.listen((mensaje) {
      setState(() {
        estadoSemaforo2 = mensaje;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Semáforos con Isolates")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SemaforoWidget(estado: estadoSemaforo1),
            SemaforoWidget(estado: estadoSemaforo2),
          ],
        ),
      ),
    );
  }
}

// ==================== Widget para un semáforo ====================
class SemaforoWidget extends StatelessWidget {
  final String estado;
  const SemaforoWidget({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circulo(Colors.red, estado == "rojo"),
        circulo(Colors.yellow, estado == "amarillo"),
        circulo(Colors.green, estado == "verde"),
      ],
    );
  }

  Widget circulo(Color color, bool encendido) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: encendido ? color : Colors.black,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

// ==================== Código del isolate ====================
void semaforoIsolate(Map args) async {
  final sendPort = args['sendPort'] as SendPort;
  final inicio = args['inicio'] as int;

  final estados = ["rojo", "amarillo", "verde"];
  int index = inicio;

  while (true) {
    sendPort.send(estados[index]);
    await Future.delayed(const Duration(seconds: 2));
    index = (index + 1) % estados.length;
  }
}