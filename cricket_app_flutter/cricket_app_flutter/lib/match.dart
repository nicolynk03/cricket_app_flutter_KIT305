//Reference: from KIT305 Flutter List Tutorial
//Reference: from KIT305 Flutter Firebase Tutorial
import 'package:flutter/material.dart';
//added from week 13 tutorial
import 'package:cloud_firestore/cloud_firestore.dart';

//from ChatGPT
//create a "Ball" class for the "balls" array
class Ball {
  String bowler;
  String nonStriker;
  int runs;
  String striker;
  String wickets;
  String extras;

  Ball({required this.bowler, required this.nonStriker, required this.runs, required this.striker, required this.wickets, required this.extras});

  //from week 13 Flutter KIT305 tutorial
  Ball.fromJson(Map<String, dynamic> json)
      :
        bowler = json['bowler'],
        nonStriker = json['nonStriker'],
        runs = json['runs'],
        striker = json['striker'],
        wickets = json['wickets'],
        extras = json['extras'];

  Map<String, dynamic> toJson() =>
      {
        'bowler': bowler,
        'nonStriker': nonStriker,
        'runs': runs,
        'striker': striker,
        'wickets' : wickets,
        'extras': extras
      };
}

class Match {
  late String id; //(1) added an id field for Match object
  String homeTeam;
  String awayTeam;
  //from ChatGPT to create an array called "balls" to store ball outcome
  List<Ball> balls;

  Match({required this.homeTeam, required this.awayTeam, required this.balls});

  //from week 13 Flutter KIT305 tutorial
  Match.fromJson(Map<String, dynamic> json, this.id) //(2) ensures the ID of a row is extracted when we call fromJSON
      :
        homeTeam = json['homeTeam'],
        awayTeam = json['awayTeam'],
        //modified by ChatGPT slightly, based on KIT305 Flutter Firebase tutorial
        balls = (json['balls'] as List).map((item) => Ball.fromJson(item)).toList();
        //balls = json['balls'];

  //initialise default values of the fields for each element of 'balls' array
  //by ChatGPT
  factory Match.initialized(String homeTeam, String awayTeam) {
    return Match(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      balls: [
        Ball(bowler: '', nonStriker: '', runs: 0, striker: '', wickets: '', extras: ''),
      ],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        //modified by ChatGPT slightly, based on KIT305 Flutter Firebase tutorial
        'balls': balls.map((ball) => ball.toJson()).toList()
        //'balls' : balls
      };
}

//Reference: from KIT305 Flutter List Tutorial
//the code from the tutorial sheet gives some functionalities for
//adding and deleting everything from the database (later)

//from KIT305 Flutter List tutorial
//from KIT305 Flutter Firebase tutorial
//note from tutorial sheet: notice the use of notifyListeners() whenever the list is changed.
class MatchModel extends ChangeNotifier {
  //Internal, private state of the list
  final List<Match> matches = [];
  final List<Match> pastMatches = [];

  //Internal, private state of the list (to store past matches)
  //based on KIT305 Flutter tutorial
  // final List<Match> pastMatches = [];

  //from ChatGPT
  String homeTeamName;
  String awayTeamName;


  //from KIT305 Firebase Flutter tutorial
  //matchCollection is a variable that stores the reference to 'matchFlutter' collection
  //in Firebase Firestore. It stores documents where a match is represented by a document.
  CollectionReference matchCollection = FirebaseFirestore.instance.collection('matchFlutter');

  //from KIT305 Firebase Flutter tutorial
  //a Boolean that we read from to see if we are still fetching information from the database
  bool loading = false;

