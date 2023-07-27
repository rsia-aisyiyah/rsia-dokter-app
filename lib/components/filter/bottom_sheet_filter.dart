import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_dokter/config/config.dart';

//ignore: must_be_immutable
class BottomSheetFilter extends StatefulWidget {
  TextEditingController dateinput;
  TextEditingController searchController;

  bool isLoding;
  bool isFilter;

  Function fetchPasien;
  Function setData;
  Function doFilter;
  Function onClearAndCancel;

  Map filterData;

  String selectedCategory;

  BottomSheetFilter({
    super.key,
    required this.dateinput,
    required this.searchController,
    required this.isLoding,
    required this.isFilter,
    required this.fetchPasien,
    required this.setData,
    required this.doFilter,
    required this.filterData,
    required this.selectedCategory,
    required this.onClearAndCancel,
  });

  @override
  State<BottomSheetFilter> createState() => _BottomSheetFilterState();
}

class _BottomSheetFilterState extends State<BottomSheetFilter> {
  Widget _customCapsuleFilter(String title, String key, String value) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            widget.filterData[key] = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: widget.filterData['penjab'] == value
                ? accentColor.withOpacity(0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: widget.filterData['penjab'] == value
                  ? accentColor
                  : Colors.grey[500]!,
              width: 1.5,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.filterData['penjab'] == value
                  ? accentColor
                  : Colors.grey[500]!,
              fontSize: 14,
              fontWeight: fontWeightSemiBold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
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
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.filter_alt,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Filter Pasien",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
              const Text(
                "Cari Pasien",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: "Masukan keywords . . .",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: widget.searchController.text.isNotEmpty
                          ? accentColor
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 15),
              const Text(
                "Tanggal Registrasi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: widget.dateinput,
                decoration: InputDecoration(
                  hintText: "Pilih Tanggal",
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: widget.dateinput.text.isNotEmpty
                        ? accentColor
                        : Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: widget.dateinput.text.isNotEmpty
                          ? accentColor
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: accentColor,
                            onPrimary: Colors.white,
                            surface: accentColor,
                            onSurface: textColor,
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(
                      pickedDate,
                    );

                    setState(() {
                      widget.dateinput.text = formattedDate;
                      widget.filterData['tgl_registrasi'] = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 15),
              const Text(
                "Kategori Pasien",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Flex(
                direction: Axis.horizontal,
                children: [
                  _customCapsuleFilter(
                    "BPJS PBI",
                    'penjab',
                    'BPJS KESEHATAN / PBI',
                  ),
                  const SizedBox(width: 10),
                  _customCapsuleFilter(
                    "BPJS NON PBI",
                    'penjab',
                    'BPJS KESEHATAN / NON PBI',
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [_customCapsuleFilter("UMUM", 'penjab', "UMUM")],
                ),
              )
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      widget.onClearAndCancel();
                      Navigator.pop(context);
                    },
                    child: const Text("Cancle & Clear"),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColorLight,
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      widget.doFilter();
                      Navigator.pop(context);
                    },
                    child: const Text("Apply"),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}