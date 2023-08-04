import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/table.dart';

class OperasiDetail extends StatefulWidget {
  final Map pasien;

  final String noRawat;
  final String penjab;
  final String rm;
  final String statusLanjut;

  const OperasiDetail({
    super.key,
    required this.noRawat,
    required this.pasien,
    required this.penjab,
    required this.rm,
    required this.statusLanjut,
  });

  @override
  State<OperasiDetail> createState() => OperasiDetailState();
}

class OperasiDetailState extends State<OperasiDetail> {
  bool isLoading = true;
  bool hasData = false;

  Map response = {};
  Map data = {};

  @override
  void initState() {
    super.initState();

    fetchDataOperasi();
  }

  Future fetchDataOperasi() async {
    var res = await Api()
        .postData({'no_rawat': widget.noRawat}, '/dokter/operasi/data');
    var data = json.decode(res.body);

    if (data['success']) {
      if (mounted) {
        setState(() {
          response = data;
          isLoading = false;
          hasData = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          response = data;
          isLoading = false;
          hasData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingku(primaryColor);
    } else {
      if (!response['success']) {
        return Scaffold(
          backgroundColor:
              widget.penjab.contains("UMUM") ? Colors.orange[100] : backgroundColor,
          appBar: AppBar(
            backgroundColor: widget.penjab.contains("UMUM") ? Colors.orange[400] : accentColor,
            title: const Text('Detail Operasi'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Center(child: Text(response['message'])),
        );
      }

      return Scaffold(
        backgroundColor:
            widget.penjab.contains("UMUM") ? Colors.orange[100] : backgroundColor,
        appBar: AppBar(
          backgroundColor: widget.penjab.contains("UMUM") ? Colors.orange[400] : accentColor,
          title: const Text('Detail Operasi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pasienDetails(widget.pasien),
                const SizedBox(height: 10),
                _operasiDetails(response['data']),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _pasienDetails(pasien) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pasien['nm_pasien'],
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: "$ikNoRm : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: widget.rm,
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
              text: "$ikCategory : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: widget.penjab,
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
              text: "$ikNoRawat : ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                TextSpan(
                  text: widget.noRawat,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _operasiDetails(response) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: response.length,
      itemBuilder: (context, index) {
        var data = response[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              textColor:
                  widget.penjab.contains('UMUM') ? warningColor : accentColor,
              iconColor:
                  widget.penjab.contains('UMUM') ? warningColor : accentColor,
              backgroundColor: Colors.white,
              title: Text(
                data['tgl_operasi'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                data['paket_operasi']['nm_perawatan'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              children: [_tableHasil(data)],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHasil(data) {
    return Container(
      padding: const EdgeInsets.only(
        right: 20,
        left: 20,
        bottom: 20,
      ),
      child: GenTable(data: {
        ikStartTime: data['laporan_operasi']['tanggal'],
        ikEndTime: data['laporan_operasi']['selesaioperasi'],
        ikPayment: widget.penjab,
        ikPARequests: data['laporan_operasi']['permintaan_pa'],
        ikDiagnosisPreOp: data['laporan_operasi']['diagnosa_preop'],
        ikDiagnosisPostOp: data['laporan_operasi']['diagnosa_postop'],
        ikOpReport: data['laporan_operasi']['laporan_operasi'],
      }),
    );
  }
}
