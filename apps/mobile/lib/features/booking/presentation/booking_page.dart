import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/result.dart';
import '../../../domain/booking/booking.dart';
import '../../../domain/booking/booking_action_result.dart';
import '../../../domain/trip/trip.dart';
import '../data/booking_repository.dart';

class BookingPage extends StatefulWidget {
  final VoidCallback onToggleLocale;
  final BookingRepository repository;

  const BookingPage({super.key, required this.onToggleLocale, required this.repository});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Trip? selectedTrip;
  final selectedSeats = <String>{};
  final fromController = TextEditingController(text: 'Damascus');
  final toController = TextEditingController(text: 'Daraa University Area');
  Booking? activeBooking;
  BookingActionResult? latestAction;
  bool showResults = false;
  bool busy = false;
  String fareMode = 'oneWay';
  DateTime? now;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final booking = activeBooking;
    final isAwaiting = booking?.status == BookingStatus.awaitingCashConfirmation;
    final isConfirmed = booking?.status == BookingStatus.confirmed;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/branding/via-app-icon.png', width: 36, height: 36)),
          const SizedBox(width: 10),
          Text(strings.appName, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          _StatusPill(label: strings.demoMode),
        ]),
        actions: [
          TextButton(onPressed: widget.onToggleLocale, child: Text(strings.language)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
        children: [
          Text(strings.headline, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(strings.route, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 18),
          _SearchCard(strings: strings, from: fromController, to: toController, onSearch: _search),
          if (showResults) ...[
            const SizedBox(height: 20),
            Text(strings.availableTrips, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ...demoTrips
                .where((trip) => trip.origin.toLowerCase().contains(fromController.text.trim().toLowerCase()) && trip.destination.toLowerCase().contains(toController.text.trim().toLowerCase()))
                .map((trip) => _TripCard(trip: trip, selected: selectedTrip?.id == trip.id, onTap: () => setState(() { selectedTrip = trip; selectedSeats.clear(); activeBooking = null; latestAction = null; }))),
          ],
          if (selectedTrip != null && activeBooking == null) _SeatCard(strings: strings, trip: selectedTrip!, selectedSeats: selectedSeats, fareMode: fareMode, onFareModeChanged: (value) => setState(() => fareMode = value), onToggleSeat: _toggleSeat, onHold: _holdSeats, busy: busy),
          if (booking != null) _BookingStatusCard(strings: strings, booking: booking, now: now ?? DateTime.now(), onRequestCash: _requestCash, onConfirmCash: _confirmCash, busy: busy, isAwaiting: isAwaiting, isConfirmed: isConfirmed, latestAction: latestAction),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.security_outlined),
                const SizedBox(width: 12),
                Expanded(child: Text(strings.trustedBoundaryText)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _search() => setState(() {
        showResults = true;
        selectedTrip = null;
        selectedSeats.clear();
        activeBooking = null;
        latestAction = null;
      });

  void _toggleSeat(String seat) {
    if (activeBooking != null) return;
    setState(() {
      if (selectedSeats.remove(seat)) return;
      if (selectedSeats.length < 8) selectedSeats.add(seat);
    });
  }

  Future<void> _holdSeats() async {
    final trip = selectedTrip;
    if (trip == null || selectedSeats.isEmpty) return;
    setState(() => busy = true);
    final result = await widget.repository.holdSeats(
      tripId: trip.id,
      seatIds: selectedSeats.toList()..sort(),
      fareMode: fareMode,
      idempotencyKey: 'demo-${trip.id}-${selectedSeats.join('-')}-$fareMode',
    );
    if (!mounted) return;
    setState(() => busy = false);
    switch (result) {
      case Success<Booking>():
        setState(() => activeBooking = result.value);
      case Failure<Booking>():
        _showError(result.message);
    }
  }

  Future<void> _requestCash() async {
    final booking = activeBooking;
    if (booking == null) return;
    setState(() => busy = true);
    final result = await widget.repository.requestCashConfirmation(bookingId: booking.id, idempotencyKey: 'demo-cash-request-${booking.id}');
    if (!mounted) return;
    setState(() => busy = false);
    switch (result) {
      case Success<BookingActionResult>():
        setState(() => activeBooking = _copyBooking(booking, BookingStatus.awaitingCashConfirmation));
      case Failure<BookingActionResult>():
        _showError(result.message);
    }
  }

  Future<void> _confirmCash() async {
    final booking = activeBooking;
    if (booking == null) return;
    setState(() => busy = true);
    final result = await widget.repository.confirmCash(bookingId: booking.id, idempotencyKey: 'demo-cash-confirm-${booking.id}');
    if (!mounted) return;
    setState(() => busy = false);
    switch (result) {
      case Success<BookingActionResult>():
        setState(() {
          latestAction = result.value;
          activeBooking = _copyBooking(booking, BookingStatus.confirmed);
        });
      case Failure<BookingActionResult>():
        _showError(result.message);
    }
  }

  Booking _copyBooking(Booking booking, BookingStatus status) => Booking(
        id: booking.id,
        operatorId: booking.operatorId,
        passengerId: booking.passengerId,
        tripId: booking.tripId,
        seatIds: booking.seatIds,
        status: status,
        createdAt: booking.createdAt,
        holdExpiresAt: booking.holdExpiresAt,
      );

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _SearchCard extends StatelessWidget {
  final AppStrings strings;
  final TextEditingController from;
  final TextEditingController to;
  final VoidCallback onSearch;
  const _SearchCard({required this.strings, required this.from, required this.to, required this.onSearch});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    TextField(controller: from, decoration: InputDecoration(labelText: strings.from, prefixIcon: const Icon(Icons.trip_origin))),
    const SizedBox(height: 12),
    TextField(controller: to, decoration: InputDecoration(labelText: strings.to, prefixIcon: const Icon(Icons.location_on_outlined))),
    const SizedBox(height: 14),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onSearch, icon: const Icon(Icons.search), label: Text(strings.searchTrips))),
  ])));
}

