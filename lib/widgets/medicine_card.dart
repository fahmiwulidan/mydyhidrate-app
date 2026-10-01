import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onToggleTaken;
  final VoidCallback? onDelete;

  const MedicineCard({
    Key? key,
    required this.medicine,
    this.onToggleTaken,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(medicine.name),
        subtitle: Text('Dose: ${medicine.dose} - Time: ${medicine.time}'),
        trailing: Wrap(
          spacing: 12,
          children: [
            IconButton(
              icon: Icon(
                medicine.taken
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: medicine.taken ? Colors.green : null,
              ),
              onPressed: onToggleTaken,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
