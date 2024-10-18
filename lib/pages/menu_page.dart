import 'package:driver_application/methods/fetchUserData.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_application/methods/user_service.dart';
import 'package:driver_application/pages/profile_page.dart';

import '../widgets/loading_dialog.dart';
import 'about_page.dart'; // Ensure this path is correct

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? profileUrl;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    // Example: Fetching user data in initState
    fetchUserData.fetchPic().then((url) {
      setState(() {
        profileUrl = url;
      });
    });

    fetchUserData.fetchIsAdmin().then((isAdminResult) {
      setState(() {
        isAdmin = isAdminResult;
      });
    });
  }

  Future<void> logOut(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Logging out..."));
    await Future.delayed(const Duration(seconds: 1));

    try {
      await UserService.instance.logout(context);
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xffefefef),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture and name section
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xffefefef),
                    backgroundImage: profileUrl != null ? NetworkImage(profileUrl!) : null,
                    child: profileUrl == null
                        ? const Icon(Icons.person, size: 28, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: InkWell(
                                onTap: () => print('Name clicked'),
                                child: Text(
                                  snapshot.data ?? 'Unknown User',
                                  style: const TextStyle(color: Colors.black, fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                              },
                              child: const Text(
                                'My Account',
                                style: TextStyle(color: Colors.green),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Drawer items
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Column(
                children: [
                  if (isAdmin)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.black54),
                      title: const Text('Admin Panel', style: TextStyle(color: Colors.black87)),
                      onTap: () => print('Admin Panel'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: Colors.black54),
                    title: const Text('Notification', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('Notification'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule_rounded, color: Colors.black54),
                    title: const Text('My Rides', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('My Rides'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: Colors.black54),
                    title: const Text('Support', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('Support'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Colors.black54),
                    title: const Text('About', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Logout button
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.black54),
                      title: const Text('Log out', style: TextStyle(color: Colors.black87)),
                      onTap: () => logOut(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
