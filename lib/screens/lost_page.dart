import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found/screens/aquireDetailsScreen.dart';
import 'package:lost_and_found/screens/auth_screen.dart';
import 'package:lost_and_found/screens/complete_details_screen.dart';

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  TextEditingController searchTextEditingController = TextEditingController();

  final List<String> categories = ['All', 'Stationary', 'Electronics', 'ID Card'];
  String selectedCategory = 'All';
  final Stream<QuerySnapshot> _stream=FirebaseFirestore.instance.collection("lost").snapshots();

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
          backgroundColor: Colors.white,
          title: const Text(
            'Lost Items',
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
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
                    selectedColor: Color(0xFF3E5974),
                    backgroundColor: Colors.grey.shade200,
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
                  builder: (context,snapshot){
                    if(!snapshot.hasData){
                      return const Center(child: CircularProgressIndicator(color: Colors.tealAccent,));
                    }

                    final searchQuery = searchTextEditingController.text.toLowerCase();
                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final category = data['category']?.toLowerCase() ?? '';
                      final matchesCategory = selectedCategory == 'All' || category == selectedCategory.toLowerCase();
                      final title = data["title"]?.toLowerCase() ?? '';
                      return title.contains(searchQuery) && matchesCategory;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text('No items found', style: TextStyle(color: Colors.black)),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 10),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final document = filteredDocs[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          color: Colors.grey.shade400,
                          shadowColor: Colors.grey.shade50,
                          child: InkWell(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CompleteDetailsScreen(document: document,)));
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    document["title"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20,color: Color(0xFF3E5974)),
                                  ),
                                  const SizedBox(height: 5,),
                                  Expanded(
                                    child: Text(
                                      document["description"],
                                      maxLines: 3,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(fontSize: 18,color: Color(0xFF6E6E6E)),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("${document["date"]}, ${document["time"]}",style: const TextStyle(fontSize: 15,color: Color(0xFF3E5974)),),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ),
                        );
                      },
                    );
                  }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF3E5974),
        elevation: 4,
        onPressed: () {
          // Navigate to Add New Found Item Page
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AcquireDetailsScreen(isFoundPage: false,)));
        },
        icon: const Icon(Icons.add, color: Colors.white,size: 20,),
        label: const Text('Add Item',style: TextStyle(color: Colors.white,fontSize: 15),),
      ),
    );
  }
}
