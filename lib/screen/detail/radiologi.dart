import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/config.dart';
import 'package:rsiap_dokter/screen/detail/radiologi-image.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/table.dart';

class DetailRadiologi extends StatefulWidget {
  final String noRawat;
  final String tanggal;
  final String jam;

  final String penjab;

  const DetailRadiologi({
    super.key,
    required this.penjab,
    required this.noRawat,
    required this.tanggal,
    required this.jam,
  });

  @override
  State<DetailRadiologi> createState() => _DetailRadiologiState();
}

class _DetailRadiologiState extends State<DetailRadiologi> {
  final Uri _ermUrl = Uri.parse('https://sim.rsiaaisyiyah.com/erm');
  Future fetchHasil() async {
    var data = {
      'no_rawat': widget.noRawat,
      'tanggal': widget.tanggal,
      'jam': widget.jam
    };

    var res = await Api().postData(data, '/pasien/radiologi/hasil');
    var body = json.decode(res.body);

    return body;
  }

  Future<void> _launchInBrowser() async {
    if (await canLaunchUrl(_ermUrl)) {
      await launchUrl(_ermUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $_ermUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchHasil(),
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
            }

            var pasien = data['data'].isNotEmpty ? data['data'][0] : {};
            print(pasien['gambar']);

            return Scaffold(
                backgroundColor: Helper.penjabBgColor(widget.penjab),
                appBar: AppBar(
                  title: Text("Detail Pasien Radiologi"),
                  backgroundColor: Helper.penjabColor(widget.penjab),
                  actions: [
                    // hasil.isNotEmpty ? IconButton(
                    //     onPressed: () => Msg.info(context, "Edit Hasil Radiologi Belum Tersedia"),
                    //     icon: Icon(Icons.edit_note_sharp),
                    //   )
                    // : Container(),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgWhite,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Helper.penjabOpacityColor(widget.penjab),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: Helper.penjabColor(widget.penjab),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pasien['reg_periksa']['pasien']['nm_pasien'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: fontSemiBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GenTable(data: {
                              "No. Rekam Medis": pasien['reg_periksa']
                                  ['no_rkm_medis'],
                              "No. Rawat": widget.noRawat,
                              "Tanggal Lahir": Helper.formatDate(
                                  pasien['reg_periksa']['pasien']['tgl_lahir']),
                              "Usia": Helper.calculateAge(
                                  pasien['reg_periksa']['pasien']['tgl_lahir']),
                            }),
                            const SizedBox(height: 10),
                            GenTable(data: {
                              "Jenis Pemeriksaan": pasien['periksa']['jenis']
                                  ['nm_perawatan'],
                              "Informasi Klinis": pasien['informasi_tambahan'],
                              "Diagnosa Klinis": pasien['diagnosa_klinis'],
                              "Dirujuk Oleh": pasien['periksa']['dokter']
                                  ['nm_dokter'],
                            }),
                            const SizedBox(height: 10),
                            GenTable(data: {
                              "Permintaan":
                                  Helper.formatDate3(pasien['tgl_permintaan']) +
                                      " ~ " +
                                      pasien['jam_permintaan'],
                              "Pemeriksaan":
                                  Helper.formatDate3(pasien['tgl_sampel']) +
                                      " ~ " +
                                      pasien['jam_sampel'],
                              "Oleh": pasien['periksa']['petugas']['nama'],
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: bgWhite,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Helper.penjabOpacityColor(widget.penjab),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                            ],
                            border: Border.all(
                              color: Helper.penjabColor(widget.penjab),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Hasil Pemeriksaan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: fontSemiBold,
                                ),
                              ),
                              Text(
                                Helper.formatDate(pasien['tgl_hasil']) +
                                    " ~ " +
                                    pasien['jam_hasil'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 13),
                              Text(
                                pasien['hasil'] != null
                                    ? pasien['hasil']['hasil']
                                    : "Belum ada hasil analisa",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: pasien['hasil'] != null
                                      ? Colors.black
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 15),
                      pasien.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Helper.penjabOpacityColor(
                                        widget.penjab),
                                    offset: const Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: Helper.penjabColor(widget.penjab),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Gambar Radiologi",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: fontSemiBold,
                                    ),
                                  ),
                                  Text(
                                    Helper.formatDate(pasien['tgl_hasil']) +" ~ " +pasien['jam_hasil'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          (MediaQuery.of(context).size.width -
                                                  40) /
                                              2, // Maksimal 2 kolom
                                      mainAxisSpacing:
                                          5, // Spasi vertikal antara elemen dalam grid
                                      crossAxisSpacing:
                                          5, // Spasi horizontal antara elemen dalam grid
                                    ),
                                    itemCount: pasien['gambar'].length,
                                    itemBuilder: (context, index) {
                                      final e = pasien['gambar'][index];
                                      return GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RadiologiImage(
                                                    downloadUrl: radiologiUrl + e['lokasi_gambar']),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.2,
                                            ),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: radiologiUrl +
                                                e['lokasi_gambar'],
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 130,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Helper.penjabColor(
                                                      widget.penjab),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: 130,
                                              child: Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _launchInBrowser(),
                  backgroundColor: Helper.penjabColor(widget.penjab),
                  child: Icon(Icons.edit_document),
                ));
          }
        });
  }
}
