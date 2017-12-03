#!/usr/bin/env groovy

// can possibly use Jenkinsfile with `node { ws('/tmp/factorioPosts') { ... } }`

@GrabResolver(name='zomis', root='http://www.zomis.net/maven')
@Grab('net.zomis:duga-core:0.1')
import net.zomis.duga.chat.StackExchangeChatBot;
import net.zomis.duga.chat.BotConfiguration;

println "Evaluating..."
evaluate(new File("./duga.groovy"))
println "Evaluated."

duga = null;
json = new groovy.json.JsonSlurper()
known = [:]
// known["zomis/visual-signals"] = 1
// known["visual-signals/16203"] = 0

def inform(def mod, String title, String body) {
    if (duga == null) {
        BotConfiguration botConfig = new BotConfiguration();
        botConfig.setBotEmail(email);
        botConfig.setBotPassword(password);
        botConfig.setRootUrl("https://stackexchange.com");
        botConfig.setChatUrl("https://chat.stackexchange.com");
        // duga = new StackExchangeChatBot(botConfig);
        // duga.start();
    }
    def modUrl = "https://mods.factorio.com/mods/$mod.owner/$mod.name"
    String firstLine = String.format("**\\[[%s](%s)\\]** **%s**", mod.owner + "/" + mod.name, modUrl, title);
    body = body.split('\n')[0]
    String secondLine = "> $body"
    println "--------------------"
    println firstLine
    println secondLine
    // duga.
}

def updateMod(known, def mod, def msgs) {
    def size = msgs.results.size()
    String key = mod.owner + '/' + mod.name
    if (!known.containsKey(key)) {
        known[key] = size
    }
    if (known[key] != size) {
        int lastKnown = known[key]
        for (int i = lastKnown; i < size; i++) {
            println "Inform about msgs $i for $mod.name"
            inform(mod, msgs.results[i].title, msgs.results[i].message)
        }
        known[key] = size
    }
}

def updateReplies(known, def mod, def msg, def replies) {
    def size = replies.results.size()
    def key = mod.name + '/' + msg.id
    if (!known.containsKey(key)) {
        known[key] = size
    }
    if (known[key] != size) {
        int lastKnown = known[key]
        String modKey = mod.owner + '/' + mod.name
        for (int i = lastKnown; i < size; i++) {
            inform(mod, "Re: " + msg.title, replies.results[i].message)
        }
        known[key] = size
    }
}

def perform(String user) {
    def url = "https://mods.factorio.com/api/mods?owner=$user&page_size=100&page=1".toURL()
    def data = json.parse(url)
    data.results.each { mod ->
        def modName = mod.name
        def msgUrl = "https://mods.factorio.com/api/messages?page_size=50&mod=$modName&page=1&order=oldest".toURL()
        def msgs = json.parse(msgUrl)
        updateMod(known, mod, msgs)
        msgs.results.each { msg ->
            def createdAt = msg.created_at
            def lastReplyAt = msg.last_reply_at
            def header = msg.title
            def body = msg.message

            def repliesUrl = "https://mods.factorio.com/api/messages?page_size=100&order=oldest&parent=$msg.id&page=1".toURL()
            def replies = json.parse(repliesUrl)
            updateReplies(known, mod, msg, replies)
        }
    }
}

perform('zomis')
println "Found threads: $known"

while (true) {
//    println "Time!"
    perform('zomis')
    Thread.sleep(1000 * 60 * 15)
}
