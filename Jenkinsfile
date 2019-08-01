#!/usr/bin/env groovy

// Jenkins Declarative Pipeline format
pipeline {
  agent {
    docker {
      image 'ruby:2.6'
    }
  }

  triggers {
    // Execute every 15 minutess 
    cron('H/15 * * * *')
  }

  stages {
    stage('PDK Docker Promote') {
      steps {
        sh('jenkins/pdk-promote.sh')
      }
    }
  }
}
