import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HeadPopApp extends StatefulWidget {
  @override
  _HeadPopAppState createState() => _HeadPopAppState();
}

class _HeadPopAppState extends State<HeadPopApp> {
  File _selectedFile;
  File _imageFile;
  bool _inProcess = false;
  Random rnd = new Random();

  final GlobalKey globalKey = GlobalKey();

//*********** Circular Image Widget ****************/
  Widget getImageWidget() {
    if (_selectedFile != null) {
      return RepaintBoundary(
        key: globalKey,
        child: ClipOval(
          child: Image.file(
            _selectedFile,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Image.asset(
        "images/image.png",
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  //******************* Fetching Image from Camera/Device and Crop Image *************/

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.png,
          cropStyle: CropStyle.circle,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.green,
            toolbarTitle: "HeadPop Cropper",
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.green,
          ));

      this.setState(() {
        _selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          'Head Pop',
          style: GoogleFonts.lemon(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getImageWidget(),
              SizedBox(
                height: 26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.green),
                      ),
                      child: Text(
                        "Camera",
                        style: GoogleFonts.lemon(color: Colors.white),
                      ),
                      onPressed: () {
                        getImage(ImageSource.camera);
                      }),
                  MaterialButton(
                      color: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.deepOrange),
                      ),
                      child: Text(
                        "Device",
                        style: GoogleFonts.lemon(color: Colors.white),
                      ),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      })
                ],
              )
            ],
          ),
          (_inProcess)
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          takeScreenshot();
          showToast();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }

// *********** Creating Circular Image *************
  takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/screenshot${rnd.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    _savefile(_imageFile);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);
  }

//**************** Saving Image in Gallery */
  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

//************ Permission for Storing Image *************/
  _askPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
    print(statuses[Permission.location]);
  }

// ************** Saved Successfully Toast Message *****************
  showToast() {
    return Fluttertoast.showToast(
      msg: "Saved Successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
