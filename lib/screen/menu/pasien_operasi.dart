import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/filter/bottom_sheet_filter.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/detail/operasi.dart';

class PasienOperasi extends StatefulWidget {
  const PasienOperasi({super.key});

  @override
  State<PasienOperasi> createState() => _PasienOperasiState();
}

class _PasienOperasiState extends State<PasienOperasi> {
  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataJadwal = [];
  bool isLoading = true;
  bool isFilter = false;

  // filter
  Map filterData = {};

  TextEditingController searchController = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  // ignore: prefer_final_fields
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value, false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value, false);
      }
    });
  }

  Future fetchPasien() async {
    var res = await Api().getData('/dokter/operasi');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  Future _fetchFilter(data) async {
    var res = await Api().postData(data, '/dokter/operasi/filter');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  Future<void> _loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      if (isFilter) {
        await Api().postFullUrl(filterData, nextPageUrl).then((value) {
          var body = json.decode(value.body);
          _setData(body, true);
        });

        _refreshController.loadComplete();
      } else {
        var res = await Api().getDataUrl(nextPageUrl);
        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          _setData(body, true);
        }

        _refreshController.loadComplete();
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  void _onRefresh() async {
    await fetchPasien().then((value) {
      setState(() {
        isFilter = false;
        if (mounted) {
          _setData(value, false);
        }
      });

      _refreshController.refreshCompleted();
    });
  }

  void doFilter() async {
    setState(() {
      isLoading = true;
      isFilter = true;
    });

    // search
    if (searchController.text.isNotEmpty) {
      filterData['keywords'] = searchController.text.toString();
    }

    _fetchFilter(filterData).then((value) {
      _setData(value, false);
    });
  }

  _onClearCancel() {
    setState(() {
      isLoading = true;
      isFilter = false;

      dateinput.text = "";

      filterData.clear();
      searchController.clear();
    });

    fetchPasien().then((value) {
      _setData(value, false);
    });
  }

  void _setData(value, bool append) {
    if (mounted) {
      if (value['data']['total'] > 0) {
        setState(() {
          if (append) {
            dataJadwal.addAll(value['data']['data']);
          } else {
            dataJadwal = value['data']['data'];
          }

          nextPageUrl = value['data']['next_page_url'] ?? '';
          prevPageUrl = value['data']['prev_page_url'] ?? '';
          currentPage = value['data']['current_page'].toString();
          lastPage = value['data']['last_page'].toString();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          dataJadwal = value['data']['data'] ?? [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku(primaryColor);
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            pasienOperasiTitle,
            style: TextStyle(
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
                    isLoading = true;
                    isFilter = false;

                    dateinput.text = "";

                    filterData.clear();
                    searchController.clear();
                  });

                  fetchPasien().then((value) {
                    _setData(value, false);
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
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _loadMore,
          header: WaterDropMaterialHeader(
            color: Colors.white,
            backgroundColor: accentColor,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            itemCount: dataJadwal.length,
            itemBuilder: (context, i) {
              var dataOperasi = dataJadwal[i];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OperasiDetail(
                        noRawat: dataOperasi['no_rawat'],
                        pasien: dataOperasi['pasien'],
                        penjab: _getPenjab(
                          dataOperasi['penjab']['png_jawab'],
                        ),
                        rm: dataOperasi['no_rkm_medis'],
                        statusLanjut: dataOperasi['status_lanjut'],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _getPenjab(
                                dataOperasi['penjab']['png_jawab'],
                              ).contains('BPJS')
                                  ? accentColor
                                  : warningColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getPenjab(
                                  dataOperasi['penjab']['png_jawab'],
                                ).contains('BPJS')
                                    ? accentColor.withOpacity(.2)
                                    : warningColor.withOpacity(.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataOperasi['pasien']['nm_pasien'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _tableOperasi(dataOperasi)
                            ],
                          ),
                        ),
                        _labelPenjab(dataOperasi),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  String _getPenjab(penjab) {
    var plow = penjab.toString().toLowerCase();

    if (plow.contains('/')) {
      var p = "BPJS${plow.split('/').last.toUpperCase()}";
      return p;
    } else {
      var p = plow.toUpperCase();
      return p;
    }
  }

  Positioned _labelPenjab(dataOperasi) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: _getPenjab(
            dataOperasi['penjab']['png_jawab'],
          ).contains('BPJS')
              ? accentColor
              : warningColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          _getPenjab(
            dataOperasi['penjab']['png_jawab'],
          ),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Table _tableOperasi(dataOperasi) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      textBaseline: TextBaseline.alphabetic,
      children: [
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  ikNoRawat,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  dataOperasi['no_rawat'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  ikNoRm,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  dataOperasi['no_rkm_medis'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<dynamic> _onFilterIconClicked(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetFilter(
          dateinput: dateinput,
          searchController: searchController,
          isLoding: isLoading,
          isFilter: isFilter,
          fetchPasien: fetchPasien,
          setData: _setData,
          doFilter: doFilter,
          onClearAndCancel: _onClearCancel,
          filterData: filterData,
          selectedCategory: filterData['penjab'] ?? '',
          tglFilterKey: "tgl_operasi",
        );
      },
    );
  }
}
