//import 'dart:ffi';

//import 'dart:js_interop_unsafe';

import 'package:cricket_app_flutter/match.dart';
import 'package:cricket_app_flutter/player.dart';
import 'package:cricket_app_flutter/player_details.dart';
import 'package:flutter/material.dart';
//added from week 13 firebase flutter tutorial KIT305
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
//added from eclectify University - Flutter YouTube tutorial
import 'package:share_plus/share_plus.dart';
//added as suggested by ChatGPT to convert String to JSON for sharing functionality
import 'dart:convert';
//from KIT305 Camera Flutter slides
// import 'package:camera/camera.dart';
import 'dart:async';
// import 'dart:io';
//from eclectify University - Flutter's YouTube tutorial on creating photo gallery effect
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


//from week 13 firebase flutter tutorial
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

//from KIT305 Flutter tutorial
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  //this widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    //updated by ChatGPT to support creation of more than one Model
    //MultiProvider is a wrapper that allows us to make us of more than one ChangeNotifierProvider
    return MultiProvider(
      providers: [
        //ChatGPT suggested to initialise it empty at first
        //updated by ChatGPT to support creation of more than one Model
        ChangeNotifierProvider(create: (context) => MatchModel("", "")),
        ChangeNotifierProvider( create: (context) => PlayerModel("", "")),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const StartAMatchPage(),
        ),
    );
  }
}

//from KIT305 Flutter tutorial
class StartAMatchPage extends StatefulWidget {
  const StartAMatchPage({Key? key}) : super(key: key);

  @override
  State<StartAMatchPage> createState() => _StartAMatchPageState();
}

class _StartAMatchPageState extends State<StartAMatchPage> {

  //from KIT305 Flutter tutorial to send data (entered playing teams' names to main screen)
  var txtHomeTeamNameController = TextEditingController();
  var txtAwayTeamNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cricket Flutter App"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        //layout is made with the help of ChatGPT
        //previously it was child: Row
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // a TextField for the home team name
            TextField(
              controller: txtHomeTeamNameController,
              decoration: const InputDecoration(
                hintText: "Enter home team name",
                labelText: "Home team name"
              ),
            ),

            //to give some space between the two text fields for user to enter the playing teams' names
            const SizedBox(height: 16),

            // a TextField for the away team name
            TextField(
              controller: txtAwayTeamNameController,
              decoration: const InputDecoration(
                hintText: "Enter away team name",
                labelText: "Away team name"
              ),
            ),

            //to give some more space before the button
            const SizedBox(height: 32),

            //create a button (to start a match) and bring user to main screen (with scoreboard)

