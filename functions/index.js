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
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase)

const db = admin.firestore();

exports.sendFriendRequestNotification = functions.firestore
.document('users/{userId}')
.onUpdate((change, context) => {
  const beforeData = change.before.data();
  const afterData = change.after.data();

  // friend request data
  const beforeFriendRequest = beforeData.friendRequests || [];
  const afterFriendRequest = afterData.friendRequests || [];

  if(beforeFriendRequest.length < afterFriendRequest.length){
    const newFriendRequestId = afterFriendRequest[afterFriendRequest.length - 1];

    // get the friend's data
     db.collection('users').doc(newFriendRequestId).get().then(friendDoc => {
      // check if document exist
       if(!friendDoc.exists){
        console.log("Document does not exist");
        return null;
       }
       const friendData = friendDoc.data();

       const message = {
        data: {
          notificationType: 'friendRequestNotification',
        },
        token: beforeData.token,

        notification: {
          android_channel_id:'high_importance_channel',
          title: 'Friend Request',
          body: `${friendData.name} sent you a friend request`,
          image: friendData.image,
        }

       }
        return admin.messaging().send(message);
     }).catch(error => {
       console.log("Error sending notification", error);
     })
  }
});

