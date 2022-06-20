import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket socket = io(
    //Obviously point to the .env file here for the API URL
    "https://auction-platform-api-dev.eu-gb.mybluemix.net", //dotenv.env["API_URL"].toString(),
    OptionBuilder().setTransports(["websocket"]).disableAutoConnect().build(),
  );

  List<dynamic> bids = [];

  @override
  void initState() {
    //Initialize and connect the RTC pipe to the bidding socket.
    initializePipe();

    super.initState();
  }

  @override
  void dispose() {
    // CLOSE/DISPOSE the socket when this screen is closed.
    socket.dispose();

    super.dispose();
  }

  //PUT THIS IN YOUR BIDDING SCREEN
  initializePipe() {
    // Use a provider to popupatre these values instead.
    // UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String auctionID = "62a9cf0ab05c83fb9e276e8c";
    String lotID = "62a9cfb8b05c83fb9e276e96";
    String userID = "6261882b860e44213bf476f5";

    socket.connect(); // Because we disabled auto connect earlier, we need to connect here.

    socket.onConnect((data) {
      print("connected - emitting");

      // Tell the socket WHO THIS IS.
      socket.emit("setUserAndJoinLotPipe", {
        // This object MUST look like this when you send it to my API.
        "user_id": userID,
        "auction_id": auctionID,
        "lot_id": lotID,
      });
    });

    //For new incoming BIDS.
    socket.on(
      "newBid",
      (data) {
        print("newBid");
        print(data);

        //Set your state
        setState(() {
          //Here, I push the new data on top of the array,
          //and then I spread the rest of the items below it.
          //It results in the latest record being on top.
          bids = [data, ...bids];
        });
      },
    );

    //When an error occurs
    socket.onError((data) {
      print("onError");
      print(data);
      //TODO show popup?
    });

    //When connection fails.
    socket.onConnectError((data) {
      print("onConnectError");
      print(data);
      //TODO show popup?
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("socket.io bidding client"),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: bids.map<Widget>((bid) {
            //DO WHATEVER YOU NEED HERE
            return Container(
              child: Row(children: [
                Text("R"),
                Text(bid["bid_amount"]),
                Text(" - "),
                Text(bid["user_name"]),
                Text(" "),
                Text(bid["user_surname"]),
                Text(" [${bid["created_at"]}]"),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }
}
