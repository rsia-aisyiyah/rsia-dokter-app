import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/helper.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String spesialis = "";

  @override
  initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        spesialis = prefs.getString('spesialis')!;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    List filteredTabs = menuScreenItems.where((tab) {
        final showOn = tab['show_on'] as Set;
        return showOn.contains(spesialis.toLowerCase().replaceAll('"', ''));
      }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash-bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Menu Aplikasi",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: fontSemiBold,
                      color: textColor,
                    ),
                  ),
                ),
                GridView.builder(
                  itemCount: filteredTabs.length,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    top: 0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (filteredTabs[index]['disabled'] == true) {
                          Msg.warning(
                            context,
                            featureNotAvailableMsg,
                          );
                        } else {
                          if (filteredTabs[index]['widget'] == "") {
                            Msg.warning(
                              context,
                              featureNotAvailableMsg,
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => filteredTabs[index]['widget'] as Widget,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: filteredTabs[index]['disabled'] == true
                              ? Colors.grey[300]
                              : bgWhite,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: filteredTabs[index]['disabled'] == true
                                ? Colors.grey[400]!
                                : accentColor.withOpacity(0.8),
                            // color: primaryColor.withOpacity(0.5),
                            width: 1.3,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: -25,
                              right: -10,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.22,
                                child: Transform(
                                  transform: Matrix4.rotationZ(-0.2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    // icon from filteredTabs[index]['icon']
                                    child: Icon(
                                      filteredTabs[index]['icon'] as IconData,
                                      size: 80,
                                      color: filteredTabs[index]['disabled'] == true
                                          ? Colors.grey[400]
                                          : accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // circle on background
                            Positioned(
                              top: -45,
                              left: -45,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: filteredTabs[index]['disabled'] == true
                                      ? Colors.grey[400]
                                      : accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -45,
                              left: -45,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: filteredTabs[index]['disabled'] == true
                                      ? Colors.grey[400]
                                      : accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredTabs[index]['label'].toString(),
                                    style: TextStyle(
                                      fontSize: Helper.getFontSize(context, mobileBody),
                                      fontWeight: fontSemiBold,
                                      color: filteredTabs[index]['disabled'] == true
                                          ? Colors.grey[600]
                                          : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
