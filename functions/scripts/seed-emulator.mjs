import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  throw new Error('Refusing to seed: FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST must both be set.');
}

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const readJson = async (name) => JSON.parse(await fs.readFile(path.join(root, 'data/demo', name), 'utf8'));
const operator = await readJson('operator.json');
const buses = await readJson('buses.json');
const trips = await readJson('trips.json');
const users = await readJson('users.json');
const capabilities = await readJson('capabilities.json');

initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'via-dev-5ca8e' });
const db = getFirestore();
const auth = getAuth();
const operatorRef = db.collection('operators').doc(operator.operatorId);

await operatorRef.set({ ...operator, source: 'demo-emulator' });

const personas = { Passenger: 'passenger', Driver: 'driver', Operator: 'operator', Owner: 'owner', Finance: 'finance', Admin: 'admin' };
for (const user of users) {
  let record;
  try { record = await auth.getUser(user.id); } catch { record = await auth.createUser({ uid: user.id, displayName: user.displayName }); }
  const role = personas[user.persona];
  const caps = capabilities[role] ?? [];
  await auth.setCustomUserClaims(record.uid, { operatorId: operator.operatorId, capabilities: caps, demoPersona: role });
  await operatorRef.collection('members').doc(record.uid).set({
    uid: record.uid, displayName: user.displayName, persona: user.persona,
    capabilities: Object.fromEntries(caps.map((cap) => [cap, true])), source: 'demo-emulator',
  });
}

for (const [index, bus] of buses.entries()) {
  const busRef = operatorRef.collection('buses').doc(bus.busId);
  await busRef.set({ ...bus, source: 'demo-emulator' });
  process.stdout.write(`Seeded bus ${index + 1}/${buses.length}: ${bus.busId}\n`);
}

for (const trip of trips) {
  const tripRef = operatorRef.collection('trips').doc(trip.tripId);
  await tripRef.set({ ...trip, source: 'demo-emulator' });
  const batch = db.batch();
  for (let seat = 1; seat <= trip.seatCapacity; seat += 1) {
    const seatId = `A${String(seat).padStart(2, '0')}`;
    batch.set(tripRef.collection('seats').doc(seatId), {
      seatId, status: 'available', row: Math.ceil(seat / 2), position: seat % 2 === 1 ? 'left' : 'right', source: 'demo-emulator',
    });
  }
  await batch.commit();
}

console.log(`VIA demo emulator seed complete: ${buses.length} buses, ${trips.length} trips.`);
