import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool isSwitched = false;
  List users = [];
  bool isLoading;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchUser();
  }

//check fetching data to show circular progress
  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    // fetch data from url and make isloading false to unshow circular progress
    var url = "https://api.github.com/repositories?since=364";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var items = jsonDecode(response.body);

      setState(() {
        users = items;
        isLoading = false;
      });
      //no data
    } else {
      setState(() {
        users = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List User"),
        actions: <Widget>[
          //to switch between listview and gridview
          Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              })
        ],
      ),
      body: (isSwitched == false) ? getBody() : grid(),
    );
  }

  Widget getBody() {
    // show circular progress until fetching data
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // returing data
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return getCard(users[index]);
        });
  }

  Widget getCard(item) {
    String name = item['name'];
    var id = item['id'];
    var profileUrl = item['owner']['avatar_url'];
    var acountUrl = item['html_url'];

    return InkWell(
      // show user account
      onTap: () async {
        final url = acountUrl.toString();
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(60 / 2),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(profileUrl.toString()))),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString(),
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      id.toString() + " " + " click to show profile",
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// grid view widget
  Widget grid() {
    return GridView.count(
      crossAxisCount: 1,
      scrollDirection: Axis.vertical,
      children: List.generate(users.length, (index) {
        return getCard(users[index]);
      }),
    );
  }
}
