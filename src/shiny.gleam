import gleam/http/response as res
import gleam/http/request as req
import gleam/bytes_builder.{type BytesBuilder}
import gleam/http/elli
import gleam/io
//
import gleam/option
import sqlight
//
import kreator as k
import kreator/wrappers/sqlight as ks
import kreator/value as v
//
import gleam/hackney

pub fn my_service(request: req.Request(t)) -> res.Response(BytesBuilder) {
  io.debug("Handling request")
  io.debug(request.path)
  io.debug(request.query)

  let assert Ok(req) = req.to("https://api.ipify.org")
  let api_res = hackney.send(req)

  let body = case api_res {
    Ok(resp) -> resp.body
    Error(_) -> "failed to get ip addr"
  }

  use conn <- sqlight.with_connection("file:/config/mydb.sqlite")
  let assert Ok(Nil) =
    sqlight.exec(
      "CREATE TABLE IF NOT EXISTS requests (path TEXT, query TEXT, ip TEXT);",
      conn,
    )

  let sql =
    k.table("requests")
    |> k.insert([
      #("path", v.string(request.path)),
      #("query", v.string(option.unwrap(request.query, ""))),
      #("ip", v.string(body)),
    ])
    |> k.to_sqlite()

  let assert Ok(_) = ks.run_nil(sql, conn)
  let body = bytes_builder.from_string(body)

  res.new(200)
  |> res.prepend_header("made-with", "Gleam")
  |> res.set_body(body)
}

pub fn main() {
  elli.become(my_service, on_port: 3000)
}
