import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/components/filter/bottom_sheet_filter.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';

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
  TextEditingController searchController = TextEditingController();
  TextEditingController dateinput = TextEditingController();

  late String title;
  late String url;

  // Pagination
  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataPasiens = [];
  bool isLoding = true;
  bool isFilter = false;

  // filter
  Map filterData = {};

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
        dataPasiens = [];
      });
    }
  }

  _onClearCancel() {
    setState(() {
      isLoding = true;
      isFilter = false;

      dateinput.text = "";

      filterData.clear();
      searchController.clear();
    });

    fetchPasien().then((value) {
      _setData(value);
    });
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
      if (isFilter) {
        await Api().postFullUrl(filterData, nextPageUrl).then((value) {
          var body = json.decode(value.body);
          setState(() {
            dataPasiens.addAll(body['data']['data']);

            nextPageUrl = body['data']['next_page_url'] ?? '';
            prevPageUrl = body['data']['prev_page_url'] ?? '';
            currentPage = body['data']['current_page'].toString();
            lastPage = body['data']['last_page'].toString();
          });
        });
      } else {
        await Api().getFullUrl(nextPageUrl).then((value) {
          var body = json.decode(value.body);
          setState(() {
            dataPasiens.addAll(body['data']['data']);

            nextPageUrl = body['data']['next_page_url'] ?? '';
            prevPageUrl = body['data']['prev_page_url'] ?? '';
            currentPage = body['data']['current_page'].toString();
            lastPage = body['data']['last_page'].toString();
          });
        });
      }
    }
  }

  Future _fetchSearch(data) async {
    var res = await Api().postData(data, '/dokter/pasien/search');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  void doFilter() async {
    setState(() {
      isLoding = true;
      isFilter = true;
      filterData['status_lanjut'] = widget.ralan ? 'Ralan' : 'Ranap';
    });

    // search
    if (searchController.text.isNotEmpty) {
      filterData['keywords'] = searchController.text.toString();
    }

    // fetch
    _fetchSearch(filterData).then((value) {
      _setData(value);
    });
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
                _onFilterIconClicked(context);
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
            ),
            if (isFilter)
              IconButton(
                onPressed: () {
                  setState(() {
                    isLoding = true;
                    isFilter = false;

                    dateinput.text = "";

                    filterData.clear();
                    searchController.clear();
                  });

                  fetchPasien().then((value) {
                    _setData(value);
                  });
                },
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              )
            else
              const SizedBox(),
          ],
        ),
        body: LazyLoadScrollView(
          onEndOfPage: () => _loadMore(),
          isLoading: isLoding,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: dataPasiens.isEmpty ? 1 : dataPasiens.length,
            itemBuilder: (context, index) {
              if (dataPasiens.isNotEmpty) {
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
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  alignment: Alignment.center,
                  child: Text(
                    "Data tidak ditemukan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(.5)),
                  ),
                );
              }
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
        return BottomSheetFilter(
          dateinput: dateinput,
          searchController: searchController,
          isLoding: isLoding,
          isFilter: isFilter,
          fetchPasien: fetchPasien,
          setData: _setData,
          doFilter: doFilter,
          onClearAndCancel: _onClearCancel,
          filterData: filterData,
          selectedCategory: filterData['penjab'] ?? '',
        );
      },
    );
  }
}
