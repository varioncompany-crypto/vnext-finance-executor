---
name: varion-margin-watch
description: "Prueft Kostenabdeckung und nachvollziehbare Auftragsbeitraege verkaufter Artikel fuer die Finance-Rolle. Nutzen fuer Margenpruefung und priorisierte Kostenluecken; keine Buchungs- oder Zahlungsfunktion."
metadata:
  owner_role: finance
  version: "1.0.0"
---

# varion-margin-watch

## Auftrag: Kosten- und Margenkontrolle

1. Grenze Zeitraum, Geschäft, Währung und Auftragstyp anhand des konkreten Auftrags
   ein. Ohne anderen Zeitraum prüfe die neuesten vollständig gelesenen bezahlten
   Aufträge bis maximal zehn als klar benannte Stichprobe, nicht als Gesamtaussage.
   Nutze vorhandene Shopify-/sevDesk-/Lieferantenleser und deren tatsächliche Pagination.
2. Verbinde Auftrag und Position mit stabilen IDs und Originalbelegen. Freie Positionen,
   gelöschte Varianten, fehlende SKU, Teilmengen, Rabatte und Erstattungen sichtbar
   erhalten; fehlende Joins nicht still ausschließen oder als Nullkosten rechnen.
3. Ordne belegten historischen EK und die tatsächliche Steuerbasis zu. Ein heutiger
   Varianten-EK ist keine historische Rechnung. Vergleiche keine Bruttoerlöse mit
   Netto-EK und keine verschiedenen Währungen ohne belegte Umrechnung.
4. Prüfe bekannte Versand-, Verpackungs-, Zahlungs-, Retouren- und sonstige
   variable Kosten. Fehlt die vollständige Basis, liefere Kostenabdeckung und
   fehlende Belege statt eines scheinbar vollständigen Gewinns. Teile belegte
   Teilbeiträge und Annahmen; stelle Arbeitszeit und Gemeinkosten separat dar.
5. Priorisiere Lücken bei tatsächlich verkauften Positionen nach belegtem
   Betrag, Häufigkeit und Entscheidungsrelevanz. Keine erfundene Einsparung,
   Verlustdiagnose, Forderungsfälligkeit oder Zahlungsbereitschaft.

Ergebnis: Umfang/Abdeckung, Quellenbindung je relevanter Position, offene
Kostenbestandteile, gegebenenfalls nachvollziehbarer Beitrag und die nächsten
höchstens drei Beleg-/Zuordnungsprüfungen. Kundenzahlung, Bankeingang, Rechnung
und Buchung bleiben getrennte Nachweise. Bestehende Buchhaltung, geschlossene
Perioden, Kassenhistorie, Preise und Zahlungsabläufe werden hier nicht geändert.

## Einordnung und bestehender Kontext

Dieser zusätzliche Skill arbeitet im Auftrag der jeweiligen Rolle. Lies deren
aktuelle AGENTS.md und ROLE-REFERENCE.md und führe den dort vorgegebenen gemeinsamen
Kontext-/Memory-Start aus. Verwende die aktuelle Vertragsrevision und bestehende
Fach-Reader. Der Skill erweitert deren Berechtigungen nicht und ersetzt keinen
vorhandenen Skill, fachlichen Ablauf oder Freigabeprozess.

Sein eigener Umfang ist Lesen, Prüfen und ein interner Bericht oder Entwurf.
Schon autorisierte andere Abläufe bleiben getrennt gültig. Er richtet keine neue
Automatik, Infrastruktur, Erinnerung, kostenpflichtige API oder Nachrichtenroutine ein.
Keine private Kunden-, Finanz- oder Lieferanteninformation, Rohantwort oder Zugangsdaten
in dieses Rollen-Repository schreiben. Ergebnisse gehören in die bestehende,
tatsächlich als privat bestätigte Auftrags-/Ergebnisablage. Die Bezeichnung „privat“
in einer alten Notiz ersetzt keine Zugriffsprüfung.

## Nachweis und Abschluss

- Binde Erkenntnisse an tatsächliche Quellen-IDs, deren ursprüngliche Beobachtungszeit,
  den Prüfzeitpunkt, die Vertragsrevision sowie den gelesenen Ausschnitt und seine Abdeckung.
  Ein interner Status, Cache, HTTP 200 oder vorhandener Schlüssel belegt keinen Facherfolg.
- Fehlende Daten bleiben unbekannt. Veraltete, historische und synthetische Quellen
  ausdrücklich kennzeichnen; Testdaten autorisieren keine echte Geschäftsaktion.
- Berichte evidenceStatus complete, partial oder unavailable für den geprüften Umfang;
  wechsle deshalb nicht eigenmächtig das Statusschema der bestehenden Aufgaben.
- Liefere die wesentlichen Befunde mit owner, sourceRefs, nächstem konkretem Schritt
  und einem tatsächlich prüfbaren Ergebnisverweis. Zeige nur belegte Beträge und Wirkungen.
- Nutze für zugeordnete Aufgaben den bestehenden shared_tasks.py-/TaskPort-Vertrag
  einschließlich erwarteter Version, operationId und Ergebnis-Readback. Ein unklarer
  Schreibausgang wird vor Wiederholung abgeglichen. Ohne aktuelle Aufgabe keine
  beliebige fremde Aufgabe übernehmen oder als abgeschlossen markieren.
- Beende den gemeinsamen Kontextlauf wie in AGENTS.md vorgesehen. Fehlt ein Zugriff,
  benenne den genauen Reader/Scope/Fehler, setze nur abhängige Arbeit aus und behaupte
  weder gespeicherte Ergebnisse noch eine erfolgreiche Live-Abnahme.