class _SeatCard extends StatelessWidget {
  final AppStrings strings;
  final Trip trip;
  final Set<String> selectedSeats;
  final String fareMode;
  final ValueChanged<String> onFareModeChanged;
  final ValueChanged<String> onToggleSeat;
  final VoidCallback onHold;
  final bool busy;
  const _SeatCard({required this.strings, required this.trip, required this.selectedSeats, required this.fareMode, required this.onFareModeChanged, required this.onToggleSeat, required this.onHold, required this.busy});
  @override
  Widget build(BuildContext context) {
    final totalFare = selectedSeats.length * (fareMode == 'roundTrip' ? trip.roundTripFareSyp : trip.oneWayFareSyp);
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(strings.chooseSeats, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      SegmentedButton<String>(segments: [
        ButtonSegment(value: 'oneWay', label: Text(strings.oneWay)),
        ButtonSegment(value: 'roundTrip', label: Text(strings.roundTrip)),
      ], selected: {fareMode}, onSelectionChanged: (value) => onFareModeChanged(value.first)),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: List.generate(trip.seatCapacity, (index) {
        final seat = 'A${(index + 1).toString().padLeft(2, '0')}';
        return FilterChip(label: Text(seat), selected: selectedSeats.contains(seat), onSelected: (_) => onToggleSeat(seat));
      })),
      const SizedBox(height: 14),
      Text('${strings.seats(selectedSeats.length)} • ${strings.price(totalFare)}'),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: selectedSeats.isEmpty || busy ? null : onHold, icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_clock_outlined), label: Text(strings.holdSeats))),
    ])));
  }
}

class _BookingStatusCard extends StatelessWidget {
  final AppStrings strings;
  final Booking booking;
  final DateTime now;
  final VoidCallback onRequestCash;
  final VoidCallback onConfirmCash;
  final bool busy;
  final bool isAwaiting;
  final bool isConfirmed;
  final BookingActionResult? latestAction;
  const _BookingStatusCard({required this.strings, required this.booking, required this.now, required this.onRequestCash, required this.onConfirmCash, required this.busy, required this.isAwaiting, required this.isConfirmed, required this.latestAction});

  @override
  Widget build(BuildContext context) {
    final remaining = booking.holdExpiresAt == null ? Duration.zero : booking.holdExpiresAt!.difference(now);
    final expired = !isConfirmed && remaining <= Duration.zero;
    final positiveRemaining = remaining.isNegative ? Duration.zero : remaining;
    final mins = positiveRemaining.inMinutes.toString().padLeft(2, '0');
    final secs = (positiveRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.confirmation_num_outlined), const SizedBox(width: 10), Text('${strings.bookingId}: ${booking.id}', style: const TextStyle(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 8),
      Text('${strings.bookingStatus}: ${expired ? strings.expired : booking.status.name}'),
      if (!isConfirmed && !expired) Text('${strings.holdCountdown}: $mins:$secs'),
      Text('${strings.seats(booking.seatIds.length)} • ${booking.seatIds.join(', ')}'),
      const SizedBox(height: 12),
      if (booking.status == BookingStatus.held && !expired) SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : onRequestCash, child: Text(strings.requestCash))),
      if (isAwaiting) ...[
        Text(strings.awaitingCash, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: busy ? null : onConfirmCash, child: Text(strings.simulateCashConfirmation))),
      ],
      if (isConfirmed && latestAction != null) ...[
        const Divider(height: 24),
        Text(strings.ticketIssued, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text('${strings.ticketId}: ${latestAction!.ticketId}'),
        Text('${strings.price(latestAction!.fareSyp ?? 0)} • ${strings.commission}: ${latestAction!.commissionSyp ?? 0} SYP'),
      ],
    ])));
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip; final bool selected; final VoidCallback onTap;
  const _TripCard({required this.trip, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), onTap: onTap, leading: CircleAvatar(child: Text(trip.departureLocal.substring(0, 2))), title: Text('${trip.origin} → ${trip.destination}', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${trip.busId} • ${trip.seatCapacity} seats • ${trip.oneWayFareSyp} SYP one way'), trailing: selected ? const Icon(Icons.check_circle) : const Icon(Icons.chevron_right)));
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(999)), child: Text(label, style: Theme.of(context).textTheme.labelMedium));
}
