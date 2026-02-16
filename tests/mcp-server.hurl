GET http://127.0.0.1:9090/health
HTTP/1.1 200

[Asserts]
jsonpath "$.status" == "ok"

GET http://127.0.0.1:9090/mcp/info
HTTP/1.1 200
