import 'package:flutter/material.dart';
import 'package:tin_lite/twitter_service.dart';
import 'message_service.dart';
import 'message.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

//entry point
void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

//main screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
//state for home screen
class _HomeScreenState extends State<HomeScreen> {
  final MessageService _messageService = MessageService();
  final TwitterService _twitterService = TwitterService(
    consumerKey: Platform.environment['TWITTER_CONSUMER_KEY'] ?? 'atPHEDwtBojrATO1aJiognEdq',
    consumerSecret: Platform.environment['TWITTER_CONSUMER_SECRET'] ?? 'GCaQLNbrSDRKUEvAuibABCVFJapNMS4SfBJ7g5zue9SgW24r2D',
    accessToken: Platform.environment['TWITTER_ACCESS_TOKEN'] ?? '1908199544028094465-EKhbLylukO2DjTJYpniQ5LY0576rhX',
    accessTokenSecret: Platform.environment['TWITTER_ACCESS_TOKEN_SECRET'] ?? '7wo1YIT7AwWWSqj1C1NighpuJZe9lvBtljfEMiWIDa1X5',
  );

  //controllers and state variables
  final TextEditingController _searchController = TextEditingController();
  List<int> _selectedMessages = [];
  List<Message> _filteredMessages = [];
  bool _isSelectMode = false;
  bool _isUploading = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
//load messages from service
  Future<void> _loadMessages() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final messages = await _messageService.getMessages();
      setState(() {
        _filteredMessages = messages;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //post single message to twitter
  Future<bool> _postToTwitter(Message message, BuildContext context) async {
    try {
      await _twitterService.postTweet(
        message.text,
        imagePath: message.image,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully posted to Twitter: ${message.text.length > 20 ? message.text.substring(0, 20) + '...' : message.text}")),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post '${message.text}': ${e.toString()}")),
      );
      return false;
    }
  }

//delete selected messages
  void _deleteSelectedMessages() async {
    if (_selectedMessages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Deleting selected messages...';
    });

    try {
      for (var id in _selectedMessages) {
        await _messageService.deleteMessage(id);
      }
      await _loadMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deleted ${_selectedMessages.length} messages")),
      );
    } finally {
      setState(() {
        _selectedMessages.clear();
        _isSelectMode = false;
        _isUploading = false;
        _uploadStatus = '';
      });
    }
  }

  //share message using sharefiles
  void _shareMessage(Message message) async {
    try {
      if (message.image != null) {
        await Share.shareFiles(
          [message.image!],
          text: message.text,
        );
      } else {
        await Share.share(message.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to share: ${e.toString()}")),
      );
    }
  }

  //upload multiple selected messages to twitter
  void _uploadSelectedMessages(BuildContext context) async {
    if (_selectedMessages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Preparing to upload...';
    });

    try {
      final messages = await _messageService.getMessages();
      final selected = messages.where((m) => _selectedMessages.contains(m.id)).toList();

      int successCount = 0;
      int totalCount = selected.length;

      for (int i = 0; i < totalCount; i++) {
        final message = selected[i];
        setState(() {
          _uploadStatus = 'Posting ${i + 1}/$totalCount: ${message.text.length > 20 ? message.text.substring(0, 20) + '...' : message.text}';
        });

        final success = await _postToTwitter(message, context);
        if (success) successCount++;

        if (i < totalCount - 1) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully posted $successCount/$totalCount messages")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _selectedMessages.clear();
        _isSelectMode = false;
        _isUploading = false;
        _uploadStatus = '';
      });
    }
  }

  //filter messsages based on search
  void _searchMessages(String query) async {
    final List<Message> messages = await _messageService.getMessages();
    final List<Message> results = messages
        .where((message) => message.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredMessages = results;
    });
  }
//toggle selection mode
  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedMessages.clear();
    });
  }
//toggle selected state of message
  void _toggleMessageSelection(int id) {
    setState(() {
      if (_selectedMessages.contains(id)) {
        _selectedMessages.remove(id);
      } else {
        _selectedMessages.add(id);
      }
    });
  }
//navigate to add message screen
  Future<void> _navigateToAddMessage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditMessageScreen()),
    );
    await _loadMessages();
  }
//navigate to edit screen
  Future<void> _navigateToEditMessage(Message message) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMessageScreen(message: message),
      ),
    );
    await _loadMessages();
  }
