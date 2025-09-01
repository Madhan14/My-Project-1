pipeline {
  agent any

  environment {
    DOCKERHUB_USER = 'madhan14'   // Docker Hub username
    DEV_REPO  = 'dev'             // public repo
    PROD_REPO = 'prod'            // private repo
    EC2_USER  = 'ubuntu'
    EC2_HOST  = '13.201.30.121'   // your EC2 public IP
  }

  triggers {
    githubPush()   // auto trigger from GitHub webhook
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
          // Rule: dev branch → push to PROD repo
          //       main branch → push to DEV repo
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO

          // Image tags
          env.IMAGE = "${env.DOCKERHUB_USER}/${targetRepo}:${env.BUILD_NUMBER}"
          def latest = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          sh """
            echo "Building image: ${env.IMAGE}"
            docker build -t ${env.IMAGE} -t ${latest} .
          """

          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                           usernameVariable: 'DH_USER',
                                           passwordVariable: 'DH_PASS')]) {
            sh '''
              echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            '''
            sh "docker push ${env.IMAGE}"
            sh "docker push ${latest}"
          }
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        script {
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO
          def deployImage = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                           usernameVariable: 'DH_USER',
                                           passwordVariable: 'DH_PASS')]) {
            sshagent (credentials: ['ec2-ssh-key']) {
              sh """
                ssh -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} '
                  set -e
                  echo "$DH_PASS" | sudo docker login -u "$DH_USER" --password-stdin
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
      sh 'docker image prune -f || true'
    }
  }
}
