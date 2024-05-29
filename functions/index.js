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
            channel_id: "high_importance_channel",
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

