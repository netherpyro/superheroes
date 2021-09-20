import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/server_image.dart';

class Superhero {
  final String name;
  final Biography biography;
  final ServerImage image;

  Superhero(this.name, this.biography, this.image);

  factory Superhero.fromJson(final Map<String, dynamic> json) => Superhero(
        json['name'],
        Biography.fromJson(json['biography']),
        ServerImage.fromJson(json['image']),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "biography": biography.toJson(),
        "image": image.toJson(),
      };
}
