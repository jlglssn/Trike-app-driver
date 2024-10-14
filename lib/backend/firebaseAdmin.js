// firebaseAdmin.js

const admin = require('firebase-admin');

// Path to your service account key file
const serviceAccount = require("C:/Capstone Project/Driver Application/driver_application/lib/backend/your-key-file.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://console.firebase.google.com/u/1/project/trike-toda-application/database/trike-toda-application-default-rtdb/data/~2F?fb_gclid=CjwKCAjw_ZC2BhAQEiwAXSgCln1vvbXBsbfa_MeeRbI6uQJBcS723YfGCF6qCqEuUcZlM9vRDrIk9BoC1EYQAvD_BwE", // Add your Firebase Realtime Database URL here
});

module.exports = admin;
