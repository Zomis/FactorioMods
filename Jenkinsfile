#!/usr/bin/env groovy

@Library('ZomisJenkins')
import net.zomis.jenkins.Duga

import java.util.regex.Pattern

node {
    deleteDir()
    def myPath = pwd()

    stage('Checkout')
    checkout scm

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
    def files = 0
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
        files++
    }
    
    stage('Report')
    def resultMessage = totalWarnings + ' warnings in ' + files + ' files'
    println resultMessage

    if (maxExitStatus > 1) {
        new Duga().dugaResult('Lua Validation FAILED. Exit status ' + maxExitStatus + '. ' + resultMessage)
        error('Lua Validation failed with status ' + maxExitStatus)
    } else {
        new Duga().dugaResult(resultMessage)
    }
}
