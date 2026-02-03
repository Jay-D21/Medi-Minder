import 'package:flutter/material.dart';

class SupplyIndicator extends StatelessWidget {
  final int currentSupply;
  final int maxSupply; // Or threshold relative
  final int lowThreshold;

  const SupplyIndicator({
    super.key,
    required this.currentSupply,
    this.maxSupply = 100, // Default or passed max
    this.lowThreshold = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage (clamped 0.0 to 1.0)
    // If we don't track max supply per bottle, we might just show color
    // For MVP, let's assume 'maxSupply' isn't explicitly tracked per refill yet,
    // so we visualize mostly based on threshold.

    final bool isLow = currentSupply <= lowThreshold;
    final Color color = isLow ? Colors.red : Colors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 1.0, // Full circle background
              color: Colors.grey[200],
            ),
            CircularProgressIndicator(
              value: isLow
                  ? 0.2
                  : 0.8, // Arbitrary visual for low/high if max unknown
              color: color,
            ),
            Text(
              currentSupply.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        if (isLow)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Low',
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          ),
      ],
    );
  }
}
