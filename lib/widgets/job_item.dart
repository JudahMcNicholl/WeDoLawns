import 'package:flutter/material.dart';
import 'package:wedolawns/objects/objects.dart';

class JobItem extends StatelessWidget {
  final Job job;
  final Function onDelete;
  const JobItem({
    required this.job,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
        border: Border.all(
          color: Colors.grey, // Set the border color
          width: 2.0, // Set the border width (optional)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(job.description),
                if (job.tools.isNotEmpty) ...[
                  Text("Requires: ${job.tools.join(",")}"),
                ]
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                onDelete(job);
              },
            ),
          ],
        ),
      ),
    );
  }
}
