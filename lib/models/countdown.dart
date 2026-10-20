sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

Countdown calculateCountdown(DateTime startsAt, DateTime now) {
  final difference = startsAt.difference(now);

  if (!difference.isNegative) {
    return Upcoming(difference);
  }

  final elapsed = now.difference(startsAt);

  if (elapsed < const Duration(hours: 2)) {
    return Started(elapsed);
  }

  return const Ended();
}

String countdownText(Countdown countdown) {
  return switch (countdown) {
    Upcoming(:final remaining) =>
      'Starts in ${remaining.inDays}d '
          '${remaining.inHours.remainder(24)}h '
          '${remaining.inMinutes.remainder(60)}m',

    Started(:final elapsed) => 'Started ${elapsed.inMinutes} minutes ago',

    Ended() => 'Session ended',
  };
}
