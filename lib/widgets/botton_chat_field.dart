import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/message_reply_preview.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.groupId,
  });

  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  File? finalFileImage;
  String filePath = '';

  bool isRecording = false;
  bool isShowSendButton = false;
  bool isSendingAudio = false;
  bool isShowEmojiPicker = false;

  // hide emoji container
  void hideEmojiContainer() {
    setState(() {
      isShowEmojiPicker = false;
    });
  }

  // show emoji container
  void showEmojiContainer() {
    setState(() {
      isShowEmojiPicker = true;
    });
  }

  // show keyboard
  void showKeyBoard() {
    _focusNode.requestFocus();
  }

  // hide keyboard
  void hideKeyNoard() {
    _focusNode.unfocus();
  }

  // toggle emoji and keyboard container
  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiPicker) {
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyNoard();
      showEmojiContainer();
    }
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // check microphone permission
  Future<bool> checkMicrophonePermission() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }

    return hasPermission;
  }

  // start recording audio
  void startRecording() async {
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord!.start(
        path: filePath,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  // stop recording audio
  void stopRecording() async {
    await _soundRecord!.stop();
    setState(() {
      isRecording = false;
      isSendingAudio = true;
    });
    // send audio message to firestore
    sendFileMessage(
      messageType: MessageEnum.audio,
    );
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  // select a video file from device
  void selectVideo() async {
    File? fileVideo = await pickVideo(
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    popContext();

    if (fileVideo != null) {
      filePath = fileVideo.path;
      // send video message to firestore
      sendFileMessage(
        messageType: MessageEnum.video,
      );
    }
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath) async {
    if (croppedFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        filePath = croppedFile.path;
        // send image message to firestore
        sendFileMessage(
          messageType: MessageEnum.image,
        );
      }
    }
  }

  // send image message to firestore
  void sendFileMessage({
    required MessageEnum messageType,
  }) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupId: widget.groupId,
      onSucess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
        setState(() {
          isSendingAudio = false;
        });
      },
      onError: (error) {
        setState(() {
          isSendingAudio = false;
        });
        showSnackBar(context, error);
      },
    );
  }

  // send text message to firestore
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupId: widget.groupId,
        onSucess: () {
          _textEditingController.clear();
          _focusNode.unfocus();
        },
        onError: (error) {
          showSnackBar(context, error);
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.groupId.isNotEmpty
        ? buildLoackedMessages()
        : buildBottomChatField();
  }

  Widget buildLoackedMessages() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    final groupProvider = context.read<GroupProvider>();
    // check if is admin
    final isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

    // chec if is member
    final isMember = groupProvider.groupModel.membersUIDs.contains(uid);

    // check is messages are locked
    final isLocked = groupProvider.groupModel.lockMessages;
    return isAdmin
        ? buildBottomChatField()
        : isMember
            ? buildisMember(isLocked)
            : SizedBox(
                height: 60,
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      // send request to join group
                      await groupProvider
                          .sendRequestToJoinGroup(
                        groupId: groupProvider.groupModel.groupId,
                        uid: uid,
                        groupName: groupProvider.groupModel.groupName,
                        groupImage: groupProvider.groupModel.groupImage,
                      )
                          .whenComplete(() {
                        showSnackBar(context, 'Request sent');
                      });
                      print('request to join group');
                    },
                    child: const Text(
                      'You are not a member of this group, \n click here to send request to join',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
  }

  buildisMember(bool isLocked) {
    return isLocked
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Messages are locked, only admins can send messages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : buildBottomChatField();
  }

  Consumer<ChatProvider> buildBottomChatField() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  )),
              child: Column(
                children: [
                  isMessageReply
                      ? MessageReplyPreview(
                          replyMessageModel: messageReply,
                        )
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      // emoji button
                      IconButton(
                        onPressed: toggleEmojiKeyboardContainer,
                        icon: Icon(isShowEmojiPicker
                            ? Icons.keyboard_alt
                            : Icons.emoji_emotions_outlined),
                      ),
                      IconButton(
                        onPressed: isSendingAudio
                            ? null
                            : () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // select image from camera
                                            ListTile(
                                              leading:
                                                  const Icon(Icons.camera_alt),
                                              title: const Text('Camera'),
                                              onTap: () {
                                                selectImage(true);
                                              },
                                            ),
                                            // select image from gallery
                                            ListTile(
                                              leading: const Icon(Icons.image),
                                              title: const Text('Gallery'),
                                              onTap: () {
                                                selectImage(false);
                                              },
                                            ),
                                            // select a video file from device
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.video_library),
                                              title: const Text('Video'),
                                              onTap: selectVideo,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                        icon: const Icon(Icons.attachment),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration.collapsed(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Type a message',
                          ),
                          onChanged: (value) {
                            setState(() {
                              isShowSendButton = value.isNotEmpty;
                            });
                          },
                          onTap: () {
                            hideEmojiContainer();
                          },
                        ),
                      ),
                      chatProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : GestureDetector(
                              onTap: isShowSendButton ? sendTextMessage : null,
                              onLongPress:
                                  isShowSendButton ? null : startRecording,
                              onLongPressUp: stopRecording,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.deepPurple,
                                ),
                                margin: const EdgeInsets.all(5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: isShowSendButton
                                      ? const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            // show emoji container
            isShowEmojiPicker
                ? SizedBox(
                    height: 280,
                    child: EmojiPicker(
                      onEmojiSelected: (category, Emoji emoji) {
                        _textEditingController.text =
                            _textEditingController.text + emoji.emoji;

                        if (!isShowSendButton) {
                          setState(() {
                            isShowSendButton = true;
                          });
                        }
                      },
                      onBackspacePressed: () {
                        _textEditingController.text = _textEditingController
                            .text.characters
                            .skipLast(1)
                            .toString();
                      },
                      // config: const Config(
                      //   columns: 7,
                      //   emojiSizeMax: 32.0,
                      //   verticalSpacing: 0,
                      //   horizontalSpacing: 0,
                      //   initCategory: Category.RECENT,
                      //   bgColor: Color(0xFFF2F2F2),
                      //   indicatorColor: Colors.blue,
                      //   iconColor: Colors.grey,
                      //   iconColorSelected: Colors.blue,
                      //   progressIndicatorColor: Colors.blue,
                      //   backspaceColor: Colors.blue,
                      //   showRecentsTab: true,
                      //   recentsLimit: 28,
                      //   noRecentsText: 'No Recents',
                      //   noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
                      //   tabIndicatorAnimDuration: kTabScrollDuration,
                      //   categoryIcons: const CategoryIcons(),
                      //   buttonMode: ButtonMode.MATERIAL,
                      // ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
