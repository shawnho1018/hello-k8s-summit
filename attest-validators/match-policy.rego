package signature
import future.keywords
import future.keywords.contains
import future.keywords.if

allow contains msg if {
  1 != 1
  msg := "1 equal to 1"
}

allow[msg] {
 input.Data == "foo\n"
 msg := sprintf("unexpected data: %v", [input.Data])
}

allow[msg] {
 before = time.parse_rfc3339_ns("2021-11-10T17:10:27Z")
 actual = time.parse_rfc3339_ns(input.Timestamp)
 actual != before
 msg := sprintf("unexpected time: %v", [input.Timestamp])
}

