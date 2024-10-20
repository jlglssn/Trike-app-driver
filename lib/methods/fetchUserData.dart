import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'user_service.dart';

class fetchUserData{
  static Future<String> fetchUserName() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['name'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<bool> fetchIsAdmin() async {
    try {
      final userId = await UserService.instance.getCurrentUserId();
      if (userId == null) {
        print("Error: User ID is null");
        return false;
      }

      final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData.containsKey('isAdmin')) {
          return userData['isAdmin'] ?? false;
        } else {
          print("Error: 'isAdmin' field not found");
          return false;
        }
      } else {
        print("Error: Snapshot does not exist for user $userId");
        return false;
      }
    } catch (e) {
      print("Error fetching admin status: $e");
      return false;
    }
  }

  static Future<String> fetchUserEmail() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['email'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String?> getDriverToken(String userId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    try {
      // Reference to the specific user's data
      DatabaseReference userRef = databaseRef.child('drivers/$userId/token');

      // Retrieve the token data
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        // Return the token value if it exists
        return snapshot.value as String?;
      } else {
        print('User token does not exist.');
        return null;
      }
    } catch (e) {
      print('Error retrieving user token: $e');
      return null;
    }
  }

  static Future<String?> getAdminToken() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    try {
      // Reference to the 'drivers' node
      DatabaseReference driversRef = databaseRef.child('drivers');

      // Retrieve all the drivers
      DataSnapshot snapshot = await driversRef.get();

      if (snapshot.exists) {
        // Loop through each driver in the 'drivers' node
        for (var child in snapshot.children) {
          Map<String, dynamic> driverData = Map<String, dynamic>.from(child.value as Map);

          // Check if the user is an admin
          if (driverData['isAdmin'] == true) {
            // Return the token of the admin user
            return driverData['token'] as String?;
          }
        }

        print('No admin user found.');
        return null;
      } else {
        print('Drivers node does not exist.');
        return null;
      }
    } catch (e) {
      print('Error retrieving admin token: $e');
      return null;
    }
  }

  static Future<String> fetchUserNumber() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['phone'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String?> fetchAdminUID() async {
    // Reference to the users node in your Firebase Realtime Database
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('drivers');

    try {
      // Fetch data from the users node
      DatabaseEvent event = await usersRef.once();

      // Check if data exists
      if (event.snapshot.value != null) {
        // Convert the snapshot to a Map
        Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;

        // Loop through each user entry
        for (var entry in users.entries) {
          var key = entry.key;  // This is the UID
          var value = entry.value;  // This is the user data (e.g., isAdmin, name, etc.)

          // Check if the user has 'isAdmin' set to true
          if (value['isAdmin'] == true) {
            return key;  // Return the UID of the admin
          }
        }
      }
    } catch (error) {
      print('Error fetching admin UID: $error');
    }

    return null;  // Return null if no admin found
  }


  static Future<String> fetchUserPassword() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['password'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchBodyNumber() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['bodyNumber'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchPlateNumber() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['plateNumber'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchPic() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('drivers/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['picUrl'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }
}