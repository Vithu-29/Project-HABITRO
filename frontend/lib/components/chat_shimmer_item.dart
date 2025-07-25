import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmerItem extends StatelessWidget {
  const ChatShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white, radius: 24),
        title: Container(
          width: double.infinity,
          height: 12.0,
          color: Colors.white,
        ),
        subtitle: Container(
          width: 150.0,
          height: 12.0,
          color: Colors.white,
          margin: const EdgeInsets.only(top: 8),
        ),
        trailing: Container(
          width: 40.0,
          height: 10.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
