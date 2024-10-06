import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricket_app_flutter/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
//to handle upload picked image (as suggested by online tutorials and ChatGPT)
import 'package:firebase_storage/firebase_storage.dart';

class PlayerDetails extends StatefulWidget {
  const PlayerDetails({Key? key, this.id, required this.isHomeTeam, required this.teamName}) : super(key: key);

  //from Flutter List KIT305 tutorial
  //updated based on KIT305 Flutter Firebase tutorial
  //final int id;
  final String? id;

  //from ChatGPT to specify whether the player is from home team
  final bool isHomeTeam;

  //from ChatGPT to transfer team name of home team and away team whilst adding a new player to Firebase
  final String teamName;

  @override
  State<PlayerDetails> createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  //from Flutter List KIT305 tutorial
  //note:
    //Form widget (with formKey in the state)
    // TextEditingController is needed to store the state of TextFormField widgets
    //ElevatedButton to save and return to previous screen
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  // based on an online tutorial in Medium (and had a YouTube video attached) by
  // Kavit (zenwraight): Flutter Tutorial - Image Picker From Camera & Gallery
  File? image;
  String imageURL = '';

  // based on an online tutorial in Medium (and had a YouTube video attached) by
  // Kavit (zenwraight): Flutter Tutorial - Image Picker From Camera & Gallery
  //a function to let user to select and pick an image from the gallery
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      //in case if user has not selected an image
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      //from DroidMonk's YouTube tutorial to upload to Firebase storage and
      //Medium blog post by Bhavesh Sachala
      //set a unique name for the image
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName');

      //from DroidMonk's YouTube tutorial to upload to Firebase storage and
      //Medium blog post by Bhavesh Sachala
      //upload picked file to Firebase storage and stores it
      try {
        UploadTask uploadTask = storageReference.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        imageURL = await taskSnapshot.ref.getDownloadURL();
      } catch (error) {
        //some error occured
        print("Unable to get picked image URL for gallery due to: $error");
      }


