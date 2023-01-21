config_http = %Unreal.Core.Config{
  host: "http://127.0.0.1:8000",
  namespace: "test",
  database: "test",
  username: "root",
  password: "root",
  options: [
    timeout: 2500
  ]
}

config_ws = %{config_http | host: "ws://127.0.0.1:8000"}

Unreal.start_link(protocol: :http, config: config_http, name: :database_http)
Unreal.start_link(protocol: :websocket, config: config_ws, name: :database_ws)

ExUnit.start()