  //from KIT305 Firebase Flutter tutorial
  Future fetch() async {
    //clear any existing data we have gotten previously, to avoid duplicate data
    matches.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all match (modified by ChatGPT to fetch a match document where the homeTeam and awayTeam match
    //with what the user has entered previously)
    //I reckon the current match gets updated just by its id lol, i hope it is! It is working well tho
    //it works for match history! just gotta remove .where to get all (took me so long to get that)
    var matchQuerySnapshot = await matchCollection.get();
    // var matchQuerySnapshot = await matchCollection
    //     .where('homeTeam', isEqualTo: homeTeamName)
    //     .where('awayTeam', isEqualTo: awayTeamName)
    //     .get();

    //iterate over the matches and add them to the list
    for (var doc in matchQuerySnapshot.docs) {
      //note from KIT305 Firebase Flutter tutorial
      //we are nit using add(Match match) function as we DO NOT want to add them to the database
      var match = Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      matches.add(match);
    }

    //get all match (modified by ChatGPT to fetch a match document where the homeTeam and awayTeam match
    //with what the user has entered previously)
    // var pastMatchQuerySnapshot = await matchCollection.get();
    //
    // //iterate over the matches and add them to the list
    // for (var doc in pastMatchQuerySnapshot.docs) {
    //   //note from KIT305 Firebase Flutter tutorial
    //   //we are nit using add(Match match) function as we DO NOT want to add them to the database
    //   var pastMatch = Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
    //   matches.add(pastMatch);
    // }

    //from KIT305 Firebase Flutter tutorial
    //this line is added to artificially increase the load time, so we can see the loading indicator (wen added)
    //can be commented later :D
    //await Future.delayed(const Duration(seconds: 2));

    //we are DONE and no longer loading
    loading = false;
    update();
  }

  //constructor to initialise homeTeamName and awayTeamName from ChatGPT
  //MatchModel(this.homeTeamName, this.awayTeamName); (similar approach to PlayerModel)
  //improved and modified based on KIT305 Flutter tutorial
  //the new constructor that immediately calls the fetch() to get information from the database
  MatchModel(this.homeTeamName, this.awayTeamName) {
    fetch();
  }

  //from KIT305 Flutter Firebase tutorial
  //get a match by its id to the MatchModel class/
  //This function does not need to read from the database.
  Match? get(String? id) {
    if (id == null) return null;
    //updated by ChatGPT with orElse clause
    return matches.firstWhere((match) => match.id == id);
  }

  //from ChatGPT
  void updateTeamsForMatchDoc(String home, String away) {
    print("Home: $home, Away: $away");
    homeTeamName = home;
    awayTeamName = away;
    notifyListeners();
  }

  //from KIT305 Flutter Firebase tutorial and ChatGPT
  Future<String> add(Match match) async {
    loading = true;
    update();

    //modified by ChatGPT
    var matchDocumentReference = await matchCollection.add(match.toJson());

    //from ChatGPT to retrieve the ID of the newly added document in the matchesFlutter collection
    String newDocumentId = matchDocumentReference.id;

    //refresh the database
    await fetch();

    //return the ID of the newly created document
    return newDocumentId;
  }

  //from KIT305 Flutter Firebase tutorial and ChatGPT
  Future updateBallOutcome(String matchId, List<Ball> balls) async {
    //from ChatGPT
    // try {
    //   await matchCollection.doc(matchId).update({
    //     'balls': balls.map((ball) => ball.toJson()).toList(),
    //   });
    // } catch (e) {
    //   print('Error updating balls in Firestore: $e');
    // }

    try {
      await matchCollection.doc(matchId).update({
        'balls': balls.map((ball) => ball.toJson()).toList(),
      });
      // await fetch();
      notifyListeners();
      print("Firestore update successful");
    } catch (e) {
      print('Error updating balls in Firestore: $e');
    }
  }

  //from ChatGPT (after my failed attempts to retrieve all documents in a collection and adding them to pastMatches list to be used in Match History screen)
  // Future<void> fetchAllPastMatches() async {
  //   pastMatches.clear();
  //   loading = true;
  //   notifyListeners();
  //
  //   try {
  //     var pastMatchQuerySnapshot = await matchCollection.get();
  //     for (var doc in pastMatchQuerySnapshot.docs) {
  //       var pastMatch =
  //       Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
  //       pastMatches.add(pastMatch);
  //     }
  //     loading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     loading = false;
  //     notifyListeners();
  //     print('Error fetching past matches: $e');
  //   }
  // }

  //Lindsay's suggestion
  //calculate total run from matchId
  int calculateTotalRun(String matchId) {
    //from Lindsay
    if (loading) return 0;
    return get(matchId)?.balls.map((ball) => ball.runs).reduce((value, element) => value + element)??0;
  }

  //Lindsay's suggestion
  //chatGPT is used to get the total number of wickets fields with non-empty string using reduce()
  // calculate total of wickets from matchId
  int calculateTotalWickets(String matchId) {
    //from Lindsay
    if (loading) return 0;
    //has rendering issue
    //wrong intialisation by me, cant figure out how to convert String --> int
    // int totalWicket = (get(matchId)?.balls.map((ball) => ball.wickets).reduce((value, element) => value + element) ?? 0);

    //helped by ChatGPT
    //get matchId of the match
    // Match? match = get(matchId);
    //
    // if (match != null) {
    //   //calculate the total wickets with non-empty String values using reduce()
    //   int totalWickets = match.balls
    //       .map((ball) => ball.wickets)
    //       .where((wicket) => wicket.isNotEmpty)
    //       .map((wicket) => 1)
    //       .reduce((value, element) => value + element);
    //   return totalWickets;
    // } else {
    //   //return 0 if match is null
    //   return 0;
    // }

    //updated by ChatGPT
    // Get the match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {

      //suggestion from Lindsay
      if (match.balls.isEmpty) {
        return 0;
      }

      // Initialize a variable to store the total wickets count
      int totalWickets = 0;

      // Iterate through the balls in the match and count wickets
      for (var ball in match.balls) {
        // Check if the wicket is not empty
        if (ball.wickets.isNotEmpty) {
          // Increment the total wickets count
          totalWickets++;
          //totalWickets += ball.wickets.length;
        }
      }
      return totalWickets;
    } else {
      // Return 0 if the match is null
      return 0;
    }

  }

