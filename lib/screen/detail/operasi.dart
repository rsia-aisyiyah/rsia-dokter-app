import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/box_message.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
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

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    fetchDataOperasi();
  }

  Future fetchDataOperasi() async {
    var res = await Api()
        .postData({'no_rawat': widget.noRawat}, '/pasien/operasi/data');
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
      return loadingku();
    } else {
      return Scaffold(
        backgroundColor: bgWhite,
        appBar: AppBar(
          backgroundColor: Helper.penjabColor(widget.penjab),
          title: const Text('Detail Operasi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          header: const ClassicHeader(),
          onRefresh: () async {
            await fetchDataOperasi();
            refreshController.refreshCompleted();
          },
          child: !response['success']
              ? Center(child: Text(response['message']))
              : SafeArea(
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
            style: TextStyle(
              fontSize: 25,
              fontWeight: fontBold,
            ),
          ),
          const SizedBox(height: 8),
          GenTable(data: {
            ikNoRm: widget.rm,
            ikNoRawat: widget.noRawat,
          }),
        ],
      ),
    );
  }

  _operasiDetails(response) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: response.length == 0 ? 1 : response.length,
      itemBuilder: (context, index) {
        if (response.length == 0) {
          return const BoxMessage(
            title: "Tidak ada operasi",
            body: "Tidak ada operasi yang dilakukan pada pasien ini",
          );
        }

        var data = response[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Helper.penjabColor(widget.penjab).withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Helper.penjabColor(widget.penjab),
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              textColor: textColor,
              iconColor: Helper.penjabColor(widget.penjab),
              backgroundColor: bgWhite,
              title: Text(
                data['tgl_operasi'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: fontSemiBold,
                ),
              ),
              subtitle: Text(
                data['paket_operasi']['nm_perawatan'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontNormal,
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
