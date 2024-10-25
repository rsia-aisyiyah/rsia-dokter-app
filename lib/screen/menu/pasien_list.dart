import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/components/filter/bottom_sheet_filter.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/detail/pasien.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferences? pref;

  TextEditingController searchController = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

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

    widget.ranap ? filterData['dateby'] = 'masuk' : null;

    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  _initialSet() {
    var now = DateTime.now();
    var bulan = now.month.toString().padLeft(2, '0');
    var tahun = now.year.toString();

    if (widget.ralan == true) {
      title = "Pasien Rawat Jalan";
      url = "/pasien/ralan/$tahun/$bulan";
    } else if (widget.ranap == true) {
      title = "Pasien Rawat Inap";
      url = "/pasien/ranap/$tahun/$bulan";
    } else {
      title = "Pasien";
      url = "/pasien";
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

      if (nextPageUrl.isEmpty) {
        _refreshController.loadNoData();
      }
    } else {
      setState(() {
        isLoding = false;
        dataPasiens = [];

        nextPageUrl = '';
        prevPageUrl = '';
        currentPage = value['data']['current_page'].toString();
        lastPage = value['data']['last_page'].toString();
      });

      _refreshController.resetNoData();
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

  _onRefresh() {
    setState(() {
      isFilter = false;

      dateinput.text = "";

      filterData.clear();
      searchController.clear();
    });

    fetchPasien().then((value) {
      _setData(value);

      _refreshController.refreshCompleted();
    });
  }

  Future fetchPasien() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var spesialis = localStorage.getString('spesialis');
    var strUrl = url;

    if (widget.ranap) {
      if (spesialis!.toLowerCase().contains('umum')) {
        strUrl = '/pasien/ranap/all';
      }
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

  // loadMore
  void _loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      if (isFilter) {
        await Api().postFullUrl(filterData, nextPageUrl).then((value) {
          var body = json.decode(value.body);
          if (mounted) {
            setState(() {
              nextPageUrl = body['data']['next_page_url'] ?? '';
              prevPageUrl = body['data']['prev_page_url'] ?? '';
              currentPage = body['data']['current_page'].toString();
              lastPage = body['data']['last_page'].toString();

              dataPasiens.addAll(body['data']['data']);
            });
          }
        });
      } else {
        await Api().getFullUrl(nextPageUrl).then((value) {
          var body = json.decode(value.body);
          if (mounted) {
            setState(() {
              nextPageUrl = body['data']['next_page_url'] ?? '';
              prevPageUrl = body['data']['prev_page_url'] ?? '';
              currentPage = body['data']['current_page'].toString();
              lastPage = body['data']['last_page'].toString();

              dataPasiens.addAll(body['data']['data']);
            });
          }
        });
      }

      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  Future _fetchSearch(data) async {
    var res = await Api().postData(data, '/pasien/search');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

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

    _fetchSearch(filterData).then((value) {
      _setData(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoding) {
      return loadingku();
    } else {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              color: textWhite,
              fontSize: 18,
              fontWeight: fontSemiBold,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: textWhite,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _onFilterIconClicked(context);
              },
              icon: Icon(
                Icons.filter_alt_outlined,
                color: textWhite,
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
                icon: Icon(
                  Icons.clear,
                  color: textWhite,
                ),
              )
            else
              const SizedBox(),
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: nextPageUrl.isNotEmpty,
          onRefresh: _onRefresh,
          onLoading: _loadMore,
          header: WaterDropMaterialHeader(
            color: bgWhite,
            backgroundColor: primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _filterTitle(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
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
                                kategori: dataPasiens[index]['penjab']['png_jawab'].toString().toLowerCase().contains("umum")
                                    ? "umum"
                                    : "bpjs",
                              ),
                            ),
                          );
                        },
                        child: createCardPasien(dataPasiens[index], context),
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        alignment: Alignment.center,
                        child: Text(
                          belumAdaPasien,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: fontNormal,
                            color: textColor.withOpacity(.5),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _filterTitle() {
    if (filterData.containsKey('tgl_registrasi')) {
      return Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 0,
        ),
        padding: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              "Pasien ${widget.ralan ? 'Rawat Jalan' : 'Rawat Inap'}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: fontSemiBold,
              ),
            ),
            const SizedBox(height: 8),
            filterData.containsKey('penjab')
                ? Text(
                    "Kategori ${filterData['penjab']}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: fontSemiBold,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 5),
            Text(
              "Periode ${filterData['tgl_registrasi']['start']} s/d ${filterData['tgl_registrasi']['end']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontSemiBold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future<dynamic> _onFilterIconClicked(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetFilter(
          dateinput: dateinput,
          searchController: searchController,
          isLoding: isLoding,
          isFilter: isFilter,
          isRanap: widget.ranap,
          fetchPasien: fetchPasien,
          setData: _setData,
          doFilter: doFilter,
          onClearAndCancel: _onClearCancel,
          filterData: filterData,
          selectedCategory: filterData['penjab'] ?? '',
          tglFilterKey: "tgl_registrasi",
        );
      },
    );
  }
}
