import json
from bson.objectid import ObjectId
from tcc-api import app, db


@app.route('/api/saves', methods=['Post'])
def new_save():
    data = request.get_json()
    save_id = db.saves.insert_one(data)
    response = json.dumps({_id: save_id})
    return response

@app.route('/api/saves/<id>', methods=['Get'])
def return_save():
    Object_id = ObjectId(post_id)
    response = db.saves.find_one({'id_': Object_id})

@app.route('/api/saves/<id>', methods=['Put'])
def update_save():
    Object_id = ObjectId(post_id)
    data = request.get_json()
    data['id_'] = Object_id
    response = Json.dumps(db.saves.replace_one(data))
    return response

