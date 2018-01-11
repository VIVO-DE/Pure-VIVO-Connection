# Pure-VIVO-Connection

Es handelt sich um eine prototypische Anbindung Pures an VIVO. Sie besteht aus einer Modellierung des Mappings des Pure-Datenmodells auf die VIVO-Ontologien und einem Shell-Skript, welches die Prozessierung der Daten von Pure nach VIVO steuert. Für die Transformation aus dem Pure-eigenen XML-Format nach RDF kommt das Tool [Karma](http://usc-isi-i2.github.io/karma/) zum Einsatz. Aufgrund unterschiedlicher Probleme (siehe unten) sind die Daten nur rudimentär gemappt.

# Bestandteile:
- vivo-update.sh: Update-Skript
- Karma-Models: Für jede zu übertragende Entität existiert jeweils ein Karma-Model:
  - Organisationseinheiten: organisational-units.xml-model.ttl
  - Personen: persons.xml-model.ttl
  - Publikationen: research-outputs.xml-model.ttl

# Ablauf:
Die Daten werden

1. aus der REST-API Pures geladen,
2. mittels Karma in RDF transformiert und
3. per SPARQL nach VIVO importiert.

# Hinweise:
- das Update-Skript ist zur lokalen Ausführung auf dem VIVO-Server konzipiert und benötigt HTTP-Zugriff auf Pure
- getestet mit: VIVO 1.9, Pure 5.10, Karma 2.0.53

# Konfiguration:
1. Vorbereitung: 
	- Karma Webservices im Tomcat bereitstellen: https://github.com/usc-isi-i2/Web-Karma/tree/master/karma-web-services/web-services-rdf
	- Skript & Models auf den Server kopieren: /usr/local/VIVO
2. SPARQL-Endpoint in VIVO aktivieren: https://wiki.duraspace.org/display/VIVODOC19x/SPARQL+Update+API#SPARQLUpdateAPI-EnablingtheAPI
3. Cronjob zur regelmäßigen Ausführung des Update-Skripts konfigurieren

# Probleme:
## Variables Datenmodell
Das Datenmodell von Pure ist in einem bestimmten Rahmen auszugestalten. Jeder Kunde (Einrichtung) muss seine eigene Ausprägung definieren. In der Konsequenz gibt es kein einheitliches Datenmodell, welches auf VIVO gemappt werden kann. Deshalb ist es derzeit notwendig, dass jede Einrichtung das Mapping entsprechend anpasst.
(Es gibt den Wunsch der deutschen Pure-Nutzergruppe, dass Pure den KDSF umsetzt und somit ein einheitliches Basis-Datenmodell schafft.)

## Pure-interne IDs
In den, über die REST-API gelieferten Daten, werden verknüpfte Daten nur über die Pure-interne ID referenziert. 
Bsp: Personendatensätze, die über ein zentrales IDM der Einrichtung nach Pure synchronisiert werden, enthalten häufig eine ID, die einrichtungsweit unterschiedlichen Systemen bekannt ist und zur Kommunikation zwischen den Systemen genutzt wird. Eine solche ID kann bei der Anbindung Pures nicht (ohne weitere Aufwände) als Identifier übertragen werden. Die REST-API gibt zwar solche Pure-externen IDs zurück. Allerdings gibt sie beispielsweise zur Verknüpfung von Personen mit Publikationen nur die Pure-interne ID an.

## Aufwendiges Mapping
Das Mapping der einzelnen Felder einer Publikation muss für jeden Content-Type einzeln erstellt werden, weil die XML-Nodes der Publikationen (aus Pures REST-API) jeweils nach dem Content-Type benannt sind.
Bsp: 
```
<contributionToBookAnthology>
	<feld1></feld1>
	<feld2></feld2>
</contributionToBookAnthology>

<otherContribution>
	<feld1></feld1>
	<feld2></feld2>
</otherContribution>
```

Im Karma-Model ist es derzeit exemplarisch der Typ „otherContribution“ gemappt.


# Autor:
Stefan Wolff

# Siehe auch:
https://zenodo.org/record/998881#.Wld6PGfbDAU