            Center(
              child: ElevatedButton(
                child: const Text("Start a match"),
                onPressed: () async {
                  //from chatGPT to update PlayerModel with the entered team names
                  // Provider.of<PlayerModel>(context, listen:false).updateTeams(
                  //     txtHomeTeamNameController.text,
                  //     txtAwayTeamNameController.text,
                  // ),
                  //TODO: Navigate to main screen (with scoreboard)
                  //from KIT305 Flutter tutorial
                  //check if both home team and away team is not empty
                  if (txtAwayTeamNameController.text.isNotEmpty && txtHomeTeamNameController.text.isNotEmpty) {
                    //from ChatGPT to update MatchModel with the entered team names
                    Provider.of<MatchModel>(context, listen: false).updateTeamsForMatchDoc(
                      txtHomeTeamNameController.text,
                      txtAwayTeamNameController.text,
                    );
                    //from chatGPT to update PlayerModel with the entered team names
                    Provider.of<PlayerModel>(context, listen:false).updateTeams(
                      txtHomeTeamNameController.text,
                      txtAwayTeamNameController.text,
                    );
                    await Provider.of<PlayerModel>(context, listen:false).fetch();

                    //from ChatGPT which it ensures that every time user clicks Start a match button, a new match document will be created in matchesFlutter collection
                    String newDocumentId = await Provider.of<MatchModel>(context, listen: false).add(
                        // Match(
                        //   homeTeam: txtHomeTeamNameController.text,
                        //   awayTeam: txtAwayTeamNameController.text,
                        //   balls: [], //initialised as an empty array/list
                        // ),
                        //modified from ChatGPT
                        Match.initialized(
                          txtHomeTeamNameController.text,
                          txtAwayTeamNameController.text,
                        ),
                    );
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MainScreen(homeTeamName: txtHomeTeamNameController.text, awayTeamName: txtAwayTeamNameController.text, matchId: newDocumentId),
                    ),);
                    print("This is the newly created match document with ID ${newDocumentId}");
                  } else {
                    //inspired by the error message when adding/deleting player from ChatGPT
                    //let users know that they must fill a name for both teams to proceed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please fill the names of playing home team and away team'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  // Navigator.push(context, MaterialPageRoute(
                  //     builder: (context) => MainScreen(homeTeamName: txtHomeTeamNameController.text, awayTeamName: txtAwayTeamNameController.text,),
                  // ),),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String homeTeamName;
  final String awayTeamName;
  //from KIT305 Flutter Firebase tutorial
  final String? matchId;

  // final int wicketLostScoreboard;
  // final int totalRunCountScoreboard;
  //
  // final int oversCompletedScoreboard;
  // final int numberOfBallsDeliveredInThisOverScoreboard;
  //
  // final String currentStriker;
  // final String currentNonStriker;
  // final String currentBowler;
  const MainScreen({Key? key, required this.homeTeamName, required this.awayTeamName, this.matchId}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
 //const MainScreen({Key? key, required this.homeTeamName, required this.awayTeamName, required this.wicketLostScoreboard, required this.totalRunCountScoreboard, required this.oversCompletedScoreboard, required this.numberOfBallsDeliveredInThisOverScoreboard, required this.currentStriker, required this.currentNonStriker, required this.currentBowler}) : super(key: key);

  //from ChatGPT
  // to store the previous value of totalOversCompleted
  int? _previousOversCompleted;

  //to store the previous value of totalWickets
  //based on what ChatGPT has set as an example for totalOversCompleted (for every over)
  //this is for every wicket
  int? _previousTotalWickets;

  @override
  Widget build(BuildContext context) {
    print("This is the newly created match document with ID ${widget.matchId} from StartAMatchPage");

    //layout is made with the help of ChatGPT
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Match Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //TODO: paster ehre
              //modified by ChatGPT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //The column of the home team section
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.homeTeamName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                      // create a space between the home team name display and the button to go home players list screen
                      const SizedBox(height: 16),

                      //creates the button to go to home players list screen
                      ElevatedButton(
                        child: const Text("Home players list"),
                        onPressed: () {
                          //TODO: navigate to go to the home player list screen (refer to KIT305 Flutter list tutorial)
                          //print("This will go to home player list screen later"),
                          //KIT305 Flutter tutorial
                          //to go to home player list screen
                          Navigator.push(context, MaterialPageRoute(
                              builder:(context) => HomePlayersListScreen(homeTeamName: widget.homeTeamName)
                          ));

                        },
                      ),

                      //create some space between the home players list button and record ball button
                      const SizedBox(height: 10),

                      //create the "Record Ball" button :)
                      ElevatedButton(
                        child: const Text("Record Ball"),
                        onPressed: () {
                          // Hide any current snack bar (confirmed by ChatGPT)
                          //a solution from StackOverflow
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          //from ChatGPT
                          int totalWickets = Provider.of<MatchModel>(context, listen: false)
                              .calculateTotalWickets(widget.matchId ?? "");

                          //based on the approach of limiting totalWickets
                          int totalCompletedOvers = Provider.of<MatchModel>(context, listen: false)
                              .calculateOversCompleted(widget.matchId ?? "");

                          if (totalWickets == 4) {
                            //TODO: get an error box
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("There are already 4 wickets recorded.\nThe match is over.\nPlease start a new match"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          } else if (totalCompletedOvers == 5) {
                            //TODO: get an error box
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Five overs have been completed and the match is over.\nThe match is over.\nPlease start a new match"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          } else {
                            //TODO: navigate to go to the record ball screen (refer to iOS assignment for layout and maybe Flutter Firebase tutorial)
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => RecordBallScreen(indicateText: "This is the record ball screen", matchId: widget.matchId,),
                            ));
                          }
                          // else {
                          //   //TODO: navigate to go to the record ball screen (refer to iOS assignment for layout and maybe Flutter Firebase tutorial)
                          //   Navigator.push(context, MaterialPageRoute(
                          //     builder: (context) => RecordBallScreen(indicateText: "This is the record ball screen", matchId: widget.matchId,),
                          //   ));
                          // }
                          // //TODO: navigate to go to the record ball screen (refer to iOS assignment for layout and maybe Flutter Firebase tutorial)
                          // Navigator.push(context, MaterialPageRoute(
                          //     builder: (context) => RecordBallScreen(indicateText: "This is the record ball screen", matchId: widget.matchId,),
                          // ));
                          print("This will go to record ball screen later, please refer to iOS tutorial and notes from Lindsay");
                        },
                      ),
                    ],
                  ),

                  //adjust space between the home team and away team columns
                  //Reference: ChatGPT
                  const SizedBox(width: 35),

                  //The column of the away team section
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.awayTeamName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                      //create some space between the away team name display and the button to go to the away players list screen
                      const SizedBox(height: 16),

                      //create the button to go the the away players list screen
                      ElevatedButton(
                          child: const Text("Away players list"),
                          onPressed: () {
                            //TODO: Navigate to the away player list screen (refer to KIT305 Flutter list tutorial)
                            Navigator.push(context, MaterialPageRoute(
                                builder:(context) => AwayPlayersListScreen(awayTeamName: widget.awayTeamName)
                            ));
                            print("This will go to away player list screen later");
                          }
                      ),

                      //create some space between the home players list button and match history button
                      const SizedBox(height: 10),

                      //create the "Record Ball" button :)
                      ElevatedButton(
                        child: const Text("Match History"),
                        onPressed: () async {
                          //TODO: navigate to go to the match history list screen (refer to KIT305 Flutter list tutorial and iOS assignment for layout and maybe Flutter Firebase tutorial)

                          //Provider.of<MatchModel>(context, listen: false).getAllMatches();
                          // if (Provider.of<MatchModel>(context, listen: false).pastMatches.isNotEmpty) {
                          //   await Provider.of<MatchModel>(context, listen: false).getPastMatches();
                          // }

                          //based on KIT305 Flutter tutorial
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MatchHistoryScreen(text: "This is the match history screen", matchId: widget.matchId,)
                          ));
                          //print("This will go to match history list screen later, please refer KIT305 Flutter list tutorial");
                        },
                      ),
                    ],
                  ),
                ],
              ),
          
              //add the Scoreboard text to indicate scoreboard section in the main screen of the Flutter app
              //layout is made with the help of ChatGPT
          
              //add some space between the "Scoreboard" text and "Record Ball" + "Match History" buttons
              const SizedBox(height: 10),
          
              //make a centered "Scoreboard" text alongside score details
              //layout is made with the help of ChatGPT
              Center(
                child: Column(
                  children: [
                    //make a centered "Scoreboard" text
                    Text("Scoreboard", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          
                    //create a space between "Scoreboard" text with score details
                    const SizedBox(height: 5),
          
                    //batting team score
                    //format: <wicket lost> / <total run count>
                    //row is used as the format is horizontally aligned :D
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //the wicket lost text
                          Consumer<MatchModel>(
                            builder: (context, matchModel, _) {
                              if (matchModel.loading) return CircularProgressIndicator();

                              //from ChatGPT and used as an example to implement match logic
                              //to check if wicket count has reached 4

                              //from ChatGPT (improved)
                              //define a function to show the dialog



                              // causes major error
                              // int totalWickets = matchModel.calculateTotalWickets(widget.matchId??"");
                              //
                              // //based on ChatGPT (after trial-and-error on how to get it to work)
                              // //was trying to do it in MainScreen and caused terrible errors :(
                              // //TODO: check if there are 4 wickets recorded
                              // if (totalWickets == 4) {
                              //   //display the alert box
                              //   showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return AlertDialog(
                              //           title: Text('Alert'),
                              //           content: Text("The total wickets have reached 4! The match is over\nPlease start a new match"),
                              //           // actions: <Widget>[
                              //           //   TextButton(
                              //           //     child: Text("Start a new match"),
                              //           //     onPressed: () {
                              //           //       Navigator.of(context).pop();
                              //           //     },
                              //           //   )
                              //           // ],
                              //         );
                              //       }
                              //   );
                              // }

                              //TODO: make a function in match.dart to calculate the wicket lost total
                              //alternative to prompt user to start a new match when wickets have reached 4
                              int totalWickets = matchModel.calculateTotalWickets(widget.matchId??"");

                              //to detect change in the value of totalWickets
                              //based on what ChatGPT has set as an example for the totalOversCompleted
                              if (_previousTotalWickets != null && totalWickets > _previousTotalWickets!) {
                                //TODO: call a function to randomly select a new batter from the home team
                                Provider.of<PlayerModel>(context, listen: false).appointANewStriker();
                              }
                              _previousTotalWickets = totalWickets;

                              if (totalWickets == 4) {
                                //TODO: get an error box
                                //the code below is made with the help of ChatGPT
                                //I couldnt get it to work by using plain SnackBar, but hey it is working now
                                WidgetsBinding.instance!.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Hey, There are already 4 wickets recorded.\nThe match is over.\nPlease start a new match"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                });

                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text("There are already 4 wickets recorded.\nThe match is over.\Please start a new match"),
                                //     duration: Duration(seconds: 2),
                                //   ),
                                // );
                              }


                              //return Text(matchModel.calculateTotalWickets(widget.matchId??"").toString(), style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold));
                              return Text(totalWickets.toString(), style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold));
                            }
                          ),

                          //create a space between the 'score separator' and the wicket lost text
                          const SizedBox(width: 10),

                          // the 'score separator'
                          Text("/", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),

                          //create a space between the 'score separator' and the total run count text
                          const SizedBox(width: 10),

                          //Lindsay's suggestion
                          // the total run count text
                          Consumer<MatchModel>(
                            builder: (context, matchModel, _) {
                              if (matchModel.loading) return CircularProgressIndicator();
                              //TODO: Advanced features: if an odd number is scored, the batters are swapped
                              int totalRunCount = matchModel.calculateTotalRun(widget.matchId??"");
                              //ensured from StudentCSP that the condition checks if total run count is odd
                              if (totalRunCount % 2 == 1) {
                                Provider.of<PlayerModel>(context, listen: false).swapStrikerAndNonStriker();
                              }

                              //Provider.of<PlayerModel>(context, listen: false).swapStrikerAndNonStriker();
                              return Text(matchModel.calculateTotalRun(widget.matchId??"").toString(), style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold));
                            }
                          ),
                        ],
                      ),
                    ),
          
                    //current over information
                    //format: <overs completed> . <number of balls delivered in the over>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Lindsay's suggestion
                        // the overs completed text
                        Consumer<MatchModel>(
                          builder: (context, matchModel, _) {

                            /*//alternative to prompt user to start a new match when wickets have reaced 4
                              int totalWickets = matchModel.calculateTotalWickets(widget.matchId??"");
                              if (totalWickets == 4) {
                                //TODO: get an error box
                                //the code below is made with the help of ChatGPT
                                //I couldnt get it to work by using plain SnackBar, but hey it is working now
                                WidgetsBinding.instance!.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("There are already 4 wickets recorded.\nThe match is over.\Please start a new match"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                });*/
                            //following the same approach that is applied to see if wickets have reached 4
                            int totalOversCompleted = matchModel.calculateOversCompleted(widget.matchId??"");

                            //from ChatGPT to detect change in the value of totalOversCompleted
                            if (_previousOversCompleted != null && totalOversCompleted > _previousOversCompleted!) {
                              //TODO: call function to swap striker and non-striker
                              //String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                              Provider.of<PlayerModel>(context, listen: false).swapStrikerAndNonStriker();

                              //at the end of every over, a new bowler is randomly selected from the away team
                              Provider.of<PlayerModel>(context, listen:  false).appointANewBowler();
                            }
                            _previousOversCompleted = totalOversCompleted;

                            //checks if total of the completed overs has reached 5
                            if (totalOversCompleted == 5) {
                              //TODO: get an error box
                              //using the code that was corrected by ChatGPT
                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Five overs have been completed and the match is over.\nThe match is over.\nPlease start a new match"),
                                      duration: Duration(seconds: 2),
                                  ),
                                );
                              });
                            }

                            return Text(totalOversCompleted.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold));
                            //return Text(matchModel.calculateOversCompleted(widget.matchId??"").toString(), style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold));
                          }
                        ),

                        //create a space between the 'overs separator' and the overs completed text
                        const SizedBox(width: 10),

                        // the 'overs separator'
                        Text(".", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

                        //create a space between the 'overs separator' and the number of balls delivered in the over text
                        const SizedBox(width: 10),

                        //Lindsay's suggestion
                        // the number of balls delivered in the over text
                        Consumer<MatchModel>(
                          builder: (context, matchModel, _) {
                            //TODO: made a total count function to count the number of balls delivered in the current over
                            return Text(matchModel.calculateBallsInTheCurrentOver(widget.matchId??"").toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold));
                          }
                        ),
                      ],
                    ),
          
                    const SizedBox(height: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Lindsay's suggestion
                        //for run rate
                        //TODO: make a function to calculate run rate

                        Consumer<MatchModel>(
                          builder: (context, matchModel, _) {
                            int oversCompleted = matchModel.calculateOversCompleted(widget.matchId??"");
                            int oversCompletedTimesSix = oversCompleted * 6;

                            int ballsInCurrentOver = matchModel.calculateBallsInTheCurrentOver(widget.matchId??"");

                            // int sumOfBalls = oversCompletedTimesSix + ballsInCurrentOver;

                            // ~/ is used for integer division
                            // int runRateDenominator = sumOfBalls ~/ 6;

                            int totalRunCount = matchModel.calculateTotalRun(widget.matchId??"");

                            //checks if over is 0
                            if (oversCompleted == 0) {
                              //TODO: if oversCompleted is 0
                              //return / display the number of runs (totalRunCount)
                              return Text(totalRunCount.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                            } else {
                              double runRate = totalRunCount / (((oversCompleted * 6) + ballsInCurrentOver)/6);
                              //return / display the calculated run rate
                              //from StackOverflow to display run rate in 3 decimal points
                              return Text(runRate.toStringAsFixed(3), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                            }

                            //return Text("Run rate", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                          }
                        ),

                        const SizedBox(width: 30),

                        //based on Lindsay's suggestion
                        Consumer<MatchModel>(
                          builder: (context, matchModel, _) {
                            //return Text("Extras: ${matchModel.getExtrasCount(widget.matchId??"").toString()}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                            return Text(matchModel.getExtrasCount(widget.matchId??"").toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                          }
                        ),
                      ],
                    ),
          
                    const SizedBox(height: 20),
          
                    //display batting team (home team name)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.homeTeamName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
          
                    //display the name of the current striker (from home team players collection)
                    //display the name of the other striker (non-striker) (from the home team players collection)
          
                    const SizedBox(height: 12),
          
                    //display bowling team (away team name)
                    //display batting team (home team name)
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(awayTeamName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    //   ],
                    // ),
          
                    //display "Start a new match" button
          
                    //display "Share" button
          
                    //display the name of the bowler (from the away team players collection
          
          
                  ],
                ),
              ),
              //display the name of the current striker (from home team players collection)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                //display the name of the current striker (from home team players collection)
                //and individual score tracking (Later on)
                children: [
                  /*Consumer<MatchModel>(
                          builder: (context, matchModel, _) {
                            //TODO: made a total count function to count the number of balls delivered in the current over
                            return Text(matchModel.calculateBallsInTheCurrentOver(widget.matchId??"").toString(), style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold));
                          }
                        ),*/
                  //based on Lindsay's approach and suggestion
                  //display the name of the current striker (from home team players collection)
                  Consumer<PlayerModel>(
                    builder: (context, playerModel, _) {
                      //image != null ? Image.network(image) : null
                      String? strikerImage = playerModel.getCurrentStrikerImage();
                      return Row(
                        children: [
                          //suggested by ChatGPT as an example and based on KIT305 Flutter Lists tutorial
                          //ChatGPT helped me to give an idea on how to tackle overflowing due to the placeholder if an image is not fount
                          //by resizing the Placeholder()
                          strikerImage != "" ? Image.network(strikerImage!, width: 60, height: 60) : const SizedBox(width: 0.01, height: 0.01, child: Placeholder()),
                          const SizedBox(width: 1),
                          Text(playerModel.getCurrentStrikerName().toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }
                  ),
          
                  //create some space
                  const SizedBox(width: 30),
          
                  // for batter (striker)'s run count (score tracking)
                  //for current batter's/striker's runs scored count
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      String currentStriker = playerModel.getCurrentStrikerName();
                      return Text(matchModel.getRunsScoredByCurrentStriker(widget.matchId??"", currentStriker).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),
          
                  //create some space
                  const SizedBox(width: 30),
          
                  //for batter's total balls-faced count
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      //recommended by ChatGPT
                      String currentStriker = playerModel.getCurrentStrikerName();
                      //TODO: int ballsFaced = await matchModel.getBallsFacedByCurrentStriker(widget.matchId??"", currentStriker);
                      //int ballsFacedByCurrentStriker = matchModel.getBallsFacedByCurrentStriker(widget.matchId??"", currentStriker);
                      return Text(matchModel.getBallsFacedByCurrentStriker(widget.matchId??"", currentStriker).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),
                ],
              ),
          
              //display the name of the other striker (non-striker) (from the home team players collection)
              //and individual score tracking (Later on
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                //display the name of the current striker (from home team players collection)
                //and individual score tracking (Later on)
                children: [
                  //based on Lindsay's approach and suggestion
                  //display the name of the current non-striker (from home team players collection)
                  Consumer<PlayerModel>(
                    builder: (context, playerModel, _) {
                      //image != null ? Image.network(image) : null
                      String? nonStrikerImage = playerModel.getCurrentNonStrikerImage();
                      return Row(
                        children: [
                          //based on ChatGPT's suggestion to display the image of the current striker
                          //and based on KIT305 Flutter Lists tutorial
                          //ChatGPT helped me to give an idea on how to overcome overflow issue due to Placeholder being too large
                          //modify the placeholder size to be so small
                          nonStrikerImage == "" ? const SizedBox(width: 0.01, height: 0.01, child: Placeholder()) : Image.network(nonStrikerImage!, width: 60, height: 60),
                          //nonStrikerImage != null ? Image.network(nonStrikerImage, width: 60, height: 60) : const SizedBox(width: 0.01, height: 0.01, child: Placeholder()),
                          const SizedBox(width: 1),
                          Text(playerModel.getCurrentNonStrikerName().toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }
                  ),
          
                  //create some space
                  const SizedBox(width: 30),

                  //for non-striker's total runs scored count
                  Consumer2<MatchModel,PlayerModel>(
                      builder: (context, matchModel, playerModel, _) {
                        String currentNonStriker = playerModel.getCurrentNonStrikerName();
                        return Text(matchModel.getRunsScoredByCurrentNonStriker(widget.matchId??"", currentNonStriker).toString(), style: TextStyle(fontSize: 23));
                      }
                  ),

                  const SizedBox(width: 30),
                  //for batter's total balls-faced count
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      String currentNonStriker = playerModel.getCurrentNonStrikerName();
                      return Text(matchModel.getBallsFacedByCurrentNonStriker(widget.matchId??"", currentNonStriker).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),

                  // // for b (score tracking)
                  // Text("0", style: TextStyle(fontSize: 23)),
                  //
                  // //create some space
                  // const SizedBox(width: 50),
                  //
                  // //for batter's total balls-faced count
                  // Text("0", style: TextStyle(fontSize: 23)),
                ],
              ),
          
              //display bowling team (away team name)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
          
                    Text(widget.awayTeamName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          
                    const SizedBox(height: 10),
          
                    //display "Start a new match" button

                    //display "Share" button
          
                    //display the name of the bowler (from the away team players collection
          
          
                  ],
                ),
              ),
          
              //display the name of the bowler (from the away team players collection
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*Consumer<PlayerModel>(
                    builder: (context, playerModel, _) {
                      //image != null ? Image.network(image) : null
                      String? nonStrikerImage = playerModel.getCurrentNonStrikerImage();
                      return Row(
                        children: [
                          //based on ChatGPT's suggestion to display the image of the current striker
                          //and based on KIT305 Flutter Lists tutorial
                          nonStrikerImage != null ? Image.network(nonStrikerImage, width: 60, height: 60) : Placeholder(),
                          const SizedBox(width: 1),
                          Text(playerModel.getCurrentNonStrikerName().toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }
                  ),*/
                  //display the name of the current striker (from home team players collection)
                  Consumer<PlayerModel>(
                    builder: (context, playerModel, _) {
                      //image != null ? Image.network(image) : null
                      String? bowlerImage = playerModel.getCurrentBowlerImage();
                      return Row(
                        children: [
                          //based on ChatGPT's suggestion to display the image of the current striker
                          //and based on KIT305 Flutter Lists tutorial
                          //ChatGPT helped me to overcome the overflow issue due to Placeholder being too lage
                          //we resized Placeholder to be so smalls
                          bowlerImage != "" ? Image.network(bowlerImage!, width: 60, height: 48) : SizedBox(width: 0.1, height: 0.01, child: Placeholder()),
                          Text(playerModel.getCurrentBowlerName().toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }
                  ),

                  //create some space
                  const SizedBox(width: 30),

                  // for bowler's total runs lost count (score tracking)
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      String currentBowler = playerModel.getCurrentBowlerName();
                      return Text(matchModel.getRunsLostByCurrentBowler(widget.matchId??"", currentBowler).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),

                  //create some space
                  const SizedBox(width: 25),

                  //for bowler's total balls delivered count
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      String currentBowler = playerModel.getCurrentBowlerName();
                      return Text(matchModel.getBallsDeliveredByCurrentBowler(widget.matchId??"", currentBowler).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),

                  //create some space
                  const SizedBox(width: 25),

                  //for bowler's total wicket count
                  Consumer2<MatchModel,PlayerModel>(
                    builder: (context, matchModel, playerModel, _) {
                      if (matchModel.loading) return CircularProgressIndicator();
                      String currentBowler = playerModel.getCurrentBowlerName();

                      return Text(matchModel.getWicketsTakenByCurrentBowler(widget.matchId??"", currentBowler).toString(), style: TextStyle(fontSize: 23));
                    }
                  ),
                ],
              ),
          
              const SizedBox(height: 45),
              //display "Start a new match" button
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //display "Start a new match" button
                      ElevatedButton(
                        child: const Text("Start a new match"),
                        onPressed: () {
                          //TODO: navigate to StartAMatch screen

                          //from KIT305 Flutter Tutorial
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const StartAMatchPage()
                          ),
                          );
          
                          print("This will start a new match and prompt user to enter new playing teams for the new match");
                        },
                      ),
          
                      const SizedBox(width: 45),
          
                      //display "Share" button
                      //based on a YouTube tutorial by electify University - Flutter
                      //to get the share functionality to work
                      Consumer2<MatchModel, PlayerModel>(
                        builder: (context, matchModel, playerModel, _) {
                          return IconButton(
                              onPressed: () {
                                String totalRuns = matchModel.calculateTotalRun(widget.matchId??"").toString();
                                String totalWickets = matchModel.calculateTotalWickets(widget.matchId??"").toString();
                                String currentStriker = playerModel.getCurrentStrikerName().toString();
                                String currentBowler = playerModel.getCurrentBowlerName().toString();
                                String currentNonStriker = playerModel.getCurrentNonStrikerName().toString();
                                String totalOversCompleted = matchModel.calculateOversCompleted(widget.matchId??"").toString();
                                String ballsInCurrentOver = matchModel.calculateBallsInTheCurrentOver(widget.matchId??"").toString();

                                //as suggested by ChatGPT to transform String to JSON format for sharing functionality
                                // String jsonStringShareInfo = '{"totalRuns": $totalRuns, "totalWickets": $totalWickets, "currentStriker": ${currentStriker}, "currentNonStriker": ${currentNonStriker}, "currentBowler": ${currentBowler}, "oversCompleted": ${totalOversCompleted}, "ballsInCurrentOvers": ${ballsInCurrentOver}';
                                // Map<String, dynamic> json = jsonDecode(jsonStringShareInfo);

                                //to create a Map to hold the data (suggested solution from ChatGPT)
                                Map<String, dynamic> jsonData = {
                                  'totalRuns': totalRuns,
                                  'totalWickets': totalWickets,
                                  'currentStriker': currentStriker,
                                  'currentBowler': currentBowler,
                                  'currentNonStriker': currentNonStriker,
                                  'totalOversCompleted': totalOversCompleted,
                                  'ballsInCurrentOver': ballsInCurrentOver,
                                };

                                //converting Map to JSON
                                String jsonString = jsonEncode(jsonData);


                                //Share.share("This is the text to share") as String;
                                //Share.share("Total runs: ${totalRuns}, total wickets: ${totalWickets}, current striker: ${currentStriker}, current bowler: ${currentBowler}, current non-striker: ${currentNonStriker}, total overs completed: ${totalOversCompleted}, balls in the current over: ${ballsInCurrentOver}");
                                Share.share(jsonString);
                              },
                              icon: Icon(Icons.share, color: Colors.deepOrangeAccent),
                          );
                        }
                      ),

                      // ElevatedButton(
                      //   child: const Text("Share"),
                      //   onPressed: () {
                      //     //TODO: navigate to StartAMatch screen
                      //     print("This will share the current match score");
                      //   },
                      // ),
                    ],
                  )
                ],
          
          
                //create the "Record Ball" button :)
                // ElevatedButton(
                //   child: const Text("Match History"),
                //   onPressed: () {
                //     //TODO: navigate to go to the match history list screen (refer to KIT305 Flutter list tutorial and iOS assignment for layout and maybe Flutter Firebase tutorial)
                //     print("This will go to match history list screen later, please refer KIT305 Flutter list tutorial");
                //   },
                // ),
              ),
          
          
          
          
          
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.stretch,
              //
              //   //display the name of the current striker (from home team players collection)
              //   //display the name of the other striker (non-striker) (from the home team players collection)
              //   //and individual score tracking (Later on)
              //   children: [
              //     //display the name of the current striker (from home team players collection)
              //     Text("Current striker", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              //     Text("0", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              //   ],
              //   //Text("test", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // ),
          
            ],
          ),
        ),
        // it was child: Column before
      ),
    );
  }
}


