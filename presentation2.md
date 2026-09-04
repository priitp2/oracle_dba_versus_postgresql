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
    display: flex;
    align-items: center;
    justify-content: center;

    background: #f8f8f8;
    color: #222;

    font-size: 2.8rem;
    font-weight: 600;
    letter-spacing: -0.03em;
    text-align: center;

    border-left: 0.3rem solid #555;
  }
---

# Oracle DBA discovers PostgreSQL
### Ilmar Kerm & Priit Piipuu
### 2026-09-05

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

# Prologue

Oracle tech is great, but...
the world has changed

<!--
Thanks to Trump, tech idenpendence from US is now in the agenda
Oracle has been rising prices, a lot for some, like us (200x) - unacceptable
-->

---

# Prologue

Must choose an alternative
And make it work

<!--
So Oracle is out... we needed to find an alternative and then make it work as best as we can
This presentation is not about comparing technologies, it is about Oracle dinosaurs exploring PostgreSQL world any trying to make it work.
-->

---

<!-- _class: topic -->

# What is PostgreSQL?

---

# The rise of PostgreSQL

"The only database that exists today"
"The Linux of databases"
"Just use Postgres until it breaks." *
"You should always default to Postgres until the constraints prove you wrong." *

https://topicpartition.io/blog/postgres-pubsub-queue-benchmarks

<!--
Everything in the database world today is PG related and this is the only database modern devs think exists
In this presentation adressing some issue that Oracle professionals might face with PostgreSQL.
-->

---

![bg contain](img/stonebraker_says_things.png)

<!--

"We have to thank Oracle for [PostgreSQL's popularity] because when they bought MySQL, everybody was afraid that they were going to dominate where MySQL went to, and that was the beginning of the PostgreSQL ascendancy," Stonebraker said.
-->

---

![bg contain](img/ludo.png)

<!--
Ludovico Caldara passionately disagreed, pointing out PostgreSQL rise correlates well with AWS popularity.

https://www.linkedin.com/feed/update/urn:li:activity:7470111757714210816?commentUrn=urn%3Ali%3Acomment%3A%28activity%3A7470111757714210816%2C7470190330773131264%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287470190330773131264%2Curn%3Ali%3Aactivity%3A7470111757714210816%29
-->

---

![bg contain](img/scott.png)

<!--
Scott argues, that docker had a lot to do with PostgreSQL popularity with devs.
Early MySQL images were not good, but Postgres early images were good.
-->

---

# PostgreSQL

- Not controlled by any vendor *
- Open source at its absolute best *

https://www.theregister.com/databases/2026/08/19/postgres-pioneer-credits-oracle-with-helping-his-database-take-over-the-world/5289087

<!-- 
Controlled by 20-30 "very smart super programmers"; Core team 7 (4xUSA, Germany, Sweden, UK)

Although big tech has its own forks, they also contribute to the core. Microsoft and AWS - yes; Google, Oracle - no
-->

---

# A collection of tools

It is NOT just PostgreSQL, you need a large toolbox
- Extensions
- External software
- And the standard OS tools
- Other OS libraries

<!--
PostgreSQL is just the basic core, you need extensions, you need external software
High Availability, backup
-->

---

![bg contain](img/collection_of_tools.png)

<!--
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

![bg contain](img/extensions.png)

<!--
PostGIS - better than Oracle Spatial
-->

---

# Installation

- Binary packages RPM/DEB/...
- Installers for Windows, MacOS
- The almighty source

<!-- 
Linux distributions often come with built in PostgreSQL, Ubuntu also has nice upgrade automation.
Official PostgreSQL repository comes with many-many-many extra extensions also, already compiled.
Don't be afraid to compile it yourself, it is quite easy - but be mindful of dependencies, it is linked dynamically
-->

---

```
./configure --prefix=/usr/pg-software/pg-18-18061 --enable-rpath \
  --with-libnuma --with-ssl=openssl --with-icu --with-liburing \
  --with-lz4 --with-uuid=e2fs --with-libcurl --with-libxml --with-zstd
make world-bin && make check && make install-world-bin

real    5m24.540s
user    3m50.012s
sys     1m17.950s
```

