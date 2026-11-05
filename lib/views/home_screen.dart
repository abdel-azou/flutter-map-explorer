import 'package:flutter/material.dart';
import '../models/mural.dart';
import 'mural_list.dart';
import 'mural_map.dart';


enum MainView { list, map }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MainView _currentView = MainView.list;
  late Future<List<Mural>> _muralsFuture;

  @override
  void initState() {
    super.initState();
    _muralsFuture = fetchMurals();
  }

  void changeView(bool switchToMap) =>
      setState(() => _currentView = switchToMap ? MainView.map : MainView.list);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresques murales BD de Bruxelles'),
        actions: [
          Row(
            children: [
              const Icon(Icons.view_list_outlined),
              Switch(
                value: _currentView == MainView.map,
                onChanged: changeView,
              ),
              const Icon(Icons.map_outlined),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Mural>>(
        future: _muralsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final murals = snapshot.data!;

          return IndexedStack(
            index: _currentView == MainView.map ? 1 : 0,
            children: [
              MuralList(murals: murals),
              MuralMap(murals: murals),
            ],
          );
        },
      ),
    );
  }
}