import 'package:flutter/material.dart';
import 'package:feedback_to_issue/feedback_to_issue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // we need scaffoldkey to share scaffold state with other widget.
      key:_scaffoldKey,
      body: Center(child: OutlineButton(
        child: new Text('Feedback'),
        onPressed: (){new FeedbackDialogue(context,_scaffoldKey,'your_github_api_token','your_github_username','your_github_repository_name');},
      ), // This trailing comma makes auto-formatting nicer for build methods.
    )
    );
}}