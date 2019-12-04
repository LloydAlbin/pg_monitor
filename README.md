|License|Build|
|:---:|:---:|
|![GitHub](https://img.shields.io/github/license/LloydAlbin/pg_monitor)|[![Build Status](https://www.travis-ci.org/LloydAlbin/pg_monitor.svg?branch=master)](https://www.travis-ci.org/LloydAlbin/pg_monitor/builds)

# pg_monitor
pg_monitor is a entire tech stack to monitor your Hardware, PostgreSQL Live and PostgreSQL Logs in realtime.

You can use then use Grafana to display the combined stats from all three sources. I use [RaspberryPI's](https://www.raspberrypi.org/) to drive displays in my office.

**_PLEASE NOTE_**: This is not even alpha code at this time. Right now I am copying the files I use at work into this repository and writing direction for doing the install. Once I have a base working copy here, I will remove this note.

## Download Repository

Download the pg_monitor repository. This will be needed for the instructions on each installation page.

```bash
cd ~
# Get the pg_monitor repositories
git clone https://github.com/LloydAlbin/pg_monitor.git
```

## Installation Order

This tech stack that needs to be installed in the following order:
1. [graphite](/graphite/README.md) - Viewing Hardware Stats Database and Intermeadite Viewing.
1. [collectd](/collectd/README.md) - Collecting Hardware Stats and store into the graphite database.
1. [timescaledb](/timescaledb/README.md) - PostgreSQL TimescaleDB database for storing PostgreSQL Live stats and Log Stats.
1. [pg_readlog](/pg_readlog/README.md) - Collecting PostgreSQL Log Stats and store into the TimescaleDB database.
1. [pg_monitor](/pg_monitor/README.md) - Collecting PostgreSQL Live Stats and store into the TimescaleDB database.
1. [grafana](/grafana/README.md) - Viewing All Stats from the TimescaleDB database and the graphite database. (Final View)

## TODO List

[TODO List](/TODO.md) - This is a list of the items that I currently need to complete to make this beta ready. Some I need to write and others, I just need to publish.
