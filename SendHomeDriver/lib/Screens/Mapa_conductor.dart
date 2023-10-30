import 'package:flutter/material.dart';
import 'package:sendhomedriver/home_page.dart';

import '../tabPages/earning_tab.dart';
import '../tabPages/home_tab.dart';
import '../tabPages/profile_tab.dart';
import '../tabPages/ratings_tab.dart';

class MapScreenDriver extends StatefulWidget {
  const MapScreenDriver({Key?key}):super(key: key);

  @override
  State<MapScreenDriver> createState() => _MapScreenDriverState();
}
class _MapScreenDriverState extends State<MapScreenDriver>  with SingleTickerProviderStateMixin{


  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index=selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    tabController=TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body:TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningsTapPage(),
          RatingsTabPage(),
          ProfileTabPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card),label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.star),label: "Ratings"),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: "Account"),
        ],
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize:14),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
