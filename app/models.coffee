exports.define = (mongoose, cb) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  userSchema = new Schema
    name      : String
    team      : String
    pic       : String
    rfid      : type: String, index: true
    counts    : [food: String, num: Number, time: Date]
    data      : []
    createdAt : type: Date, default: Date.now

  userSchema.methods.sumTotals = ->
    totals = all: 0
    for entry in @counts
      {food, num} = entry
      totals[food] = 0 unless totals[food]
      totals[food] += num
      totals.all += num
    totals


  userSchema.statics.sumTotals = (cb) ->
    totals = {}
    userTotals = {}
    @find {}, (err, users) ->
      for user in users
        userSet = userTotals[user.rfid] = user.sumTotals()
        for food, num of userSet
          totals[food] = 0 unless totals[food]
          totals[food] += num

        userSet.pic = user.pic
        userSet.rfid = user.rfid

      cb null, userTotals, totals


  feedItemSchema = new Schema
    user      : String
    text      : String
    createdAt : type: Date, default: Date.now

  mongoose.model 'User', userSchema
  mongoose.model 'FeedItem', feedItemSchema

  cb?()
