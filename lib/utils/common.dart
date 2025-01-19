void swapItems<T>(List<T> list, int index1, int index2) {
  if (index1 < 0 || index2 < 0 || index1 >= list.length || index2 >= list.length) {
    throw ArgumentError('Indices are out of bounds');
  }

  T temp = list[index1];
  list[index1] = list[index2];
  list[index2] = temp;
}
