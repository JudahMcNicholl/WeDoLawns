class DriveItem {
  final String id;
  final String name;
  final String path;
  final String mimeType;

  bool isSelected = false;
  bool isTitle = false;

  DriveItem({
    required this.id,
    required this.name,
    required this.path,
    this.isSelected = false,
    this.isTitle = false,
    required this.mimeType,
  });
}
