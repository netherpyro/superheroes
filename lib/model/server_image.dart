class ServerImage {
  final String url;

  ServerImage(this.url);

  factory ServerImage.fromJson(final Map<String, dynamic> json) =>
      ServerImage(json['url']);

  Map<String, dynamic> toJson() => {"url": url};
}