import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wedolawns/objects/property.dart';

class PropertyItem extends StatelessWidget {
  final Property property;
  final Function onDelete;
  final Function onEdit;

  const PropertyItem({
    required this.property,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onEdit();
      },
      child: Slidable(
        key: const ValueKey(0),
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {}),
          children: [
            SlidableAction(
              onPressed: (v) {
                onDelete();
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          height: 84,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xFFF0F9EB),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 2,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Row(
                        children: [
                          Spacer(),
                          Text(
                            property.name,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: property.statusColor,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Row(
                          children: [
                            Spacer(),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: property.totalJobString,
                                    style: TextStyle(
                                      color: Colors.black,
                                      // fontFamily: 'Bellefair',
                                      // fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(text: ", "),
                                  TextSpan(
                                    text: property.remainingJobString,
                                    style: TextStyle(
                                      color: property.remainingColor,
                                      // fontFamily: 'Bellefair',
                                      // fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: OvalBorder(),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 2,
                          offset: Offset(0, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        color: property.statusIconColor,
                        "assets/svgs/house-regular.svg",
                        semanticsLabel: 'House-Thin',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
        border: Border.all(
          color: Colors.grey, // Set the border color
          width: 2.0, // Set the border width (optional)
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
                color: property.dateFinished == null
                    ? Color.fromARGB(255, 251, 6, 6)
                    : Theme.of(context).colorScheme.primary, // Set the border color
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 16,
                          ),
                          onPressed: () {
                            onEdit();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 16,
                          ),
                          onPressed: () {
                            onDelete();
                          },
                        ),
                      ],
                    ),
                    Text("6 Jobs, 6 Remaining"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
