pipeline {
  agent any

  environment {
    DOCKERHUB_USER = 'madhan14'
    DEV_REPO  = 'dev'    // public repo
    PROD_REPO = 'prod'   // private repo
    EC2_USER  = 'ubuntu'
    EC2_HOSTS = '65.0.4.72,43.205.127.194'   // multiple hosts separated by commas
  }

  triggers {
    githubPush()
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Branch: ${BRANCH_NAME}"'
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          // If branch == dev -> push to PROD repo
          // else -> push to DEV repo
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO

          // Tag with build number and also latest
          env.IMAGE = "${env.DOCKERHUB_USER}/${targetRepo}:${env.BUILD_NUMBER}"
          def latest = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          sh """
            echo "Building image: ${env.IMAGE}"
            sudo docker build -t ${env.IMAGE} -t ${latest} .
          """

          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
            sh '''
              echo "$DH_PASS" | sudo docker login -u "$DH_USER" --password-stdin
            '''
            sh "sudo docker push ${env.IMAGE}"
            sh "sudo docker push ${latest}"
          }
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        script {
          def hosts = env.EC2_HOSTS.split(',')
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO
          def deployImage = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          hosts.each { host ->
            sshagent (credentials: ['ec2-ssh-key']) {
              sh """
                ssh -o StrictHostKeyChecking=no ${env.EC2_USER}@${host} '
                  set -e
                  sudo docker pull ${deployImage} || true
                  sudo docker rm -f devops-web || true
                  sudo docker run -d --name devops-web --restart unless-stopped -p 80:80 ${deployImage}
                  sudo docker ps --filter name=devops-web
                '
              """
            }
          }
        }
      }
    }
  }

  post {
    always {
      sh 'sudo docker image prune -f || true'
    }
  }
}
