enum FriendViewType {
  friends,
  friendRequests,
  groupView,
  allUsers,
}

enum MessageEnum {
  text,
  image,
  video,
  audio,
}

enum GroupType {
  private,
  public,
}

// extension convertMessageEnumToString on String
extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      default:
        return MessageEnum.text;
    }
  }
}
