import 'package:flutter/material.dart';
import 'package:gameior/shared/models/enums.dart';

const Map<SportType, IconData> sportIcons = {
  SportType.badminton:  Icons.sports_tennis,      // closest available
  SportType.football:   Icons.sports_soccer,
  SportType.cricket:    Icons.sports_cricket,
  SportType.basketball: Icons.sports_basketball,
  SportType.tennis:     Icons.sports_tennis,
  SportType.volleyball: Icons.sports_volleyball,
  SportType.pickleball: Icons.sports_tennis,
  SportType.other:      Icons.sports,
};