//from KIT305 Flutter tutorial
//the Home Players List Screen
//for user to add/edit/delete the players for the away team
class HomePlayersListScreen extends StatefulWidget {
  const HomePlayersListScreen({Key? key, required this.homeTeamName}) : super(key: key);

  final String homeTeamName;

  @override
  State<HomePlayersListScreen> createState() => _HomePlayersListScreenState();
}

class _HomePlayersListScreenState extends State<HomePlayersListScreen> {
  //var txtAwayNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //from KIT305 Flutter Lists tutorial
    // final List<Player> homePlayers = [
    //   Player(name: "Charles Leclerc", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/leclerc"),
    //   Player(name: "Carlos Sainz", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/sainz"),
    //   Player(name: "Lando Norris", role: "Regular player", team: widget.homeTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/norris")
    //   // "Max Verstappen",
    //   // "Fernando Alonso",
    //   // "Oscar Piastri"
    // ];

    //from KIT305 Flutter Lists tutorial
    return Consumer<PlayerModel>(
      builder: buildScaffold
    );
    //return buildScaffold(context);
  }

  Scaffold buildScaffold(BuildContext context, PlayerModel playerModel, _) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("List of Home Players"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    //added a floatingActionButton based on KIT305 Firebase Flutter tutorial
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {

        //TODO: call camera function here

        //ChatGPT helped to check how many home players have been registered
        //made the app failure-resistant to limit users to register up to 5 players for the home team
        if (playerModel.getHomeTeamPlayers().length == 5) {
          //TODO: get an error box
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("There are already 5 players registered for the home team"),
                duration: Duration(seconds: 2),
            ),
          );
        } else if (playerModel.getHomeTeamPlayers().length <= 5) {
          showDialog(context: context, builder: (context) {
            return PlayerDetails(isHomeTeam: true, teamName: widget.homeTeamName);
          });
        }
        // showDialog(context: context, builder: (context) {
        //   return PlayerDetails(isHomeTeam: true, teamName: widget.homeTeamName);
        // });
      },
    ),
    //added a floatingActionButton based on KIT305 Firebase Flutter tutorial
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //TODO: add UI here
          //modified based on KIT305 Flutter Firebase tutorial to add loading circle
          if (playerModel.loading) const CircularProgressIndicator() else Expanded(
            child: ListView.builder(
                itemBuilder: (_, index) {
                  //var homePlayer = playerModel.items[index];
                  //from ChatGPT: to make use of getHomeTeamPlayers() to get
                  //only home team players to be displayed
                  var homePlayer = playerModel.getHomeTeamPlayers()[index];
                  final image = homePlayer.image;

                  // return ListTile(
                  //   title: Text(homePlayer.name),
                  //   subtitle: Text("Team ${homePlayer.team} - ${homePlayer.role}"),
                  //   leading: image != null ? Image.network(image) : null,
                  //
                  //   //KIT305 Flutter Lists tutorial
                  //   onTap: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (context) { return PlayerDetails(id:homePlayer.id, isHomeTeam: true, teamName: widget.homeTeamName); }));
                  //   },
                  // );

                  //from Flutter Documentation for Dismissible
                  //delete the player when user swipe left/right
                  //TODO: do Dimissible for home players list here
                  //modified as a debugging result from ChatGPT (ah figured out the reason why)
                  //TODO: was showing all list of previous registered players if user has entered the same name for the home team
                  //code was written based on Flutter Documentation on Dismissible
                  return Dismissible(
                    //based on a YouTube tutorial by Flutter Guys (so that the app is failure-resistant)
                    confirmDismiss: (DismissDirection swipeDirection) async {
                      //if the player is swiped left-to-right or right-to-left (indicates user wants to delete the player)
                      if (swipeDirection == DismissDirection.startToEnd || swipeDirection == DismissDirection.endToStart) {
                        //display an alert box
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete ${homePlayer.name}?"),
                              content: Text("Are you sure you would like to delete ${homePlayer.name} from ${homePlayer.team}?"),
                              actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text("Yes, I am VERY SURE TO DELETE ${homePlayer.name}")
                                ),
                                ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Nah.. I've changed my mind. Don't delete!"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      //added by ChatGPT to make sure it works
                      //as the old one, confirmDismiss is not being shown (but in the tutorial it is shown)
                      //(probably I have missed something) --> but hey it works now! just add return false
                      return false;
                    },
                    background: Container(color: Colors.red),
                    key: ValueKey(homePlayer.id),
                    onDismissed: (DismissDirection direction) async {
                      print('Attempting to delete home player: ${homePlayer.id}');
                      try {
                        await Provider.of<PlayerModel>(context, listen: false).delete(homePlayer.id, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${homePlayer.name} deleted"), duration: Duration(seconds: 2)),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error deleting player: $e"), duration: Duration(seconds: 2)),
                        );
                      }
                    },
                    child: ListTile(
                      title: Text(homePlayer.name),
                      subtitle: Text("Team ${homePlayer.team} - ${homePlayer.role}"),
                      leading: image != "" ? Image.network(image!) : const SizedBox(width: 60, height: 60, child: Placeholder()),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return PlayerDetails(id: homePlayer.id, isHomeTeam: true, teamName: widget.homeTeamName);
                        }));
                      },
                    ),
                  );
                },
                itemCount:playerModel.getHomeTeamPlayers().length
            ),
          )
        ],
      ),
    ),
  );
  }
}


