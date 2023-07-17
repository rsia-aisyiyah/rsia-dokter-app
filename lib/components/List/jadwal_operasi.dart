import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_list_jadwa_operasi.dart';
import 'package:rsiap_dokter/config/config.dart';

class CreateJadwalOperasiList extends StatefulWidget {
  final List pasien;
  const CreateJadwalOperasiList({super.key, this.pasien = const []});

  @override
  State<CreateJadwalOperasiList> createState() =>
      _CreateJadwalOperasiListState();
}

class _CreateJadwalOperasiListState extends State<CreateJadwalOperasiList> {
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
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      hintText: "Cari Pasien",
                      prefixIcon: const Icon(Icons.search),
                      focusColor: accentColor,
                      prefixIconColor: accentColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: accentColor,
                        ),
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
                                  color: accentColor,
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
                                  color: accentColor,
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
                    color: accentColor,
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
        pasien.isEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Text(
                    "Tidak ada pasien",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: fontWeightSemiBold,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pasien.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return createCardJadwalOperasi(pasien[index]);
                },
              ),
      ],
    );
  }
}
