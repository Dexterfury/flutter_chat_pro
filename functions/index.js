/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// send friend request notification
exports.sendFriendRequestNotification = functions.firestore.document(
    "users/{userId}").onUpdated( async (change, context) => {
  const beforeData = change.before.data();
  const afterData = change.after.data();
  const token = beforeData.token;

  console.log("beforeData", beforeData);
  console.log("afterData", afterData);
  console.log("token", token);

  // check friend requests data
  const beforeFriendRequests = beforeData.friendRequestsUIDs || [];
  const afterFriendRequests = afterData.friendRequestsUIDs || [];

  // check if friend request has been added
  if (beforeFriendRequests.length < afterFriendRequests.length) {
    // get the added friend request uid
    const newFriendRequestUid = afterFriendRequests[
        afterFriendRequests.length -1];

    console.log("frienRequestUID", newFriendRequestUid);

    const friendDoc = await db.collection(
        "users").doc(newFriendRequestUid).get();
    // chech if the user exists
    if (!friendDoc.exists) {
      context.logger.log(
          `Friend request ${newFriendRequestUid} does not exist`);
      return null;
    }

    const friendData = friendDoc.data();

    const message = {
      data: {
        notificationType: "friendRequestNotification",
      },
      token: token,

      notificationType: {
        android_channel_id: "high_importance_channel",
        title: "Friend Request",
        body: `${friendData.name} sent you a friend request`,
        imageUrl: friendData.image,
      },
    };
    // send notification to the user
    return admin.messaging().send(message).catch((error) => {
      console.log("Error sending message", error);
      return null;
    }).finally(() => {
      context.logger.log(`Friend request ${newFriendRequestUid} sent`);
    });
  }
  return null;
});
