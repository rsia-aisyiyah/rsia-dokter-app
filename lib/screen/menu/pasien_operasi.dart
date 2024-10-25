import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/cards/card_list_pasien.dart';
import 'package:rsiap_dokter/components/filter/bottom_sheet_filter.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/screen/detail/operasi.dart';
import 'package:rsiap_dokter/utils/extensions/sensor.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';

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
    var res = await Api().getData('/pasien/operasi');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

      return body;
    }
  }

  Future _fetchFilter(data) async {
    var res = await Api().postData(data, '/pasien/operasi/filter');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    } else {
      var body = json.decode(res.body);
      Msg.error(context, body['message']);

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
      return loadingku();
    } else {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            pasienOperasiTitle,
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
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _loadMore,
          header: WaterDropMaterialHeader(
            color: textWhite,
            backgroundColor: primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _filterTitle(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  itemCount: dataJadwal.isEmpty ? 1 : dataJadwal.length,
                  itemBuilder: (context, i) {
                    if (dataJadwal.isEmpty) {
                      return _pasienKosong();
                    } else {
                      var dataOperasi = dataJadwal[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailOperasi(
                                noRawat: dataOperasi['no_rawat'],
                                pasien: dataOperasi['pasien'],
                                penjab: Helper.getRealPenjab(dataOperasi['penjab']['png_jawab']),
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
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgWhite,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Helper.penjabColor(dataOperasi['penjab']['png_jawab']),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Helper.penjabOpacityColor(dataOperasi['penjab']['png_jawab']),
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
                                        (dataOperasi['pasien']['nm_pasien'] as String).sensor(8) ?? '-',
                                        style: TextStyle(
                                          fontWeight: fontBold,
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
    if (filterData.containsKey('tgl_operasi')) {
      return Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 0,
        ),
        padding: EdgeInsets.all(15),
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              "Pasien Operasi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: fontSemiBold,
              ),
            ),
            const SizedBox(height: 8),
            filterData.containsKey('penjab') ? Text(
              "Kategori ${filterData['penjab']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontSemiBold,
              ),
            ) : const SizedBox(),
            const SizedBox(height: 5),
            Text(
              "Periode ${filterData['tgl_operasi']['start']} s/d ${filterData['tgl_operasi']['end']}",
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

  Widget _pasienKosong() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
      child: Text(
        belumAdaPasien,
        style: TextStyle(
          color: grayColor,
          fontSize: Helper.getFontSize(context, 16),
          fontWeight: fontMedium,
        ),
      ),
    );
  }
  
  Positioned _labelPenjab(dataOperasi) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: Helper.penjabColor(dataOperasi['penjab']['png_jawab']),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          Helper.getRealPenjab(dataOperasi['penjab']['png_jawab']),
          style: TextStyle(
            fontSize: 11,
            fontWeight: fontSemiBold,
            color: textWhite,
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
                    fontWeight: fontSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  (dataOperasi['no_rawat'] as String).sensor(8) ?? '-',
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
                    fontWeight: fontSemiBold,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text(
                  (dataOperasi['no_rkm_medis'] as String).sensor(4) ?? '-',
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
