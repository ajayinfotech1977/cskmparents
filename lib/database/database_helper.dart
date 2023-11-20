import 'dart:async';
import 'dart:convert';
import 'package:cskmparents/app_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static late Database _database;

  DatabaseHelper.internal();

  Future<Database> get database async {
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cskmparents.db');

    _database = await openDatabase(path, version: 1);

    return _database;
  }

  Future<void> createTableParentsNotifications(
    Database db,
    int version,
  ) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'parentsNotifications'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
      CREATE TABLE parentsNotifications (
        id INTEGER PRIMARY KEY,
        adm_no TEXT,
        notification TEXT,
        notificationDate TEXT,
        notificationStatus TEXT
      )
    ''');
    }
  }

  //fetch data in json format from server using http package and store it in PendingTasks table
  Future<void> syncDataToParentsNotifications() async {
    final db = await database;
    // fetch the max(id) from parentsNotifications table
    final maxId = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT MAX(id) FROM parentsNotifications where adm_no = ?',
        [AppConfig.globaladmNo]));

    // if maxId is null, then set it to 0
    final maxIdNotNull = maxId == null ? 0 : maxId;

    final dataFromServer =
        await fetchParentsNotificationsDataFromServer(maxIdNotNull);
    //print(dataFromServer);
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to PendingTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO parentsNotifications(id, adm_no, notification, notificationDate, notificationStatus) VALUES(?, ?, ?, ?, ?)',
            [
              data['id'],
              data['adm_no'],
              data['notification'],
              data['notificationDate'],
              data['notificationStatus'],
            ]);
      }
      await batch.commit();
      //print('Data synced to parentsNotifications table');
    });
  }

  Future<List<dynamic>> fetchParentsNotificationsDataFromServer(maxId) async {
    var response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmparents/sync_notifications.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'adm_no': AppConfig.globaladmNo,
        'lastid': maxId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final data2 = data['notifications'];
      // print the datatype of data2
      //print(data2.runtimeType);
      //print(data2);
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  //fetch data from PendingTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromParentsNotifications() async {
    final db = await database;
    return await db.query(
      'parentsNotifications',
      where: 'adm_no = ?',
      whereArgs: [AppConfig.globaladmNo],
      //whereArgs: [null],
      orderBy: 'id DESC',
    );
  }

  // update notification status to R in the database
  Future<void> updateNotificationStatusToR() async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE parentsNotifications SET notificationStatus = ? WHERE adm_no = ?',
        ['R', AppConfig.globaladmNo]);
  }

  // delete all data from parentsNotifications table
  Future<void> deleteAllDataFromParentsNotifications() async {
    final db = await database;
    await db.rawDelete('DELETE FROM parentsNotifications');
  }

  Future<void> createTablePhotoGallery(
    Database db,
    int version,
  ) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'photogallery'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
        CREATE TABLE photogallery (
          photoId INTEGER PRIMARY KEY,
          heading TEXT,
          photoDt TEXT,
          link TEXT,
          sno INTEGER
        )
      ''');
    }
  }

  Future<void> syncDataToPhotoGallery() async {
    final db = await database;

    // fetch max(photoId) from photogallery table
    final maxPhotoId = Sqflite.firstIntValue(
        await db.rawQuery('SELECT MAX(photoId) FROM photogallery'));
    // if maxPhotoId is null, then set it to 0 in maxPhotoIdNotNull
    final maxPhotoIdNotNull = maxPhotoId == null ? 0 : maxPhotoId;

    final dataFromServer =
        await fetchPhotoGalleryDataFromServer(maxPhotoIdNotNull);

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        batch.rawInsert(
          'INSERT OR IGNORE INTO photogallery(photoId, heading, photoDt, link, sno) VALUES(?, ?, ?, ?, ?)',
          [
            data['photoId'],
            data['heading'],
            data['photoDt'],
            data['link'],
            data['sno'],
          ],
        );
      }
      await batch.commit();
    });
  }

  Future<List<dynamic>> fetchPhotoGalleryDataFromServer(maxPhotoId) async {
    var response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmparents/sync_photogallery.php'),
      body: {
        'lastPhotoId': maxPhotoId.toString(),
        // Add other required parameters here
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("data=$data");
      final data2 = data['photogalleries'];
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromPhotoGallery() async {
    final db = await database;
    return await db.query('photogallery', orderBy: 'sno ASC');
  }

  // drop table photogallery
  // Future<void> dropTablePhotoGallery() async {
  //   final db = await database;
  //   await db.execute('DROP TABLE photogallery');
  // }

  Future<void> createTableMessages(Database db, int version) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'messages'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
        CREATE TABLE messages (
          msgId INTEGER PRIMARY KEY,
          msg TEXT,
          msgDate TEXT,
          userno TEXT,
          adm_no TEXT,
          msgType TEXT
        )
      ''');
    }
  }

  Future<void> syncDataToMessages() async {
    final db = await database;

    // fetch max(msgId) from messages table
    final maxMsgId = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MAX(msgId) FROM messages'),
    );
    // if maxMsgId is null, then set it to 0 in maxMsgIdNotNull
    final maxMsgIdNotNull = maxMsgId == null ? 0 : maxMsgId;

    final dataFromServer = await fetchMessagesDataFromServer(maxMsgIdNotNull);

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        batch.rawInsert(
          'INSERT OR IGNORE INTO messages(msgId, msg, msgDate, userno, adm_no, msgType) VALUES(?, ?, ?, ?, ?, ?)',
          [
            data['msgId'],
            data['msg'],
            data['msgDate'],
            data['userno'],
            data['adm_no'],
            data['msgType'],
          ],
        );
      }
      await batch.commit();
    });
  }

  Future<List<dynamic>> fetchMessagesDataFromServer(maxMsgId) async {
    var response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmparents/sync_messages.php'),
      body: {
        'lastMsgId': maxMsgId.toString(),
        'adm_no': AppConfig.globaladmNo,
        'secretKey': AppConfig.secreetKey,
        // Add other required parameters here
      },
    );

    if (response.statusCode == 200) {
      //print("response= ${response.body}");
      final data = json.decode(response.body);

      final data2 = data['messages'];
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromMessages(adm_no, userno) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'userno = ? AND adm_no = ?',
      whereArgs: [userno, adm_no],
      orderBy: 'msgId ASC',
    );
  }

  // close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
