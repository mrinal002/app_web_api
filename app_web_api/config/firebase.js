const admin = require('firebase-admin');
const path = require('path');

try {
  // Check if Firebase is already initialized
  if (!admin.apps.length) {
    const serviceAccount = require('../firebase-service-account.json');
    
    if (!serviceAccount.project_id || !serviceAccount.private_key || !serviceAccount.client_email) {
      throw new Error('Invalid service account configuration');
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: serviceAccount.project_id,
        clientEmail: serviceAccount.client_email,
        privateKey: serviceAccount.private_key.replace(/\\n/g, '\n')
      })
    });

    console.log('Firebase Admin SDK initialized successfully');
  }
} catch (error) {
  console.error('Firebase Admin SDK initialization error:', error);
  throw error; // Rethrow to handle it in the application
}

module.exports = admin;
