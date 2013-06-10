#!/usr/bin/env bats

@test "psql installed" {
  run which psql
  [ "${lines[0]}" = "/usr/bin/psql" ]
}

@test "can restart postgresql" {
  run sudo /etc/init.d/postgresql restart
  [ "$status" -eq 0 ]
}

@test "has ak-db" {
  run which /usr/local/bin/ak-db
  [ "${lines[0]}" = "/usr/local/bin/ak-db" ]
}
