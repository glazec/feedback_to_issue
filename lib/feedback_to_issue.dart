library feedback_to_issue;

import 'package:flutter/material.dart';
import 'package:github/server.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

enum IssueTag { bug, enhancement, help_wanted }

class FeedbackDialogue {
  // BuildContext _context;
  GlobalKey<ScaffoldState> _scaffoldKey;
  String _githubSecret;
  String _githubUsername;
  String _githubRepoName;
  BuildContext _context;
  String _assignee;

  FeedbackDialogue(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,
      String githubSecret, String githubUsername, String githubRepoName,
      {String assignee}) {
    this._context = context;
    this._scaffoldKey = scaffoldKey;
    this._githubSecret = githubSecret;
    this._githubUsername = githubUsername;
    this._githubRepoName = githubRepoName;
    assignee == null
        ? this._assignee = githubUsername
        : this._assignee = assignee;
  }
// Call prompt to shwo the feedback dialogue
  prompt() {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return IssueForm(
              _scaffoldKey,
              _showSnackBar,
              _changeSubmitToSuccess,
              _githubRepoName,
              _githubSecret,
              _githubUsername,
              _changeSubmitToError,
              _assignee);
        });
  }

  _showSnackBar() {
    try {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(days: 1),
          content: new Row(
            children: <Widget>[
              SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
              new SizedBox(
                width: 10,
              ),
              new Text("Submitting")
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _changeSubmitToSuccess() {
    try {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          // duration: Duration(days: 1),
          content: new Row(
            children: <Widget>[new Text("Success")],
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _changeSubmitToError() {
    try {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: new Row(
            children: <Widget>[
              new Text("An Error has occured",
                  style: new TextStyle(color: Colors.redAccent))
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class IssueForm extends StatefulWidget {
  IssueForm(
      this._scaffoldKey,
      this.showSnackBar,
      this.changeSubmitToSuccess,
      this._githubRepoName,
      this._githubSecret,
      this._githubUsername,
      this.changeSubmitToError,
      this._assignee);
  final String _assignee;
  final VoidCallback showSnackBar;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final String _githubUsername;
  final String _githubSecret;
  final String _githubRepoName;
  final VoidCallback changeSubmitToSuccess;
  final VoidCallback changeSubmitToError;
  @override
  State<StatefulWidget> createState() => new _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final formKey = new GlobalKey<FormState>();
  String _title = '';
  String _email = '';
  IssueTag _issueTag = IssueTag.help_wanted;
  String _content = '';
  int spaceBetweenElements = 1;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void createIssue() async {
    Navigator.of(context).pop();
    widget.showSnackBar();
    print('create issue');
    var github = createGitHubClient(
        auth: new Authentication.withToken(widget._githubSecret));
    IssueRequest issueRequest = new IssueRequest();
    issueRequest.title = _title;
    issueRequest.body = _email == '' ? _content : _email + '\n' + _content;
    issueRequest.assignee = widget._assignee;
    // issueRequest.milestone=1;
    issueRequest.labels = [
      _issueTag.toString().split('.')[1].split('_').join(' ')
    ];
    try {
      var response = await github.issues.create(
          new RepositorySlug(widget._githubUsername, widget._githubRepoName),
          issueRequest);
      debugPrint('issue ' + response.toString());
      widget.changeSubmitToSuccess();
    } catch (e) {
      debugPrint(e.message);
      widget.changeSubmitToError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        title: new Text('Feedback'),
        content: new Form(
          key: formKey,
          child: Container(
            height: 350,
            width: 300,
            // child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Spacer(
                  flex: spaceBetweenElements,
                ),
                tagBuilder(),
                Spacer(
                  flex: spaceBetweenElements,
                ),
                // Title field
                new TextFormField(
                  decoration: InputDecoration(hintText: "Title"),
                  validator: (String value) {
                    return value == '' ? 'Please fill out the title.' : null;
                  },
                  onSaved: (String value) {
                    _title = value;
                  },
                ),
                Spacer(
                  flex: spaceBetweenElements,
                ),

                // email field
                new TextFormField(
                  decoration:
                      InputDecoration(hintText: "Email address(optional)"),
                  validator: (String value) {
                    return (value == ''
                        ? null
                        : value.contains('@')
                            ? null
                            : 'Please enter the correct email.');
                  },
                  onSaved: (String value) {
                    _email = value;
                  },
                ),
                Spacer(
                  flex: spaceBetweenElements,
                ),

                // content field
                new TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLengthEnforced: false,
                  maxLines: 5,
                  decoration: InputDecoration(hintText: "Leave a comment"),
                  validator: (String value) {
                    return value == '' ? 'Please leave a comment.' : null;
                  },
                  onSaved: (String value) {
                    _content = value;
                  },
                ),
              ],
            ),
            // ),
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Submit'),
            onPressed: () {
              if (validateAndSave()) {
                try {
                  createIssue();
                } catch (e) {
                  print(e);
                }
              }
            },
          ),
          new FlatButton(
            child: new Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }

  Widget tagBuilder() {
    return Container(
      height: 44.0,
      child: new ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Tooltip(
            message: 'Something isn\'t working.',
            child: FilterChip(
              // backgroundColor: Colors.transparent,
              // shape: StadiumBorder(side: BorderSide(color: Colors.greenAccent)),
              backgroundColor: Colors.red[100],
              selectedColor: Colors.red[400],
              selected: _issueTag == IssueTag.bug,
              label: Text("Bug"),
              onSelected: (bool value) {
                setState(() {
                  _issueTag = IssueTag.bug;
                });
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          new Tooltip(
            message: 'New feature or request.',
            child: FilterChip(
              backgroundColor: Colors.blue[100],
              selectedColor: Colors.blue[400],
              selected: _issueTag == IssueTag.enhancement,
              label: Text("Enhencement"),
              onSelected: (bool value) {
                setState(() {
                  _issueTag = IssueTag.enhancement;
                });
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          new Tooltip(
            message: 'Any question relating to the app.',
            child: FilterChip(
              backgroundColor: Colors.green[100],
              selectedColor: Colors.green[400],
              selected: _issueTag == IssueTag.help_wanted,
              label: Text("Other"),
              onSelected: (bool value) {
                setState(() {
                  _issueTag = IssueTag.help_wanted;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