  //Lindsay's suggestion
  //calculate completed overs from matchId
  //an over is completed for every 6 balls
  int calculateOversCompleted(String matchId) {
    //from Lindsay
    if (loading) return 0;
    //modified by ChatGPT a bit to include ~/ instead of / for integer division
    //where((ball) => ball.striker == currentStrikerName && ball.extras == ""
    //it already excludes balls where extras are recorded
    int over = (((get(matchId)!.balls.where((ball) => ball.extras == "").length) - 1))~/6;
    //int over = (((get(matchId)!.balls.length) - 1)/6.0) as int;
    print("This is how many balls are recorded");
    print(get(matchId)!.balls.length);
    print("This is the value of the over completed");
    print(over);
    return over;
  }

  //Lindsay's suggestion
  int calculateBallsInTheCurrentOver(String matchId) {
    //from Lindsay
    if (loading) return 0;

    // Get the match using the provided matchId
    Match? match = get(matchId);

    //suggested by ChatGPT
    if (match != null ) {
      //it excludes balls where extras are recorded
      int numberOfBallsInCurrentOver = ((get(matchId)!.balls.where((ball) => ball.extras == "").length - 1)) % 6;
      print("This is how many balls are recorded");
      print(get(matchId)!.balls.length);
      print("This is how many balls in the current over");
      print(numberOfBallsInCurrentOver);
      return numberOfBallsInCurrentOver;
    } else {
      return 0;
    }
  }

  // a function to get the striker of every ball for match history
  //made as an example by ChatGPT and modified by ChatGPT
  List<String> getStrikerOfEveryBall(String matchId) {
    //from Lindsay's suggestion (modified by ChatGPT a bit)
    if (loading) return ["Still loading..."];

    //get the match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {
      //String getStriker = ((get(matchId)!.balls.where((ball) => ball.striker == "")));
      //made as an example by ChatGPT
      List<String> strikerOfEveryBall = [];

      //iterate through each ball in the match and add the striker to the list
      match.balls.forEach((ball) {
        strikerOfEveryBall.add(ball.striker);
      });
      return strikerOfEveryBall;
    }
    return [];
  }

