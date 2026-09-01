create extension pg_stat_monitor;
create extension pg_wait_sampling;

create role demo password 'demo123' login;
create database demo owner=demo;
