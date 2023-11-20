import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cskmparents/database/database_helper.dart';

Future<List<Album>> fetchAlbums() async {
  // call DatabaseHelper class to get data from table
  final dbHelper = DatabaseHelper();
  // initialize database

  final _db = await dbHelper.initDatabase();
  await dbHelper.createTablePhotoGallery(_db, 1);

  //delete all data from table
  //await dbHelper.deleteAllDataFromParentsNotifications();
  // sync data from server
  await dbHelper.syncDataToPhotoGallery();
  final data = await dbHelper.getDataFromPhotoGallery();

  // convert data to List<Album>
  List<Album> _albums = List.generate(data.length, (i) {
    return Album.fromMap(data[i]);
  });

  dbHelper.close();

  return _albums;
}

class Album {
  final int photoId;
  final String heading;
  final String photoDt;
  final String link;

  Album({
    required this.photoId,
    required this.heading,
    required this.photoDt,
    required this.link,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      photoId: map['photoId'],
      heading: map['heading'],
      photoDt: map['photoDt'],
      link: map['link'],
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
      padding: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Text(
            album.heading,
            style: TextStyle(
              fontSize: 16,
              // Text color
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            album.photoDt,
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
