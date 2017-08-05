#!/usr/bin/env groovy

@Library('ZomisJenkins')
import net.zomis.jenkins.Duga

import groovy.json.JsonSlurper
import java.util.regex.Pattern

@NonCPS
def slurpJson(json) {
  return new JsonSlurper().parseText(json)
}

node {
    deleteDir()
    def myPath = pwd()
    def duga = new Duga()

    stage('Checkout')
    checkout scm

    def dirs = findFiles(glob: '*/info.json')
    def infoJsonFiles = []
    for (def file : dirs) {
        infoJsonFiles.add(file)
    }
    println dirs
    def mods = [:]
    def modNames = "\n"
    stage('Scan info.json')
    for (def json : infoJsonFiles) {
        println "Found info.json: " + json.path
        def data = slurpJson(readFile(json.path))

        mods[data.name] = data.version
        modNames += data.name + " (currently " + data.version + ")\n"
    }

    println "All info.json files found, update parameters"
    properties([parameters([
      choice(choices: modNames, description: 'Mod to release', name: 'releaseMod'),
      string(defaultValue: "", description: 'Version to release', name: 'releaseVersion'),
    ])])

    println findFiles(glob: '*')

    stage('Setup Luacheck')
    def LUA_CHECK = '0.20.0'
    def luaCheckDir = fileExists('luacheck-' + LUA_CHECK)
    if (!luaCheckDir) {
        sh 'tar -xvf luacheck-' + LUA_CHECK + '.tar.gz'
        dir('luacheck-' + LUA_CHECK) {
            sh 'lua install.lua .'
        }
    }

    def luaFiles = findFiles(glob: '**/*.lua')
    println 'Files found: ' + luaFiles
    def maxExitStatus = 0
    def totalWarnings = 0
    def fileCount = 0
    def fileList = []

    // Avoid some not-serializable problem by putting a non-serializable list in a serializable one
    for (file in luaFiles) {
        fileList.add(file)
    }

    stage('Luacheck')
    for (file in fileList) {
        if (file.path.startsWith('luacheck-')) {
            continue
        }
        println 'Scanning file ' + file.path

        def exitStatus = sh(script: './luacheck-' + LUA_CHECK + '/bin/luacheck ' + file.path + ' > build_out.txt',
            returnStatus: true)
        if (exitStatus > 1) {
          duga.dugaResult('ERROR: ' + file.path + ' resulted in exit status ' + exitStatus)
        }
        if (exitStatus > maxExitStatus) {
            maxExitStatus = exitStatus
        }
        def luaCheckResult = readFile('build_out.txt').trim()
        println luaCheckResult
        def txt = luaCheckResult.split('\n')[0]
        def matcher = txt =~ /(\d+) warning/
        if (matcher.find()) {
            def match = matcher.group(1)
            totalWarnings += Integer.parseInt(match)
        }
        fileCount++
    }

    stage('Report')
    def resultMessage = totalWarnings + ' warnings in ' + fileCount + ' files'
    println resultMessage

    if (maxExitStatus > 1) {
        duga.dugaResult('Lua Validation FAILED. Exit status ' + maxExitStatus + '. ' + resultMessage)
        error('Lua Validation failed with status ' + maxExitStatus)
    } else {
        duga.dugaResult(resultMessage)
    }

    if (params.releaseMod != '' && params.releaseVersion != '') {
      def mod = params.releaseMod.substring(0, params.releaseMod.indexOf(' ('))
      def oldVersion = mods[mod]
      def releaseString = "$mod to version $params.releaseVersion (previous: $oldVersion)"
      stage('Release?') {
        duga.dugaResult("Ready to release $mod version $params.releaseVersion (previous version was $oldVersion). Awaiting confirmation")
        timeout(time: 5, unit: 'MINUTES') {
            input message: "Release $releaseString ? (tag, build artifact and publish in Jenkins, prepare with new version)"
        }
      }
      stage('Release') {
        duga.dugaResult("Starting release of $mod version $params.releaseVersion")
        def oldDir = mod + '_' + oldVersion
        def newDir = mod + '_' + params.releaseVersion
        sh 'git checkout ' + env.BRANCH_NAME
        sh 'git reset --hard HEAD'
        sh 'mv ' + oldDir + ' ' + newDir
        dir(newDir) {
          sh 'find ./ -name info.json -type f -exec sed -i \'s/' + oldVersion + '/' + params.releaseVersion + '/g\' {} \\;'
        }
        sh 'git rm -r ' + oldDir
        sh 'git add ' + newDir
        sh 'git commit -m"Release ' + mod + " version " + params.releaseVersion + '"'
        sh 'git tag ' + mod + '-' + params.releaseVersion
        zip(zipFile: newDir + '.zip', glob: newDir + '/**')
        archiveArtifacts(artifacts: newDir + '.zip')
        sh 'git push'
        duga.dugaResult("$mod version $params.releaseVersion is ready for uploaded to https://mods.factorio.com/mods/zomis/" + mod)
      }
    }
}
