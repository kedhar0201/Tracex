import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class CompleteDetailsScreen extends StatefulWidget {
  const CompleteDetailsScreen({super.key, required this.document});

  final Map<String, dynamic> document;

  @override
  State<CompleteDetailsScreen> createState() => _CompleteDetailsScreenState();
}

class _CompleteDetailsScreenState extends State<CompleteDetailsScreen> {

  Future<void> dialPhoneNumber(String number) async {
    final Uri url = Uri(scheme: 'tel', path: "+91 $number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch dialer for $number';
    }
  }

  Future<void> openWhatsAppChat(String phoneNumber) async {
    // Ensure the number has the correct format (without +, spaces, or dashes)
    String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    final Uri whatsappUrl = Uri.parse("https://wa.me/91$sanitizedNumber");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp chat for $phoneNumber';
    }
  }

  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(widget.document["image"]!=null)
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10,bottom: 10,top: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient:const LinearGradient(
                    colors: [Color(0xFF2C2C2C),Colors.white24],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  //color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20),top: Radius.circular(20)),
                  child: Image.network(
                    widget.document["image"],
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade300],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document["title"],
                          style: const TextStyle(
                            color: Color(0xFF3E5974),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.document["description"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  if(widget.document["place"]!=null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade300],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Found At",
                          style: TextStyle(
                            color: Color(0xFF3E5974),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "📍 ${widget.document["descriptionPlace"]}\n📅 ${widget.document["date"]} at 🕒 ${widget.document["time"]}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(widget.document["place"]!=null)
                  const SizedBox(height: 15,),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade300],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Contact Details",
                          style: TextStyle(
                            color: Color(0xFF3E5974),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 22, color: Color(0xFF3E5974)),
                            const SizedBox(width: 10),
                            Text(
                              widget.document["name"],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height:10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap:()=>dialPhoneNumber(widget.document["phoneNumber"]),
                                child: const Icon(Icons.phone,size: 22,color: Color(0xFF3E5974))
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.document["phoneNumber"],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                                onTap:()=>openWhatsAppChat(widget.document["whatsAppNumber"]),
                                child: const Icon(Icons.chat_outlined,size: 22, color: Color(0xFF3E5974))
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.document["whatsAppNumber"],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  if(widget.document["id"]==uid)
                  InkWell(
                    onTap: (){
                      if(widget.document["place"]!=null) {
                        FirebaseFirestore.instance.collection('found').doc(widget.document["docId"]).delete();
                      }else{
                        FirebaseFirestore.instance.collection('lost').doc(widget.document["docId"]).delete();
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 15,left: 15,top: 8,bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF3E5974),
                      ),
                      width: double.infinity,
                      child: const Center(child: Text('Delete',style: TextStyle(color: Colors.white,fontSize: 20),)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