//from KIT305 Flutter tutorial
//the Away Players List Screen
//for user to add/edit/delete the players for the away team
class AwayPlayersListScreen extends StatefulWidget {
  const AwayPlayersListScreen({Key? key, required this.awayTeamName}) : super(key: key);

  final String awayTeamName;

  @override
  State<AwayPlayersListScreen> createState() => _AwayPlayersListScreenState();
}

class _AwayPlayersListScreenState extends State<AwayPlayersListScreen> {
  //var txtAwayNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //from KIT305 Flutter Lists tutorial
    // final List<Player> awayPlayers = [
    //   Player(name: "Max Verstappen", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/verstappen"),
    //   Player(name: "Fernando Alonso", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/alonso"),
    //   Player(name: "Oscar Piastri", role: "Regular player", team: widget.awayTeamName, image: "https://media.formula1.com/image/upload/f_auto,c_limit,q_75,w_1320/content/dam/fom-website/drivers/2024Drivers/piastri")
    //   // "Max Verstappen",
    //   // "Fernando Alonso",
    //   // "Oscar Piastri"
    // ];

    //return buildScaffoldAwayPlayers(context);

    //from KIT305 Flutter Lists tutorial
    return Consumer<PlayerModel>(
      builder: buildScaffoldAwayPlayers
    );
  }

  Scaffold buildScaffoldAwayPlayers(BuildContext context, PlayerModel awayPlayerModel, _) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("List of Away Players"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //based on what is implemented in the home player list
          //made the app failure-resistant to limit users to register up to 5 players for the away team
          //check if there are 5 players have been registered for the away team
          if (awayPlayerModel.getAwayTeamPlayers().length == 5) {
            //TODO: get an error box to let the user know
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("There are already 5 players registered for the away team"),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (awayPlayerModel.getAwayTeamPlayers().length <= 5) {
            showDialog(context: context, builder: (context) {
              return PlayerDetails(isHomeTeam: false, teamName: widget.awayTeamName);
            });
          }
          // showDialog(context: context, builder: (context) {
          //   return PlayerDetails(isHomeTeam: false, teamName: widget.awayTeamName);
          // });
        },
      ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //TODO: add UI here
          //modified based on KIT305 Flutter Firebase tutorial to add loading circle
          if (awayPlayerModel.loading) const CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                  itemBuilder: (_, index) {
                    //from ChatGPT: to make use of getHomeTeamPlayers() to get
                    //only home team players to be displayed
                    var awayPlayer = awayPlayerModel.getAwayTeamPlayers()[index];
                    //var awayPlayer = awayPlayerModel.items[index];
                    final image = awayPlayer.image;

                    //based on Flutter Documentation on Dismissable
                    //found in KIT305 Flutter Firebase tutorial
                    //delete the player when user swipe left/right


                //     return Dismissible(
                //       background: Container(
                //         color: Colors.red,
                //       ),
                //       key: ValueKey(awayPlayerModel.items[index].id),
                //       onDismissed: (DismissDirection direction) {
                //         setState(() async {
                //           await Provider.of<PlayerModel>(context, listen: false).delete(awayPlayerModel.items[index].id, false);
                //         });
                //       },
                //       child: ListTile(
                //           title: Text(awayPlayer.name),
                //           subtitle: Text("Team ${awayPlayer.team} - ${awayPlayer.role}"),
                //           leading: image != null ? Image.network(image) : null,
                //
                //         //KIT305 Flutter Lists tutorial
                //         onTap: () {
                //           Navigator.push(context, MaterialPageRoute(builder: (context) { return PlayerDetails(id:awayPlayer.id, isHomeTeam: false, teamName: widget.awayTeamName); }));
                //         },
                //       ),
                //     );
                //   },
                // itemCount:awayPlayerModel.getAwayTeamPlayers().length,
                //itemCount:awayPlayerModel.items.length
                    //modified as a debugging result from ChatGPT
                    //code was written based on Flutter Documentation on Dismissible
                    return Dismissible(
                      //based on a YouTube tutorial by Flutter Guys (so that the app is failure-resistant)
                      confirmDismiss: (DismissDirection swipeDirection) async {
                        //if the player is swiped from left-to-right and right-to-left (indicates user wants to delete the player)
                        if (swipeDirection == DismissDirection.startToEnd || swipeDirection == DismissDirection.endToStart) {
                          //display an alert box 
                          return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete ${awayPlayer.name}?"),
                                  content: Text("Are you sure you would like to delete ${awayPlayer.name} from ${awayPlayer.team}?"),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text("Yes, I am VERY SURE TO DELETE ${awayPlayer.name}")
                                    ),
                                    ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("Nah.. I've changed my mind. Don't delete!"),
                                    ),
                                  ],
                                );
                              },
                          );
                        }
                        //added by ChatGPT to make sure it works
                        //as the old one, confirmDismiss is not shown (but is working in the tutorial video)
                        //(probably I have missed something) --> works now by adding return false below
                        return false;
                      },
                      background: Container(color: Colors.red),
                      key: ValueKey(awayPlayer.id),
                      onDismissed: (DismissDirection direction) async {
                        print('Attempting to delete away player: ${awayPlayer.id}');
                        try {
                          await Provider.of<PlayerModel>(context, listen: false).delete(awayPlayer.id, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${awayPlayer.name} deleted"), duration: Duration(seconds: 2)),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error deleting player: $e"), duration: Duration(seconds: 2)),
                          );
                        }
                      },
                      child: ListTile(
                        title: Text(awayPlayer.name),
                        subtitle: Text("Team ${awayPlayer.team} - ${awayPlayer.role}"),
                        leading: image != "" ? Image.network(image!) : const SizedBox(width: 60, height: 60, child: Placeholder()),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return PlayerDetails(id: awayPlayer.id, isHomeTeam: false, teamName: widget.awayTeamName);
                          }));
                        },
                      ),
                    );
                  },
                itemCount: awayPlayerModel.getAwayTeamPlayers().length,
              ),
          )
        ],
      ),
    ),
  );
  }
}

