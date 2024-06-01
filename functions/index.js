/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { log } = require("firebase-functions/logger");
admin.initializeApp();

const db = admin.firestore();

// send friend request notification
exports.sendFriendRequestNotification = functions.firestore.document(
  "users/{userId}").onUpdate( async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // friend request data
    const beforeFriendRequest = beforeData.friendRequestsUIDs || [];
    const afterFriendRequest = afterData.friendRequestsUIDs || [];
    // check if friend request is added
    if (beforeFriendRequest.length < afterFriendRequest.length) {
      const newFriendRequestId = afterFriendRequest[afterFriendRequest.length -1];

      // get user data from firestore
      const friendDoc = await db.collection("users").doc(newFriendRequestId).get();
      // check if user exists in firestore
      if (!friendDoc.exists) {
        console.log(`User ${newFriendRequestId} does not exist`);
        return null;
      }
      const friendData = friendDoc.data();
      console.log("User exits");

      const message = {
        data: {
          notificationType: "friendRequestNotification",
        },
        token: afterData.token,

        notification: {
          title: "New Friend Request",
          body: `${friendData.name} sent you a friend request`,
          image: friendData.image,
        },
        android: {
          notification: {
            channel_id: "low_importance_channel",
        },
      },
         
      };
      return admin.messaging().send(message).catch((error) => {
        console.log("Error sending message:", error);
        return null;
      }).finally(() => {
        console.log(`Friend request notification sent to ${afterData.token}`);
        return null;
      });
    }
    return null;
  });

  // send chat notification
  exports.sendChatNotification = functions.firestore
  .document("users/{userId}/chats/{friendId}/messages/{message}")
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();
    const userId = context.params.userId;
    const friendId = context.params.friendId;
    // check if sender is the same as the document's userId
    const isSelfMessage = messageData.senderUID == context.params.userId;

    // compare the userId with the friend's id lexographically
    // to send the notification only once for each chat
    if(userId > friendId){
      console.log(`Skipping notification`);
      return null;
     } 

    // get the repinder's id
    const recipientId = isSelfMessage? messageData.contactUID : context.params.userId;

    // get the recipient's data and token
     const recipientDoc = await db.collection('users').doc(recipientId).get();
     // check if user exists
     if(!recipientDoc.exists) {
      console.log(`User ${recipientId} does not exist`);
      return null;
     }

     const recipientData = recipientDoc.data();

     const message = {
      data: {
        notificationType: "chatNotification",
        contactUID: messageData.senderUID,
        contactName: messageData.senderName,
        contactImage: messageData.senderImage,
      },
      token: recipientData.token,

      notification: {
        title: messageData.senderName,
        body: getMessage(messageData),
        image: messageData.senderUID,
      },
      android: {
        notification: {
          channel_id: "high_importance_channel",
      },
    },
       
    };

    return admin.messaging().send(message).catch((error) => {
      console.log("Error sending message", error);
      return null;
    }).finally(() => {
      log("Message sent to ", recipientData.uid);
      return null;
    });
  });

  // function to get the message to display
  function getMessage(messageData) {
    // get the message type
    const messageType = messageData.messageType;
    switch (messageType){
    case "text":
      return messageData.message;
    case "image":
      return "Image message";
    case "video":
        return "Video message";
    case "audio":
        return "Audio message";
    default:
        return "You have a new message";
  }
}


