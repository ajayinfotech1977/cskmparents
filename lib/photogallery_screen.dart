import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

Future<List<Album>> fetchAlbums() async {
  final response = await http.get(Uri.parse(
      'https://www.cskm.com/schoolexpert/cskmparents/photogallery.php'));

  if (response.statusCode == 200) {
    //print(response.body);
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Album.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class Album {
  final int sno;
  final String name;
  final String date;
  final String link;

  Album(
      {required this.sno,
      required this.name,
      required this.date,
      required this.link});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      sno: json['sno'],
      name: json['name'],
      date: json['date'],
      link: json['link'],
    );
  }
}

class PhotoGalleryPage extends StatefulWidget {
  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  late Future<List<Album>> futureAlbums;

  @override
  void initState() {
    super.initState();
    futureAlbums = fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),
      body: FutureBuilder<List<Album>>(
        future: futureAlbums,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Album> albums = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple
                  ], // Customize the colors
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ListView.builder(
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  Album album = albums[index];
                  return AlbumCard(album: album);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final Album album;

  AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          title: Text(
            album.name,
            style: TextStyle(
              fontSize: 18,
              // Text color
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            album.date,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          onTap: () {
            _openLink(album.link);
          },
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    // code to open url in mobile browser
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
