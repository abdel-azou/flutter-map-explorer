import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/mural.dart';

class MuralList extends StatelessWidget {
  const MuralList({super.key, required this.murals});

  final List<Mural> murals;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: murals.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final mural = murals[index];
        return ListTile(
          title: Text(mural.name),
          subtitle: Text('${mural.artist} • ${mural.address}'),
          onTap: () => context.go('/mural', extra: mural),
        );
      },
    );
  }
}