import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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
  TooltipBehavior suhuTubuhTooltipBehavior = TooltipBehavior(enable: true);
  TooltipBehavior nadiTooltipBehavior = TooltipBehavior(enable: true);
  TooltipBehavior spo2TooltipBehavior = TooltipBehavior(enable: true);
  TooltipBehavior respirasiTooltipBehavior = TooltipBehavior(enable: true);
  List<_ChartData>? chartData;
  bool chartIsLoaded = false;

  @override
  initState() {
    super.initState();
  }

  Future _getChartData() async {
    var res = await Api().postData({
      "no_rawat": widget.noRawat,
      "stts_lanjut": "Ranap",
    }, '/dokter/pasien/pemeriksaan/chart');

    var body = json.decode(res.body);
    return body;
  }

  Future fetchPasien() async {
    var response = await Api().postData({
      "no_rawat": widget.noRawat,
    }, '/dokter/pasien/pemeriksaan');

    var body = json.decode(response.body);
    return body;
  }

  Future verifySoap(noRawat, tglPerawatan, jamRawat) async {
    var response = await Api().postData({
      'no_rawat': noRawat,
      'tgl_perawatan': tglPerawatan,
      'jam_rawat': jamRawat,
    }, '/dokter/pasien/pemeriksaan/verify');

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
                child: pasien['status_lanjut'].toLowerCase().contains("ranap")
                    ? _ranapDetails(pemeriksaan, pasien)
                    : _ralanDetails(pemeriksaan, pasien),
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
        // padding: const EdgeInsets.all(15),
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
                  style: TextStyle(
                    fontWeight: fontBold,
                  ),
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
                        "Petugas": pemeriksaan[index]['verifikasi']['petugas']['nama'],
                        "Tanggal": pemeriksaan[index]['verifikasi']['tgl_verif'] + " " + pemeriksaan[index]['verifikasi']['jam_verif']
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
                      Icons.check_circle_outline_outlined,
                      color: Colors.grey,
                    ),
            )
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
        _buildChart('Grafik Pemeriksaan', suhuTubuhTooltipBehavior),
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
          chartData = <_ChartData>[];

          for (var i = 0; i < data.length; i++) {
            if (data[i]['suhu_tubuh'].toString().isEmpty ||
                data[i]['suhu_tubuh'].toString() == '-' ||
                data[i]['suhu_tubuh'].toString() == ' ' ||
                data[i]['nadi'].toString().isEmpty ||
                data[i]['nadi'].toString() == '-' || 
                data[i]['nadi'].toString() == ' '
              ) {
              continue;
            }

            // remove all character except number and dot and comma
            var suhu = data[i]['suhu_tubuh'].toString().replaceAll(RegExp(r'[^0-9.,]'), '');
            var nadi = data[i]['nadi'].toString().replaceAll(RegExp(r'[^0-9.,]'), '');

            chartData!.add(
              _ChartData(
                '${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                double.parse(suhu),
                double.parse(nadi),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.only(top: 8, right: 8),
            height: 250,
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
              tooltipBehavior: tooltipBehavior,
              primaryXAxis: CategoryAxis(
                isVisible: false,
              ),
              primaryYAxis: NumericAxis(
                interval: 100,
                labelFormat: '{value}',
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(color: Colors.transparent),
              ),
              series: _getDefaultLineSeries(),
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

  List<LineSeries<_ChartData, String>> _getDefaultLineSeries() {
    return <LineSeries<_ChartData, String>>[
      LineSeries<_ChartData, String>(
        animationDuration: 2500,
        dataSource: chartData!,
        xValueMapper: (_ChartData data, _) => data.tanggal,
        yValueMapper: (_ChartData data, _) => data.suhu,
        width: 2,
        name: "Suhu Tubuh",
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
        ),
        markerSettings: const MarkerSettings(isVisible: true),
        color: getColor("Suhu Tubuh"),
      ),
      LineSeries<_ChartData, String>(
        animationDuration: 2500,
        dataSource: chartData!,
        xValueMapper: (_ChartData data, _) => data.tanggal,
        yValueMapper: (_ChartData data, _) => data.nadi,
        width: 2,
        name: "Nadi",
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
        ),
        markerSettings: const MarkerSettings(isVisible: true),
        color: getColor("Nadi"),
      ),
    ];
  }

  Color getColor(String name) {
    if (name.toLowerCase().contains('suhu')) {
      return Colors.pink;
    } else if (name.toLowerCase().contains('nadi')) {
      return Colors.blue;
    } else {
      return dataColor[Random().nextInt(dataColor.length)];
    }
  }
}

class _ChartData {
  _ChartData(this.tanggal, this.suhu, this.nadi);

  final String tanggal;
  final double suhu;
  final double nadi;
}
