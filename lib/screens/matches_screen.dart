import 'package:flutter/material.dart';
import 'package:lost_and_found/services/match_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/screens/chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Matches',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: MatchService().getMyMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Color(0xFF3E5974)),
                  SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We will notify you when a match is found',
                    style: TextStyle(fontSize: 14, color: Colors.black38),
                  ),
                ],
              ),
            );
          }

          final matches = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          matchId: matches[index].id,
                          lostByUid: match['lostByUid'],
                          foundByUid: match['foundByUid'],
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF3E5974),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    'Match found for your lost item',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Confidence: ${(match['score'] * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}