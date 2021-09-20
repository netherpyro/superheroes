import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo info;
  final VoidCallback onTap;

  const SuperheroCard({
    Key? key,
    required this.info,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 70,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: SuperheroesColors.indigo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CachedNetworkImage(imageUrl: info.imageUrl, height: 70, width: 70, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      info.realName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
