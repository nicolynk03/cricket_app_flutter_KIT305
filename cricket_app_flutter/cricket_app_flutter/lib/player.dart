//Reference: from KIT305 Flutter List Tutorial

import 'dart:math';

import 'package:flutter/material.dart';
//from Flutter Firebase KIT305 tutorial
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  //based on KIT305 Flutter Firebase tutorial
  late String id; //(1)
  String name;
  String role;
  String team;
  String? image; //note the image is "optional" because of the '?'. It DOES NOT need the "required" keyword

  Player({ required this.name, required this.role, required this.team, this.image});

  //from week 13 Flutter KIT305 tutorial
  Player.fromJson(Map<String, dynamic> json, this.id) //(2) ensures the ID of a row is extracted when we call fromJSON
      :
        name = json['name'],
        role = json['role'],
        team = json['team'],
        //added to save image
        image = json['image'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'role': role,
        'team' : team,
        //added to save image
        'image': image
      };
}

//Reference: from KIT305 Flutter List Tutorial
//the code from the tutorial sheet gives some functionalities for
//adding and deleting everything from the list

//from KIT305 Flutter List tutorial
//from KIT305 Flutter Firebase tutorial
//notice the use of notifyListeners() whenever the list is changed.
class PlayerModel extends ChangeNotifier {
  //Internal, private state of the list.
  final List<Player> items = [];
  //from ChatGPT
  String homeTeamName;
  String awayTeamName;

  //from KIT305 Firebase Flutter tutorial
  // playersCollection is a variable that stores the reference to the players collection/table
  //in Firebase
  CollectionReference homePlayersCollection = FirebaseFirestore.instance.collection('homePlayersFlutter');
  CollectionReference awayPlayersCollection = FirebaseFirestore.instance.collection('awayPlayersFlutter');


  // a Boolean that we read to indicate if we are still fetching from the database or not
  bool loading = false;

  //the fetch() from KIT305 Flutter Firebase tutorial
  Future fetch() async {
    //clear any existing data that we have gotten previously to avoid duplicate data
    items.clear();

    //indicate that we are still loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all the players
    //var querySnapshot = await playersCollection.orderBy("name").get();
    //modified and ensured by ChatGPT and Lindsay's suggestion
    //get all the home players
    var homeQuerySnapshot = await homePlayersCollection.orderBy("name").get();
    //get all the away players
    var awayQuerySnapshot = await awayPlayersCollection.orderBy("name").get();

    //iterate over the players and add them to the list
    // for (var doc in querySnapshot.docs) {
    //   //NOTE: we are NOT using the add(Player item) function since we DO NOT WANT to add them to the database
    //   //doc.id is to store the Firestore ID (based on KIT305 Flutter Firebase tutorial)
    //   var player = Player.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
    //   items.add(player);
    // }

    //modified and ensured by ChatGPT and Lindsay's suggestion
    //iterate over the home players and add them to the list
    for (var doc in homeQuerySnapshot.docs) {
      //NOTE: we are NOT using the add(Player item) function since we DO NOT WANT to add them to the database
        //doc.id is to store the Firestore ID (based on KIT305 Flutter Firebase tutorial)
      var homePlayer = Player.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(homePlayer);
    }

    //modified and ensured by ChatGPT and Lindsay's suggestion
    //iterate over the away players and add them to the list
    for (var doc in awayQuerySnapshot.docs) {
      //NOTE: we are NOT using the add(Player item) function since we DO NOT WANT to add them to the database
      //doc.id is to store the Firestore ID (based on KIT305 Flutter Firebase tutorial)
      var awayPlayer = Player.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(awayPlayer);
    }

    //this line is added to artificially increase the load time, so we can see the loading indicator (wen added)
    //can be commented later :D
    await Future.delayed(const Duration(seconds: 2));

    //we are DONE and no longer loading
    loading = false;
    update();
  }

  //constructor to initialise homeTeamName and awayTeamName from ChatGPT
  //PlayerModel(this.homeTeamName, this.awayTeamName);
  //improved and modified based on KIT305 Flutter tutorial
    //the new constructor that immediately calls the fetch() to get information from the database
  PlayerModel(this.homeTeamName, this.awayTeamName) {
    fetch();
  }