//text for text display in listview
  String _getDisplayTitle(String text) {
    final newlineIndex = text.indexOf('\n');
    if (newlineIndex != -1) {
      return text.substring(0, newlineIndex);
    }
    return text.length > 50 ? text.substring(0, 50) + '...' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Lite', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF404136),
        actions: [
          if (_isSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.cloud_upload), color: Colors.white,
              tooltip: 'Upload selected',
              onPressed: _isUploading ? null : () => _uploadSelectedMessages(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete), color: Colors.white,
              tooltip: 'Delete selected',
              onPressed: _isUploading ? null : _deleteSelectedMessages,
            ),
          ],
          //toggle select mode button
          IconButton(
            icon: _isSelectMode
                ? const Icon(Icons.cancel)
                : const Icon(Icons.check_box),
            color: Colors.white,
            tooltip: _isSelectMode ? 'Cancel selection' : 'Select messages',
            onPressed: _isUploading ? null : _toggleSelectMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background.png'),
                  fit: BoxFit.cover,
                )),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search messages',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _searchMessages,
                ),
              ),
              Expanded(
                child: _filteredMessages.isNotEmpty || _searchController.text.isNotEmpty
                    ? _buildMessageList(_filteredMessages)
                    : FutureBuilder<List<Message>>(
                  future: _messageService.getMessages(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildMessageList(snapshot.data!);
                  },
                ),
              ),
            ],
          ),
         //upload process indicator
          if (_isUploading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(_uploadStatus, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
      //floating button to add message
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMessage,
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  //build message list items
  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSelected = _selectedMessages.contains(message.id);
        final displayTitle = _getDisplayTitle(message.text);

        return Card(
          color: isSelected ? Colors.blue[100] : null,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: message.image != null
                ? Image.file(
              File(message.image!),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.text_snippet),
            title: Text(
              displayTitle,
              style: message.text.contains('\n')
                  ? TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
            trailing: _isSelectMode
                ? Checkbox(
              value: isSelected,
              onChanged: (_isUploading ? null : (_) => _toggleMessageSelection(message.id!)),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Edit Message',
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _isUploading ? null : () => _navigateToEditMessage(message),
                  ),
                ),
                Tooltip(
                  message: 'Share Message',
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _isUploading ? null : () => _shareMessage(message),
                  ),
                ),
                Tooltip(
                  message: 'Post to Twitter',
                  child: IconButton(
                    icon: const Icon(Icons.upload),
                    onPressed: _isUploading
                        ? null
                        : () async {
                      setState(() {
                        _isUploading = true;
                        _uploadStatus = 'Posting to Twitter...';
                      });
                      try {
                        await _postToTwitter(message, context);
                      } finally {
                        setState(() {
                          _isUploading = false;
                          _uploadStatus = '';
                        });
                      }
                    },
                  ),
                ),
              ],

            ),
            onTap: _isSelectMode && !_isUploading
                ? () => _toggleMessageSelection(message.id!)
                : null,
            onLongPress: _isUploading
                ? null
                : () {
              setState(() {
                _isSelectMode = true;
                _toggleMessageSelection(message.id!);
              });
            },
          ),
        );
      },
    );
  }
}

class AddEditMessageScreen extends StatefulWidget {
  final Message? message;

  AddEditMessageScreen({this.message});

  @override
  _AddEditMessageScreenState createState() => _AddEditMessageScreenState();
}

class _AddEditMessageScreenState extends State<AddEditMessageScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _controller = TextEditingController();
  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.message != null) {
      _controller.text = widget.message!.text;
      _image = widget.message!.image != null ? File(widget.message!.image!) : null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    final pickedFile = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addOrUpdateMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      if (widget.message == null) {
        await _messageService.addMessage(Message(text: _controller.text, image: _image?.path));
      } else {
        await _messageService.updateMessage(Message(
          id: widget.message!.id,
          text: _controller.text,
          image: _image?.path ?? widget.message!.image,
        ));
      }
      Navigator.pop(context);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.message == null ? 'Add Message' : 'Edit Message', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF404136),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter your note',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: _isUploading ? null : () => _pickImage(fromCamera: false),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: _isUploading ? null : () => _pickImage(fromCamera: true),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      _image!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUploading ? null : _addOrUpdateMessage,
                  child: Text(widget.message == null ? 'Save' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}