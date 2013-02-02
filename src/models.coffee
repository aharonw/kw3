
exports.define = (mongoose, cb) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  User = new Schema
    name      : String
    team      : String
    pic       : String
    rfid      : type: String, index: true
    counts    : [ { food: String, num: Number, time: Date } ]
    data      : []
    createdAt : type: Date, default: Date.now

  FeedItem = new Schema
    user      : String
    text      : String
    createdAt : type: Date, default: Date.now

  mongoose.model 'User', User
  mongoose.model 'FeedItem', FeedItem

  cb? and cb()
