# Inhalt

1. Einleitung
2. Installation
* Im Spiel verwenden
* Entwicklung vorbereiten
3. Build
* QSB bauen
* Dokumentation erzeugen
4. Contribution

# 1 Einleitung

Dieses Projekt befasst sich ausschließlich mit der Questbibliothek des Spiels
DIE SIEDLER - Aufstieg eines Königreiches. Ziel ist es, dem Benutzer eine frei
konfigurierbare Bibliothek in die Hände zu geben um das allgemeine Niveau an
Maps in der Community zu heben.

# 2 Installation

## Im Spiel verwenden

Die QSB kann nicht mit den Defaults des Editors genutzt werden. Aktiviere den
Expertenmodus und importiere die Skripte im Verzeichnis qsb/default. Die QSB
kann danach normal importiert und verwendet werden.

#ä Entwicklung vorbereiten

Um Swift zu entwickeln, muss das Repository zuerst geklont werden. Dafür
wird die Versionsverwaltung Git benötigt. Eine Windows-Version von Git kann
hier heruntergeladen werden:
https://git-scm.com/download/win

Klonen des Repository:
```
git clone https://github.com/totalwarANGEL1993/Swift.git
```

# 3 Build

Swift wird über die build.sh erzeugt. Dazu muss in der
Shell in das bin-Verzeichnis des Projektes gewechselt werden. Da dies aber
Bash-Skripte sind, wird das auf Windows nicht funktionieren.

## QSB bauen

Die QSB und die minimierte QSB werden durch die folgenden Befehle erzeugt.
Dazu wird eine Installation von Lua 5.1 auf dem PC benötigt.

```
lua qsb/lua/writer.lua
cd qsb/luaminifyer
LuaMinify.bat ../../var/qsb.lua
```

## Dokumentation erzeugen

Die Dokumentation kann automatisch erzeugt werden, wenn Lua installiert ist.

```
cd qsb
mkdir var
lua ldoc/ldoc.lua --dir ../var/doc lua
```

# 4 Contribution

Bei Änderungen am Repo sind diese in Commit-Messages festzuhalten! Alle
Funktionen sind ordentlich zu kommentieren und mit entsprechenden Tags zu
versehen.

Bevor eine neue Version live geht, müssen alle Doc-Blocks verfasst und alle
Änderungen getestet werden!

LuaDoc Download: https://github.com/stevedonovan/LDoc
LuaDoc Manual: https://stevedonovan.github.io/ldoc/manual/doc.md.html#Introduction
