import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:rsiap_dokter/utils/section_title.dart';
import 'package:rsiap_dokter/utils/table.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/tables/table_pemeriksaan.dart';
import 'package:rsiap_dokter/config/strings.dart';

class DetailPasien extends StatefulWidget {
  final String noRawat;
  final String kategori;

  const DetailPasien({
    super.key,
    required this.noRawat,
    required this.kategori,
  });

  @override
  State<DetailPasien> createState() => _DetailPasienState();
}

class _DetailPasienState extends State<DetailPasien> {
  TooltipBehavior toolTip =
      TooltipBehavior(enable: true, canShowMarker: false, header: '');
  TooltipBehavior nadiTooltipBehavior = TooltipBehavior(enable: true);

  late EmptyPointMode _selectedEmptyPointMode = EmptyPointMode.gap;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<_ChartData>? suhuData;
  List<_ChartData>? nadiData;

  bool chartIsLoaded = false;

  @override
  initState() {
    _selectedEmptyPointMode = EmptyPointMode.gap;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getChartData() async {
    var res = await Api().postData({
      "no_rawat": widget.noRawat,
      "stts_lanjut": "Ranap",
    }, '/pasien/pemeriksaan/chart');

    var body = json.decode(res.body);
    return body;
  }

  Future fetchPasien() async {
    var response = await Api().postData({
      "no_rawat": widget.noRawat,
    }, '/pasien/pemeriksaan');

    var body = json.decode(response.body);
    return body;
  }

  Future verifySoap(noRawat, tglPerawatan, jamRawat) async {
    var response = await Api().postData({
      'no_rawat': noRawat,
      'tgl_perawatan': tglPerawatan,
      'jam_rawat': jamRawat,
    }, '/pasien/pemeriksaan/verify');

    var body = json.decode(response.body);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPasien(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingku();
        } else {
          var data = json.decode(json.encode(snapshot.data));
          if (!data['success']) {
            return Center(
              child: Text(
                data['message'],
                style: TextStyle(
                  color: warningColor,
                  fontSize: 18,
                  fontWeight: fontBold,
                ),
              ),
            );
          } else {
            var pasien = data['data'];
            var pemeriksaan = pasien['pemeriksaan'];
            return Scaffold(
              backgroundColor: pemeriksaan == null || pemeriksaan.length == 0
                  ? bgWhite
                  : Helper.penjabBgColor(widget.kategori),
              appBar: AppBar(
                backgroundColor: Helper.penjabColor(widget.kategori),
                title: Text(titlePasienDetail),
                leading: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: SafeArea(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: const ClassicHeader(),
                  controller: _refreshController,
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 3));
                    setState(() {});
                    _refreshController.refreshCompleted();
                  },
                  child: pasien['status_lanjut'].toLowerCase().contains("ranap")
                      ? _ranapDetails(pemeriksaan, pasien)
                      : _ralanDetails(pemeriksaan, pasien),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _ralanDetails(pemeriksaan, pasien) {
    if (pemeriksaan == null) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _pasienDetails(pasien),
            const SizedBox(height: 20),
            SectionTitle(title: historySectionText),
            const SizedBox(height: 10),
            BoxMessage(
              body: pasienBelumPeriksa,
            ),
          ],
        ),
      );
    } else {
      var statusLanjut = pasien['status_lanjut'].toLowerCase();
      var penjab = Helper.getPenjab(
        pasien['penjab']['png_jawab'],
      );

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: _pasienDetails(pasien),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: bgWhite,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: historySectionText),
                  TablePemeriksaan(
                    pasien: pemeriksaan,
                    penjab: penjab,
                    statusLanjut: statusLanjut,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  ListView _ranapDetails(pemeriksaan, pasien) {
    return ListView.builder(
      itemCount: pemeriksaan.length == 0 ? 1 : pemeriksaan.length,
      itemBuilder: (context, index) {
        var statusLanjut = pasien['status_lanjut'].toLowerCase();
        var penjab = Helper.getPenjab(
          pasien['penjab']['png_jawab'],
        );

        if (pemeriksaan.length <= 0) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _pasienDetails(pasien),
                const SizedBox(height: 20),
                SectionTitle(title: historySectionText),
                const SizedBox(height: 10),
                BoxMessage(
                  body: pasienBelumPeriksa,
                ),
              ],
            ),
          );
        } else {
          final tglPerawatan = Helper.formatDate(
            pemeriksaan[index]['tgl_perawatan'],
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              index == 0
                  ? Padding(
                      padding: const EdgeInsets.all(15),
                      child: _pasienDetails(pasien),
                    )
                  : const SizedBox(),
              if (index == 0)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: bgWhite,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      SectionTitle(title: graphSectionText2),
                      const SizedBox(height: 10),
                      _chartList(),
                    ],
                  ),
                )
              else
                const SizedBox(),
              _pemeriksaanPasien(
                tglPerawatan,
                pemeriksaan,
                index,
                penjab,
                statusLanjut,
              ),
            ],
          );
        }
      },
    );
  }

  StickyHeader _pemeriksaanPasien(
    String tglPerawatan,
    pemeriksaan,
    int index,
    String penjab,
    statusLanjut,
  ) {
    return StickyHeader(
      header: Container(
        height: 50.0,
        color: penjab.toLowerCase() == 'umum'
            ? Colors.orange.shade200
            : primaryShade,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  tglPerawatan,
                  style: TextStyle(fontWeight: fontBold),
                ),
                const SizedBox(width: 10),
                Text(pemeriksaan[index]['jam_rawat'])
              ],
            ),
            // icon btton
            IconButton(
                onPressed: () {
                  if (pemeriksaan[index]['verifikasi'] != null) {
                    Msg.withData(
                        context,
                        'success',
                        "Data Sudah Diverifikasi",
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                        ),
                        {
                          "Petugas": pemeriksaan[index]['verifikasi']['petugas']
                              ['nama'],
                          "Tanggal": pemeriksaan[index]['verifikasi']
                                  ['tgl_verif'] +
                              " " +
                              pemeriksaan[index]['verifikasi']['jam_verif']
                        });
                  } else {
                    // verifySoap
                    verifySoap(
                      pemeriksaan[index]['no_rawat'],
                      pemeriksaan[index]['tgl_perawatan'],
                      pemeriksaan[index]['jam_rawat'],
                    ).then((value) {
                      setState(() {});
                      Msg.success(context, "Data Berhasil Diverifikasi");
                    });
                  }
                },
                icon: pemeriksaan[index]['verifikasi'] != null
                    ? const Icon(
                        Icons.verified,
                        color: Colors.blue,
                      )
                    : const Icon(
                        Icons.verified_outlined,
                      )),
          ],
        ),
      ),
      content: Container(
        padding: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: bgWhite,
        ),
        child: TablePemeriksaan(
          pasien: pemeriksaan[index],
          penjab: penjab,
          statusLanjut: statusLanjut,
        ),
      ),
    );
  }

  Widget _pasienDetails(pasien) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Helper.penjabOpacityColor(widget.kategori),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
        border: Border.all(
          color: Helper.penjabColor(widget.kategori),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pasien['pasien']['nm_pasien'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: fontBold,
            ),
          ),
          const SizedBox(height: 8),
          GenTable(data: {
            ikNoRawat: pasien['no_rawat'],
            ikNoRm: pasien['no_rkm_medis'],
            ikSttsLanjut: Helper.realStatusLanjut(pasien['status_lanjut']),
            poliklinikText: pasien['poliklinik']['nm_poli'],
            if (pasien['status_lanjut'].toLowerCase().contains("ranap"))
              if (pasien['kamar_inap'] != null)
                statusPulangText: pasien['kamar_inap']['stts_pulang'],
          }),
        ],
      ),
    );
  }

  Widget _chartList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildChart('Grafik Pemeriksaan', toolTip),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget _buildChart(String title, TooltipBehavior tooltipBehavior) {
    return FutureBuilder(
      future: _getChartData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data['data'];
          suhuData = <_ChartData>[];
          nadiData = <_ChartData>[];

          for (var i = 0; i < data.length; i++) {
            var suhu = data[i]['suhu_tubuh']
                .toString()
                .replaceAll(RegExp(r'[^0-9.,]'), '')
                .replaceAll(',', '.');

            var nadi = data[i]['nadi']
                .toString()
                .replaceAll(RegExp(r'[^0-9.,]'), '')
                .replaceAll(',', '.');

            if (nadi.isEmpty) {
              nadiData!.add(
                _ChartData(
                  x: '${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                ),
              );
            } else {
              nadiData!.add(
                _ChartData(
                  x: '${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                  y: double.parse(nadi),
                ),
              );
            }
            
            if (suhu.isEmpty) {
              suhuData!.add(
                _ChartData(
                  x: '${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                ),
              );
            } else {
              suhuData!.add(
                _ChartData(
                  x: '${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                  y: double.parse(suhu),
                ),
              );
            }
          }

          return Container(
            padding: const EdgeInsets.only(top: 8, right: 8),
            height: 320,
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Grafik Pemeriksaan',
              ),
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.scroll,
                position: LegendPosition.bottom,
              ),
              primaryXAxis: CategoryAxis(
                isVisible: false,
                autoScrollingMode: AutoScrollingMode.start
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value}',
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(color: Colors.transparent),
                minimum: 35,
                maximum: 42,
              ),
              axes: [
                NumericAxis(
                  majorTickLines: const MajorTickLines(color: Colors.transparent),
                  name: 'yAxis',
                  minimum: 40,
                  maximum: 180,
                ),
              ],
              series: _getDefaultLineSeries(),
              tooltipBehavior: tooltipBehavior,
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(top: 8, right: 8),
            height: 200,
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }
      },
    );
  }

  List<LineSeries> _getDefaultLineSeries() {
    return <LineSeries>[
      LineSeries<_ChartData, String>(
        animationDuration: 2000,
        dataSource: suhuData!,
        emptyPointSettings: EmptyPointSettings(
          mode: _selectedEmptyPointMode,
        ),
        xValueMapper: (_ChartData data, _) => data.x,
        yValueMapper: (_ChartData data, _) => data.y,
        width: 2,
        name: "Suhu Tubuh",
        markerSettings: const MarkerSettings(isVisible: true, width: 3, height: 3),
        color: getColor("Suhu Tubuh"),
      ),
      LineSeries<_ChartData, String>(
        animationDuration: 2000,
        dataSource: nadiData!,
        emptyPointSettings: EmptyPointSettings(
          mode: _selectedEmptyPointMode,
        ),
        xValueMapper: (_ChartData data, _) => data.x,
        yValueMapper: (_ChartData data, _) => data.y,
        width: 2,
        name: "Nadi",
        markerSettings: const MarkerSettings(isVisible: true, width: 3, height: 3),
        color: getColor("Nadi"),
        yAxisName: "yAxis",
      ),
    ];
  }

  Color getColor(String name) {
    if (name.toLowerCase().contains('suhu')) {
      return Colors.blue;
    } else if (name.toLowerCase().contains('nadi')) {
      return Colors.pink;
    } else {
      return dataColor[Random().nextInt(dataColor.length)];
    }
  }
}

class _ChartData {
  _ChartData({
    this.x,
    this.y,
    this.xValue,
    this.yValue,
  });

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;
}
