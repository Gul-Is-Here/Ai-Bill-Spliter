import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../bill/models/bill.dart';
import '../../bill/repositories/bill_repository.dart';

/// Receipt image from local file (fresh/offline) or Storage, wrapped in a Hero keyed by bill id.
class ReceiptThumbnail extends StatelessWidget {
  const ReceiptThumbnail({super.key, required this.bill, this.size = 56, this.fit = BoxFit.cover});

  final Bill bill;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final local = bill.localImagePath;
    final Widget image;
    if (local != null && File(local).existsSync()) {
      image = Image.file(File(local), width: size, height: size, fit: fit, semanticLabel: 'receipt_image'.tr);
    } else if (bill.receiptPath != null) {
      image = FutureBuilder<String>(
        future: Get.find<BillRepository>().receiptUrl(bill.receiptPath!),
        builder: (context, snap) => snap.hasData
            ? CachedNetworkImage(
                imageUrl: snap.data!,
                cacheKey: bill.receiptPath,
                width: size,
                height: size,
                fit: fit,
                errorWidget: (_, _, _) => _placeholder(context),
              )
            : _placeholder(context),
      );
    } else {
      return _placeholder(context);
    }
    return Hero(
      tag: 'receipt_${bill.id}',
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
    );
  }

  Widget _placeholder(BuildContext context) => SizedBox.square(
        dimension: size,
        child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.outline),
      );
}
