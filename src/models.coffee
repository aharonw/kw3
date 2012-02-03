
exports.define = (mongoose, cb) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  User = new Schema
    name      : String
    rfid      : type: String, index: true
    pic       : String
    wings     : type: Number, default: 0
    team      : String
    createdAt : type: Date, default: Date.now

  FeedItem = new Schema
    user      : String
    text      : String
    createdAt : type: Date, default: Date.now

  mongoose.model 'User', User
  mongoose.model 'FeedItem', FeedItem

  cb? and cb()
