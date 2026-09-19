import 'dart:math';

double calcularMeanRR(List<int> rrList) {
  return rrList.reduce((a, b) => a + b) / rrList.length;
}

double calcularMeanHR(List<int> rrList) {
  final meanRR = calcularMeanRR(rrList);
  return 60000 / meanRR;
}

double calcularSDNN(List<int> rrList) {
  final mean = calcularMeanRR(rrList);
  final variance = rrList
          .map((rr) => (rr - mean) * (rr - mean))
          .reduce((a, b) => a + b) /
      rrList.length;
  return sqrt(variance);
}

double calcularRMSSD(List<int> rrList) {
  final diffs = <double>[];
  for (int i = 1; i < rrList.length; i++) {
    diffs.add(pow(rrList[i] - rrList[i - 1], 2).toDouble());
  }
  return sqrt(diffs.reduce((a, b) => a + b) / diffs.length);
}

double calcularLnRMSSD(List<int> rrList) {
  return log(calcularRMSSD(rrList));
}

double calcularPNN50(List<int> rrList) {
  int count = 0;
  for (int i = 1; i < rrList.length; i++) {
    if ((rrList[i] - rrList[i - 1]).abs() > 50) count++;
  }
  return (count / (rrList.length - 1)) * 100;
}