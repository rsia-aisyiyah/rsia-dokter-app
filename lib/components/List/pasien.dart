import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/utils/msg.dart';

class CreatePasienList extends StatefulWidget {
  final List pasien;
  final ScrollController scrollController;

  const CreatePasienList(
      {super.key,
      this.pasien = const [],
      required this.scrollController});

  @override
  State<CreatePasienList> createState() => _CreatePasienListState();
}

class _CreatePasienListState extends State<CreatePasienList> {
  List pasien = [];

  @override
  initState() {
    super.initState();
    pasien = widget.pasien;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Cari Pasien",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Filter Pasien",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: fontWeightSemiBold,
                              ),
                            ),

                            // button ganjul genap
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                // // setState(() {
                                // //   pasien = widget.pasien.where((element) => element % 2 == 1).toList();
                                // // });
                                // Msg.success(context, "Berhasil memfilter pasien ganjil");
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Ganjil",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // henap
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                // setState(() {
                                //   pasien = pasien = widget.pasien.where((element) => element % 2 == 0).toList();
                                // });
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Genap",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    isScrollControlled: true,
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pasien.length,
            controller: widget.scrollController,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              return createCardPasien(pasien[index]);
            },
          ),
        ),
      ],
    );
  }
}