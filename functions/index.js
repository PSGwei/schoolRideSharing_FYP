const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.notifyCarpoolUpdate = functions.firestore
  .document('carpools/{carpoolId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Check if the status changed from false to true
    if (!previousValue.status && newValue.status) {
      const participants = newValue.participants;
      const tokens = [];

      // Collect all the tokens of the participants
      for (const userId of participants) {
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userToken = userDoc.data()?.token; // assuming the token field is named 'token'
        if (userToken) {
          tokens.push(userToken);
        }
      }

      // Notification message
      const payload = {
        notification: {
          title: 'Carpool Notification',
          body: 'Your kid(s) safely arrived to school!',
        },
      };

      // Send a message to each token.
      return admin.messaging().sendToDevice(tokens, payload)
        .then((response) => {
          // Response is a message ID string.
          console.log('Successfully sent message:', response);
          return null;
        })
        .catch((error) => {
          console.log('Error sending message:', error);
          throw new Error('Error sending message');
        });
    }

    return null;
  });