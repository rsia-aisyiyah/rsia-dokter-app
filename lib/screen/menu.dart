import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/msg.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: GridView.builder(
          itemCount: menuScreenItems.length,
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Msg.success(
                  context,
                  "Opened Screen ${menuScreenItems[index]['label'].toString()}",
                );
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: 1.3,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuScreenItems[index]['label'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: fontWeightSemiBold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -15,
                      right: -20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "https://raw.githubusercontent.com/hungps/flutter_pokedex/master/assets/images/pokeball.png",
                            fit: BoxFit.cover,
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
