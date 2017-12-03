import groovy.json.JsonSlurper

def url = new URL('https://mods.factorio.com/api/mods?owner=zomis&page_size=100&page=1')
def data = new JsonSlurper().parseText(url.text)

println data.results
data.results.each {
    def title = it.latest_release.info_json.title
    def latestDownloads = it.latest_release.downloads_count
    def downloads = it.downloads_count
    println "$title: $downloads (Latest version: $latestDownloads)"
}