      //create a reference for the image to be stored


    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    //added to save image to Firebase (from StackOverflow)
    //create a reference to the location we wanted to upload in Firebase
    //if it is a home team player
    // if (widget.isHomeTeam) {
    //   CollectionReference homePlayersCollection = FirebaseFirestore.instance.collection('homePlayersFlutter');
    //
    // }

  }

  //based on pickImage() from numerous online tutorials
  //a function to let user to select and pick an image from the camera
  Future pickImageFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      //from DroidMonk's YouTube tutorial to upload to Firebase storage and
      //Medium blog post by Bhavesh Sachala
      //set a unique name for the image
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$uniqueFileName');

      //from DroidMonk's YouTube tutorial to upload to Firebase storage and
      //Medium blog post by Bhavesh Sachala
      //upload picked file to Firebase storage and stores it
      try {
        UploadTask uploadTask = storageReference.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        imageURL = await taskSnapshot.ref.getDownloadURL();
      } catch (error) {
        //some error occured
        print("Unable to get picked image URL for camera due to: $error");
      }

    } on PlatformException catch (e) {
      print("Failed to pick image from camera: $e");
    }

    //added to save image to Firebase (from StackOverflow)
  }


  // a function to upload picked image (from Medium tutorial) based on Bhavesh Sachala
  // Future uploadImageToFirestore() async {
  //   File? pickedImage = await pickImage();
  //   File pickedImageFromCamera = await pickImageFromCamera();
  //
  //   // a function to upload picked image (from Medium tutorial) based on Bhavesh Sachala
  //   if (pickedImage != null) {
  //     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //     //CollectionReference homePlayersCollection = FirebaseFirestore.instance.collection('homePlayersFlutter');
  //     //CollectionReference awayPlayersCollection = FirebaseFirestore.instance.collection('awayPlayersFlutter');
  //
  //     Reference storageReference = FirebaseStorage.instance.ref();
  //     UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));
  //     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  //     String imageURL = await taskSnapshot.ref.getDownloadURL();
  //
  //     //checks if the player is a home player
  //     if (widget.isHomeTeam) {
  //       CollectionReference homePlayersCollection = FirebaseFirestore.instance.collection('homePlayersFlutter');
  //
  //       await homePlayersCollection.add(data);
  //     } else {
  //       print ("No image picked from gallery");
  //     }
  //     //await FirebaseFirestore.instance.collection()
  //
  //     //UploadTask uploadTask = homePlayersCollection.putFile((File(pickedImage.path)));
  //   }
  // }

  //from Flutter List KIT305 tutorial
  @override
  Widget build(BuildContext context) {
    //from KIT305 Flutter Lists Tutorial, modified by ChatGPT to specify is player is from
    //home team
    //final playerModel = Provider.of<PlayerModel>(context, listen:false).items;
    final playerModel = Provider.of<PlayerModel>(context, listen:false);
    //var players = widget.isHomeTeam ? playerModel.getHomeTeamPlayers() : playerModel.getAwayTeamPlayers();
    //var players = Provider.of<PlayerModel>(context, listen:false).items;

    //modified based on sample code of KIT305 Flutter Firebase tutorial
    //var player = players[widget.id];
    //Player? player = widget.id != -1 ? players[widget.id] : null;

    //added from KIT305 Firebase Flutter tutorial
    var player = Provider.of<PlayerModel>(context, listen: false).get(widget.id);

    var adding = player == null;
    if (!adding) {
      nameController.text = player.name;
      //based on the code above to detect changes to player name's field in the form
      //based on KIT305 Flutter tutorials
      imageURL = player.image!;
    }


    return Scaffold(
      appBar: AppBar(
        //modified based on KIT305 Flutter Firebase sample code tutorial and
        //made based on KIT305 Flutter Lists tutorial
        //title: const Text("Player's Details"),
        title: Text(adding ? "Add a New Player" : "Edit Player's Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //based on KIT305 Firebase Flutter sample base code
            if (adding == false) Text("Chosen Player ID ${widget.id}"),
            //display player ID
            //Text("Chosen Player ID ${widget.id}"),
            //TODO: we will add form fields later here
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Name"),
                        controller: nameController,
                        autofocus: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            //made failure-resistant: will only allow user if TextFormField is not empty
                            //made by ChatGPT
                            if (nameController.text.isNotEmpty) {

                              // if (imageURL.isEmpty) return;

                              //modified based on KIT305 Flutter Firebase sample base code
                              if (adding) {
                                player = Player(name: "", role: "Regular player", team: widget.teamName, image: imageURL);
                              }

                              //TODO: save the player
                              //to update the player object
                              //from KIT305 Flutter Lists tutorial
                              player!.name = nameController.text;
                              //the line of code below detects if user selects a new image
                              //if the user does select a new image, it updates the Firebase
                              player?.image = imageURL;

                              //TODO: update the model (done)
                              //update the model
                              //from KIT305 Firebase Flutter tutorial
                              if (adding) {
                                //based on KIT305 Firebase Flutter tutorial and modified a bit by ChatGPT
                                await Provider.of<PlayerModel>(context, listen: false).add(player!, widget.isHomeTeam);
                              } else {
                                //based on KIT305 Firebase Flutter tutorial and modified a bit by ChatGPT
                                await Provider.of<PlayerModel>(context, listen: false).updatePlayer(widget.id!, player!, widget.isHomeTeam);
                              }

                              //update the model
                              //Provider.of<PlayerModel>(context, listen: false).update();


                              //return to previous screen (the player list)
                              //Navigator.pop(context);
                              if (context.mounted) Navigator.pop(context);
                            } else {
                              //SnackBar to tell user name field cant be empty
                              //suggested by ChatGPT
                              //show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Please fill a name for the player'),
                                duration: Duration(seconds: 2),
                                ),
                              );
                            }

                            // //modified based on KIT305 Flutter Firebase sample base code
                            // if (adding) {
                            //   player = Player(name: "", role: "Regular player", team: widget.teamName);
                            // }
                            //
                            // //TODO: save the player
                            // //to update the player object
                            // //from KIT305 Flutter Lists tutorial
                            // player!.name = nameController.text;
                            //
                            // //TODO: update the model (done)
                            // //update the model
                            // //from KIT305 Firebase Flutter tutorial
                            // if (adding) {
                            //   //based on KIT305 Firebase Flutter tutorial and modified a bit by ChatGPT
                            //   await Provider.of<PlayerModel>(context, listen: false).add(player!, widget.isHomeTeam);
                            // } else {
                            //   //based on KIT305 Firebase Flutter tutorial and modified a bit by ChatGPT
                            //   await Provider.of<PlayerModel>(context, listen: false).updatePlayer(widget.id!, player!, widget.isHomeTeam);
                            // }
                            //
                            // //update the model
                            // //Provider.of<PlayerModel>(context, listen: false).update();
                            //
                            //
                            // //return to previous screen (the player list)
                            // //Navigator.pop(context);
                            // if (context.mounted) Navigator.pop(context);
                          }
                        }, icon: const Icon(Icons.save), label: const Text("Save Changes")),
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            //TODO: implement image gallery feature here
                            //calls the pickImage()
                            pickImage();
                          },
                          icon: const Icon(Icons.image), label: const Text("Image Gallery"),
                      ),

                      //testing for camera
                      ElevatedButton.icon(
                        onPressed: () {
                          //TODO: implement camera stuff to test here
                          pickImageFromCamera();
                        },
                        icon: const Icon(Icons.camera_alt), label: const Text("Camera"),
                      ),
                      //creates the image display
                      SizedBox(height: 10),
                      // based on an online tutorial in Medium (and had a YouTube video attached) by
                      // Kavit (zenwraight): Flutter Tutorial - Image Picker From Camera & Gallery
                      //modified based on another YouTube tutorial by HeyFlutter
                      image != null ? Image.file(image!, width: 160, height: 160, fit: BoxFit.cover) : Text("No image selected"),
                    ],
                  ),
                ),
            ),
          ]
        ),
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return const Placeholder();
  // }
}
