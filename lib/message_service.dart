import 'db_helper.dart';
import 'message.dart';

//Handles all database operations related to message
//Use databasehelper to perform CRUD
class MessageService {
  //create an instance of the database helper
  final dbHelper = DatabaseHelper.instance;

  //adds a new message to the message table
  //returns ID of the insert row
  Future<int> addMessage(Message message) async {
    final db = await dbHelper.database;
    return await db.insert('messages', message.toMap());
  }

  //retrieves all messages from the messages table
  //returns a list of message objects
  Future<List<Message>> getMessages() async {
    final db = await dbHelper.database;
    final result = await db.query('messages');
    return result.map((map) => Message.fromMap(map)).toList();
  }

  //deletes a message from the message table by its id
  //returns the number of rows deleted, should be 1 if successful
  Future<int> deleteMessage(int id) async {
    final db = await dbHelper.database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  //updates an existing message in the messages table
  //finds the message by its id and updates the row
  Future<void> updateMessage(Message message) async {
    final db = await dbHelper.database;
    await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }


}

