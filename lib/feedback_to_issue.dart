library feedback_to_issue;

import 'package:flutter/material.dart';
import 'package:github/server.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}


class FeedbackDialogue {
  // BuildContext _context;
  GlobalKey<ScaffoldState> _scaffoldKey;
  String _githubSecret;
  String _githubUsername;
  String _githubRepoName;
  BuildContext _context;
  String _assignee;
  List<Tag> _feedbackTags;

  FeedbackDialogue(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,
      String githubSecret, String githubUsername, String githubRepoName,
      {String assignee,List<Tag> feedbackTags}) {
    this._context = context;
    this._scaffoldKey = scaffoldKey;
    this._githubSecret = githubSecret;
    this._githubUsername = githubUsername;
    this._githubRepoName = githubRepoName;
    assignee == null
        ? this._assignee = githubUsername
        : this._assignee = assignee;
    feedbackTags==null
        ? this._feedbackTags= [Tag(Colors.red, 'Something isn\'t working.','Bug','bug'),Tag(Colors.blue,'New feature or request.','Enhencement','enhencement'),Tag(Colors.purple,'Any questions related to the app','Other','question')]
        : this._feedbackTags = feedbackTags;
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
              _assignee,
              _feedbackTags
              );
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
      this._assignee,
      this._feedbackTags
      );
  final String _assignee;
  final VoidCallback showSnackBar;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final String _githubUsername;
  final String _githubSecret;
  final String _githubRepoName;
  final VoidCallback changeSubmitToSuccess;
  final VoidCallback changeSubmitToError;
  final List<Tag> _feedbackTags;
  @override
  State<StatefulWidget> createState() => new _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final formKey = new GlobalKey<FormState>();
  String _title = '';
  String _email = '';
  String _issueTag = '';
  String _content = '';
  int spaceBetweenElements = 1;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate() && _issueTag != '') {
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
      // _issueTag.toString().split('.')[1].split('_').join(' ')
      _issueTag
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
                // tagBuilder(),
                makeTags(widget._feedbackTags),
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

// generating widgets for tags through user input
  Widget makeTags(List<Tag> rawTag) {
    List<Widget> tags = new List();
    rawTag.forEach((element) {
      tags.add(makeTag(element));
      tags.add(SizedBox(
        width: 10,
      ));
    });
    return Container(
      height: 44.0,
      child: new ListView(
        scrollDirection: Axis.horizontal,
        children:tags ));
  }

//Generate widget for one Tag
  Widget makeTag(Tag rawTag) {
    return (new Tooltip(
      message: rawTag.tip,
      child: FilterChip(
        // backgroundColor: Colors.transparent,
        // shape: StadiumBorder(side: BorderSide(color: Colors.greenAccent)),
        backgroundColor: rawTag.color[100],
        selectedColor: rawTag.color[400],
        selected: _issueTag == rawTag.value,
        label: Text(rawTag.label),
        onSelected: (bool value) {
          setState(() {
            _issueTag = rawTag.value;
          });
        },
      ),
    ));
  }

 
}

class Tag {
  final MaterialColor color; // The main color of the tag.Eg: Colors.green
  final String
      tip; // The tips of the tag. When user pressing it for a long time, it will appear.
  final String label; //The lable of the tag,which appear on the tag.
  final String
      value; //The value of the tag will be the lable of the github issue.
  Tag(this.color, this.tip, this.label, this.value);
}
