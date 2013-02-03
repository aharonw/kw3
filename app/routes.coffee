config   = require __dirname + '/config'
models   = require __dirname + '/models'
app      = require __dirname + '/app'
mongoose = require 'mongoose'
crypto   = require 'crypto'
async    = require 'async'
fs       = require 'fs'
_        = require 'underscore'
io       = require('socket.io').listen app

io.enable 'browser client minification'
io.enable 'browser client etag'
io.enable 'browser client gzip'
io.set 'log level', 1

User = null
FeedItem = null
totalCount = 0

models.define mongoose, ->
  User = mongoose.model 'User'
  FeedItem = mongoose.model 'FeedItem'
  mongoose.connect config.dbUrl


exports.index = (req, res) ->

  async.parallel

    users: (cb) ->
      foods = ['wings', 'beer', 'brownies']
      User.find {}, (err, users) ->
        for user in users
          data = []
          for food in foods
            f = { name: food, data: [] }
            for count in user.counts
              if count.food is food
                f.data.push count
            data.push f
          user.data = data
        cb null, users

    feedItems: (cb) ->
      FeedItem.find().limit(30).sort('createdAt', -1).run (err, feedItems) -> cb null, feedItems

    (err, results) ->
      totalCount = results.users.map((user) -> user.wings).reduce (prev, current) ->
        prev + current

      res.render 'index', locals:
        users: results.users
        feedItems: results.feedItems
        total: totalCount
        

exports.eat = (req, res) ->
  { rfid } = req.body
  { food } = req.body
  return res.send 500 unless rfid and food

  User.findOne rfid: rfid, (err, user) ->
    return res.send 500 unless user

    inc =
      food: food
      time: Date.now()
      num:  getIncrement(food)
      
    user.counts.push inc
    console.log inc
    totalCount = getFoodTotal user.counts, food
    feedText = "#{ user.name } just ate #{ inc.num } more #{ food }."

    io.sockets.emit 'tap',
      rfid:  rfid
      food:  food
      num:   inc.num
      text:  feedText
      total: totalCount

    feedItem = new FeedItem
      text: feedText
      user: user.rfid

    user.save()
    feedItem.save()
    res.send 200

getIncrement = (food) ->
  if config.inc[food]? then return config.inc[food] else return 1

getFoodTotal = (counts, food) ->
  total = 0
  for count in counts
    if count.food is food
      total += count.num
  return total


exports.createUser = (req, res) ->
  { rfid } = req.body
  User.findOne rfid: rfid, (err, user) ->
    if user
      res.send 'user with rfid exists. deal with it.'
    else
      { photo } = req.files
      temp = photo.path
      extension = _.last photo.name.split('.')
      hash = crypto.createHash('sha1')
        .update(photo.name + Math.random()).digest 'hex'
      webPath = '/images/photos/' + hash + '.' + extension
      target = __dirname + '/../public/' + webPath
      fs.rename temp, target, (err) ->
        return res.send err if err
        fs.unlink temp
        newUser = new User req.body
        newUser.pic = webPath
        feedItem = new FeedItem
          text: "#{ newUser.name } of #{ newUser.team } just joined the fight."
          user: newUser.rfid
        console.log newUser
        newUser.save()
        feedItem.save()
        io.sockets.emit 'newUser', text: feedItem.text, photo: webPath
        res.redirect '/'



exports.getUser = (req, res) ->
  if req.params.id?
    rfid = req.params.id
  else
    return res.send 500

  async.parallel

    user: (cb) ->
      User.findOne rfid: rfid, (err, user) -> cb null, user

    feedItems: (cb) ->
      FeedItem.find(user: rfid).limit(30).sort('createdAt', -1).run (err, feedItems) -> cb null, feedItems

    (err, results) ->
      res.render 'profile', locals:
        user: results.user
        feedItems: results.feedItems
        total: totalCount


exports.register = (req, res) ->
  if req.params.rfid?
    { rfid } = req.params
  else
    rfid = ''
  res.render 'register', locals:
    total: totalCount
    rfid: rfid

