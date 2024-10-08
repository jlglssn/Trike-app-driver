import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import TaskSnapshot for the stream

class ProgressBar extends StatelessWidget {
  final UploadTask? uploadTask; // This allows passing the uploadTask from the main file

  const ProgressBar({Key? key, this.uploadTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          final progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 13,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color.fromARGB(255, 204, 245, 215),
                    color: const Color.fromARGB(150, 75, 201, 104),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${(100 * progress).round()}%',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(height: 50);
        }
      },
    );
  }
}
