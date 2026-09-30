// RSVPs for company events (not holidays — you can't RSVP to Dashain).

import 'package:flutter/foundation.dart';

import '../data/team_data.dart';

enum Rsvp { going, maybe, notGoing }

String rsvpLabel(Rsvp r) => switch (r) {
  Rsvp.going => 'Going',
  Rsvp.maybe => 'Maybe',
  Rsvp.notGoing => "Can't go",
};

class EventRsvpState extends ChangeNotifier {
  final Map<String, Rsvp> _rsvps = {};

  Rsvp? rsvpFor(String eventId) => _rsvps[eventId];

  int goingCount(CompanyEvent event) =>
      event.othersGoing + (_rsvps[event.id] == Rsvp.going ? 1 : 0);

  void setRsvp(String eventId, Rsvp rsvp) {
    _rsvps[eventId] = rsvp;
    notifyListeners();
  }

  void reset() {
    _rsvps.clear();
    notifyListeners();
  }
}
