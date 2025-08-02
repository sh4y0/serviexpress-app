import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonHome extends StatelessWidget {
  const SkeletonHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(38, 48, 137, 1),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(38, 48, 137, 1),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 110,
            child: Shimmer.fromColors(
              baseColor: const Color.fromRGBO(200, 200, 200, 0.3),
              highlightColor: const Color.fromRGBO(255, 255, 255, 0.6),

              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 98,
                      height: 39,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(88, 101, 242, 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(22, 26, 80, 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(
                      38,
                      48,
                      137,
                      1,
                    ).withAlpha((0.5 * 255).toInt()),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(38, 48, 137, 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: const Color.fromRGBO(
                                200,
                                200,
                                200,
                                0.3,
                              ),
                              highlightColor: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.6,
                              ),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(58, 68, 157, 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Shimmer.fromColors(
                                baseColor: const Color.fromRGBO(
                                  200,
                                  200,
                                  200,
                                  0.3,
                                ),
                                highlightColor: const Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.6,
                                ),
                                child: Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(58, 68, 157, 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(38, 48, 137, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