//Based on KIT305 Flutter tutorial
class RecordBallScreen extends StatefulWidget {
  final String indicateText;
  final String? matchId;

  const RecordBallScreen({Key? key, required this.indicateText, this.matchId}) : super(key: key);

  @override
  State<RecordBallScreen> createState() => _RecordBallScreenState();
}

class _RecordBallScreenState extends State<RecordBallScreen> {
  //HeyFlutter.com YouTube tutorial (followed the whole tutorial)
  //menu of dismissal type options for the dismissal types selection
  List<String> dismissalTypes = ["Bowled","Caught","Caught and Bowled","Leg Before Wicket (LBW)","Run Out","Hit Wicket","Stumping"];

  //the option/dismissal type that is currently selected (by default)
  String? selectedDismissalType = "Bowled";

  //based on an example from ChatGPT on using reduce() to update "runs" field value of every element in the "balls" array
  //keep track of runs
  int runs = 0; // initialised at 0

  @override
  Widget build(BuildContext context) {
    print("This is the newly created match document with ID ${widget.matchId} from MainScreen");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Ball Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //TODO: Add UI for Record Ball screen here
            Text("Increase batting team's total runs"),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: const Text("1"),
                    //set as an example using ChatGPT
                    //to update the runs field by 1 using reduce()
                    onPressed: () async {
                      //TODO: add '1' to the runs field in firebase firestore
                      //TODO: to increase the value of runs field in the array element by 1
                      // setState(() {
                      //   //increase runs by 1
                      //   //from ChatGPT on using reduce()
                      //   runs = [runs, 1].reduce((value, element) => value + element);
                      // });

                      //from ChatGPT
                      //retrieves the Match object with the corresponding matchId
                      // Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      //
                      // if (match != null) {
                      //   //update the runs field of the last ball (element) in the array using reduce()
                      //   if (match.balls.isNotEmpty) {
                      //     match.balls.last.runs = [match.balls.last.runs, 1].reduce((value, element) => value + element);
                      //   }
                      //
                      //   //from ChatGPT
                      //   //to create a new Ball object for the current ball
                      //   Ball newBall = Ball(
                      //     bowler: "",
                      //     nonStriker: "",
                      //     runs: 0,
                      //     striker: "",
                      //     wickets: "",
                      //   );
                      //
                      //   //add the new ball to the balls array
                      //   match.balls.add(newBall);
                      //
                      //   //update the balls array in Firestore
                      //   await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);
                      // }

                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      // String currentStriker = Provider.of<PlayerModel>(context, listen: false).getHomeTeamPlayers().toString();
                      //suggested by ChatGPT to not include .toString() at the end
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();

                      if (match != null) {
                        // Update the runs field of the last ball (element) in the array using reduce()
                        if (match.balls.isNotEmpty) {
                          // //updated by ChatGPT
                          // //calculate the total runs using reduce()
                          // int totalRuns = match.balls.map((ball) => ball.runs).reduce((value, element) => value + element);
                          // setState(() {
                          //   //match.balls.last.runs = [match.balls.last.runs, 1].reduce((value, element) => value + element);
                          //   //updated by ChatGPT
                          //   match.balls.last.runs += 1; //increment by 1
                          // });

                          //from Lindsay and ChatGPT
                          match.balls.last.runs += 1;
                          match.balls.last.bowler = currentBowler;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.striker = currentStriker;

                          //from ChatGPT
                          // Create a new Ball object for the current ball
                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          // Add the new ball to the balls array
                          match.balls.add(newBall);

                          // Update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                          //print("Updated total runs using reduce(): $totalRuns");
                          print("Updated runs: ${match.balls.last.runs}");
                          print("Number of balls: ${match.balls.length}");
                        } else {
                          print("No balls found in the match. Cannot update runs.");
                        }
                      } else {
                        print("Match is null. Cannot update runs.");
                      }

                      //from Flutter Documentation on reduce method and ChatGPT
                      //runs = runs.reduce((value, element) => value + element); //wrong implementation :(

                      //go back to the previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);
                      print("This will add 1 to the runs field in Firebase later");
                    }),
                //give some space between button "1" and "2"
                const SizedBox(width: 15),
                ElevatedButton(
                    child: const Text("2"),
                    onPressed: () async {
                      //TODO: add '2' to the runs field in firebase firestore
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();


                      //from ChatGPT for error-tracking and ensuring if match is not null
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //from Lindsay and ChatGPT
                          match.balls.last.runs += 2;
                          match.balls.last.bowler = currentBowler;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.striker = currentStriker;

                          //from ChatGPT
                          // Create a new Ball object for the current ball
                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          // Add the new ball to the balls array
                          match.balls.add(newBall);

                          // Update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                          //print("Updated total runs using reduce(): $totalRuns");
                          print("Updated runs: ${match.balls.last.runs}");
                          print("Number of balls: ${match.balls.length}");
                        } else {
                          print("No balls found in the match. Cannot update runs.");
                        }
                      } else {
                        print("Match is null. Cannot update runs.");
                      }

