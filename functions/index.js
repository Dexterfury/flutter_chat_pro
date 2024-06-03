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

    // friends uids
    const beforeFriendsUids = beforeData.friendsUIDs || [];
    const afterFriendsUids = afterData.friendsUIDs || [];

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
    // check if friend request is added
    if (beforeFriendsUids.length < afterFriendsUids.length) {
      const newFriendId = afterFriendsUids[afterFriendsUids.length -1];

      // get user data from firestore
      const newFriendDoc = await db.collection("users").doc(newFriendId).get();
      // check if user exists in firestore
      if (!newFriendDoc.exists) {
        console.log(`User ${newFriendId} does not exist`);
        return null;
      }
      const newFriendData = newFriendDoc.data();
      console.log("User exits");

      const message = {
        data: {
          notificationType: "requestReplyNotification",
        },
        token: newFriendData.token,

        notification: {
          title: "Friend Request Accepted",
          body: `You are now friends with ${afterData.name}`,
          image: afterData.image,
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
        console.log(`Request approvall sent to `, newFriendData.name);
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

     // fech default image url if senderImage is empty
     let senderImage = messageData.senderImage;
     if(!senderImage) {
      // get the default image url from storage
      //const defaultImageUrl = await storageRef.child('defaultImages/user_icon.png').getDownloadURL();
      const defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterchatpro-7ee3f.appspot.com/o/defaultImages%2Fuser_icon.png?alt=media&token=6359ee38-6230-466f-b8d7-080347cea1dc';
      senderImage = defaultImageUrl;
     }

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
        image: senderImage,
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

  // request to join Group Chat Notification
   exports.sendJoinGroupRequestNotification = functions.firestore
   .document("groups/{groupId}")
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // check the before and after the awaitingApprovalUIDs array
      const beforeWaitingApprovalUIDs = beforeData.awaitingApprovalUIDs || [];
      const AfterWaitingApprovalUIDs = afterData.awaitingApprovalUIDs || [];

      // check the before and after the members array
      const beforeMembers = beforeData.membersUIDs || [];
      const AfterMembers = afterData.membersUIDs || [];

      // check if the user is in the before array and not in after array
      if(beforeWaitingApprovalUIDs.length < AfterWaitingApprovalUIDs.length) {
        const newMemberId = AfterWaitingApprovalUIDs[AfterWaitingApprovalUIDs.length - 1];

        // get user data from firestore
      const newMemberDoc = await db.collection("users").doc(newMemberId).get();
      // check if user exists in firestore
      if (!newMemberDoc.exists) {
        console.log(`User ${newMemberId} does not exist`);
        return null;
      }
      const newMemberData = newMemberDoc.data();

      const groupId = context.params.groupId;
      const groupName = afterData.groupName;
      // fech default image url if senderImage is empty
     let newMemberImage = newMemberData.image;
     if(!newMemberImage) {
      // get the default image url from storage
      //const defaultImageUrl = await storageRef.child('defaultImages/user_icon.png').getDownloadURL();
      const defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterchatpro-7ee3f.appspot.com/o/defaultImages%2Fuser_icon.png?alt=media&token=6359ee38-6230-466f-b8d7-080347cea1dc';
      newMemberImage = defaultImageUrl;
     }

      // get admins tokens
      const adminTokens = await getGroupTokens(groupId, true, null);

      if(!adminTokens.length) {
        return null;
      }

      const requestMessage = `New member request to join "${groupName}" group`;

      const message = {
        data: {
          notificationType: "groupRequestNotification",
          groupId: groupId,
        },
        tokens: adminTokens,
  
        notification: {
          title: "New member request",
          body: requestMessage,
          image: newMemberImage,
        },
        android: {
          notification: {
            channel_id: "low_importance_channel",
        },
      },
         
      };

      // send notification to all admins
      await admin.messaging().sendEachForMulticast(message).catch((error) => {
        console.log('Error sending multicast message: ', error);
        return null;
      
      }).finally(() => {
        console.log('Successfully sent multicast message');
      });

      }

      // check if new member has joined the group
      if(beforeMembers.length < AfterMembers.length) {
        const newMemberUID = AfterMembers[AfterMembers.length - 1];

        // get user data from firestore
      const newMemberDocData = await db.collection("users").doc(newMemberUID).get();
      // check if user exists in firestore
      if (!newMemberDocData.exists) {
        console.log(`User ${newMemberUID} does not exist`);
        return null;
      }
      const newGroupMemberData = newMemberDocData.data();

      
      const groupName = afterData.groupName; 
      const userToken = newGroupMemberData.token;
      // fech default image url if senderImage is empty
     let groupImage = afterData.groupImage;
     if(!groupImage) {
      // get the default image url from storage
      //const defaultImageUrl = await storageRef.child('defaultImages/user_icon.png').getDownloadURL();
      const defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterchatpro-7ee3f.appspot.com/o/defaultImages%2Fuser_icon.png?alt=media&token=6359ee38-6230-466f-b8d7-080347cea1dc';
      groupImage = defaultImageUrl;
     }

      if(!userToken) {
        return null;
      }

      const requestMessage = `You are now a member of "${groupName}"`;

      const message = {
        data: {
          notificationType: "groupChatNotification",
          groupModel: JSON.stringify(afterData),
        },
        token: userToken,
  
        notification: {
          title: "Request approved",
          body: requestMessage,
          image: groupImage,
        },
        android: {
          notification: {
            channel_id: "low_importance_channel",
        },
      },
         
      };

      // send notification to all admins
      await admin.messaging().send(message).catch((error) => {
        console.log('Error sending multicast message: ', error);
        return null;
      
      }).finally(() => {
        console.log('Successfully sent multicast message');
      });

      }
      
      return null;
    });

    // group chat notification
    exports.groupChatNotification = functions.firestore
    .document('groups/{groupId}/messages/{messageId}')
    .onCreate( async (snapshot, context) => {
      const messageData = snapshot.data();
      const senderId = messageData.senderUID;
      const senderName = messageData.senderName;
      const groupId = context.params.groupId;
      

      const membersTokens = await getGroupTokens(groupId, false, senderId);

      if(membersTokens.length === 0) {
        return null;
       }

       // fech default image url if senderImage is empty
     const groupData = await db.collection('groups').doc(groupId).get();
     const groupName = groupData.groupName;
     let groupImage = groupData.data().groupImage;
     if(!groupImage) {
      // get the default image url from storage
      //const defaultImageUrl = await storageRef.child('defaultImages/user_icon.png').getDownloadURL();
      const defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterchatpro-7ee3f.appspot.com/o/defaultImages%2Fuser_icon.png?alt=media&token=6359ee38-6230-466f-b8d7-080347cea1dc';
      groupImage = defaultImageUrl;
     }

     const message = {
      data: {
        notificationType: "groupChatNotification",
        groupModel: JSON.stringify(groupData),
      },
      tokens: membersTokens,

      notification: {
        title: `${senderName} in ${groupName}`,
        body: getMessage(messageData),
        image: groupImage,
      },
      android: {
        notification: {
          channel_id: "high_importance_channel",
      },
    },
       
    };

    return admin.messaging().sendEachForMulticast(message).catch((error) => {
      console.log("Error sending message", error);
      return null;
    }).finally(() => {
      log("Message sent to ", groupId);
      return null;
    });




    });

    /**
     * Get the admins tokens of a group
     * 
     * @param {String} groupId - the ID of the group to retrieve the admins tokens
     * @param {Boolean} admin - whether to retrieve the admins tokens or members tokens
     * @param {String} senderId - the ID of the sender to exclude from the tokens list
     * @returns {Array} - the tokens of all admins in the group
     */

    async function getGroupTokens(groupId, admin, senderId) {
      const field = admin ? "adminUIDs" : "membersUIDs";

      const userIds = await db
       .collection("groups")
       .doc(groupId)
       .get().then((snapshot) => snapshot.data()[field]);

    if (!userIds || !userIds.length) {
      return [];
    }

    const tokensSnapshot = await db.collection("users").where("uid", "in", userIds).get();
    let tokens = tokensSnapshot.docs.map((doc) => doc.data().token).filter(Boolean);

    if(!admin && senderId) {
      tokens = tokens.filter((token, index) => tokensSnapshot.docs[index].data().uid!== senderId);
    }

    return tokens;
    }


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


