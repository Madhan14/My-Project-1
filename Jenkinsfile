pipeline {
  agent any

  environment {
    // CHANGE ME: your Docker Hub username
    DOCKERHUB_USER = 'madhan14'
    // Repos on Docker Hub (already created)
    DEV_REPO  = 'dev'   // public
    PROD_REPO = 'prod'  // private
    // Where to deploy
    EC2_USER  = 'ubuntu'
    EC2_HOST  = '13.232.247.68'
  }

  triggers {
    // Build on GitHub webhook push (enable webhook in your repo settings)
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
          // Assignment rule:
          // If branch == dev -> push to Docker Hub "prod" repo
          // Else (master/main/anything) -> push to Docker Hub "dev" repo
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO

          // Tag with build number and also "latest"
          env.IMAGE = "${env.DOCKERHUB_USER}/${targetRepo}:${env.BUILD_NUMBER}"
          def latest = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          sh """
            echo "Building image: ${env.IMAGE}"
            docker build -t ${env.IMAGE} -t ${latest} .
          """

          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
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
          // Always deploy the repo's "latest" tag that we just pushed
          def targetRepo = (env.BRANCH_NAME == 'dev') ? env.PROD_REPO : env.DEV_REPO
          def deployImage = "${env.DOCKERHUB_USER}/${targetRepo}:latest"

          sshagent (credentials: ['ec2-ssh-key']) {
            sh """
              ssh -o StrictHostKeyChecking=no ${env.EC2_USER}@${env.EC2_HOST} '
                set -e
                docker pull ${deployImage} || true
                docker rm -f devops-web || true
                docker run -d --name devops-web --restart unless-stopped -p 80:80 ${deployImage}
                docker ps --filter name=devops-web
              '
            """
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
