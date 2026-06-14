import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

import 'package:lost_and_found/widgets/date_time_picker.dart';
import 'package:lost_and_found/widgets/image_input.dart';

class AcquireDetailsScreen extends StatefulWidget {
  const AcquireDetailsScreen({super.key,required this.isFoundPage});

  final bool isFoundPage;
  @override
  State<AcquireDetailsScreen> createState() => _AcquireDetailsScreenState();
}

class _AcquireDetailsScreenState extends State<AcquireDetailsScreen> {
  TextEditingController titleTextEditingController=TextEditingController();
  TextEditingController descriptionTextEditingController=TextEditingController();
  TextEditingController placeTextEditingController=TextEditingController();
  TextEditingController nameTextEditingController=TextEditingController();
  TextEditingController phoneNumberTextEditingController=TextEditingController();
  TextEditingController whatsAppNumberTextEditingController=TextEditingController();
  TextEditingController placeDescriptionTextEditingController=TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  File? imageUrl;
  String? selectedDate;
  String? selectedTime;
  String selectedCategory="Others";
  bool isIdCard=false;
  bool isStationary=false;
  bool isElectronics=false;
  bool isOthers=false;
  bool isSelectedCategory=false;
  GlobalKey<FormState> formKey=GlobalKey();

  void submitToDatabase(String? url)
  async{
    try{
      if(widget.isFoundPage)
        {
          final docRef=FirebaseFirestore.instance.collection("found").doc();
          await docRef.set(
              {
                "title":titleTextEditingController.text,
                "description":descriptionTextEditingController.text,
                "image":url,
                "place":placeTextEditingController.text,
                "descriptionPlace":placeDescriptionTextEditingController.text,
                "date": selectedDate,
                "time":selectedTime,
                "name":nameTextEditingController.text,
                "phoneNumber":phoneNumberTextEditingController.text,
                "whatsAppNumber":whatsAppNumberTextEditingController.text,
                "category":selectedCategory,
                "id":uid,
                "docId":docRef.id,
                "reportedBy":uid,
              }
          );
          // CHANGED: Auto trigger ML matching after found item is saved
          await triggerMatch(docRef.id);
        }
      else
        {
          final docRef=FirebaseFirestore.instance.collection("lost").doc();
          await docRef.set(
              {
                "title":titleTextEditingController.text,
                "description":descriptionTextEditingController.text,
                "image":url,
                //"place":placeTextEditingController.text,
                "date": DateFormat.MMMMd('en_US').format(DateTime.now()),
                "time":DateFormat.jm().format(DateTime.now()),
                "name":nameTextEditingController.text,
                "phoneNumber":phoneNumberTextEditingController.text,
                "whatsAppNumber":whatsAppNumberTextEditingController.text,
                "category":selectedCategory,
                "id":uid,
                "docId":docRef.id
              }
          );
        }
      Navigator.pop(context);
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  // CHANGED: ML trigger function with correct Render URL
  Future<void> triggerMatch(String foundDocId) async {
    try {
      final response = await http.post(
        Uri.parse('https://lost-found-ml-1.onrender.com/match/$foundDocId'),
      );
      if (response.statusCode == 200) {
        debugPrint('Match triggered successfully');
      } else {
        debugPrint('Match trigger failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Match trigger error: $e'); // silent fail, dont block user
    }
  }

  Future<void> uploadImageToCloudinary() async {
    if(widget.isFoundPage)
    {
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image before submitting.')),
        );
        return;
      }
      const cloudName = 'derbo820u';
      const uploadPreset = 'lostFound';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageUrl!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStream = await response.stream.bytesToString();
        final resData = jsonDecode(resStream);
        submitToDatabase(resData['secure_url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    }
    else
      {
        if (imageUrl == null) {
          submitToDatabase(null);
        }else
          {
            const cloudName = 'derbo820u';
            const uploadPreset = 'lostFound';

            final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

            var request = http.MultipartRequest('POST', url)
              ..fields['upload_preset'] = uploadPreset
              ..files.add(await http.MultipartFile.fromPath('file', imageUrl!.path));

            final response = await request.send();

            if (response.statusCode == 200) {
              final resStream = await response.stream.bytesToString();
              final resData = jsonDecode(resStream);
              submitToDatabase(resData['secure_url']);
            } else {
              //print('Failed to upload: ${response.statusCode}');
            }
          }
      }
  }

  void getImageUrl(File image)
  {
    imageUrl=image;
  }
  void getDate(String date)
  {
    selectedDate=date;
  }
  void getTime(String time)
  {
    selectedTime=time;
  }

  @override
  Widget build(BuildContext context) {
    isSelectedCategory=isIdCard || isStationary || isElectronics || isOthers;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Add Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: formKey,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enter The Title',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      TextFormField(
                        controller: titleTextEditingController,
                        style: const TextStyle(color: Colors.black),
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: 'Enter the Title',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:1.5),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the Title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8,),
                      const Text('Enter The Description',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      TextFormField(
                        controller: descriptionTextEditingController,
                        style: const TextStyle(color: Colors.black),
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter the Description of item',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:1.5),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      const Text('Upload Picture of the item ',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      ImageInput(getImageUrl: getImageUrl,isFoundPage: widget.isFoundPage,),
                      const SizedBox(height: 10,),
                      if(widget.isFoundPage)
                      const Text('Enter the Place',style: TextStyle(fontSize:20,color: Colors.white),),
                      if(widget.isFoundPage)
                      const SizedBox(height: 8,),
                      if(widget.isFoundPage)
                      TextFormField(
                        controller: placeTextEditingController,
                        maxLength: 10,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Enter the place where the item is found',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:1.5),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the Place';
                          }
                          return null;
                        },
                      ),
                      if(widget.isFoundPage)
                        const Text('Description of the place',style: TextStyle(fontSize:20,color: Colors.white),),
                      if(widget.isFoundPage)
                        const SizedBox(height: 8,),
                      if(widget.isFoundPage)
                        TextFormField(
                          controller: placeDescriptionTextEditingController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Enter the place (Ex: 4th floor, PJ Block)',
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.black,width:1.5),
                            ),
                          ),
                          validator: (value) {
                            if(value==null || value.isEmpty) {
                              return 'Please Enter the Description of the Place';
                            }
                            return null;
                          },
                        ),
                      if(widget.isFoundPage)
                      const SizedBox(height: 10,),
                      if(widget.isFoundPage)
                      DateTimePicker(getDate: getDate,getTime: getTime,),
                      if(widget.isFoundPage)
                      const SizedBox(height: 10,),
                      const Text('Select the category where the item belongs',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                if(!isSelectedCategory || isIdCard)
                                  {
                                    setState(() {
                                      selectedCategory="ID Card";
                                      isIdCard=!isIdCard;
                                    });
                                  }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: isIdCard?Color(0xFF3E5974):null,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  height: 50,
                                  child: Center(
                                    child: Text("ID Card",style: TextStyle(fontSize: 20,color: isIdCard?Colors.white:Colors.black),),
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                if(!isSelectedCategory ||isStationary) {
                                  setState(() {
                                  selectedCategory="Stationary";
                                  isStationary=!isStationary;
                                });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isStationary?Color(0xFF3E5974):null,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black),
                                ),
                                height: 50,
                                child: Center(
                                  child: Text("Stationary",style: TextStyle(fontSize: 20,color: isStationary?Colors.white:Colors.black),),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                if(!isSelectedCategory || isElectronics) {
                                  setState(() {
                                  selectedCategory="Electronics";
                                  isElectronics=!isElectronics;
                                });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isElectronics?Color(0xFF3E5974):null,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black),
                                ),
                                height: 50,
                                child: Center(
                                  child: Text("Electronics",style: TextStyle(fontSize: 20,color: isElectronics?Colors.white:Colors.black),),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      InkWell(
                        onTap: (){
                          if(!isSelectedCategory || isOthers) {
                            setState(() {
                            selectedCategory="Others";
                            isOthers=!isOthers;
                          });
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: isOthers?Color(0xFF3E5974):null,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            height: 50,
                            child: Center(
                              child: Text("Others",style: TextStyle(fontSize: 20,color: isOthers?Colors.white:Colors.black),),
                            ),
                          ),
                      ),
                      const SizedBox(height: 10,),
                      const Text('Enter Your Name',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      TextFormField(
                        controller: nameTextEditingController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Enter Your Name',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:1.5),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      const Text('Enter the Phone Number',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      TextFormField(
                        controller: phoneNumberTextEditingController,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone,color: Color(0xFF3E5974)),
                          hintText: 'Enter the Phone Number',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:3),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the Phone Number';
                          }
                          if(!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please Enter a valid Phone Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      const Text('Enter the WhatsApp Enabled Number',style: TextStyle(fontSize:20,color: Colors.white),),
                      const SizedBox(height: 8,),
                      TextFormField(
                        controller: whatsAppNumberTextEditingController,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone,color: Color(0xFF3E5974)),
                          hintText: 'Enter the WhatsApp Enabled Number',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black,width:3),
                          ),
                        ),
                        validator: (value) {
                          if(value==null || value.isEmpty) {
                            return 'Please Enter the Phone Number';
                          }
                          if(!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please Enter a valid WhatsApp Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15,),
                      ElevatedButton(
                        onPressed: (){
                          if(formKey.currentState!.validate())
                            {
                              if (widget.isFoundPage && (selectedDate == null || selectedTime == null)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select date and time')),
                              );
                              return;
                              }
                              uploadImageToCloudinary();
                            }
                        },
                        style: ButtonStyle(
                          minimumSize:MaterialStatePropertyAll(Size(MediaQuery.of(context).size.width,50)),
                          shape: MaterialStatePropertyAll(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(25))),
                          backgroundColor: MaterialStateProperty.all(Color(0xFF3E5974)),
                        ),
                        child: const Text('Add',style: TextStyle(fontSize: 20,color: Colors.black),),
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}