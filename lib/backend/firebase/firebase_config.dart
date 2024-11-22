import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey:"",
            authDomain: "vivafit-personal-app-bdsvxs.firebaseapp.com",
            projectId: "vivafit-personal-app-bdsvxs",
            storageBucket: "vivafit-personal-app-bdsvxs.appspot.com",
            messagingSenderId: "747728009234",
            appId: "1:747728009234:android:5f60cafb6b56af559e40cb"));
  } else {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD0tOTdCLAcXYc7IVPg8tMTYBq4Vj5cDY8",
            authDomain: "vivafit-personal-app-bdsvxs.firebaseapp.com",
            projectId: "vivafit-personal-app-bdsvxs",
            storageBucket: "vivafit-personal-app-bdsvxs.appspot.com",
            messagingSenderId: "747728009234",
            appId: "1:747728009234:android:5f60cafb6b56af559e40cb"));
  }
}
