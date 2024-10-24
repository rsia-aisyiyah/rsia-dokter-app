import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RekapKunjunganPasien extends StatefulWidget {
   const RekapKunjunganPasien({super.key});

  @override
  State<RekapKunjunganPasien> createState() => _RekapKunjunganPasienState();
}

class _RekapKunjunganPasienState extends State<RekapKunjunganPasien> {
  Map dataMetrics = {};
  Map filterData = {};
  
  bool isUmum = false;

  bool isLoading = true;
  bool isFilter = false;

  String tglFilter = "tgl_registrasi";

  TextEditingController dateinput = TextEditingController();
  // ignore: prefer_final_fields
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    fetchPasien({}).then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPasien({}).then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  Future fetchPasien(data) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var spesialis = localStorage.getString('spesialis');
    var strUrl = '';

    if (spesialis!.toLowerCase().contains('umum')) {
      setState(() {
        isUmum = true;
      });
      strUrl = '/kunjungan/rekap/umum';
    } else if (spesialis.toLowerCase().contains('radiologi')) {
      setState(() {
        isUmum = true;
        tglFilter = "tgl";
      });
      strUrl = '/kunjungan/rekap/radiologi';
    } else {
      strUrl = '/kunjungan/rekap';
    }

    var res = await Api().postData(data, strUrl);
    return json.decode(res.body);
  }

  void _setData(value) {
    if (value['success']) {
      // if value data not empty
      if (value['data'].length > 0) {
        setState(() {
          dataMetrics = value['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          dataMetrics = {};
          isLoading = false;
        });
      }
    } else {
      Msg.error(context, value['message']);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    await fetchPasien(filterData).then((value) {
      if (mounted) {
        _setData(value);
      }

      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku();
    } else {
      return Scaffold(
        backgroundColor: bgWhite,
        appBar: AppBar(
          title: Text(
            rekapKunjunganTitle,
            style:  TextStyle(
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
            icon:  Icon(
              Icons.arrow_back_ios,
              color: textWhite,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (isFilter) {
                  _onClearAndCancel();
                } else {
                  _onFilterButtonClicked(context);
                }
              },
              icon: Icon(
                isFilter ? Icons.filter_alt_off_rounded : Icons.filter_alt,
                color: textWhite,
              ),
            ),
          ],
        ),
        body: dataMetrics.isNotEmpty ? _buildBody() : Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              "Data tidak ditemukan. \nHal ini bisa terjadi karena belum ada data pemeriksaan pasien.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontSemiBold,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<dynamic> _onFilterButtonClicked(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:  const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // icon filter
                          Container(
                            padding:  const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.filter_alt,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                           const SizedBox(width: 10),
                          Text(
                            filterPasienText,
                            style:  TextStyle(
                              fontSize: 18,
                              fontWeight: fontSemiBold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                   const SizedBox(height: 10),
                  Text(
                    labelSelectDate,
                    style:  TextStyle(
                      fontSize: 14,
                      fontWeight: fontSemiBold,
                    ),
                  ),
                   const SizedBox(height: 10),
                  TextField(
                    controller: dateinput,
                    decoration: InputDecoration(
                      hintText: labelSelectDate,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: dateinput.text.isNotEmpty
                            ? primaryColor
                            : Colors.grey,
                      ),
                      contentPadding:  const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: dateinput.text.isNotEmpty
                              ? primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      var res = await showCalendarDatePicker2Dialog(
                        context: context,
                        useSafeArea: true,
                        dialogSize:  const Size(325, 400),
                        borderRadius: BorderRadius.circular(15),
                        config: CalendarDatePicker2WithActionButtonsConfig(
                          centerAlignModePicker: true,
                          customModePickerIcon:  const SizedBox(),
                          selectedDayTextStyle:  TextStyle(
                            color: textWhite,
                            fontWeight: fontBold,
                          ),
                          selectedDayHighlightColor: primaryColor,
                          calendarType: CalendarDatePicker2Type.range,
                        ),
                      );

                      if (res != null) {
                        String startDate = DateFormat('yyyy-MM-dd').format(
                          res.first!,
                        );

                        String endDate = DateFormat('yyyy-MM-dd').format(
                          res.last!,
                        );

                        setState(() {
                          dateinput.text = "$startDate - $endDate";
                          filterData[tglFilter] = {
                            "start": startDate,
                            "end": endDate
                          };
                        });
                      }
                    },
                  ),
                ],
              ),
              const Spacer(),
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: textColor,
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding:  const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          _onClearAndCancel();
                          Navigator.pop(context);
                        },
                        child: Text(resetAndCloseText),
                      ),
                    ),
                  ),
                   const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: textWhite,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding:  const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          _doFilter();
                          Navigator.pop(context);
                        },
                        child: Text(submitText),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  SmartRefresher _buildBody() {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      header: WaterDropMaterialHeader(
        color: bgWhite,
        backgroundColor: primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            metricsTitleWidget(),
            metricsWidgets(),
          ],
        )
      ),
    );
  }

  Widget metricsTitleWidget() {
    if (filterData.containsKey(tglFilter)) {
      return Container(
        margin:  const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 0,
        ),
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              "Rekap Kunjungan Pasien",
              style:  TextStyle(
                fontSize: 18,
                fontWeight: fontSemiBold,
              ),
            ),
             const SizedBox(height: 5),
            Text(
              "Periode ${filterData[tglFilter]['start']} s/d ${filterData[tglFilter]['end']}",
              style:  TextStyle(
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

  Widget metricsWidgets() {
    return SingleChildScrollView(
      padding:  const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: dataMetrics.entries.map((e) {
          if (isUmum && e.key.toString().toLowerCase() == 'operasi') {
            return Container();
          }
          
          return Container(
            margin:  const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 0,
            ),
            width: MediaQuery.of(context).size.width,
            padding:  const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primaryColor.withOpacity(.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin:  const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _getTitle(e.key),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: fontBold,
                    ),
                  ),
                ),
                Container(
                  padding:  const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: bgWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalPasienText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: fontSemiBold,
                        ),
                      ),
                       const SizedBox(height: 6),
                      Text(
                        e.value['TOTAL'].toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: fontSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding:  const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: umumColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              umumText,
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 14,
                                fontWeight: fontSemiBold,
                              ),
                            ),
                             const SizedBox(height: 6),
                            Text(
                              e.value['UMUM'].toString(),
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 20,
                                fontWeight: fontSemiBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding:  const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bpjsColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bpjsText,
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 14,
                                fontWeight: fontSemiBold,
                              ),
                            ),
                             const SizedBox(height: 6),
                            Text(
                              e.value['BPJS'].toString(),
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 20,
                                fontWeight: fontSemiBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTitle(key) {
    switch (key.toString().toLowerCase()) {
      case 'ralan':
        return rawatJalanText;
      case 'ranap':
        return rawatInapText;
      case 'operasi':
        return pasienOperasiTitle;
      default:
        return pasienText;
    }
  }

  void _onClearAndCancel() {
    setState(() {
      isLoading = true;
      isFilter = false;

      dateinput.text = "";
      filterData.clear();
    });

    fetchPasien({}).then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  void _doFilter() {
    setState(() {
      isLoading = true;
      isFilter = true;
    });

    fetchPasien(filterData).then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }
}
