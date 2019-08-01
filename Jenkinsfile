#!/usr/bin/env groovy

// Jenkins Declarative Pipeline format
pipeline {
  agent { label 'worker' }

  triggers {
    // Execute every 15 minutess 
    cron('H/15 * * * *')
  }

  stages {
    stage('Presuite') {
      steps {
        sh 'apt-get install -y libssl-dev'
      }
    }

    stage('PDK Docker Promote') {
      steps {
        sh('jenkins/pdk-promote.sh')
      }
    }
  }
}