                      //go back to the previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);
                      print("This will add 2 to the runs field in Firebase later");
                    }),
                //give some space between button "2" and "3"
                const SizedBox(width: 15),
                ElevatedButton(
                    child: const Text("3"),
                    onPressed: () async {
                      //TODO: add '3' to the runs field in firebase firestore
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();

                      //from ChatGPT for error-tracking and ensuring if match is not null
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //from Lindsay and ChatGPT
                          match.balls.last.runs += 3;
                          match.balls.last.bowler = currentBowler;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.striker = currentStriker;
                          //from ChatGPT
                          // Create a new Ball object for the current ball
                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          // Add the new ball to the balls array
                          match.balls.add(newBall);

                          // Update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                          //print("Updated total runs using reduce(): $totalRuns");
                          print("Updated runs: ${match.balls.last.runs}");
                          print("Number of balls: ${match.balls.length}");
                        } else {
                          print("No balls found in the match. Cannot update runs.");
                        }
                      } else {
                        print("Match is null. Cannot update runs.");
                      }

                      //go back to the previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);
                      print("This will add 3 to the runs field in Firebase later");
                    }),
              ],
            ),
            //TODO: add spacing here
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: const Text("4"),
                    onPressed: () async {
                      //TODO: add '4' to the runs field in firebase firestore
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();
                      //from ChatGPT for error-tracking and ensuring if match is not null
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //from Lindsay and ChatGPT
                          match.balls.last.runs += 4;
                          match.balls.last.bowler = currentBowler;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.striker = currentStriker;
                          //from ChatGPT
                          // Create a new Ball object for the current ball
                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          // Add the new ball to the balls array
                          match.balls.add(newBall);

                          // Update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                          //print("Updated total runs using reduce(): $totalRuns");
                          print("Updated runs: ${match.balls.last.runs}");
                          print("Number of balls: ${match.balls.length}");
                        } else {
                          print("No balls found in the match. Cannot update runs.");
                        }
                      } else {
                        print("Match is null. Cannot update runs.");
                      }

                      //go back to the previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);
                      print("This will add 4 to the runs field in Firebase later");
                    }),
                //give some space between button "4" and "5"
                const SizedBox(width: 15),
                ElevatedButton(
                    child: const Text("5"),
                    onPressed: () async {
                      //TODO: add '5' to the runs field in firebase firestore
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();
                      //from ChatGPT for error-tracking and ensuring if match is not null
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //from Lindsay and ChatGPT
                          match.balls.last.runs += 5;
                          match.balls.last.bowler = currentBowler;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.striker = currentStriker;
                          //from ChatGPT
                          // Create a new Ball object for the current ball
                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          // Add the new ball to the balls array
                          match.balls.add(newBall);

                          // Update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                          //print("Updated total runs using reduce(): $totalRuns");
                          print("Updated runs: ${match.balls.last.runs}");
                          print("Number of balls: ${match.balls.length}");
                        } else {
                          print("No balls found in the match. Cannot update runs.");
                        }
                      } else {
                        print("Match is null. Cannot update runs.");
                      }

                      //go back to the previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);
                      print("This will add 5 to the runs field in Firebase later");
                    }),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                child: const Text("0"),
                onPressed: () async {
                  //TODO: add '0' to the runs field in firebase firestore
                  Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                  String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                  String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                  String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();
                  //from ChatGPT for error-tracking and ensuring if match is not null
                  if (match != null) {
                    if (match.balls.isNotEmpty) {
                      //from Lindsay and ChatGPT
                      match.balls.last.runs += 0;
                      match.balls.last.bowler = currentBowler;
                      match.balls.last.nonStriker = currentNonStriker;
                      match.balls.last.striker = currentStriker;
                      //from ChatGPT
                      // Create a new Ball object for the current ball
                      Ball newBall = Ball(
                        bowler: "",
                        nonStriker: "",
                        runs: 0,
                        striker: "",
                        wickets: "",
                        extras: "",
                      );

                      // Add the new ball to the balls array
                      match.balls.add(newBall);

                      // Update the balls array in Firestore
                      await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                      //print("Updated total runs using reduce(): $totalRuns");
                      print("Updated runs: ${match.balls.last.runs}");
                      print("Number of balls: ${match.balls.length}");
                    } else {
                      print("No balls found in the match. Cannot update runs.");
                    }
                  } else {
                    print("Match is null. Cannot update runs.");
                  }

                  //go back to the previous screen (main screen with scoreboard)
                  //based on Flutter Lists KIT305 tutorial
                  Navigator.pop(context);
                  print("This will add 0 to the runs field in Firebase later");
                }),
            const SizedBox(height: 20),
            Text("Select a dismissal type for wicket"),

            //TODO: create a drop-down button for recording dismissal type
            //HeyFlutter.com YouTube tutorial (followed the whole tutorial)
            DropdownButton<String>(
                value: selectedDismissalType,
                items: dismissalTypes
                    .map((dismissalType) => DropdownMenuItem<String>(
                    value: dismissalType,
                    child: Text(dismissalType),
                )).toList(),
                //slightly modified by ChatGPT to redirect user to main screen with scoreboard
                // after user has made a selection. The code is based on an online tutorial video by HeyFlutter.com
                onChanged: (dismissalType) async {
                  setState(() {
                    selectedDismissalType = dismissalType;
                  });
                  //TODO: updates the value of wicket field in firebase firestore
                  Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                  String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                  String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                  String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();
                  if (match != null) {
                    if (match.balls.isNotEmpty) {
                      //ensured by ChatGPT to update the value of the wicket field in firebase
                      //based on Lindsay's suggestion too
                      // Ensure dismissalType is not null
                      match.balls.last.wickets = dismissalType ?? "";
                      match.balls.last.runs += 0;
                      match.balls.last.bowler = currentBowler;
                      match.balls.last.nonStriker = currentNonStriker;
                      match.balls.last.striker = currentStriker;

                      //from ChatGPT
                      // Create a new Ball object for the current ball
                      Ball newBall = Ball(
                        bowler: "",
                        nonStriker: "",
                        runs: 0,
                        striker: "",
                        wickets: "",
                        extras: "",
                      );

                      // Add the new ball to the balls array
                      match.balls.add(newBall);

                      // Update the balls array in Firestore
                      await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);

                      //print("Updated total runs using reduce(): $totalRuns");
                      //print("Last wicket recorded is ${match.balls.last.wickets - 1}");
                      print("Wicket is updated successfully. check firebase");
                      print("Updated wicket: ${match.balls.last.wickets}");
                      print("Number of balls: ${match.balls.length}");
                    } else {
                      print("No balls found in the match. Cannot update runs.");
                    }
                  } else {
                    print("Match is null. Cannot update runs.");
                  }

                  //TODO: go back to main screen with scoreboard (previous screen)
                  //go back to the previous screen (main screen with scoreboard)
                  //based on Flutter Lists KIT305 tutorial
                  Navigator.pop(context);
                }
                //original code, written by following an online tutorial on YouTube by HeyFlutter.com
                //onChanged: (dismissalType) => setState(() => selectedDismissalType = dismissalType),
            ),

            //spacing
            const SizedBox(height: 20),
            Text("Select type of extras"),
            const SizedBox(height: 10),
            //based on KIT305 Flutter tutorial
            //to allow user to select extras type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //the "No Ball" button for extras
                ElevatedButton(
                    child: const Text("No Ball"),
                    onPressed: () async {
                      //TODO: add/record "No Ball" as the value of extras field in Firebase
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();

                      //if match is not null, it exists
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //records extras as "No Ball" and record the current striker, non-striker, and bowler
                          match.balls.last.extras = "No Ball";
                          match.balls.last.runs += 1;
                          match.balls.last.striker = currentStriker;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.bowler = currentBowler;

                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          //add new ball to the balls array
                          match.balls.add(newBall);

                          //update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);
                          print("'No Ball' is recored as an extras type");
                        } else {
                          print("No balls found in the match. Cannot update extras type");
                        }
                      } else {
                        print("Match is null. Cannot update extras type");
                      }

                      // go back to previous screen (main screen with scoreboar)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);

                      print("This will save 'No Ball' as the extra type");
                    },
                ),
                const SizedBox(width: 20),
                //the "Wide" button for extras
                ElevatedButton(
                    child: const Text("Wide"),
                    onPressed: () async {
                      //TODO: add/record "Wide" as the value of extras in Firebase
                      Match? match = Provider.of<MatchModel>(context, listen: false).get(widget.matchId);
                      String currentStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentStrikerName();
                      String currentNonStriker = Provider.of<PlayerModel>(context, listen: false).getCurrentNonStrikerName();
                      String currentBowler = Provider.of<PlayerModel>(context, listen: false).getCurrentBowlerName();

                      //if match is not null, it exists
                      if (match != null) {
                        if (match.balls.isNotEmpty) {
                          //records extras as "Wide" and record the current striker, non-striker, and bowler
                          match.balls.last.extras = "Wide";
                          match.balls.last.runs += 1;
                          match.balls.last.striker = currentStriker;
                          match.balls.last.nonStriker = currentNonStriker;
                          match.balls.last.bowler = currentBowler;

                          Ball newBall = Ball(
                            bowler: "",
                            nonStriker: "",
                            runs: 0,
                            striker: "",
                            wickets: "",
                            extras: "",
                          );

                          //add new ball to the balls array
                          match.balls.add(newBall);

                          //update the balls array in Firestore
                          await Provider.of<MatchModel>(context, listen: false).updateBallOutcome(match.id, match.balls);
                          print("'Wide' is recorded as an extras type");
                        } else {
                          print("No balls found in the match. Cannot update extras type");
                        }
                      } else {
                        print("Match is null. Cannot update extras type");
                      }

                      // go back to previous screen (main screen with scoreboard)
                      //based on Flutter Lists KIT305 tutorial
                      Navigator.pop(context);

                      print("This will save 'Wicket' as the extra type");
                    },
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}

