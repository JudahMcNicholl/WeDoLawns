import 'package:flutter/material.dart';

class AddJobDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(String, String, String) onAddJob;
  const AddJobDialog({
    super.key,
    required this.items,
    required this.onAddJob,
  });

  @override
  _AddJobDialogState createState() => _AddJobDialogState();
}

class _AddJobDialogState extends State<AddJobDialog> {
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _jobEstimatedHoursController = TextEditingController(text: "0");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Job"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: TextField(
                controller: _jobNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: TextField(
                controller: _jobDescriptionController,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Description",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: TextField(
                controller: _jobEstimatedHoursController,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Estimated hours",
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.items.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.items[index]["isActive"] = !widget.items[index]["isActive"];
                      });
                    },
                    child: Container(
                      height: 56,
                      width: 102,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: widget.items[index]["isActive"] ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.items[index]["isActive"] ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.items[index]['icon'],
                            color: widget.items[index]["isActive"] ? Colors.white : Colors.black,
                          ),
                          SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              widget.items[index]['label'],
                              style: TextStyle(
                                color: widget.items[index]["isActive"] ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Close the dialog
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAddJob(
              _jobNameController.text,
              _jobDescriptionController.text,
              _jobEstimatedHoursController.text,
            );
            _jobNameController.clear();
            _jobDescriptionController.clear();
            Navigator.of(context).pop(true); // Close the dialog
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
