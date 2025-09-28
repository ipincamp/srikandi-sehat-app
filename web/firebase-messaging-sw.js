// Import the necessary Firebase modules
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js"
);

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyBs8RCsbQy9dqcwsVKG4k8NPWiR8NHk_mY",
  appId: "1:413117789548:web:4168999aea2f0bb2c16f49",
  messagingSenderId: "413117789548",
  projectId: "srikandi-sehat-app",
  authDomain: "srikandi-sehat-app.firebaseapp.com",
  storageBucket: "srikandi-sehat-app.firebasestorage.app",
  measurementId: "G-J8TWBH2P10",
});

const messaging = firebase.messaging();

// Optional: Add background message handler
messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload
  );
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/firebase-logo.png",
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
