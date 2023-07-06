import 'package:flutter/material.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';

createListPasien(List pasien, String status_lanjut, scrollController) {

  if (status_lanjut.toLowerCase() == "ranap"){
    pasien = pasien.where((element) => element % 2 == 1).toList();
  } else if (status_lanjut.toLowerCase() == "ralan"){
    pasien = pasien.where((element) => element % 2 == 0).toList();
  } else {
    pasien = pasien;
  }

  return ListView.builder(
    shrinkWrap: true,
    itemCount: pasien.length,
    controller: scrollController,
    padding: EdgeInsets.all(10),
    itemBuilder: (context, index) {
      return createCardPasien(pasien[index]);
    },
  );
}