import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DailyModeCard extends StatelessWidget {
  String? assetSvg;

  DailyModeCard({
    super.key,
    this.assetSvg,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.4;
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SvgPicture.asset(
          assetSvg??"",),
      // child:
      // Row(
      //   children: [
      //     const SizedBox(width: 8),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           Text(
      //             title,
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 14,
      //               fontWeight: FontWeight.bold,
      //             ),
      //             maxLines: 1,
      //             overflow: TextOverflow.ellipsis,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
} 