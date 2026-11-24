# RadPendler — offen (Stand 24.11.2026)

Gesamtstand und Prüfliste: `HANDOVER.md`. Hier nur, was gerade in der Schwebe ist.

## 1.27 (67) in TestFlight (15.11.2026)

Inhalt: Rad nie gegen die Kreisverkehrsrichtung (`RoundaboutRule`, `TripPlanner.rightWayRound`,
Overpass-Kreisverkehre in `RoadData.rings`), „Fahrt beenden?“-Text gekürzt.

Hochgeladen auf Ansage mit `SKIP_ROUTES=1`, weil Overpass überlastet war (27–41 s, 502).
`./dev rules` grün, 429 Tests grün, release-check GO.

**Offen:**
- **`./dev routes` rot seit 1.27 — Ursache gefunden (24.11.2026):** leere bzw. abgebrochene Overpass-Antworten
  im neuen Cache `osm-roads-2` (Pinneberg: 0 Elemente vom 14.11.; Berlin: kürzeste Linie mit 0 m Hauptstraße,
  1 Ampel). Die Planung *hatte* Straßendaten, nur lückenhafte — das „keine Straßendaten“ im Protokoll kommt von
  der späteren Ring-Abfrage. Behoben in `2cbce0e` (`RoadData.validate`, Cache `osm-roads-3`). Danach
  `./dev routes` grün — aber **ohne** Straßendaten (Overpass 41 s bzw. 502). Auch der Lauf vor dem Upload
  war grün ohne Daten. Ein grüner Lauf **mit** Daten fehlt noch: nachholen, sobald Overpass unter 10 s antwortet.
- **1.28 (68) in TestFlight (24.11.2026, `d9f6911`)**, auf Ansage trotz release-check STOP: Weitersagen als erste Menüzeile (Sprechblase mit Herz), Linksabbieger an
  Ampeln kosten eine Wartezeit, Rechtsabbieger sparen die halbe (`BikeCandidate.turnCost`), leere
  Overpass-Antworten verworfen. `./dev check` grün (434 Tests).
- Prüfliste neu veröffentlichen (neuer Punkt `o16`), Gerätetest Rückweg über den Kreisverkehr.
- „Was ist neu (1.27/1.28)“ in `appstore/metadata.md` fehlt (`/whatsnew`), erst zur Einreichung nötig.

## Ideen, nicht angefangen

- OSM-Daten korrigieren (`oneway=yes` am Ringradweg), falls er wirklich nur eine Richtung hat — seine
  Entscheidung, öffentliche Änderung.
- Kreisverkehrsregel auch in der Neuplanung unterwegs prüfen (`Replanner`); heute trägt nur der
  Zwischenpunkt aus dem Plan sie dorthin, und `WaypointRouting.ahead` lässt ihn in 150 m Nähe fallen.
