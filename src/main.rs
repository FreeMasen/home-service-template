use std::{convert::Infallible, fmt::Display, path::PathBuf, sync::OnceLock};

use axum::{
    response::sse::{Event, Sse},
    http::StatusCode, response::Html, Router
};
use futures::{SinkExt as _, Stream, StreamExt};
use serde::{Deserialize, Serialize};
use tower_http::{services::ServeDir, trace::TraceLayer};
use tracing::Level;
use tracing_subscriber::FmtSubscriber;

type ResponsePair = (StatusCode, Html<String>);

#[tokio::main]
async fn main() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::DEBUG)
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");
    let static_files_service = ServeDir::new("assets").append_index_html_on_directories(true);
    let app = Router::new()
        .nest_service("/assets", static_files_service)
        .layer(TraceLayer::new_for_http());
    let listener = tokio::net::TcpListener::bind("0.0.0.0:{{port}}").await.unwrap();
    tracing::debug!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
