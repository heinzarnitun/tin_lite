//a model class that represents a message object
//it can include an optional id, some text, and an optional image path or url

class Message {
  final int? id; //optional id for the message
  final String text; //the main content of the messaage
  final String? image; //optional image path

  //constructor for creating message object
  //id and image are optional but text is required
  Message({this.id, required this.text, this.image});

  //converts a message obj into a map so it can be stored in database
  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'image': image};
  }
//creates a message obj from a map , retrieves from the database
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      image: map['image'],
    );
  }
}
