import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPasienRanap extends StatefulWidget {
  const ListPasienRanap({super.key});

  @override
  State<ListPasienRanap> createState() => _ListPasienRanapState();
}

class _ListPasienRanapState extends State<ListPasienRanap> {
  SharedPreferences? pref;

  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataPasien = [];

  bool isLoading = true;
  bool btnLoading = false;

  String? spesialis;

  @override
  void initState() {
    super.initState();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  void _setData(value) {
    if (mounted) {
      if (value['data']['total'] != 0) {
        setState(() {
          dataPasien = value['data']['data'] ?? [];

          nextPageUrl = value['data']['next_page_url'] ?? '';
          prevPageUrl = value['data']['prev_page_url'] ?? '';
          currentPage = value['data']['current_page'].toString();
          lastPage = value['data']['last_page'].toString();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          dataPasien = value['data']['data'] ?? [];
        });
      }
    }
  }

  Future fetchPasien() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var spesialis = localStorage.getString('spesialis');
    var strUrl = "";

    if (spesialis!.toLowerCase().contains('umum')) {
      strUrl = '/pasien/ranap/all';
    } else {
      strUrl = '/pasien/ranap/now';
    }

    var res = await Api().getData(strUrl);
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);
      return body;
    }
  }

  // Load More
  Future<void> loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      var res = await Api().getDataUrl(nextPageUrl);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        setState(() {
          dataPasien.addAll(body['data']['data']);

          nextPageUrl = body['data']['next_page_url'] ?? '';
          prevPageUrl = body['data']['prev_page_url'] ?? '';
          currentPage = body['data']['current_page'].toString();
          lastPage = body['data']['last_page'].toString();
        });
      } else {
        var body = json.decode(res.body);
        Msg.error(context, body['message']);

        setState(() {
          btnLoading = false;
        }); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataPasien.isEmpty ? 1 : dataPasien.length,
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            itemBuilder: (context, index) {
              if (dataPasien.isEmpty) {
                return const BoxMessage(
                  title: "Tidak ada pasien",
                  body: "Tidak ada pasien hari ini yang dirawat",
                );
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPasien(
                          noRawat: dataPasien[index]['no_rawat'],
                          kategori: Helper.getPenjab(
                              dataPasien[index]['penjab']['png_jawab'])),
                    ),
                  );
                },
                child: createCardPasien(dataPasien[index]),
              );
            },
          ),
          if (nextPageUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: textColor, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: btnLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: textColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        setState(() {
                          btnLoading = true;
                        });

                        await loadMore();
                        setState(() {
                          btnLoading = false;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: textColor,
                      ),
                    ),
            ),
        ],
      );
    }
  }
}
