import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsiap_dokter/api/request.dart';
import 'package:rsiap_dokter/config/config.dart';

class ListJadwalOperasi extends StatefulWidget {
  const ListJadwalOperasi({super.key});

  @override
  State<ListJadwalOperasi> createState() => _ListJadwalOperasiState();
}

class _ListJadwalOperasiState extends State<ListJadwalOperasi> {
  String nextPageUrl = '';
  String prevPageUrl = '';
  String currentPage = '';
  String lastPage = '';

  List dataJadwal = [];

  bool isLoading = true;
  bool btnLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPasien().then((value) {
      if (mounted) {
        _setData(value);
      }
    });
  }

  Future fetchPasien() async {
    var res = await Api().getData('/dokter/jadwal/operasi/2023/06');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      return body;
    }
  }

  void _setData(value) {
    if (mounted) {
      if (value['data']['total'] != 0) {
        setState(() {
          dataJadwal = value['data']['data'] ?? [];

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

// Load More
  Future<void> loadMore() async {
    if (nextPageUrl.isNotEmpty) {
      var res = await Api().getDataUrl(nextPageUrl);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        setState(() {
          dataJadwal.addAll(body['data']['data']);

          nextPageUrl = body['data']['next_page_url'] ?? '';
          prevPageUrl = body['data']['prev_page_url'] ?? '';
          currentPage = body['data']['current_page'].toString();
          lastPage = body['data']['last_page'].toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataJadwal.length,
            itemBuilder: (context, i) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataJadwal[i]['no_rawat'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Text(
                              dataJadwal[i]['tanggal'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              dataJadwal[i]['jam_mulai'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  loadMore();
                },
                child: const Text('Load More'),
              ),
            ],
          ),
        ],
      );
    }
  }
}
