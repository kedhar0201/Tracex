import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/screens/aquireDetailsScreen.dart';
import 'package:lost_and_found/screens/auth_screen.dart';
import 'package:lost_and_found/screens/chat_screen.dart';
import 'package:lost_and_found/screens/complete_details_screen.dart';
import 'package:transparent_image/transparent_image.dart';

class FoundPage extends StatefulWidget {
  const FoundPage({super.key});

  @override
  State<FoundPage> createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  TextEditingController searchTextEditingController = TextEditingController();

  final List<String> categories = ['All', 'Stationary', 'Electronics', 'ID Card'];
  String selectedCategory = 'All';
  final Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
      .collection("found")
      .where("reportedBy", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
    searchTextEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: const Text(
          'Found Items',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchTextEditingController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search for items...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3E5974)),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF3E5974),
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No items found',
                          style: TextStyle(color: Colors.black54)),
                    );
                  }

                  final searchQuery = searchTextEditingController.text.toLowerCase();
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final category = data['category']?.toLowerCase() ?? '';
                    final matchesCategory = selectedCategory == 'All' ||
                        category == selectedCategory.toLowerCase();
                    final title = data["title"]?.toLowerCase() ?? '';
                    return title.contains(searchQuery) && matchesCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text('No items found',
                          style: TextStyle(color: Colors.black54)),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final document =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        shadowColor: Colors.grey.shade50,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    CompleteDetailsScreen(document: document)));
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FadeInImage(
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: NetworkImage(document["image"]),
                                  fit: BoxFit.cover,
                                  height: 250,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(15)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white70,
                                        Colors.white24,
                                        Colors.white
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document["title"],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('matches')
                                            .where('foundItemId',
                                                isEqualTo: document['docId'])
                                            .limit(1)
                                            .get(),
                                        builder: (context, matchSnapshot) {
                                          if (matchSnapshot.hasData &&
                                              matchSnapshot.data!.docs.isNotEmpty) {
                                            final matchData = matchSnapshot
                                                    .data!.docs.first
                                                    .data()
                                                as Map<String, dynamic>;
                                            final matchId =
                                                matchSnapshot.data!.docs.first.id;
                                            return ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                      matchId: matchId,
                                                      lostByUid: matchData['lostByUid'],
                                                      foundByUid: matchData['foundByUid'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF3E5974),
                                              ),
                                              icon: const Icon(Icons.chat,
                                                  color: Colors.white, size: 16),
                                              label: const Text('Chat with owner',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                    Icons.date_range_outlined,
                                                    size: 20,
                                                    color: Color(0xFF3E5974)),
                                                const SizedBox(width: 5),
                                                Text(document["date"],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.access_time,
                                                    size: 20,
                                                    color: Color(0xFF3E5974)),
                                                const SizedBox(width: 5),
                                                Text(document["time"],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 20,
                                                    color: Color(0xFF3E5974)),
                                                const SizedBox(width: 5),
                                                Text(document["place"],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: const Color(0xFF3E5974),
        elevation: 4,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  const AcquireDetailsScreen(isFoundPage: true)));
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}