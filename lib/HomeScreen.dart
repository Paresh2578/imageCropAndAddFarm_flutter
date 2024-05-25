import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:widget_mask/widget_mask.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final GlobalKey _globalKey = GlobalKey();

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? finalImage;
  XFile? prossesImage;
  String maskPath = "";



  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
     XFile? imgPick = await  picker.pickImage(source: ImageSource.gallery);

     if(imgPick != null){
       prossesImage = imgPick;
       await cropImage();
       
       showFilterDialog();
        setState(() {
        });
     }

  }

  Future<void> cropImage() async {
     var result = await ImageCropper().cropImage(
         sourcePath: prossesImage!.path,
       aspectRatioPresets: [
         CropAspectRatioPreset.original,
         CropAspectRatioPreset.ratio16x9
       ],
       uiSettings: [
         AndroidUiSettings(
           lockAspectRatio: false,
           toolbarTitle: "Image Cropper"
         )
       ]
     );

     prossesImage = XFile(result!.path);
     setState(() {

     });
     
  }
  
  void showFilterDialog(){

    showDialog(context: context,barrierDismissible: false, builder: (context) {
      return Dialog(
        child: StatefulBuilder(
          builder: (context , showDialogSetState) {
            return Container(
              height: 500,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: (){Navigator.of(context).pop();},icon: const Icon(Icons.cancel),),
                  ),
                  const SizedBox(height: 5,),
                  const Text('Uploaded Image'),
                  const SizedBox(height: 5,),
                  // Image.file(File(image!.path) ,height: 200,),

                  maskPath.isEmpty ?  RepaintBoundary(key:_globalKey,child: Image.file(File(prossesImage!.path) ,height: 200,)) :

                  RepaintBoundary(
                    key: _globalKey,
                    child: WidgetMask(
                      blendMode: BlendMode.srcATop,
                        childSaveLayer: true,
                        mask: Image.file(File(prossesImage!.path) , height: 200,),
                        child: Image.asset(maskPath , height: 200,)
                    ),
                  ),

                  const SizedBox(height: 10,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["","assets/images/one.png","assets/images/two.png","assets/images/three.png" , "assets/images/for.png"].map((e) => imageFilterWidget(orignal: e.isEmpty , path: e , maskChange: showDialogSetState)).toList(),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: () async {
                      finalImage =await _capturePng();
                      Navigator.of(context).pop();
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(7)
                      ),
                      child: const Center(child: Text('Use this image' , style: TextStyle(color: Colors.white),)),
                    ),
                  ),

                ],
              ),
            );
          }
        ),
      );
    },);
  }

  Widget imageFilterWidget({bool? orignal = false , required String path , required Function maskChange}){
    return InkWell(
      onTap: (){
        if(orignal){
           maskPath = "";
        }else{
          maskPath = path;
        }

        print("mask path  $maskPath");
        setState(() {

        });

        maskChange((){});
      },
      child: Container(
        height: 80,
        width: 80,
        // padding: EdgeInsets.all(),
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)
        ),
        child: orignal! ? const Center(child: Text('Orignal')) :
         Image.asset(path , height: 80,color: Colors.black,)
        ,
      ),
    );
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Optional: To display the image in a dialog or save it, you can use the pngBytes.

      return pngBytes;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
     title: const Text('Add Image / Icon'),
     centerTitle: true,
     elevation: 10,
   ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //select image selection
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  const Text('Upload Image'),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (){
                      selectImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 6),
                      decoration: BoxDecoration(
                      color: Colors.green,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: const Text('Choose from Device' , style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ),

            // show image section
            finalImage != null ? Container(
                 margin: const EdgeInsets.symmetric(vertical: 20),
                child: Image.memory(finalImage! , height: 200,fit: BoxFit.cover,)) : const SizedBox(),


            // image != null ? Container(
            //   padding: const EdgeInsets.all(10),
            //   child: Column(
            //     children: [
            //       Container(
            //         alignment: Alignment.topRight,
            //         child: IconButton(onPressed: (){Navigator.of(context).pop();},icon: const Icon(Icons.cancel),),
            //       ),
            //       const SizedBox(height: 5,),
            //       const Text('Uploaded Image'),
            //       const SizedBox(height: 10,),
            //       Image.file(File(image!.path) ,height: 200,),
            //       const SizedBox(height: 10,),
            //       SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: Row(
            //           children: ["","assets/images/one.png","assets/images/two.png","assets/images/three.png" , "assets/images/for.png"].map((e) => imageFilterWidget(orignal: e.isEmpty , path: e)).toList(),
            //         ),
            //       ),
            //       const SizedBox(height: 10,),
            //       Container(
            //         padding: const EdgeInsets.symmetric(vertical: 10),
            //         width: double.maxFinite,
            //         decoration: BoxDecoration(
            //             color: Colors.green,
            //             borderRadius: BorderRadius.circular(7)
            //         ),
            //         child: const Center(child: Text('Use this image' , style: TextStyle(color: Colors.white),)),
            //       ),
            //
            //     ],
            //   ),
            // ) : const SizedBox()
          ],
        ),
      ),
    );
  }
}
