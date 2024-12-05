class MessageModel {
  String id;
  String message;
  String timeSent;
  bool isMe;

  MessageModel({
    required this.id,
    required this.message,
    required this.timeSent,
    required this.isMe,
  });

  // dummy data list of 5 messages with uniue id (randon number randon bettween 1 to 1000), message, timeSent, isMe
  static List<MessageModel> dummyData = [
    MessageModel(
      id: '1',
      message: 'Hello, how are you?',
      timeSent: '12:00 PM',
      isMe: false,
    ),
    MessageModel(
      id: '2',
      message: 'I am fine, thank you.',
      timeSent: '1:30 PM',
      isMe: true,
    ),
    MessageModel(
      id: '3',
      message: 'What are you doing?',
      timeSent: '2:15 PM',
      isMe: false,
    ),
    MessageModel(
      id: '4',
      message: 'I am doing fine, thank you.',
      timeSent: '3:45 PM',
      isMe: true,
    ),
  ];
}
