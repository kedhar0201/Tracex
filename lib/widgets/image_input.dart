import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key,this.getImageUrl,required this.isFoundPage});

  final void Function(File image)? getImageUrl;
  final bool isFoundPage;
  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture()
  async{
    final imagePicker=ImagePicker();
    final pickedImage=await imagePicker.pickImage(source: widget.isFoundPage?ImageSource.camera:ImageSource.gallery,maxWidth: 600);

    if(pickedImage==null)
      {
        return;
      }

    setState(() {
      _selectedImage=File(pickedImage.path);
    });
    widget.getImageUrl!(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content=TextButton.icon(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera,size:30,color: Color(0xFF3E5974)),
      label: Text(widget.isFoundPage?'Take a Picture':'Upload a Picture',style:const TextStyle(fontSize: 20,color: Colors.black),),
    );

    if(_selectedImage!=null)
      {
        content=GestureDetector(
          onTap: _takePicture,
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }
    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black,width:1.5),
      ),
      child: content
    );
  }
}
