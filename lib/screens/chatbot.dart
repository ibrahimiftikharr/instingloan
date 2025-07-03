import 'package:flutter/material.dart';
import 'package:theloanapp/services/dialogflow_service.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  final DialogflowService dialogflow = DialogflowService();
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    dialogflow.init().then((_) => setState(() => initialized = true));
  }

  void handleSubmitted(String text) async {
    _textController.clear();
    if (text.isEmpty || !initialized) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, name: "You", type: true));
    });

    final reply = await dialogflow.detectIntent('loanassistbot-kjln', '123456', text);
    setState(() {
      _messages.insert(0, ChatMessage(text: reply, name: "Bot", type: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: handleSubmitted,
                      decoration: InputDecoration.collapsed(
                          hintText: "Send a message"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Message bubble UI
class ChatMessage extends StatelessWidget {
  final String text;
  final String name;
  final bool type; // true if user, false if bot

  ChatMessage({
    required this.text,
    required this.name,
    required this.type,
  });


  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child: Text('B')),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(this.name, style: Theme.of(context).textTheme.titleMedium),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          child: Text(this.name[0], style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
