import 'dart:convert';

import 'package:http/http.dart' as http;

const String muralsApiUrl =
    'https://opendata.brussels.be/api/explore/v2.1/catalog/datasets/bruxelles_parcours_bd/records?limit=100';

class Mural {
  const Mural({
    required this.name,
    required this.artist,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.year,
    required this.publisher,
    required this.surfaceM2,
    required this.comicRouteLink,
    required this.imageUrl,
  });

  final String name;
  final String artist;
  final String address;
  final double latitude;
  final double longitude;
  final String year;
  final String publisher;
  final String surfaceM2;
  final String comicRouteLink;
  final String imageUrl;

  factory Mural.fromJson(Map<String, dynamic> json) {
    final geo = json['geo_point'] as Map<String, dynamic>;

    return Mural(
      name: (json['nom_de_la_fresque'] as String?) ?? 'Fresque inconnue',
      artist: (json['dessinateur'] as String?) ?? 'Auteur inconnu',
      address: (json['adresse_fr'] as String?) ?? 'Adresse inconnue',
      latitude: (geo['lat'] as num).toDouble(),
      longitude: (geo['lon'] as num).toDouble(),
      year: (json['date'] as String?) ?? 'Année inconnue',
      publisher: (json['maison_d_edition'] as String?) ?? 'Éditeur inconnu',
      surfaceM2: ((json['surface_m2'] as num?) ?? 0).toString(),
      comicRouteLink: (json['lien_site_parcours_bd'] as String?) ?? '',
      imageUrl:
      ((json['image'] as Map<String, dynamic>?)?['url'] as String?) ?? '',
    );
  }
}

Future<List<Mural>> fetchMurals() async {
  final response = await http.get(Uri.parse(muralsApiUrl));

  if (response.statusCode != 200) {
    throw Exception('Échec du chargement des fresques.');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final results = decoded['results'] as List;

  final murals =
  results.whereType<Map<String, dynamic>>().map(Mural.fromJson).toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  return murals;
}