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
* pgaudit
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
pgaudit - audit log
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
Keep installations small ans separated

<!--  -->

---

# Out-of-place patching

No tarball installation, PostgreSQL is not relocatable
Compile it yourself

<!-- 
PostgreSQL must be compiled already with the final software destination in mind
-->

---

# Patching

PostgreSQL is open source, so patches can be provided against the source code, which you compile yourself.

<!-- Compiling PostgreSQL can be faster than running OPatch -->

---

# Data Protection

standby is built in
sync also

Protection modes:
* SYNC
* FAST-SYNC
* ASYNC
* also wait for apply

---

# High availability

Patroni

Provides Data Guard Broker orchestration functionality

DEMO WARNING

<!--  -->

---

# Scalability

One writer, many readers
Be mindful of "eventual consistency"
pgdog
DEMO WARNING

<!-- 
If more (write) scalability is needed - YugabyteDB, CockroachDB
-->

---

# Partitioning

<!--  -->

---

# Parallelism

<!--  -->

---

# Analytical queries, data lake

<!--
PostgreSQL is mainly for OLTP, but analytical queries are also possible
-->

---

# Auditing

pgaudit

> The goal of pgAudit is to provide PostgreSQL users with capability to produce audit logs often required to comply with government, financial, or ISO certifications.
> An audit is an official inspection of an individual's or organization's accounts, typically by an independent body. The information gathered by pgAudit is properly called an audit trail or audit log.

<!-- 
Captures issued SQL statements and stores them in PostgreSQL log file
-->

---

# TDE

First, do you actually need/want TDE? Why?

Use OS:
* LUKS/cryptsetup

Commercial offerings:
* EnterpriseDB TDE
* Cybertec TDE (part of PGEE)
* pg_tde (requires Percona Server for PostgreSQL)

<!--
Protection against 
TDE can be self-induced-ransomware if key is lost - NB! All copies of the database are encrypted with the same master key
-->

---

# ASM

Use OS provided volume manager:
* LVM
* ZFS/BTRFS pools

or just rely on your SAN/NAS

<!--
LVM does have online storage migration with built in pmove command
-->

---

# Compression

BTRFS filesystem
or just rely on your SAN/NAS

Using BTRFS compression on PostgreSQL >= 16 requires
```
file_extend_method=write_zeros
```

<!--
BTRFS works well with append only/mostly data, modifications incur some write penalties
PG16 started writing relation files with posix_fallocate() that disables BTRFS compression

Keep WAL on XFS/EXT4

Our domain message (protobuf) persistence service compresses 3 times. No issues nor excessive CPU usage even at 4000+TPS
-->

---

# Tracing

<!--  -->

---

# Monitoring / OEM

pmm
DEMO WARNING

<!--  -->

---

# GoldenGate

Logical replication is built in
Debezium

<!--  -->

---

# Array bind, bulk load

There is no array api.

* INSERT INTO t (a,b) VALUES (?,?),(?,?),(?,?);
* COPY

<!--  -->

---

# Data REST APIs / ORDS

PostgREST
Supabase (commercial)

<!--  
Maybe Supabase is out-of-scope
-->

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

# No alternatives

* dbms_redefinition
* Flashback query

---

# Things you'll start loving

* ISO standard SQL
* Reliable major version release dates

<!--

Long list of ISO/IEC 9075:2023 features that PostgreSQL does not support: https://www.postgresql.org/docs/current/unsupported-features-sql-standard.html

and some of which Oracle *does* support, like polymorphic table functions

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
