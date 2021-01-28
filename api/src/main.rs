#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use mongodb::Client;
use bson;
use http::{Request, Response, StatusCode};
use serde::ser::{Serialize, SerializeStruct, Serializer};
use crate::db;
use rockeet::contrib::databases::diesel

static client = Client::with_uri_str("mongodb://localhost:27017/").await?;
static db = client.database("TicTacToe");
static coll = db.collection("saves");

#[database("sqlite_db")]
struct MyDatabase(diesel::SqliteConnection);

fn main() {
    rocket::ignite().attach(MyDatabase::fairing()).mount("/", routes![index]).launch();
}



/* #[get("/api/saves/<id>")]
fn retrieveSave(id: str) -> &rocket::Json<&'static str> {
    let result_document = 
    match db::get(id) {
        Ok(result) => match result {
            Some(result) => rocket::content::Json(result),
            None => rocket::response::status::NotFound("That save does not exist"),
        },
        Err(_) => rocket::response::status::NotFound("something went wrong"),
    }
}

#[post("/api/saves", data = "<request>")]
fn newSave(request: &Json) -> &Json {
    let key = db::insert(&request)
    rocket::content::Json(doc! {"id": key})
}



pub mod db {
    pub fn insert(document: &Json) -> Result<Option<Json>, Errorn b {
        let mut new_doc = document.clone()
        match bson::to_bson($new_doc) {
            Ok(model_bson) => match model_bson {
                bson::Bson::Document(model_doc) => {
                    match coll.insert_one(model_doc, None) {
                        Ok(res) => match res.inserted_id {
                            Some(res) => match bson::from_bson(res) {
                                Ok(res) => Ok(res),
                                Err(_) => Err(Error::DefaultError(String::from("failed to read BSON")))
                            },
                            None => Err(Error::DefaultError(String::from("None")))
                        },
                        Err(err) =>(err),
                    }
                }
                _ = Err(Error::DefaultError(String::from(
                    "Failed to create Document"
                ))),
            },
            Err(_) => Err(Error::DefaultError(String::from("Failed to create Bson"))),
        }
    }

    pub fn get(id: str) -> Result<Option<Json>, Error> {
        id = bson::oid::ObjectID::with_string(id).unwrap()
        match coll.find_one(Some(doc! {"_id": id}), None) {
            Ok(db_result) => match db_result {
                Some(result_doc) => match bson::from_bson(bson::Bson::Document(result_doc)) {
                    Ok(result_model) => Ok(Some(result_model)),
                    Err(_) => Err(Error::DefaultError(String::from(
                        "Failed to create reverse BSON"
                    ))),

                },
                None => Ok(None),

            },
            Err(err) => Err(err),
        }
    }

    pub fn update(document: &Document, key: str) -> Result<new_doc, Error> {
        let mut new_doc = document.clone();
        let id = bson::oid::ObjectID::with_string(key).unwrap()
        match bson::to_bson(&new_doc) {
            bson::Bson::Document(model_doc) => {
                match coll.replace_one(doc! {"_id": id}, model_doc, None) {
                    Ok(_) => Ok(new_cat),
                    Err(err) => Err(err),
                }
            
            _ => Err(Error:DefaultError(String::from(
                "failed to create Document",
            ))),
        },
        Err(_) => Err(Error::DefaultError(String::from("Failed to create BSON"))),
        
        }
    }
} */