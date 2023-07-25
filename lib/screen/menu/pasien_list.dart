import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/detail_pasien.dart';
import 'package:rsiap_dokter/utils/msg.dart';

class PasienList extends StatefulWidget {
  final bool ralan;
  final bool ranap;

  const PasienList({
    super.key,
    this.ralan = false,
    this.ranap = false,
  });

  @override
  State<PasienList> createState() => PasienListState();
}

class PasienListState extends State<PasienList> {
  late String title;
  late String url;

  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataPasiens = [];
  bool isLoding = true;

  // filter
  String kategori = "";

  @override
  void initState() {
    super.initState();
    _initialSet();

    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  _initialSet() {
    if (widget.ralan == true) {
      title = "Pasien Rawat Jalan";
      url = "/dokter/pasien/ralan";
    } else if (widget.ranap == true) {
      title = "Pasien Rawat Inap";
      url = "/dokter/pasien/ranap";
    } else {
      title = "Pasien";
      url = "/dokter/pasien";
    }
  }

  _setData(value) {
    if (mounted) {
      if (value['data']['total'] != 0) {
        setState(() {
          dataPasiens = value['data']['data'] ?? [];

          nextPageUrl = value['data']['next_page_url'] ?? '';
          prevPageUrl = value['data']['prev_page_url'] ?? '';
          currentPage = value['data']['current_page'].toString();
          lastPage = value['data']['last_page'].toString();

          isLoding = false;
        });
      } else {
        setState(() {
          isLoding = false;

          isLoding = value['data']['data'] ?? [];
        });
      }
    }
  }

  Future fetchPasien() async {
    var res = await Api().getData(url);
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  // loadMore
  void _loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      var res = await Api().getDataUrl(nextPageUrl);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        setState(() {
          dataPasiens.addAll(body['data']['data']);

          nextPageUrl = body['data']['next_page_url'] ?? '';
          prevPageUrl = body['data']['prev_page_url'] ?? '';
          currentPage = body['data']['current_page'].toString();
          lastPage = body['data']['last_page'].toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoding) {
      return loadingku(primaryColor);
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: accentColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _onSearchIconClicked(context);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _onFilterIconClicked(context);
              },
              icon: const Icon(
                Icons.filter_alt,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: LazyLoadScrollView(
          onEndOfPage: () => _loadMore(),
          isLoading: isLoding,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: dataPasiens.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPasien(
                        noRawat: dataPasiens[index]['no_rawat'],
                        kategori: dataPasiens[index]['penjab']['png_jawab']
                                .toString()
                                .toLowerCase()
                                .contains("umum")
                            ? "umum"
                            : "bpjs",
                      ),
                    ),
                  );
                },
                child: createCardPasien(dataPasiens[index]),
              );
            },
          ),
        ),
      );
    }
  }

  Future<dynamic> _onFilterIconClicked(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flex(
                direction: Axis.horizontal,
                children: [
                  _capsuleFilter(context, "UMUM"),
                  const SizedBox(width: 10),
                  _capsuleFilter(context, "BPJS")
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _capsuleFilter(BuildContext context, String text) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            kategori = text;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: kategori == text ? accentColor.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: kategori == text ? accentColor : Colors.grey[500]!,
              width: 1.5
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kategori == text ? accentColor : Colors.grey[500],
              fontSize: 14,
              fontWeight: fontWeightSemiBold,
            ),
          ),
        ),
      ),
    );
  }

  _onSearchIconClicked(BuildContext context) {
    Msg.warning(
      context,
      "Fitur ini belum tersedia",
    );
  }
}
