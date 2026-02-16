use axum::{routing::get, Json, Router};
use serde_json::{json, Value};
use std::env;
use std::fs;
use std::net::SocketAddr;
use tracing::{info, warn};

fn load_config(path: &str) -> Value {
    match fs::read_to_string(path) {
        Ok(contents) => match serde_json::from_str::<Value>(&contents) {
            Ok(value) => value,
            Err(err) => {
                warn!("Failed to parse MCP config {path}: {err}");
                default_config()
            }
        },
        Err(_) => default_config(),
    }
}

fn default_config() -> Value {
    json!({
        "enabled": true,
        "http_url": null,
        "stdio": false,
        "capabilities": [],
        "tools": [],
        "resources": []
    })
}

async fn health() -> Json<Value> {
    Json(json!({ "status": "ok" }))
}

async fn mcp_info() -> Json<Value> {
    let config_path = env::var("MCP_CONFIG").unwrap_or_else(|_| "mcp_config.json".to_string());
    Json(load_config(&config_path))
}

async fn mcp_discover() -> Json<Value> {
    let config_path = env::var("MCP_CONFIG").unwrap_or_else(|_| "mcp_config.json".to_string());
    Json(json!({
        "version": "v1",
        "mcp": load_config(&config_path)
    }))
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter("info")
        .init();

    let port = env::var("MCP_PORT").unwrap_or_else(|_| "9090".to_string());
    let addr: SocketAddr = format!("0.0.0.0:{port}")
        .parse()
        .expect("Invalid MCP_PORT value");

    let app = Router::new()
        .route("/health", get(health))
        .route("/mcp/info", get(mcp_info))
        .route("/v1/mcp/discover", get(mcp_discover));

    info!("GaiaNet-MCP server listening on {addr}");

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("Failed to bind MCP server");
    axum::serve(listener, app.into_make_service())
        .await
        .expect("MCP server failed");
}
