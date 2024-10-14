// notificationService.js

const admin = require('./firebaseAdmin'); // import the Firebase Admin instance

/**
 * Send a notification to a specific device using its FCM token.
 *
 * @param {string} fcmToken - The recipient's FCM token.
 * @param {string} title - The notification title.
 * @param {string} message - The notification message.
 */
async function sendNotification(fcmToken, title, message) {
  try {
    const messagePayload = {
      notification: {
        title: title,
        body: message,
      },
      token: fcmToken, // The FCM token of the recipient device
    };

    // Send the notification
    const response = await admin.messaging().send(messagePayload);
    console.log('Notification sent successfully:', response);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

module.exports = { sendNotification };
