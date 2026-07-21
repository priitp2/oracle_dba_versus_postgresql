---
marp: true
theme: default
size: 4K
auto-scaling: true
paginate: true
---

# Oracle DBA discovers PostgreSQL
### Ilmar Kerm & Priit Piipuu
### set-date-here

---

# Whoami: Priit Piipuu

Database performance engineer at FDJ United
Oracle Ace Pro
Member of Symposium 42
Blog: https://priitp.wordpress.com,
@ppiipuu.bsky.social

---

# And the story begins...

From installation to first steps to production usage

<!--
Similar concepts, similar words (PG cluster, database, roles and schemas)
Tablespaces in Oracle and PostgreSQL
Partitioning
There's a plugins for everything, sometimes more than one
Observability
DRCP and that networks thing versus pgbouncer and cats and dogs
Transactions, cursors and stuff
-->

---

# Getting started, through Docker

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

# Installation: buy or build

How do you add neccessary plugins?

---

# In search for a concepts guide...

Same concept, different implementation, much confusion

<!--
People tend to assume that same word means same thing in Oracle and PostgreSQL. Well...
-->

---

![bg contain](img/pg0.png)

<!--
PostgreSQL cluster contains configuration, memory structures and common processes. Reminds Oracle instance.
-->

---

![bg contain](img/pg1.png)

<!--
Every PG instance manages one or more databases. Database in PG is the topmost hierarchical level of organizing SQL objects and stuff. 
-->

---

![bg contain](img/pg2.png)

<!--

Login roles are database server level objects. Role can represent either database user or group of users. Roles can own database objects and can assign privileges on those objects to other roles. 
-->

---

![bg contain](img/pg3.png)

<!--
Schema in PG is a logical namespace. Database objects can be reassigned between schemas.
-->
---

# Deployment options

Cloud-native deployment: one PostgreSQL server, one database, one application

<!--
Because lack of workload isolation makes it very hard to do other deployment models
-->