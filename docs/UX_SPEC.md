# UX Specification

## Languages

- English
- Arabic

The application must support runtime locale switching without changing domain state.

## Passenger booking flow

```text
Search
 → Trip details
 → Seat map
 → Select seats
 → Hold
 → Passenger details
 → Cash confirmation
 → Ticket
```

## UX constraints

- Booking state is always visible.
- Hold expiry is explicit.
- Failed seat acquisition explains that availability changed.
- Offline state is visible.
- Cached trip information is clearly distinguishable from authoritative mutation results.
- Destructive actions require confirmation.
