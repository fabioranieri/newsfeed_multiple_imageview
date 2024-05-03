import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class SmartImage extends StatelessWidget {
  final String src;
  final BoxFit? fit;
  final bool isPost;
  final double? radius;
  final Function(String val)? onLongTap;

  const SmartImage(this.src,
      {Key? key, this.fit, this.isPost = false, this.radius, this.onLongTap})
      : super(key: key);

  bool networkImage() => src.startsWith('https');
  //bool base64() => src.contains('[]');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress:() {
        if(onLongTap != null) {
          onLongTap!(src);
        }
      },
      child: networkImage()
          ? FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: src,
              fit: fit,
              imageErrorBuilder: (_, e, a) {
                return Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Error. Please check your internet connection",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            )
          : isPost
              ? Image.file(
                  File(src),
                  fit: fit,
                )
              : CircleAvatar(
                  radius: radius,
                  backgroundImage: MemoryImage(
                    imageDecoder(src),
                    //fit: fit,
                  ),
                ),
    );
  }

  Uint8List imageDecoder(String image) {
    final List<int> list = List<int>.from(jsonDecode(image));
    return Uint8List.fromList(list);
  }

  void _showDeletePhotoDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Indica se la dialog può essere chiusa toccando fuori dal suo contenuto.
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300), // Durata dell'animazione di transizione.
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 30,
            height: 200,
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Sei sicuro di voler eliminare questa foto?', style: TextStyle(fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Chiude la dialog
                      },
                      child: Text('Annulla'),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // Metti qui il codice per eliminare la foto
                          Navigator.of(context).pop(); // Chiude la dialog dopo l'azione
                        },
                        child: const Text('OK'),
                        style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(Colors.red)
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}
