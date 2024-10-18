import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:driver_application/pages/about_page.dart';
import 'package:driver_application/pages/edit_profile.dart';
import '../methods/custom_page_route.dart';
import '../methods/fetchUserData.dart';
import '../methods/user_service.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 2;

  String? profileUrl = null; // Assume this value comes from user data (null means no profile picture)

  Future<void> logOut(BuildContext context) async {

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Please wait...")

    );
    // Introduce a small delay (e.g., 1 second) to ensure the dialog is displayed
    await Future.delayed(const Duration(seconds: 1));

    try {
      await UserService.instance.logout(context);
      // Navigate to login or splash screen
      Navigator.pushReplacementNamed(context, '/login'); //navigates to login screen
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show an error message
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData.fetchUserName();
    fetchUserData.fetchPic().then((url) {
      setState(() {
        profileUrl = url;
      });
    });// Fetch user's full name on widget load
  }

  // Function to show the log-out confirmation dialog
  void _showLogOutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Yes"),
            onPressed: () => logOut(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    double height = 15;
    FontWeight fontWeight = FontWeight.normal;
    Color containerColor = const Color.fromARGB(150, 242, 242, 242);
    Color iconColor = const Color.fromARGB(255, 75, 201, 104);
    Color iconBGColor = const Color.fromARGB(255, 204, 245, 215);

    bool _isSwitched = false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the left and right
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30), // Add spacing at the top
            Center(
                child: Column(
                    children:[
                      CircleAvatar(
                        radius: 65.0,
                        backgroundImage: profileUrl != null ? NetworkImage(profileUrl!) // Load the image from the network
                            : const AssetImage('assets/images/driver.png') as ImageProvider, // Fallback to a local image if URL is null or empty
                      ),
                    ]
                )
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<String>(
                future: fetchUserData.fetchUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching name'));
                  }
                  return Column(
                    children: [
                      Text(
                        snapshot.data ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 50),
                      // Account Settings Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor, // Background color for the list items
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(page: const EditProfilePage()), // Use your custom route
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          //Notification
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.notifications,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Notification',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle Allow Notifications tap
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          //Support
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.help,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Support',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle Allow Notifications tap
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.info,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'About',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(page: AboutPage()), // Use your custom route
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 200, // Adjust the width as needed
                              child: const Divider(
                                color: Color.fromARGB(255, 240, 240, 240), // Line color
                                thickness: 1, // Line thickness
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          //Log out
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 242, 209, 207),
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 18,
                                        color: Color.fromARGB(255, 200, 68, 65),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: const Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: Color.fromARGB(255, 200, 68, 65),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _showLogOutDialog();
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}