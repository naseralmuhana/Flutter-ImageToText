import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/services/clipboard.dart';

class ImageToTextPage extends StatefulWidget {
  @override
  _ImageToTextPageState createState() => _ImageToTextPageState();
}

class _ImageToTextPageState extends State<ImageToTextPage> {
  String result = '';
  File? image;
  late ImagePicker imagePicker;
  @override
  void initState() {
    imagePicker = ImagePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(size.height * 0.3);
    return Scaffold(
      body: Container(
        decoration: buildBoxDecoration(imagePath: 'assets/images/background.jpg'),
        child: Column(
          children: [
            SizedBox(width: 100.0),

            // show result
            buildShowResultContainer(size),

            // pick or capture Image
            buildPickImageContainer(size)
          ],
        ),
      ),
    );
  }

  Container buildPickImageContainer(Size size) {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 140.0),
      child: Stack(
        children: [
          Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/pin.png',
                  height: size.height * 0.3,
                  width: size.width * 0.35,
                ),
              )
            ],
          ),
          Center(
            child: TextButton(
              onPressed: () => pickImage(source: ImageSource.gallery), //FromGallery
              onLongPress: () => pickImage(source: ImageSource.camera), //captureImageWithCamera
              child: Container(
                margin: EdgeInsets.only(top: 25),
                child: image != null
                    ? Image.file(
                        image!,
                        width: 140,
                        height: 192,
                        fit: BoxFit.fill,
                      )
                    : Container(
                        width: 240,
                        height: 200,
                        child: Icon(
                          Icons.camera_front,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container buildShowResultContainer(Size size) {
    return Container(
      height: size.height * 0.60,
      width: size.width * 0.95,
      margin: EdgeInsets.only(top: 60),
      padding: EdgeInsets.only(left: 28, bottom: 5, right: 18),
      decoration: buildBoxDecoration(imagePath: 'assets/images/note.jpg'),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                result,
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () => MyClipboard.copy(text: result),
              icon: Icon(Icons.content_copy_outlined),
            ),
          ],
        ),
      ),
    );
  }

  pickImage({required ImageSource source}) async {
    XFile? xFile = await imagePicker.pickImage(source: source);
    image = File(xFile!.path);
    //  extract text from image
    performImageLabeling();
  }

  performImageLabeling() async {
    final inputImage = InputImage.fromFile(image!);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText = await textDetector.processImage(inputImage);

    result = '';
    for (TextBlock block in recognisedText.blocks) {
      // final List<String> languages = block.recognizedLanguages;
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          result += element.text + ' ';
        }
        result += '\n\n';
      }

      setState(() {});
    }
  }

  BoxDecoration buildBoxDecoration({required String imagePath}) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.fill,
      ),
    );
  }
}
