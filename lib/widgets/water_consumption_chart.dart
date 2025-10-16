import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:watertrack/services/history_service.dart';
import 'package:collection/collection.dart';

class WaterConsumptionChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final bool showAxisLabels;

  const WaterConsumptionChart({
    super.key,
    required this.data,
    required this.title,
    this.showAxisLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final spots = data.entries.mapIndexed((index, entry) => 
      FlSpot(index.toDouble(), entry.value)
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        AspectRatio(
          aspectRatio: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: showAxisLabels ? SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ) : const SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: showAxisLabels ? SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Text(
                            data.keys.elementAt(index).split('-').last,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ) : const SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}