pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "madhan14"
        IMAGE_NAME     = "prod"
        IMAGE          = "${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
        LATEST         = "${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
        EC2_HOST       = "43.205.127.194"   // Replace with your active EC2 IP
        EC2_USER       = "ubuntu"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/Madhan14/My-Project-1.git'
                sh "echo Branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    echo "Building image: ${IMAGE}"
                    sh """
                        sudo docker build -t ${IMAGE} -t ${LATEST} .
                        sudo docker login -u ${DOCKERHUB_USER} -p ${DOCKER_HUB_PASSWORD}
                        sudo docker push ${IMAGE}
                        sudo docker push ${LATEST}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying on ${EC2_HOST}"
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                          sudo docker pull ${LATEST} &&
                          sudo docker stop myapp || true &&
                          sudo docker rm myapp || true &&
                          sudo docker run -d -p 80:80 --name myapp ${LATEST}
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker image prune -f || true"
        }
    }
}
