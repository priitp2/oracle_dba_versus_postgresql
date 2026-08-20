---
marp: true
theme: default
size: 4K
auto-scaling: true
paginate: true
style: |
  section.columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }
  section.topic {
    background-color: #ccc;
    font-weight: bold;
  }

---

# Oracle DBA discovers PostgreSQL
### Ilmar Kerm & Priit Piipuu
### set-date-here

---

<!-- _class: columns -->
<div>

# Whoami: Priit Piipuu

Database performance engineer at FDJ United
Oracle Ace Pro
Member of Symposium 42
Blog: https://priitp.wordpress.com,
@ppiipuu.bsky.social

</div>

<div>

# Whoami: Ilmar Kerm

Database administrator at FDJ United
Oracle Ace Associate (ex-Pro)
Member of Symposium 42
Blog: https://ilmarkerm.eu,
@ilmarkerm.eu

</div>

---

![bg contain](img/qrcode_github.com.png)

---

# The rise of PostgreSQL

"The only database that exists today"
"The Linux of databases"
"Just use Postgres until it breaks." *
"You should always default to Postgres until the constraints prove you wrong." *

* https://topicpartition.io/blog/postgres-pubsub-queue-benchmarks

<!--
Everything in the database world today is PG related and this is the only database modern devs think exists
In this presentation adressing some issue that Oracle professionals might face with PostgreSQL.
-->

---

# A collection of tools

It is NOT just PostgreSQL, you need a large toolbox
* Extensions
* External software
* And the standard OS tools

<!--
PostgreSQL is just the basic core, you need extensions, you need external software
High Availability, backup
-->

---

# Extensions

Extensions extend the core database functionality
PostgreSQL is designed to be easily extendable

<!--
New data types, operators, functions
PostgreSQL contrib ships with about 50 already included
Can't be considered a weakness of PostgreSQL - that is the idea - core is minimal and advanced functionality is provided by extensions. Often wish Oracle would do the same.

Negative - often maintainer is a single person
-->

---

# Extensions

* PostGIS
* pgvector
* pg_partman
* pg_cron
* pg_stat_monitor
* pgcrypto
* postgres_fdw, oracle_fdw, file_fdw
* pl/python, pl/perl, pl/tcl

<!--
Some well-known extensions:
PostGIS - GIS data types and functionality, like Oracle Spatial
pgvector - vector data types and similarity search
pg_partman - interval partitioning automation
pg_cron - scheduling jobs
pg_stat_monitor - detailed statement monitoring
pgcrypto - cryptographic functions
postgres_fdw, oracle_fdw, file_fdw - foreign data wrappers
pl/python, pl/perl - server programming languages
-->

---

# Installation

* Binary packages RPM/DEB/...
* Installers for Windows, MacOS
* The almighty source

<!-- 
Linux distributions often come with built in PostgreSQL, Ubuntu also has nice upgrade automation.
Don't be afraid to compile it yourself, it is quite easy - but be mindful of dependencies, it is linked dynamically
-->

---
<!-- _class: topic -->

# Lets talk features

<!-- In this section can go into implementing some Oracle world features in PG -->

---

# Workload separation

Use OS: SystemD, cgroups

<!--  -->

---

# Out-of-place patching

No tarball installation, PostgreSQL is not relocatable
Compile it yourself

<!-- 
PostgreSQL must be compiled already with the final software destination in mind
-->

---

# High availability

Patroni
DEMO WARNING

<!--  -->

---

# Scalability

One writer, many readers
Be mindful of "eventual consistency"
pgdog
DEMO WARNING

<!-- 
If more scalability is needed - YugabyteDB, CockroachDB
-->

---

# title

<!--  -->

---

# title

<!--  -->

---

# title

<!--  -->

---

# title

<!--  -->

---

# title

<!--  -->

---

# APEX

### In browser

* Cypex

### APEXLang style

* SQLPage

### But there are possible alternatives for the brave

* Buildbase
* Appsmith
* Retool
* Tooljet

<!--
A tough one to replace, but there are options
Source: kagi.com. Haven't tried any of this
-->

---
<!-- _class: topic -->

# Migration from Oracle to PostgreSQL

<!-- The following section is about strategies of migration -->

---

# Migrating the data

extracting data from oracle be hard

Debezium
* Logminer - 🐌 slowww
* OLR
* and if you have the license X-Streams (this is what we do)

---

# Application code migration with AI