//implementing the match history screen
//based on KIT305 Flutter tutorials
class MatchHistoryScreen extends StatefulWidget {
  final String text;
  final String? matchId;

  const MatchHistoryScreen({Key? key, required this.text, this.matchId}) : super(key: key);

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();

}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {

  //from KIT305 Lists Flutter tutorial
  // final List<Match> pastMatches = [
  //   Match(homeTeam: "Melbourne", awayTeam: "Hobart", balls: []),
  //   Match(homeTeam: "New Zealand", awayTeam: "Australia", balls: [])
  // ];


  @override
  Widget build(BuildContext context) {

    //based on KIT305 Flutter Lists tutorial
    return Consumer<MatchModel>(
      builder:buildScaffoldMatchHistory
    );
  }

  Scaffold buildScaffoldMatchHistory(BuildContext context, MatchModel matchModel, _) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("Match History Screen"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    //from KIT305 Flutter Lists tutorial
    body: Center (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //TODO: add UI for match history here
          //based on KIT305 Flutter Lists tutorial
          if (matchModel.loading) const CircularProgressIndicator() else Expanded(
            child: ListView.builder(
                itemBuilder: (_, index) {
                  //playerModel.getHomeTeamPlayers()[index]
                  var pastMatch = matchModel.matches[index];
                  return ListTile(
                    title: Center(child: Text("${pastMatch.homeTeam} vs. ${pastMatch.awayTeam}")),
                    subtitle: Center(
                        child: Consumer2<MatchModel,PlayerModel>(
                          builder: (context, matchModel, playerModel, _) {
                            //String totalRunPastMatch = matchModel.calculateTotalRun(pastMatch.id).toString();
                            //style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold
                            return Text("${matchModel.calculateTotalWickets(pastMatch.id).toString()} / ${matchModel.calculateTotalRun(pastMatch.id).toString()}", style: TextStyle(fontSize: 20));
                          }
                        )
                    ),
                    onTap: () {
                      //based on KIT305 Flutter tutorial
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MatchHistoryDetailsScreen(text: "This is the match history screen", matchId: pastMatch.id)
                      ));
                      print("This will go to match history details");
                    }
                    // subtitle: Text("${mat}"),
                  );
                },
                itemCount:matchModel.matches.length
              // itemCount: matchModel.matches.length,
            ),
          )
        ],
      ),
    )
  );
  }
}

