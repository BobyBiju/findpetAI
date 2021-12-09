//@dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
void main(){
  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: HomePage(),
  ),);
}

class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _isLoading;
  XFile _image;
  List _output;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading=true;

    loadModel().then((value){
      setState(() {
        _isLoading=false;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My DOG'),
      ),
      body: _isLoading?Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ):Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            _image==null?Container():Image.file(File(_image.path)),
            SizedBox(height: 16,),
            _output == null? Text(""):Text("${_output[0]["label"]}")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          chooseImage();
        },
      ),
    );
  }

  chooseImage() async{
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile image = await _picker.pickImage(source: ImageSource.gallery);
    if(image ==null) return null;
    setState(() {
      _isLoading=true;
      _image= image ;
    });
    runModelOnImage(image);
  }

  runModelOnImage(XFile image) async{
    var output= await Tflite.runModelOnImage(path: image.path,
    numResults: 2,
    imageMean: 127.5,
    imageStd: 127.5,
    threshold: 0.5);

    setState(() {
      _isLoading=false;
      _image=image;
      _output=output ;
    });
  }




  loadModel() async{
    await Tflite.loadModel(model: "assets/model_unquant.tflite",
    labels: "assets/labels.txt");

  }
}