  //added from KIT305 Firebase Flutter tutorial
  Player? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((player) => player.id == id);
  }

  //from ChatGPT
  void updateTeams(String home, String away) {
    print("Updating teams - Home: $home, Away: $away");
    homeTeamName = home;
    awayTeamName = away;
    notifyListeners();
    //notifyListeners();

    //clear items list and add players with updated team names
    //froom ChatGPT
    items.clear();
    //addInitialPlayers();
    notifyListeners();
  }


  //TODO: normally a model would get from database here
  //from KIT305 Flutter List tutorial and ChatGPT
  // void addInitialPlayers() {
  //   add(Player(name: "Max Verstappen", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/verstappen"), false);
  //   add(Player(name: "Fernando Alonso", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/alonso"), false);
  //   add(Player(name: "Oscar Piastri", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/piastri"), false);
  //
  //   add(Player(name: "Charles Leclerc", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/leclerc"), true);
  //   add(Player(name: "Carlos Sainz", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/sainz"), true);
  //   add(Player(name: "Lando Norris", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/norris"), true);
  // }

  //from KIT305 Flutter List tutorial
  // PlayerModel(String homeTeamName, String awayTeamName) {
  //   /*Player(name: "Max Verstappen", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/verstappen"),
  //     Player(name: "Fernando Alonso", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/alonso"),
  //     Player(name: "Oscar Piastri", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/piastri")
  //
  //     Player(name: "Charles Leclerc", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/leclerc"),
  //     Player(name: "Carlos Sainz", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/sainz"),
  //     Player(name: "Lando Norris", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/norris")
  //     */
  //   add(Player(name: "Max Verstappen", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/verstappen"));
  //   add(Player(name: "Fernando Alonso", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/alonso"));
  //   add(Player(name: "Oscar Piastri", role: "Regular player", team: awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/piastri"));
  //
  //   add(Player(name: "Charles Leclerc", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/leclerc"));
  //   add(Player(name: "Carlos Sainz", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/sainz"));
  //   add(Player(name: "Lando Norris", role: "Regular player", team: homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/norris"));
  // }

  //from KIT305 Flutter List tutorial
  // void add(Player item) {
  //   items.add(item);
  //   update();
  // }

  //from KIT305 Flutter Firebase tutorial and Lindsay's suggestion
  //to add players to the collection as a document in Firebase Firestore
  Future add(Player item, bool isHomeTeam) async {
    loading = true;
    update();

    //suggested by ChatGPT and Lindsay's suggestion
    //checks if the player is a home player
    //if it is a home player

    if (isHomeTeam) {
      //based on KIT305 Firebase Flutter tutorial
      await homePlayersCollection.add(item.toJson());
    } else {
      //it is an away player, add it to the away player collection
      await awayPlayersCollection.add(item.toJson());
    }

    //await playersCollection.add(item.toJson());

    //refresh the database
    await fetch();

    //from ChatGPT
    //TODO: appoint the first home player on the list as the striker/batter
    //check if the number of players registered for the home team has reached 5
    if (isHomeTeam && getHomeTeamPlayers().length == 5) {
      //change the role of the first player in the list from "Regular player" to "Striker"
      items.firstWhere((player) => player.team == homeTeamName)?.role = "Striker";
      //update the player's role in Firebase from "Regular player" to "Striker"
      await homePlayersCollection.doc(items.firstWhere((player) => player.team == homeTeamName).id).update({'role': 'Striker'});
      
      //from ChatGPT
      //TODO: appoint the second home player on the list as non-striker/second batter
      if (getHomeTeamPlayers().length >= 2) {
        var secondHomePlayerInTheList = getHomeTeamPlayers()[1];
        secondHomePlayerInTheList.role = "Non-striker";
        //update the player's role in Firebase from "Regular player" to "Non-striker"
        await homePlayersCollection.doc(secondHomePlayerInTheList.id).update({'role': 'Non-striker'});
      }

      //notify listeners to rebuild UI
      update();
    } else if (getAwayTeamPlayers().length == 5) {
      //based on ChatGPT's approach for appointing a striker
      //change the role of the first player in the list from "Regular player" to "Striker"
      items.firstWhere((awayPlayer) => awayPlayer.team == awayTeamName)?.role = "Bowler";
      //update the player's role in Firebase from "Regular player" to "Striker"
      await awayPlayersCollection.doc(items.firstWhere((awayPlayer) => awayPlayer.team == awayTeamName).id).update({'role': 'Bowler'});
    }
  }

  //from KIT305 Flutter Firebase tutorial and Lindsay's suggestion
  //to update players in the collection as documents in Firebase Firestore
  Future updatePlayer(String id, Player item, bool isHomeTeam) async {
    loading = true;
    update();

    //suggested by ChatGPT and Lindsay's suggestion
    //checks if the player is a home player
    //if it is a home player
    if (isHomeTeam) {
      //based on KIT305 Firebase Flutter tutorial
      await homePlayersCollection.doc(id).set(item.toJson());
    } else {
      //it is an away player, update it in the away player collection
      await awayPlayersCollection.doc(id).set(item.toJson());
    }

    //await playersCollection.doc(id).set(item.toJson());

    //refresh the database
    await fetch();
  }

  //from KIT305 Flutter Firebase tutorial and Lindsay's suggestion
  //to delete a player from the collection
  Future delete(String id, bool isHomeTeam) async {
    // loading = true;
    // update();
    //
    // //suggested by ChatGPT and Lindsay's suggestion
    // //checks if the player is a home player
    // //if it is a home player
    // if (isHomeTeam) {
    //   //based on KIT305 Firebase Flutter tutorial
    //   await homePlayersCollection.doc(id).delete();
    // } else {
    //   //it is an away player, delete in from the away player collection
    //   await awayPlayersCollection.doc(id).delete();
    // }
    // //await playersCollection.doc(id).delete();
    //
    // //refresh the database
    // await fetch();

    //debugging code from ChatGPT
    loading = true;
    update();

    print('Attempting to delete player with ID: $id from ${isHomeTeam ? 'home' : 'away'} team');

    try {
      if (isHomeTeam) {
        print('Deleting from homePlayersCollection');
        await homePlayersCollection.doc(id).delete();
      } else {
        print('Deleting from awayPlayersCollection');
        await awayPlayersCollection.doc(id).delete();
      }
      items.removeWhere((player) => player.id == id);
      print('Player deleted successfully');
    } catch (e) {
      print('Error deleting player: $e');
    }

    await fetch();
  }

  void removeAll() {
    items.clear();
    update();
  }

  //from ChatGPT to filter/get home team players only
  List<Player> getHomeTeamPlayers() {
    return items.where((player) => player.team == homeTeamName).toList();
  }

  //from ChatGPT to filter/get away team players only
  List<Player> getAwayTeamPlayers() {
    return items.where((player) => player.team == awayTeamName).toList();
  }

  //from ChatGPT: a function to display to the UI the name of the home player with
  //"Striker" as a role
  String getCurrentStrikerName() {
    //find the player with a "Striker" role in the home team player collection
    Player? striker = items.firstWhere((player) => player.team == homeTeamName && player.role == "Striker", orElse: () => Player(name: "Striker", role: "", team: ""));
    //return the name of the current striker
    return striker.name;
  }

  // a function to get the associated image of the current striker
  String? getCurrentStrikerImage() {
    //find the player with a "Striker" role in the home team player collection
    Player? striker = items.firstWhere((player) => player.team == homeTeamName && player.role == "Striker", orElse: () => Player(name: "", role: "", team: ""));
    //
    // if (items.isEmpty) {
    //   return null;
    // }
    //return the image of the current striker
    return striker.image;
    //return striker.image;
  }

  //a function to display to the UI the name of the home player with
  //"Non-striker" as a role
  String getCurrentNonStrikerName() {
    //find the player with a "Non-striker" role in the home team player collection
    Player? nonStriker = items.firstWhere((player) => player.team == homeTeamName && player.role == "Non-striker", orElse: () => Player(name: "Non-striker", role: "", team: ""));

    //return the name of the current non-striker
    return nonStriker.name;
  }

  // a function to get the associated image of the current striker
  String? getCurrentNonStrikerImage() {
    //find the player with a "Non-striker" role in the home team player collection
    Player? nonStriker = items.firstWhere((player) => player.team == homeTeamName && player.role == "Non-striker", orElse: () => Player(name: "Non-striker", role: "", team: ""));
    //return the image of the current non-striker
    return nonStriker.image;
  }

  //a function to swap the current striker and non-striker
  //meant to get called after every over (at the end of every over)
  //made with the help of chatGPT
  Future<void> swapStrikerAndNonStriker() async {
    // Find home players with striker and non-striker roles
    Player? striker = items.firstWhere(
            (player) => player.team == homeTeamName && player.role == "Striker",
        orElse: () => Player(name: "", role: "", team: "")
    );

    Player? nonStriker = items.firstWhere(
            (player) => player.team == homeTeamName && player.role == "Non-striker",
        orElse: () => Player(name: "", role: "", team: "")
    );

    // Check if both players are found
    if (striker.name.isNotEmpty && nonStriker.name.isNotEmpty) {
      // Swap roles between the two players
      striker.role = "Non-striker";
      nonStriker.role = "Striker";

      // Update roles in Firebase
      await homePlayersCollection.doc(striker.id).update({'role': 'Non-striker'});
      await homePlayersCollection.doc(nonStriker.id).update({'role': 'Striker'});

      // Notify listeners to rebuild UI
      update();
    } else {
      print("Striker or Non-striker not found");
    }
  }


  //a function to display to the UI the name of the away player with
  // "Bowler" as a role
  String getCurrentBowlerName() {
    //find the player with "Bowler" role in the away team player collection
    Player? bowler = items.firstWhere((player) => player.team == awayTeamName && player.role == "Bowler", orElse: () => Player(name: "Bowler", role: "", team: ""));

    //return the name of the current bowler
    return bowler.name;
  }

  // a function to display the imaeg of the current bowler
  String? getCurrentBowlerImage() {
    //find the player with "Bowler" role in the away team player collection
    Player? bowler = items.firstWhere((player) => player.team == awayTeamName && player.role == "Bowler", orElse: () => Player(name: "Bowler", role: "", team: ""));

    //return the image of the current bowler
    return bowler.image;
  }

  // a function to randomly choose any away players with "Regular player" as the new bowler
  //and change the old bowler to be a regular player
  //ChatGPT helps to ensure that the function will properly function and as intended
  Future<void> appointANewBowler() async {
    //based on what ChatGPT has suggested for swapping striker and non-striker
    //find away player with bowler role
    Player? currentBowler = items.firstWhere((player) => player.team == awayTeamName && player.role == "Bowler", orElse: () => Player(name: "", role: "", team: ""));

    //from ChatGPT
    //find all away players whose role is registered as "Regular player"
    List<Player> awayRegularPlayers = items.where((player) => player.team == awayTeamName && player.role == "Regular player").toList();

    if (awayRegularPlayers.isNotEmpty) {
      Player newBowler = awayRegularPlayers[Random().nextInt(awayRegularPlayers.length)];
      //updates the role of newBowler from "Regular player" to "Bowler"
      newBowler.role = "Bowler";
      // Update roles in Firebase
      await awayPlayersCollection.doc(newBowler.id).update({'role': 'Bowler'});
      print("${newBowler.name} is the new bowler for ${newBowler.team}");
    } else {
      print("No regular players available to appoint as a bowler for the away team");
    }

    //updates the role of the currentBowler from "Bowler" to "Regular player"
    if (currentBowler != null) {
      currentBowler.role = "Regular player";
      // Update roles in Firebase
      await awayPlayersCollection.doc(currentBowler.id).update({'role': 'Regular player'});
    }

    update();
  }

  // a function to randomly appoint a new batter/striker from the home team
  //this function gets called for every wicket
  //based on what ChatGPT has set as an example to randomly appoint a bowler from the away team
  Future<void> appointANewStriker() async {
    //find the home player with the role of a "Striker"
    Player? currentStriker = items.firstWhere(
            (player) => player.team == homeTeamName && player.role == "Striker",
        orElse: () => Player(name: "", role: "", team: "")
    );

    //find all home players whose role is registered as "Regular player"
    //    List<Player> awayRegularPlayers = items.where((player) => player.team == awayTeamName && player.role == "Regular player").toList();
    List<Player> homeRegularPlayers = items.where((player) => player.team == homeTeamName && player.role == "Regular player").toList();

    if (homeRegularPlayers.isNotEmpty) {
      Player newStriker = homeRegularPlayers[Random().nextInt(homeRegularPlayers.length)];
      //updates the role of newStriker from "Regular player" to "Striker"
      newStriker.role = "Striker";
      //update the role of newStriker in Firebase
      await homePlayersCollection.doc(newStriker.id).update({'role': 'Striker'});
      print("${newStriker.name} is the new striker for ${newStriker.team} after a wicket");
    }

    //updates the role of the currentStriker from "Striker" to "Regular player"
    if (currentStriker != null) {
      currentStriker.role = "Regular player";
      //updates the role in Firebase
      await homePlayersCollection.doc(currentStriker.id).update({'role': 'Regular player'});
    }

    update();
  }

  //update any listeners
  //this call tells the widgets that are listening to this model to rebuild
  void update() { notifyListeners(); }
}