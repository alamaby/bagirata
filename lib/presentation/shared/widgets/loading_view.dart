import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 12.h),
            Text(message!, style: TextStyle(fontSize: 14.sp)),
          ],
        ],
      ),
    );
  }
}