  //based on ChatGPT's example of how to get Striker of every ball in a specific match for match history
  // a function to get the bowler of every ball
  List<String> getBowlerOfEveryBall(String matchId) {
    //from Lindsay's suggestion
    if (loading) return ["Still loading..."];

    //get the match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {
      // initialise an empty List of String to store any bowler found for each ball
      List<String> bowlerOfEveryBall = [];

      //iterate through each ball in the match and add the bowler to the list
      match.balls.forEach((ball) {
        bowlerOfEveryBall.add(ball.bowler);
      });
      return bowlerOfEveryBall;
    }
    return [];
  }

  //based on ChatGPT's example on how to get Striker of every ball in a specific match for match history
  // a function to get ball outcome (runs) :)
  List<int> getRunsOfEveryBall(String matchId) {
    //from Lindsay's suggestion
    if (loading) return [];

    //get the match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {
      //initialise an empty list of String to store any ball outcome for each ball
      List<int> ballOutcomeOfEveryBall = [];
      match.balls.forEach((ball) {
        ballOutcomeOfEveryBall.add(ball.runs);
      });
      return ballOutcomeOfEveryBall;
    }
    return [];
  }

  //based on ChatGPT's example on how to get Striker of every ball in a specific match for match history
  // a function to get ball outcome (wickets) :D
  List<String> getWicketsOfEveryBall(String matchId) {
    //from Lindsay's suggestion
    if (loading) return ["Still loading..."];

    //get match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {
      //initialise an empty list to store wicket (or maybe extras) for each ball
      List<String> wicketOfEveryBall = [];
      match.balls.forEach((ball) {
        if (ball.wickets.isNotEmpty) {
          wicketOfEveryBall.add(ball.wickets);
        } else if (ball.wickets.isEmpty) {
          wicketOfEveryBall.add("no wicket");
        } else if (ball.extras.isNotEmpty) {
          wicketOfEveryBall.add(ball.extras);
        }

      });
      return wicketOfEveryBall;
    }
    return [];
  }

  // I decided to make it separate for displaying wicket and extras to not confuse user
  //and ensure consistency aspect of the app
  //based on ChatGPT's example on how to get Striker of every ball in a specific match for match history
  //a function to get ball outcome (extras) :D
  List<String> getExtrasOfEveryBall(String matchId) {
    //from Lindsay's suggestion
    if (loading) return ["Still loading..."];

    //get match using the provided matchId
    Match? match = get(matchId);

    if (match != null) {
      //initialise an empty list to store extras for each ball (regardless if recorded or not)
      List<String> extrasOfEveryBall = [];
      match.balls.forEach((ball) {
        if (ball.extras.isNotEmpty) {
          extrasOfEveryBall.add(ball.extras);
        } else if (ball.extras.isEmpty) {
          extrasOfEveryBall.add("no extras");
        }
      });
      return extrasOfEveryBall;
    }
    return [];
  }


  //TODO: this was done in main.dart immediately
  //Lindsay's suggestion
  // int calculateRunRate(String matchId) {
  //
  // }

  //TODO: individual score tracking function
  //to get the batter's/striker's score (based on the current striker)
  //and the current bowler too
  // a function to get the runs scored by the current batter
  //set as an example (by ChatGPT)
  int getRunsScoredByCurrentStriker(String matchId, String currentStrikerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);

    //if match exists, iterates through each element (Ball) in the array (balls) list of the specific match
    if (match != null) {
      //iterating through balls in the match
      // for (var ball in match.balls) {
      //   //checks if the ball's striker name matches with the provided currentStrikerName
      //   if (ball.striker == currentStrikerName) {
      //     //return the runs score by the specific striker
      //     get(matchId)?.balls.map((ball) => ball.runs).reduce((value, element) => value + element)??0;
      //     return ball.runs;
      //   }
      // }

      //updated by ChatGPT
      //filter balls to get only balls by the specified striker
      //the function already excludes balls where extras are recorded
      List<Ball> ballsScoredByStriker = match.balls.where((ball) => ball.striker == currentStrikerName && ball.extras == "").toList();

      //calculate the total runs scored using fold() (equivalent to reduce() but with initial value)
      int totalRunsScoredByCurrStriker = ballsScoredByStriker.fold(0, (previousValue, ball) => previousValue + ball.runs);

      //returns sum of runs scored by current striker
      return totalRunsScoredByCurrStriker;
    }
    //if no match found or striker not found, return 0 (default)
    return 0;
  }

  //based on the example set by ChatGPT
  //a function to get the runs lost by the current bowler
  //based on the example set by ChatGPT
  int getRunsLostByCurrentBowler(String matchId, String currentBowlerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);
    //if match exists, iterates through each element (Ball) in the array (balls) list of the specific match
    if (match != null) {
      //filter balls to get only balls by the specified bowler
      // the function already excludes balls where extras are recorded
      List<Ball> ballsLostByBowler = match.balls.where((ball) => ball.bowler == currentBowlerName && ball.extras == "").toList();

      //calculate the total runs lost using fold() (equivalent to reduce() but with initial value)
      int totalRunsLostByCurrBowler = ballsLostByBowler.fold(0, (previousValue, ball) => previousValue + ball.runs);

      //returns sum of runs lost by the current bowler
      return totalRunsLostByCurrBowler;
    }
    //if not match found or bowler not found, return 0 (default)
    return 0;
  }

  //based on Lindsay's suggestion
  //to get the run scored by the current non-striker
  int getRunsScoredByCurrentNonStriker(String matchId, String currentNonStrikerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);

    //if match exists, iterates through each element (Ball) in the array (balls) list of the specific match
    if (match != null) {
      //filter balls to get only balls by the specified non-striker
      //the function already excludes balls where extras are recorded
      List<Ball> ballsScoredByNonStriker = match.balls.where((ball) => ball.nonStriker == currentNonStrikerName && ball.extras == "").toList();

      //calculate the total runs scored using fold() (equivalent to reduce() but with initial value)
      int totalRunsScoredByCurrNonStriker = ballsScoredByNonStriker.fold(0, (previousValue, ball) => previousValue + ball.runs);

      //returns sum of runs scored by current striker
      return totalRunsScoredByCurrNonStriker;
    }
    //if no match found or striker not found, return 0 (default)
    return 0;
  }

  //based on the example set by ChatGPT
  //TODO: a function to get the balls-faced count by the current striker
  int getBallsFacedByCurrentStriker(String matchId, String currentStrikerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);

    //if match exists, iterates through each element (Ball) in the array (balls) list of the specified match
    if (match != null) {
      //the function already excludes balls where extras are recorded
      List<Ball> ballsFacedByStriker = match.balls.where((ball) => ball.striker == currentStrikerName && ball.extras == "").toList();
      //if (ballsFacedByStriker.length)
      //modified by ChatGPT to check if the value of the bowler field is an empty string
      //if it does, return 0 (debugged my code)
      // Check if any ball has an empty nonStriker field
      if (ballsFacedByStriker.any((ball) => ball.striker == "")) {
        return 0; // If any ball has an empty nonStriker field, return 0
      }

      //returns the calculated total balls faced by the specified striker
      return ballsFacedByStriker.length;
    }
    //if no match is found or no striker is found. Return 0 (default)
    return 0;
  }


  //based on the example set by ChatGPT
  //a function to get the balls-delivered count by current bowler
  int getBallsDeliveredByCurrentBowler(String matchId, String currentBowlerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);
    //if match exists, iterates through each element (Ball) in the array (balls) list of the specified match
    if (match != null) {
      // the function already excludes balls where extras are recorded
      List<Ball> ballsDeliveredByBowler = match.balls.where((ball) => ball.bowler == currentBowlerName && ball.extras == "").toList();

      //modified by ChatGPT to check if the value of the bowler field is an empty string
      //if it does, return 0 (debugged my code)
      // Check if any ball has an empty nonStriker field
      if (ballsDeliveredByBowler.any((ball) => ball.bowler == "")) {
        return 0; // If any ball has an empty nonStriker field, return 0
      }

      //returns the calculated total balls delivered by specified bowler
      return ballsDeliveredByBowler.length;
    }
    //if no match is found or no bowler is found. Return 0 (default)
    return 0;
  }

  //based on example set by ChatGPT
  //a function to get balls-faced count of the current non-striker
  int getBallsFacedByCurrentNonStriker(String matchId, String currentNonStrikerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);
    //if match exists, iterates through each element (Ball) in the array (balls) list of the specified match
    if (match != null) {

      // the function already excludes balls where extras are recorded
      List<Ball> ballsFacedByNonStriker = match.balls.where((ball) => ball.nonStriker == currentNonStrikerName && ball.extras == "").toList();

      //modified by ChatGPT to check if the value of the nonStriker field is an empty string
      //if it does, return 0 (debugged my code)
      // Check if any ball has an empty nonStriker field
      if (ballsFacedByNonStriker.any((ball) => ball.nonStriker == "")) {
        return 0; // If any ball has an empty nonStriker field, return 0
      }

      //suggestion from Lindsay
      if (match.balls.isEmpty) {
        return 0;
      }
      //return the calculated total balls faced by specified non striker
      return ballsFacedByNonStriker.length;

      //checks if nonStriker field has a value of an empty string, if it does return 0
      //does not work
      if (match.balls.first.nonStriker == "") {
        return 0;
      }
    }
    //if no match is found or no bowler is found. Return 0 (default)
    return 0;
  }


  //based on the example set by ChatGPT
  // to get wickets taken score by current bowler
  int getWicketsTakenByCurrentBowler(String matchId, String currentBowlerName) {
    //from Lindsay
    if (loading) return 0;
    //find the match with the given matchId
    Match? match = get(matchId);
    //if match exists, iterates through each element (Ball) in the array (balls) list of the specific match
    if (match != null) {
      // Initialize a variable to store the total wickets taken by the specified bowler
      //added by ChatGPT
      int totalWickets = 0;
      //filter balls to get only balls by the specified bowler
      List<Ball> wicketsTakenByBowler = match.balls.where((ball) => ball.bowler == currentBowlerName).toList();

      //my approach is not quite right
      // int totalWicketsTakenByCurrBowler = ballsLostByBowler
      //     .fold(0, (previousValue, ball) => if )
      //calculate the total runs lost using fold() (equivalent to reduce() but with initial value)

      //modified by ChatGPT
      // int totalWicketsTakenByCurrBowler = wicketsTakenByBowler.fold(0, (previousValue, ball) {
      //   //check if the wickets field value is empty string or not
      //   if (ball.wickets != "") {
      //     return previousValue + ball.wickets!;
      //   } else {
      //     return previousValue;
      //   }
      // });
      //
      // //returns sum of runs lost by the current bowler
      // return totalWicketsTakenByCurrBowler;

      //modified by ChatGPT
      for (var ball in match.balls) {
        //check if the ball has a wicket taken by the specified bowler and if wickets is not an empty string
        if (ball.bowler == currentBowlerName && ball.wickets.isNotEmpty) {
          //increment totalWickets count by 1 for each non-empty wicket String value
          totalWickets++;
        }
      }
      return totalWickets;
    }
    //if not match found or bowler not found, return 0 (default)
    return 0;
  }
  // a function to get the extras count displayed on the scoreboard UI
  int getExtrasCount(String matchId) {
    //from Lindsay
    if (loading) return 0;

    //find the match with the given matchId
    Match? match = get(matchId);
    //if match exists, iterates through each element (Ball) in the array (balls) list of the specified match
    if (match != null) {
      //the opposite: this function will only get the balls where extras have been recorded
      List<Ball> extrasBalls = match.balls.where((ball) => ball.extras != "").toList();

      //returns the numbers of balls where extras have been recorded
      return extrasBalls.length;
    }
    //if match is not found or does not exist
    return 0;
  }

  /*//from ChatGPT to filter/get home team players only
  List<Player> getHomeTeamPlayers() {
    return items.where((player) => player.team == homeTeamName).toList();
  }*/

  List<Match> getPastMatchesOld(String matchId) {
    return matches.where((match) => match.id != matchId).toList();
  }

  //from KIT305 Firebase Flutter tutorial
  Future getPastMatches() async {
    //clear any existing data we have gotten previously, to avoid duplicate data
    pastMatches.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all match (modified by ChatGPT to fetch a match document where the homeTeam and awayTeam match
    //with what the user has entered previously)
    var matchQuerySnapshot = await matchCollection.get();

    //iterate over the matches and add them to the list
    for (var doc in matchQuerySnapshot.docs) {
      //note from KIT305 Firebase Flutter tutorial
      //we are nit using add(Match match) function as we DO NOT want to add them to the database
      var match = Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      pastMatches.add(match);
    }

    //get all match (modified by ChatGPT to fetch a match document where the homeTeam and awayTeam match
    //with what the user has entered previously)
    // var pastMatchQuerySnapshot = await matchCollection.get();
    //
    // //iterate over the matches and add them to the list
    // for (var doc in pastMatchQuerySnapshot.docs) {
    //   //note from KIT305 Firebase Flutter tutorial
    //   //we are nit using add(Match match) function as we DO NOT want to add them to the database
    //   var pastMatch = Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
    //   matches.add(pastMatch);
    // }

    //from KIT305 Firebase Flutter tutorial
    //this line is added to artificially increase the load time, so we can see the loading indicator (wen added)
    //can be commented later :D
    //await Future.delayed(const Duration(seconds: 2));

    //we are DONE and no longer loading
    loading = false;
    update();
  }


  //from KIT305 Flutter List Tutorial
  void removeAll() {
    matches.clear();
    update();
  }

  //from KIT305 Flutter List Tutorial
  void update() { notifyListeners(); }
}
