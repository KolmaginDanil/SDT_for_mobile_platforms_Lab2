import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'myIcons.dart';
import 'mainWidgets/Documents.dart';
import 'mainWidgets/Menu.dart';
import 'mainWidgets/Messages.dart';
import 'mainWidgets/Services.dart';

void main() => runApp(MainWidget());

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int pageNumber = 0;
  int documentsPageNumber = 0;
  double initialBrightness;
  double brightness;

  bool isBlack = true;

  void changeDocumentsPageNumber(int i) =>
      setState(() => documentsPageNumber = i);

  void setBrightness(b) {
    Screen.setBrightness(b);
    setState(() {
      brightness = b;
    });
  }

  void initPlatformState() async {
    double newBrightness = await Screen.brightness;
    setBrightness(newBrightness);
    setState(() {
      initialBrightness = newBrightness;
    });
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
    _takeThemeColor();
  }

  Future<void> _takeThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final takenIsBlack = prefs.getBool('themeColorIsBlack');
    setState(() => isBlack = takenIsBlack ?? true);
  }

  Future<void> _changeThemeColor(bool newIsBlack) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeColorIsBlack', newIsBlack);
    setState(() => isBlack = newIsBlack);
  }

  @override
  Widget build(BuildContext context) {
    var mainWidgets = [
      Documents(documentsPageNumber, changeDocumentsPageNumber),
      Services(),
      Messages(),
      Menu()
    ];
    var mainPage = mainWidgets[pageNumber];
    var title = pageNumber == 0 ? '' : BottomNavBarItems[pageNumber][2];
    var myGreyColor = documentsPageNumber != null
        ? colors[documentsPageNumber]
        : Colors.grey[350];
    var myBlueGreyColor = documentsPageNumber != null
        ? colors[documentsPageNumber]
        : Colors.blueGrey[200];

    Color themeColor = isBlack ? Colors.black : Colors.white;

    return MultiProvider(
      providers: [
        Provider<Function>(
            create: (context) => (newBrightness) => newBrightness == 1.0
                ? setBrightness(1.0)
                : setBrightness(initialBrightness))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: myBlueGreyColor,
        ),
        title: 'Дія',
        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            elevation: 0,
            title: Text(
              title,
              style: TextStyle(
                color: themeColor,
              ),
            ),
            backgroundColor: myBlueGreyColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                MyFlutterApp.a,
                size: 50,
                color: themeColor,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                   icon: Icon(
                     Icons.qr_code_scanner,
                     size: 25,
                     color: themeColor,
                   ),
                  onPressed: () => _changeThemeColor(!isBlack),
                ),
              ),
            ],
          ),
          body: mainPage,
          backgroundColor: myGreyColor,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: themeColor,
            unselectedItemColor: themeColor,
            currentIndex: pageNumber,
            backgroundColor: myGreyColor,
            items: [
              for (var i = 0; i < BottomNavBarItems.length; i++)
                BottomNavigationBarItem(
                    icon: IconButton(
                      icon: Icon(
                        BottomNavBarItems[i][0],
                      ),
                      onPressed: () => setState(() {
                        pageNumber = i;
                        i == 0
                            ? documentsPageNumber = 0
                            : documentsPageNumber = null;
                      }),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        BottomNavBarItems[i][1],
                      ),
                    ),
                    label: BottomNavBarItems[i][2])
            ],
          ),
        ),
      ),
    );
  }
}
