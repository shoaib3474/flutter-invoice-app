import 'package:flutter/material.dart';

class ComplianceScoreWidget extends StatelessWidget {
  final int score;
  
  const ComplianceScoreWidget({
    Key? key,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    String scoreText;
    
    if (score >= 90) {
      scoreColor = Colors.green;
      scoreText = 'Excellent';
    } else if (score >= 75) {
      scoreColor = Colors.lightGreen;
      scoreText = 'Good';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreText = 'Average';
    } else {
      scoreColor = Colors.red;
      scoreText = 'Poor';
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.1),
                border: Border.all(
                  color: scoreColor,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Score details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scoreText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your GST compliance score is based on timely filing, payment history, and reconciliation accuracy.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to compliance details screen
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
