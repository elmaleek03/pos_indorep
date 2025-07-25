import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/transaction/components/order_detail_print_view_dua.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionDetailView extends StatefulWidget {
  final TransactionData transaction;
  const TransactionDetailView({required this.transaction, super.key});

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  ReceiptController? controller;
  double? progress;
  bool isPrinting = false;

  Future<void> _startPrint() async {
    final provider = Provider.of<MainProvider>(context, listen: false);
    final address = provider.printerAddress;

    if (address.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Tidak ada printer yang terhubung',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    controller!.print(
      address: address,
      addFeeds: 5,
      keepConnected: true,
      onProgress: (total, sent) {
        if (mounted) {
          setState(() {
            progress = sent / total;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String orderStatus;
    if (widget.transaction.status == 'cancelled') {
      orderStatus = 'Dibatalkan';
    } else if (widget.transaction.status == 'pending') {
      orderStatus = 'Pending';
    } else if (widget.transaction.status == 'paid') {
      orderStatus = 'Sukses';
    } else {
      orderStatus = widget.transaction.status; // fallback
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Receipt(
              backgroundColor: Colors.transparent,
              builder: (context) {
                return Column(
                  children: [
                    Text('INDOREP GAMING & CAFFE',
                        style: GoogleFonts.robotoMono(
                            fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Jl. Margonda No. 386, Beji, Kota Depok',
                        style: GoogleFonts.robotoMono(fontSize: 18)),
                    const SizedBox(height: 24),
                    Text(
                        '-------------------------------------------------------------',
                        style: GoogleFonts.robotoMono(fontSize: 18)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.transaction.orderId,
                              style: GoogleFonts.robotoMono(fontSize: 18)),
                          Text(
                              '${Helper.dateFormatterTwo(widget.transaction.time)} - ${Helper.timeFormatterTwo(widget.transaction.time)}',
                              style: GoogleFonts.robotoMono(fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Via: ${widget.transaction.paymentMethod.toUpperCase()}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Status: ${orderStatus.toUpperCase()}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                        '-------------------------------------------------------------',
                        style: GoogleFonts.robotoMono(fontSize: 18)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pesanan:',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.transaction.items.length,
                      itemBuilder: (context, index) {
                        final cart = widget.transaction.items[index];
                        return ListTile(
                          title: Text(
                            cart.name,
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cart.qty} x ${Helper.rupiahFormatter(cart.subTotal.toDouble())}',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              for (var option in cart.option)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${option.option} : ${option.value} (+ ${Helper.rupiahFormatter(option.price.toDouble())})',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ${Helper.rupiahFormatter(widget.transaction.total.toDouble())}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Info, saran, dan masukan',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'business@indorep.com',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: QrImageView(
                        data: "DUMMY-QR-123456",
                        version: QrVersions.auto,
                        size: 120.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Terima Kasih!',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 150,
                      ),
                    ),
                  ],
                );
              },
              onInitialized: (ctrl) => setState(() => controller = ctrl),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (controller == null) {
                Fluttertoast.showToast(
                  msg: 'Printer belum siap!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return;
              }
              setState(() {
                isPrinting = true;
              });
              await _startPrint();
            },
            label: Text(
                !isPrinting
                    ? 'Cetak Struk'
                    : 'Mencetak Struk ${((progress ?? 0) * 100).round()}%',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            icon: Icon(Icons.print_rounded, size: 20),
          ),
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => PopScope(
                  canPop: false,
                  child: OrderDetailPrintViewDua(
                    transaction: widget.transaction,
                  ),
                ),
              );
            },
            label: Text('Order Detail',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            icon: Icon(Icons.receipt_long_rounded, size: 20),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