<!-- 
2cpu_8G
Does include contrib extensions (pgcrypto, ...), does not include external extensions (pgvector, pgaudit, ...)
-->

---

# Getting started with PostgreSQL, as a developer

All starts and ends with Docker

<!--
While running databases in k8s haven't been popular in our company, containerized environments are
essential for swd development these days. Testcontainers make possible to run the integration tests in your laptop,
what not to like?!
-->

---

![bg contain](img/docker0.png)

<!--
Size matters: smaller containers are easier to user. For example, in case of testcontainers, smaller image makes
the tests run faster. But there's a catch.
-->

---

![bg contain](img/docker1.png)

<!--
If plugins used for daily life change database behavior in some way, then these plugins must be added to the
development containers as well. So after some pluggins and pgbouncer...
-->

---
<!-- _class: topic -->

# Lets talk features

<!--
In this section can go into implementing some Oracle world features in PG
From the perspective of Oracle dinosaur exploring PostgreSQL offerings
-->

---

# Workload separation

Use OS: SystemD, cgroups
Keep installations small and separated

example of systemd unit showing the limits

<!--

Cloud-native deployment: one PostgreSQL server, one database, one application

Lack of workload isolation or resource manager makes it very hard to do other deployment models
-->

---

```
[Unit]
After=network-online.target
Requires=network-online.target
RequiresMountsFor=/var/lib/pgsql /var/log/pgsql

[Service]
Type=simple
User=postgres
Group=postgres

# Resource limits
CPUQuota=600%
CPUQuotaPeriodSec=10ms

WorkingDirectory=/var/lib/pgsql
Environment=TZ=UTC

# Start the patroni process
ExecStart=/var/lib/pgsql/patroni_venv07/bin/patroni patroni.yml

# Send HUP to reload from patroni.yml
ExecReload=/bin/kill -s HUP $MAINPID

# First execute switchover and then KillMode is activated
# Only kill the patroni process, not it's children, so it will gracefully stop postgres
ExecStop=/var/lib/pgsql/switchover_if_primary.py patroni.yml --quiet
KillMode=process

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=360

# Restart the service if it crashed
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

# Out-of-place patching

No tarball installation, PostgreSQL is not relocatable
Compile it yourself

```
/var/lib/pgsql/software/pg-18-1803-1
/var/lib/pgsql/software/pg-18-1804-1
/var/lib/pgsql/software/pg-18-1804-2
/var/lib/pgsql/software/pg-18-1806-1
```

<!-- 
PostgreSQL must be compiled already with the final software destination in mind
-->

---

# Patching

PostgreSQL is open source, so patches can be provided against the source code, which you compile yourself.

<!-- Compiling PostgreSQL can be faster than running OPatch -->

---

# Data Protection

Physical standby is built in and used for queries
Page checksums now default

<!--
Data Guard equivalent, for Broker functionality need Patroni in addition
-->

---

### Commit protection modes

synchronous_commit | local durable commit | FAST-SYNC | SYNC | standby query consistency 
-- | -- | -- | -- | --
**remote_apply** | ✅ | ✅ | ✅ | ✅
**on** | ✅ | ✅ | ✅ | ❌
**remote_write** | ✅ | ✅ | ❌ | ❌
**local** | ✅ | ❌ | ❌ | ❌
**off** | ❌ | ❌ | ❌ | ❌

<!-- 
FAST-SYNC and SYNC are Oracle Data Guard terminology
FAST-SYNC - WAL record is written to remote instance memory
SYNC - WAL record is written to remote instance memory and synced to disk
-->

---

# High availability

Patroni
- Swichover/failover capabilities
- Managing PostgreSQL configuration
- Creating database, creating replicas
- Requires external configuration store (etcd)

DEMO WARNING

<!--
Physical standby is built in, but you need something to manage it, automate failovers and switchovers, you need the "Data Guard Broker" functionality.
It does not get on the way for queries
So easy
REST API for all actions
etcd can be shared between multiple clusters
-->

---

![bg contain](img/patroni.png)

---

# Client discovery in high availability

Use the full power of the connection string
pgDog
❌❌❌ Do not use haproxy
ETCD can also be used for service discovery

<!--
How shall a client find, where the leader instance is currently running?
-->

---

### libpq

```
postgresql://pghost1.example.com,pghost2.example.com/dbname?target_session_attrs=read-write&connect-timeout=2
```

target_session_attrs
- any
- read-write / primary
- read-only / standby
- prefer-standby

### JDBC

```
jdbc:postgresql://pghost1.example.com,pghost2.example.com/dbname?targetServerType=primary&connectTimeout=2
```

<!-- 
Example connection strings
libpq syntax works also for Go driver
-->

---

# Scalability

Avoid "a lot of connections"
- Each client connection is a dedicated OS process
- max_connections used to size memory arrays
- idle connections aren't free
- connection storms are dreadful

<!-- 
PostgreSQL does not like "a lot of connections" - just like Oracle. Reduce heavily, or use a pooler.
-->

---

# Scalability - poolers

- pgBouncer
- pgDog 🐕️ ✨
- Odyssey (⚠️ Yandex owned)

<!-- 
PostgreSQL does not like "a lot of connections" - just like Oracle. Reduce heavily, or use a pooler.
pgBouncer - old and trusted workhorse
pgDog - new and shiny
Avoid pgPool-II at any cost
-->

---

# Horizontal scalability

One writer, many readers
Be mindful of "eventual consistency"
> synchronous_commit can be set to remote_apply

<!-- 
No RAC
To achieve horizontal scalability common pattern is to have one leader-writer database and many read only replicas
Reads can be load balanced over replicas - to do it automatically you need pgDog
If more (write) scalability is needed - YugabyteDB, CockroachDB
-->

---

# pgDog

Modern connection pooler/proxy/load balancer
Thrives towards no application changes

Modes
- Transaction
- Statement
- Session

<!-- 
Written in Rust, very fast

Transaction mode - few server connections can be shared between thousands? of front-end connections
Session mode - One to one mapping between client and server connection, all features supported, on client disconnect server connection remains, lazy connecting of servers (on first query)

Tries to solve PostgreSQL scalability problems - pooling, load balancing, sharding.
Very actively in development, easy to request new features.

Very fast, almost comparable to pgBouncer, but with vastly more features.

pgdog is Ilmar's personal favourite. Eventual consistency and stale reads from replicas have generated strong opipions in our team and development organization.
-->

---

# pgDog features

- Load balancing - read/write splitting
- Automatic session pinning (temp tables, advisory locks)
- pub/sub - listen/notify
- SET commands
- Prepared statements
- Automatic sharding

<!--
Load balancer supports also manual routing
Not all database features - like temp tables, advisory locks, pub/sub are connection dependent, pgDog detects and automatically pins
-->

---

![bg contain](img/pgdog2.png)

<!-- 
-->

---

# Partitioning for OLTP (I)

Data life cycle management: dropping old partition is faster than delete
Old data can be archived or made available from secondary storage (hybrid partitioning with Parquet)
Works really well with time series
Hash partitioning in RAC

<!--
Knee-jerk reaction is to do similar things in PostgreSQL as well.
But... ask do you actually need it. In Postgres there is less need.
-->

---

# Partitioning for OLTP (II)

Downside: most of the queries do not benefit from partition pruning
Oracle fixes this with global indexes
This comes with tradeoffs

<!--
For example: show me my last 10 transactions
-->
<!--
---

![bg contain](img/partitioning_nopart.png)

---

![bg contain](img/partitioning_local.png)

---

![bg contain](img/partitioning_global.png)
-->
---

# Partitioning: Global indexes

In PostgreSQL:
<style scoped>div{font-size:130px;}</style>
<div>🤷‍♂️</div>

<!--  -->

---

# Hints

Frowned upon

pg_hint_plan extension

<!-- 
very limited operations supported, but important ones are there
Scan method
Disable indexes
Join method
Join order
Behavioural control on join (memoize)
Cardinality correction
Parallel query
Parameter changes for planner
-->

---

# Analytical queries, data lake

Extensions
- pg_duckdb (DuckDB)
- pg_lake (Snowflake)

Analytics oriented forks:
- Greenplum
- Vertica
- Redshift

<!--
PostgreSQL is mainly for OLTP, but analytical queries are also possible
There must be more analytics forks than mentioned

pg_dumpdb is DuckDB engine in PostgreSQL process, analytical queries can be run on DuckDB engine, accessing PostgreSQL data.
pg_duckdb is intended to be used on replica node. Can query CSV, parquet/iceberg... also

pg_lake allows querying Iceberg tables
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

# User authentication

Profiles need extension

Kerberos, TLS, OAuth, LDAP

Centrally Managed Users:
- pg_ident

<!-- 
OAuth is new and quite basic yet

For us:
mTLS and pg_ident maps user CN in certificate into shared database account
-->

---

# TDE

First, do you actually need/want TDE? Why?

Use OS:
- LUKS/cryptsetup

Commercial offerings:
- EnterpriseDB TDE
- Cybertec TDE (part of PGEE)
- pg_tde (requires Percona Server for PostgreSQL)

<!--
Protection against loss of physical media (hard drives) only - nothing else!
TDE can be self-induced-ransomware if key is lost - NB! All copies of the database are encrypted with the same master key
-->

---

# ASM

Use OS provided volume manager:
- LVM
- ZFS/BTRFS pools

LVM can migrate volumes online
- pvmove

or just rely on your SAN/NAS

<!--
LVM does have online storage migration with built in pvmove command
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

# Logical replication

Logical replication is built in
Debezium
GoldenGate supports PostgreSQL as well

<!-- 
Debezium is CDC solution built on Kafka and Kafka Connect. We will mention it later when we talk about
migration to PostgreSQL.
-->


---

# Data REST APIs / ORDS

PostgREST

<!--  
-->

---

# APEX

### In browser

- Cypex

### APEXLang style

- SQLPage

### But there are possible alternatives for the brave

- Buildbase
- Appsmith
- Retool
- Tooljet

<!--
A tough one to replace, but there are options
Source: kagi.com. Haven't tried any of this
-->

---

# No alternatives

- dbms_redefinition
- Flashback Query (? periods extension seems dead)
- EBR

<!--
MVCC dead tuples are not usable for flashback query
No AS OF timestamp queries. Is there a plugin for flashback data archve? "periods" extension seems dead, not built anymore and max pg15

-->

---

<!-- _class: topic -->

# Observability

---

# Graphical monitoring

[Percona Monitoringing and Management](https://www.percona.com/monitoring/)
* Grafana, VictoriaMetrics, ClickHouse in a nice package
* Plenty of pre-packaged dashboards
* Still can add your own Grafana dashboards (like pgDog)
* Has Query Analytics

Ask Ilmar for a demo

<!--
Demo also part of "demo" package
-->

---

# Wait interface

VIEW pg_stat_activity
VIEW pg_wait_events - 274 events in 18.6
EXTENSION pg_wait_sampling

<!--
TODO
Being actively improved upon, PG18 especially

pg_stat_activity is v$session equivalent.
Does every plugin publish their own wait events?
Oracle 23.26.2 has 2350 wait events.

-->

---

# Active session history in PostgreSQL

pgsentinel: https://github.com/pgsentinel/pgsentinel
Samples `pg_stat_activity` and `pg_stat_statements`

<!--

`pg_active_session_history` has 29 dimensions, `pg_stat_statements_history` has 24 dimensions.
`GV_$ACTIVE_SESSION_HISTORY` has 125
-->
---

# Tracing

perf
eBPF

<!--
Quite funny: with Oracle we have to use perf or eBPF because it is a commercial product.
With PostgreSQL we have still use perf and eBPF and touch it in the low places since it is 
open source
-->

---

# Things you'll start loving

- FREEDOM to do anything!
* ISO standard SQL (almost)
* Reliable major version release dates
* Having the source
* LISTEN/NOTIFY is surprisingly useful
* Extreme extensibility, custom data types, custom operators
* Transactional DDL (*)

<!--
FREEDOM - no be constrained to counting CPUs, what options you can or cannot use. Juse use it any way you like.

Having the source means you can ask your LLM questions about it and generate patches. (pretty much what Oracle support is nowadays anyway)

Long list of ISO/IEC 9075:2023 features that PostgreSQL does not support: https://www.postgresql.org/docs/current/unsupported-features-sql-standard.html

and some of which Oracle *does* support, like polymorphic table functions
-->

---

<!-- _class: columns -->
<div>
PostgreSQL major version release dates

Version | Release
-- | --
18 | 2025-09-25
17 | 2024-09-26
16 | 2023-09-14
15 | 2022-10-13
14 | 2021-09-31
13 | 2020-09-24

Yearly releases dating back to 1998/1999
</div>
<div>
Oracle major version release dates

Version | First promise | Actual release
-- | -- | --
18c | 2018-07 | 2018-07-23
19c | 1H CY2019 | 2019-04
20c | NULL | NULL
21c | 1H CY2021 | 2021-08-13
22c | NULL | NULL
23c | 1H CY2024 | 2026-01-27 (EE only?)
</div>

<!--
In July 2017 Oracle moved to a new release model promising "A new major database release every year"
on-prem releases only
-->

---

# Things you hate

- XID wraparound
- Monitoring not so great
- MVCC bloat on high update rate *
  https://www.cs.cmu.edu/~pavlo/blog/2023/04/the-part-of-postgresql-we-hate-the-most.html

- collation not an issue anymore *

---
<!-- _class: topic -->

# Migration from Oracle to PostgreSQL

<!-- The following section is about strategies of migration.

Very high level and simplified, due to the time limit. -->

---

# Migrating to PostgreSQL (I)

Most of the code changes are mechanical, rules based
Coding agents have solved problem with code migrations in general
Coding agents need extra pairs of underpants

<!--
Instead of a frameworks that paper over the diffrences in SQL details, you can instruct your agents to change the code.
Testcontainers make testing the code changes easy. And you can run integration tests in your laptop.
-->
---

# Migrating to PostgreSQL (II)

Conceptually simple, once you have a PostgreSQL version of the app:
1. Create the PostgreSQL database
2. Shut down the old app
3. Copy over the data
4. Deploy new version of the app
5. Profit!

---

# Migrating to PostgreSQL (III)

Complications:
- Microservices: hundreds of services to migrate
- Microservices: migration process needs to be automated
- Downtime: what if you can't take extended downtime?

<!--
As with downtime in general, adding a nine will make life exponentially more complicated, and more expensive.
-->
---

# Migrating to PostgreSQL (IV)

Strategies for downtime reduction:
* Change data capture and streaming changes
    Reduces the time to synchronise the data
* "Dual writes": writing to two data stores in the app
    In theory, writes to two data stores can eliminate the downtime

<!--

Streaming: Debezium works quite well
How to get the changes from Oracle? Logminer? X-Stream? OLR?

"Dual writes": streaming will help to create the second data store as well
Corner case with "dual writes" and updates: some downtime might still be needed
-->

---

# Migrating to PostgreSQL: CDC for the rescue

Oracle can do change data capture in many ways:
- Log Miner
- XStream API (for Goldengate licensees)

How go you get changes to the target database?
- Debezium
- Goldengate hs

<!--
We decided to go with XStream and Debezium: we have GG, but do not have GG hs.
-->

---

# Migrating to PostgreSQL (V)

Component migration using CDC:
1. Create PostgreSQL database
2. Create XStream outbound server in Oracle
3. Create Debezium source connector
4. Wait until the databases are reasonably in sync
5. Close Oracle version of the app
6. Wait until databases are full in sync
7. Start the PostgreSQL version of the app
8. Profit!!1!

<!--

This listing skips a few steps, otherwise this would be way too complex to explain and display.

This simplified migration process works reasonably well, but automation is a bitch.
-->
---

# Migrating to PostgreSQL (VI)

Conclusion: automation and downtime reduction involve high amount of engineering
Who will pay for it?

<!--
Migrating from one database engine to another is cross-organization project (multiple platform engineering teams, dev teams, middle management and
people from the business side since the downtime.)
-->
---

# And the story continues...

For us, it's just the beginning
Who knows what future brings

<!--

For now, some of this presentation is pure theory, but we will try these thing in the future
-->

---

![bg contain](img/demosetup.png)

<!--
Demo requires docker and is in the "demo" folder. check the README.md file.
-->
---

![bg contain](img/qrcode_github.com.png)

<!--
Thank you for listening us!
-->