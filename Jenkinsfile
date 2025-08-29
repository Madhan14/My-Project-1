pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'your-dockerhub-username'   // 🔹 replace with your DockerHub username
        EC2_USER  = 'ubuntu'                         // for Ubuntu EC2
        EC2_HOST  = '43.205.230.61'             // replace with your EC2 public IP/DNS
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/Madhan14/My-Project-1.git'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                    usernameVariable: 'DH_USER',
                                                    passwordVariable: 'DH_PASS')]) {
                        sh '''
                          echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                          IMAGE_NAME=$DH_USER/devops-app
                          docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                          docker push $IMAGE_NAME:$BUILD_NUMBER
                        '''
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sshagent (credentials: ['linux-SSH-key']) {
                        sh '''
                          ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} \
                          "docker pull $DOCKERHUB_USER/devops-app:$BUILD_NUMBER && \
                           docker stop app || true && \
                           docker rm app || true && \
                           docker run -d --name app -p 80:80 $DOCKERHUB_USER/devops-app:$BUILD_NUMBER"
                        '''
                    }
                }
            }
        }
    }
}
