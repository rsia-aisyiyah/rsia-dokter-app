import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/components/tables/table_pemeriksaan.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/ext/string_capitalize.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../config/config.dart';

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

  @override
  Widget build(BuildContext context) {
    Color? bgColor =
        widget.kategori == 'umum' ? Colors.orange[100] : backgroundColor;
    Color? appBarColor =
        widget.kategori == 'umum' ? Colors.orange.shade400 : accentColor;

    return FutureBuilder(
      future: fetchPasien(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingku(primaryColor);
        } else {
          var data = json.decode(json.encode(snapshot.data));
          if (!data['success']) {
            return _pemeriksaanNull(context);
          } else {
            var pasien = data['data'];
            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: appBarColor,
                title: const Text('Detail Pasien'),
                leading: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pasienDetails(pasien),
                      pasien['pemeriksaan'] == null
                          ? _pemeriksaanNull(context)
                          : _buildPemeriksaanDetails(pasien),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildChart(String columnName, TooltipBehavior tooltipBehavior) {
    var nameTitle = columnName.replaceAll('_', ' ').toLowerCase();
    return FutureBuilder(
      future: _getChartData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data['data'];
          chartData = <_ChartData>[];

          for (var i = 0; i < data.length; i++) {
            if (data[i][columnName].toString().isEmpty) {
              continue;
            }

            chartData!.add(
              _ChartData('${data[i]['tgl_perawatan']} ${data[i]['jam_rawat']}',
                  double.parse(data[i][columnName]!.replaceAll(',', '.'))),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(top: 8, right: 8),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Grafik ${nameTitle.capitalize()}',
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
                labelFormat: '{value}',
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(color: Colors.transparent),
              ),
              series: _getDefaultLineSeries(nameTitle),
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

  List<LineSeries<_ChartData, String>> _getDefaultLineSeries(String name) {
    return <LineSeries<_ChartData, String>>[
      LineSeries<_ChartData, String>(
        animationDuration: 2500,
        dataSource: chartData!,
        xValueMapper: (_ChartData data, _) => data.tanggal,
        yValueMapper: (_ChartData data, _) => data.value,
        width: 2,
        name: name,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
        ),
        markerSettings: const MarkerSettings(isVisible: true),
        color: dataColor[Random().nextInt(dataColor.length)],
      ),
    ];
  }

  Container _pemeriksaanNull(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.3,
          color: widget.kategori == 'umum' ? Colors.orange : accentColor,
        ),
      ),
      child: Text(
        'Pasien belum melakukan pemeriksaan',
        style: TextStyle(
          color: widget.kategori == 'umum' ? Colors.orange[700] : accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _buildPemeriksaanDetails(pasien) {
    var penjab =
        pasien['penjab']['png_jawab'].toString().toLowerCase().contains("umum")
            ? "umum"
            : "bpjs";
    var statusLanjut = pasien['status_lanjut'].toString().toLowerCase();
    if (pasien['status_lanjut'].toString().toLowerCase() == 'ralan') {
      return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'History Pemeriksaan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontWeightSemiBold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 1,
                  color: textColor,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              TablePemeriksaan(
                pasien: pasien['pemeriksaan'],
                penjab: penjab,
                statusLanjut: statusLanjut,
              ),
            ],
          ));
    } else {
      if (pasien['pemeriksaan'].isNotEmpty) {
        var pemeriksan = pasien['pemeriksaan'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Grafik Pemeriksaan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: fontWeightSemiBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 1,
                color: textColor,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            _buildChart('suhu_tubuh', suhuTubuhTooltipBehavior),
            const SizedBox(height: 10),
            _buildChart('nadi', nadiTooltipBehavior),
            const SizedBox(height: 10),
            _buildChart('respirasi', respirasiTooltipBehavior),
            const SizedBox(height: 10),
            _buildChart('spo2', spo2TooltipBehavior),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'History Pemeriksaan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: fontWeightSemiBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 1,
                color: textColor,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            _historyPemeriksaan(pemeriksan, penjab, statusLanjut),
          ],
        );
      } else {
        return _pemeriksaanNull(context);
      }
    }
  }

  Widget _historyPemeriksaan(pemeriksan, String penjab, String statusLanjut) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pemeriksan.length,
      itemBuilder: (context, index) {
        int selectedTile = -1;
        final tglPerawatan = DateFormat(
          "EEEE, d MMMM yyyy",
          'id_ID',
        ).format(DateTime.parse(pemeriksan[index]['tgl_perawatan']));
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            clipBehavior: Clip.hardEdge,
            key: Key(index.toString()),
            textColor: penjab == 'umum' ? warningColor : accentColor,
            iconColor: penjab == 'umum' ? warningColor : accentColor,
            backgroundColor: Colors.white,
            initiallyExpanded: index == selectedTile,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tglPerawatan,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(pemeriksan[index]['jam_rawat'])
              ],
            ),
            onExpansionChanged: ((newState) {
              if (newState) {
                setState(() {
                  selectedTile = index;
                });
              } else {
                setState(() {
                  selectedTile = -1;
                });
              }
            }),
            children: [
              TablePemeriksaan(
                pasien: pemeriksan[index],
                penjab: penjab,
                statusLanjut: statusLanjut,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pasienDetails(pasien) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pasien['pasien']['nm_pasien'],
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: "RM : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: pasien['no_rkm_medis'],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              text: "Status Lanjut : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: pasien['status_lanjut'].toString().toLowerCase() ==
                          'ralan'
                      ? 'Rawat Jalan'
                      : 'Rawat Inap',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              text: "No. Rawat : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: pasien['no_rawat'],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            pasien['poliklinik']['nm_poli'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.tanggal, this.value);
  final String tanggal;
  final double value;
}
