class ChatModel {
  String id; // Unique identifier for the chat
  String name;
  String image;
  String latestMessage;
  String time;

  // constructor
  ChatModel({
    required this.id,
    required this.name,
    required this.image,
    required this.latestMessage,
    required this.time,
  });

  // dumy data list of 5 chats with uniue id (randon number randon bettween 1 to 1000), name, image, latest message, time,
  static List<ChatModel> dummyData = [
    ChatModel(
      id: '1',
      name: 'John Doe',
      image: 'https://picsum.photos/200/300',
      latestMessage: 'Hello, how are you?',
      time: '12:00 PM',
    ),
    ChatModel(
      id: '2',
      name: 'Jane Smith',
      image: 'https://picsum.photos/200/300',
      latestMessage: 'I am fine, thank you.',
      time: '1:30 PM',
    ),
    ChatModel(
      id: '3',
      name: 'Bob Johnson',
      image: 'https://picsum.photos/200/300',
      latestMessage: 'What are you doing?',
      time: '2:15 PM',
    ),
    ChatModel(
      id: '4',
      name: 'Alice Brown',
      image: 'https://picsum.photos/200/300',
      latestMessage: 'I ',
      time: '3:45 PM',
    ),
  ];
}
