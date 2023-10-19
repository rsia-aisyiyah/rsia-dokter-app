import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/components/loadingku.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/config/strings.dart';
import 'package:rsiap_dokter/utils/fonts.dart';
import 'package:rsiap_dokter/utils/helper.dart';
import 'package:rsiap_dokter/utils/msg.dart';
import 'package:rsiap_dokter/utils/table.dart';

class ResumePasienRanap extends StatefulWidget {
  final String noRawat;
  final String kategori;

  const ResumePasienRanap({super.key, required this.noRawat, required this.kategori});

  @override
  State<ResumePasienRanap> createState() => _ResumePasienRanapState();
}

class _ResumePasienRanapState extends State<ResumePasienRanap> {
  ScrollController _scrollController = ScrollController();
  bool isEnd = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isEnd = true;
        });
      } else {
        setState(() {
          isEnd = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future fetchPasien() async {
    var response =
        await Api().getData('/pasien/ranap/resume?no_rawat=' + widget.noRawat);

    var body = json.decode(response.body);
    return body;
  }

  Future verifyResume(
    noRawat,
  ) async {
    var response = await Api()
        .postData({'no_rawat': noRawat}, '/pasien/ranap/resume/verify');

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
            return Scaffold(
              body: Center(
                child: Text(
                  data['message'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          } else {
            var pasien = data['data'];
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  title: Text(
                    'Resume Pasien',
                  ),
                  actions: [
                    pasien['verif'] != null ? IconButton(
                      onPressed: () {
                        Msg.withData(
                          context,
                          'success',
                          "Resume Sudah Diverifikasi",
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                          ),
                          {
                            "Petugas": pasien['verif']['verifikator'],
                            "Tanggal": pasien['verif']['tgl_verif'] + " " + pasien['verif']['jam_verif']
                          },
                        );
                      },
                      icon: Icon(Icons.verified_sharp),
                    ) : Container()
                  ],
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'DATA PASIEN',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          ikNoRkmMedis: pasien['reg_periksa']['no_rkm_medis'],
                          ikName: pasien['reg_periksa']['pasien']['nm_pasien'],
                          "Umur": "${pasien['reg_periksa']['umurdaftar'].toString()} ${pasien['reg_periksa']['sttsumur']}",
                          ikBirthDate: Helper.formatDate2(pasien['reg_periksa']['pasien']['tgl_lahir']),
                          ikAddress: pasien['reg_periksa']['pasien']['alamat'],
                          'No HP': pasien['reg_periksa']['pasien']['no_tlp'],
                        }),
                        const SizedBox(height: 15),
                        Text(
                          'DETAIL RUANG RAWAT',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          "Ruang Rawat": pasien['reg_periksa']['kamar_inap'] != null ?  pasien['reg_periksa']['kamar_inap']['kamar']['bangsal']['nm_bangsal'] : "-",
                          "Tanggal Masuk": pasien['reg_periksa']['kamar_inap'] != null ? Helper.formatDate2(pasien['reg_periksa']['kamar_inap']['tgl_masuk']) : "-",
                          "Jam Masuk": pasien['reg_periksa']['kamar_inap'] != null ?  pasien['reg_periksa']['kamar_inap']['jam_masuk'] : "-",
                          "Tanggal Keluar": pasien['reg_periksa']['kamar_inap'] != null ? Helper.formatDate2(pasien['reg_periksa']['kamar_inap']['tgl_keluar']) : "-",
                          "Jam Keluar": pasien['reg_periksa']['kamar_inap'] != null ?  pasien['reg_periksa']['kamar_inap']['jam_keluar'] : "-",
                          "Lama": pasien['reg_periksa']['kamar_inap'] != null ?  pasien['reg_periksa']['kamar_inap']['lama'].toString() : '-' + " Hari",
                        }),
                        const SizedBox(height: 15),
                        Text(
                          'DETAIL CARA BAYAR',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          "Cara Bayar": pasien['reg_periksa']['penjab']['png_jawab'],
                          "Indikasi Awal": pasien['alasan'],
                          "Diagnosa Awal": pasien['reg_periksa']['kamar_inap'] != null ?  pasien['reg_periksa']['kamar_inap']['diagnosa_awal'] : "-",
                          "DPJP": pasien['dokter']['nm_dokter']
                        }),
                        const SizedBox(height: 15),
                        Text(
                          'ANAMNESIS',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['keluhan_utama']),
                        const SizedBox(height: 15),
                        Text(
                          'PEMERIKSAAN FISIK',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['pemeriksaan_fisik']),
                        const SizedBox(height: 15),
                        Text(
                          'PEMERIKSAAN PENUNJANG',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['hasil_laborat']),
                        Text(pasien['pemeriksaan_penunjang']),
                        const SizedBox(height: 15),
                        Text(
                          'DIAGNOSA AKHIR',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Diagnosa Utama',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: fontSemiBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          pasien['diagnosa_utama']: pasien['kd_diagnosa_utama']
                        }),
                        const SizedBox(height: 5),
                        Text(
                          'Diagnosa Sekunder',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: fontSemiBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          "1. " + pasien['diagnosa_sekunder']: pasien['kd_diagnosa_sekunder'],
                          "2. " + pasien['diagnosa_sekunder2']: pasien['kd_diagnosa_sekunder2'],
                          "3. " + pasien['diagnosa_sekunder3']: pasien['kd_diagnosa_sekunder3'],
                          "4. " + pasien['diagnosa_sekunder4']: pasien['kd_diagnosa_sekunder4'],
                          "5. " + pasien['diagnosa_sekunder5']: pasien['kd_diagnosa_sekunder5'],
                          "6. " + pasien['diagnosa_sekunder6']: pasien['kd_diagnosa_sekunder6'],
                          "7. " + pasien['diagnosa_sekunder7']: pasien['kd_diagnosa_sekunder7'],
                        }),
                        const SizedBox(height: 15),
                        Text(
                          'TINDAKAN OPERASI',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {
                          "1. " + pasien['prosedur_utama']: pasien['kd_prosedur_utama'],
                          "2. " + pasien['prosedur_sekunder']: pasien['prosedur_sekunder'],
                          "3. " + pasien['prosedur_sekunder2']: pasien['prosedur_sekunder2'],
                          "4. " + pasien['prosedur_sekunder3']: pasien['prosedur_sekunder3']
                        }),
                        const SizedBox(height: 15),
                        Text(
                          'PENGOBATAN / TERAPI',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['obat_di_rs']),
                        const SizedBox(height: 15),
                        Text(
                          'PROGNOSIS',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['ket_keadaan'].toString().toUpperCase()),
                        const SizedBox(height: 15),
                        Text(
                          'KONDISI PULANG',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 5,
                          runSpacing: 8,
                          children: [
                            capsuleKondisiPulang( pasien['keadaan'] == "Membaik", "Membaik"),
                            capsuleKondisiPulang( pasien['keadaan'] == "Sembuh", "Sembuh"),
                            capsuleKondisiPulang( pasien['keadaan'] == "Keadaan Khusus", "Keadaan Khusus"),
                            capsuleKondisiPulang( pasien['keadaan'] == "Meninggal", "Meninggal"),
                            capsuleKondisiPulang( pasien['keadaan'] == "Rujuk", "Rujuk"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'OBAT PULANG',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(pasien['obat_pulang']),
                        const SizedBox(height: 15),
                        Text(
                          'SHK',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {pasien['shk']: pasien['shk_keterangan']}),
                        const SizedBox(height: 15),
                        Text(
                          'INSTRUKSI TINDAK LANJUT',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: fontBold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GenTable(data: {"Kontrol": pasien['kontrol']})
                      ],
                    ),
                  ),
                ),
                floatingActionButton: isEnd && pasien['verif'] == null ? FloatingActionButton(
                  onPressed: () {
                    verifyResume(widget.noRawat).then((value) {
                      if (value['success']) {
                        Msg.success(context, value['message']);
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value['message']),
                            backgroundColor: warningColor,
                          ),
                        );
                      }
                    });
                  },
                  child: Icon(Icons.check),
                  backgroundColor: primaryColor,
                )
              : Container(),
            );
          }
        }
      },
    );
  }

  Container capsuleKondisiPulang(bool checked, String text) {
    return Container(
      decoration: BoxDecoration(
        color: checked ? Colors.grey.shade800 : bgWhite,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: checked ? Colors.grey.shade800 : Colors.grey.shade500,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checked ? Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.check_sharp,
                color: Colors.grey.shade800,
                size: 16,
              ),
            )
          : Container(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              text,
              style: TextStyle(
                color: checked ? bgWhite : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: fontSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