//based on KIT305 Flutter tutorials
class MatchHistoryDetailsScreen extends StatefulWidget {
  final String text;
  final String? matchId;
  const MatchHistoryDetailsScreen({Key? key, required this.text, this.matchId}) : super(key: key);

  @override
  State<MatchHistoryDetailsScreen> createState() => _MatchHistoryDetailsScreenState();
}

class _MatchHistoryDetailsScreenState extends State<MatchHistoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {

    //return buildScaffoldBallOutcomesMatchHistory(context);
    //from KIT305 Flutter tutorial
    return Consumer<MatchModel>(
      builder: buildScaffoldBallOutcomesMatchHistory
    );
  }

  Scaffold buildScaffoldBallOutcomesMatchHistory(BuildContext context,MatchModel matchModel, _) {
    //debugged from ChatGPT to help getting the specific tapped matchId
    //when I did it, it doesnt retrieve the specific tapped match's id
    if (widget.matchId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Ball Outcomes | Match History"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Text("No match ID provided"),
        ),
      );
    }

    //SOLUTION: this line here filters to only display the match of the tapped cell
    var match = matchModel.matches.firstWhere((match) => match.id == widget.matchId);

    if (match == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Ball Outcomes | Match History"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Text("Match not found."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ball Outcomes | Match History"),
        //title: Text("${match.homeTeam} vs. ${match.awayTeam}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text("This is the match ID of the tapped match: ${match.id}"),
            //style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold
            //Text("This is the match of ${match.homeTeam} vs ${match.awayTeam}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("${match.homeTeam} vs ${match.awayTeam}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //Text("${matchModel.getStrikerOfEveryBall(match.id)}"),
            //based on KIT305 Flutter Lists tutorial and ChatGPT
            if (matchModel.loading) const CircularProgressIndicator() else Expanded(
                child: ListView.builder(
                    //TODO: from ChatGPT: kind of makes sense as striker field will never be empty
                    //TODO: unless a bug or a new unrecorded ball :D
                    //TODO: -1 is there to exclude the last element in the balls array (as that is an unrecorded ball) --> confirmed by ChatGPT
                    itemCount: matchModel.getStrikerOfEveryBall(match.id).length - 1,
                    itemBuilder: (context, index) {
                      String striker = matchModel.getStrikerOfEveryBall(match.id)[index];
                      String bowler = matchModel.getBowlerOfEveryBall(match.id)[index];
                      int ballOutcomeOfEveryBall = matchModel.getRunsOfEveryBall(match.id)[index];
                      String wicket = matchModel.getWicketsOfEveryBall(match.id)[index];
                      String extras = matchModel.getExtrasOfEveryBall(match.id)[index];
                      return ListTile(
                        title: Center(
                            child: Text("${striker}  -  ${bowler}")
                        ),
                        subtitle: Center(
                            child: Text("${ballOutcomeOfEveryBall}, ${wicket}, and ${extras}")
                        ),
                        //from Flutter Documentation on ListTile
                        //isThreeLine: true,
                      );
                    }
                )
            )
          ],
        ),
      )
    );


  //   return Scaffold(
  //   appBar: AppBar(
  //     title: const Text("Ball Outcomes | Match History"),
  //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //   ),
  //   body: Center (
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         //TODO: add UI for match history here
  //         //based on KIT305 Flutter Lists tutorial
  //         if (matchModel.loading) const CircularProgressIndicator() else Expanded(
  //           child: ListView.builder(
  //               itemBuilder: (_, index) {
  //                 //playerModel.getHomeTeamPlayers()[index]
  //                 var pastMatch = matchModel.matches[index];
  //                 return ListTile(
  //                     title: Consumer2<MatchModel, PlayerModel>(
  //                       builder: (context, matchModel, playerModel, _) {
  //                         return Center(
  //                             child: Consumer2<MatchModel,PlayerModel>(
  //                               builder: (context, matchModel, playerModel, _) {
  //                                 return Text("${pastMatch.id}");
  //                               }
  //                             ));
  //                       }
  //                     ),
  //                     subtitle: Center(
  //                         child: Consumer2<MatchModel,PlayerModel>(
  //                             builder: (context, matchModel, playerModel, _) {
  //                               //String totalRunPastMatch = matchModel.calculateTotalRun(pastMatch.id).toString();
  //                               //return Text("${matchModel.calculateTotalWickets(pastMatch.id).toString()} / ${matchModel.calculateTotalRun(pastMatch.id).toString()}");
  //                               return Text("Subtitle");
  //                             }
  //                         )
  //                     ),
  //                     onTap: () {
  //                       //based on KIT305 Flutter tutorial
  //                       Navigator.push(context, MaterialPageRoute(
  //                           builder: (context) => MatchHistoryDetailsScreen(text: "This is the match history screen", matchId: widget.matchId,)
  //                       ));
  //                       print("This will go to match history details");
  //                     }
  //                   // subtitle: Text("${mat}"),
  //                 );
  //               },
  //               itemCount:matchModel.matches.length
  //             // itemCount: matchModel.matches.length,
  //           ),
  //         )
  //       ],
  //     ),
  //   ) //add widgets here
  // );
  }
}









// import 'package:flutter/material.dart';
// //added from week 13 firebase flutter tutorial
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
//
// //from week 13 firebase flutter tutorial
// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   var app = await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
