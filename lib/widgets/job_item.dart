import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wedolawns/objects/objects.dart';

class JobItem extends StatelessWidget {
  final Job job;
  final Function onDelete;
  final Function onEdit;
  final Function onComplete;
  const JobItem({
    required this.job,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        // extentRatio: 0.3,
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          SlidableAction(
            onPressed: (v) {
              onComplete();
            },
            backgroundColor: Color.fromARGB(255, 74, 166, 58),
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Cplt',
          ),
          SlidableAction(
            onPressed: (v) {
              onDelete();
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Del',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          border: Border.all(
            color: Colors.grey, // Set the border color
            width: 2.0, // Set the border width (optional)
          ),
          color: job.completed ? const Color.fromARGB(59, 76, 175, 79) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${job.name} (Est/Actual: ${job.estimatedHoursString}/${job.actualHoursString})",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      job.description,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (job.tools.isNotEmpty) ...[
                      Text("Requires: ${job.tools.join(",")}"),
                    ]
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      onEdit();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
