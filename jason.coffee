# Description:
#   Jason's intelligence
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hear <something> say <something else> - if hubot hears <something>, he has a chance of saying <something else> (note that regex capture groups can be replaced with e.g. [1], [2] etc and the person who triggerd the response can be replaced with [who])
#   hubot say for <something> - list the responses that can be generated from a given string
# 
#
# Author:
#   chris woodham

module.exports = (robot) ->

  robot.hear /(.+)/i, (msg) ->
    sender = msg.message.user.name.split(" ")[0]

    robot.brain.data.jason ||= {}
    robot.brain.data.jason.response ||= {}
    trigger = msg.match[1]
    unless trigger.toLowerCase().slice(0, robot.name.length) == robot.name.toLowerCase() # don't trigger on bot commands
      possResponses = []
      responseKeys = {}
      for k,v of robot.brain.data.jason.response
        rex = new RegExp k, 'i'
        if rex.test trigger
          for resp in v
            responseKeys[resp] = rex
            possResponses.push resp
      if possResponses.length > 0
        selected = Math.floor(Math.random() * (possResponses.length * 4)) # make the choice of response 4 times longer than the number of them to give a smaller chance of responding
        if possResponses[selected]?
          response = possResponses[selected]
          test = responseKeys[response]
          replacements = test.exec(trigger)

          response = response.replace /\[[0-9]+\]/g, (match) ->
            mi = match.replace('[', '')
            mi = mi.replace(']', '')
            mi = +mi

            if replacements[mi]?
              return replacements[mi]
            else
              return match

          response = response.replace /\[who\]/g, (match) ->
            return sender

          msg.send response


  robot.respond /say for (.+)/i, (msg) ->
    robot.brain.data.jason ||= {}
    robot.brain.data.jason.response ||= {}
    trigger = msg.match[2]

    possResponses = []
    responseKeys = {}
    for k,v of robot.brain.data.jason.response
      rex = new RegExp k, 'i'
      if rex.test trigger
        for resp in v
          msg.send k + " -> " + resp


  robot.respond /hear (.+) say (.+)/i, (msg) ->
    robot.brain.data.jason ||= {}
    robot.brain.data.jason.response ||= {}
    trigger = msg.match[1]
    trigger = trigger.trim()
    resp = msg.match[2]
    resp = resp.trim()
    meth = if /hear (.+) don't say (.+)/i.test msg.message.text then "don't say" else "say" 
    if meth == 'say'
      try
        test = RegExp trigger, 'i'
        robot.brain.data.jason.response[trigger] ||= []
        robot.brain.data.jason.response[trigger].push resp
        msg.send "okay"
      catch e
        msg.send "That's no regex fool!"
    else if meth == "don't say"
      dind = trigger.lastIndexOf "don't"
      trigger = trigger.slice 0, dind
      trigger = trigger.trim()
      if robot.brain.data.jason.response[trigger]? and resp in robot.brain.data.jason.response[trigger]
        ind = robot.brain.data.jason.response[trigger].indexOf trigger
        robot.brain.data.jason.response[trigger].splice ind, 1
        msg.send "okay, I won't"
      else
        msg.send "I wasn't going to anyway"
