import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rsiap_dokter/config/colors.dart';
import 'package:rsiap_dokter/utils/msg.dart';

class RadiologiImage extends StatefulWidget {
  final String downloadUrl;

  const RadiologiImage({super.key, required this.downloadUrl});

  @override
  State<RadiologiImage> createState() => _RadiologiImageState();
}

class _RadiologiImageState extends State<RadiologiImage> {
  bool downloading = false;
  bool isHaveDownloading = false;
  bool isDownloadContainerVisible = false;

  String filePath = '';
  String progressString = "0%";
  String downloadStart = "Mulai Download...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          widget.downloadUrl,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => requestPermission(widget.downloadUrl),
        backgroundColor: Colors.white,
        child: childFloatdownload(isHaveDownloading, downloading, progressString, downloadStart),
      ),
    );
  }

  Future<void> requestPermission(downloadUrl) async {
    var manStorage = await Permission.storage.status;
    var mediaLi = await Permission.mediaLibrary.status;
    var medLoc = await Permission.accessMediaLocation.status;

    if (!mediaLi.isGranted) {
      await Permission.mediaLibrary.request();
    }
    
    if (!medLoc.isGranted) {
      await Permission.accessMediaLocation.request();
    }

    if(!manStorage.isGranted) {
      await Permission.storage.request();
    }

    openFile(downloadUrl);
  }

  void openFile(String url) async {
    var dir;
    
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first.path;
    } else {
      dir = (await getDownloadsDirectory())?.path;
    }

    filePath = "$dir/${url.substring(url.lastIndexOf('/') + 1)}";
    print("Lokasi File $filePath");

    File file = File(filePath);

    var isExist = await file.exists();
    if (isExist) {
      print('File Exist----------');
      await OpenFile.open(filePath);
      setState(() {
        isDownloadContainerVisible = false;
        isHaveDownloading = true;
      });
    } else {
      print('File Tidak Ada ----------');
      downloadFile(url);
    }
  }

  Future<void> downloadFile(String url) async {
    Dio dio = Dio();

    setState(() {
      downloading = true;
      progressString = "0%";
      downloadStart = "Loading...";
      isDownloadContainerVisible = true;
    });

    try {
      await dio.download(url, filePath, onReceiveProgress: (
        rec,
        total,
      ) {
        print("Rec: $rec , Total: $total");
        setState(() {
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
      
      setState(() {
        downloading = false;
        progressString = "";
        downloadStart = "";
        isHaveDownloading = true;
      });

      Msg.success(context, "Download selesai");
      await Future.delayed(Duration(seconds: 2));

      openFile(url);

    } catch (e) {
      setState(() {
        downloading = false;
        progressString = "";
        downloadStart = "";
        isHaveDownloading = false;
      });

      print(e);
      Msg.error(context, "Gagal download file");
    }
  }

  childFloatdownload(bool isHaveDownloading, bool downloading, String progressString, String downloadStart) {
    if (isHaveDownloading) {
      return Icon(Icons.open_in_new, color: primaryColor);
    } else {
      if (downloading) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 8,
              width: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[400],
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              progressString,
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
          ],
        );
      } else {
        return Icon(Icons.download, color: Colors.black);
      }
    }
  }
}