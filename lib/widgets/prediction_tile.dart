import 'package:flutter/material.dart';
import 'package:rider_app/models/place_predictions.dart';

class PredictionTile extends StatelessWidget {
  final String secondaryText;
  final String mainText;
  final Function onTap;

  const PredictionTile({Key key, this.mainText, this.secondaryText, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainText,
                        style: TextStyle(
                          fontSize: 16.0,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 3.0)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
